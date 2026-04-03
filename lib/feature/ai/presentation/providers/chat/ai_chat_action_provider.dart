import 'dart:async';

import 'package:JsxposedX/core/enums/ai_api_type.dart';
import 'package:JsxposedX/core/models/ai_config.dart';
import 'package:JsxposedX/core/models/ai_message.dart';
import 'package:JsxposedX/core/models/ai_session.dart';
import 'package:JsxposedX/core/network/http_service.dart';
import 'package:JsxposedX/core/providers/pinia_provider.dart';
import 'package:JsxposedX/feature/ai/data/datasources/chat/ai_chat_action_datasource.dart';
import 'package:JsxposedX/feature/ai/data/repositories/chat/ai_chat_action_repository_impl.dart';
import 'package:JsxposedX/feature/ai/domain/constants/builtin_ai_config.dart';
import 'package:JsxposedX/feature/ai/domain/models/ai_chat_session_context.dart';
import 'package:JsxposedX/feature/ai/domain/models/padi_chat_options.dart';
import 'package:JsxposedX/feature/ai/domain/models/ai_response_issue.dart';
import 'package:JsxposedX/feature/ai/domain/models/ai_session_init_state.dart';
import 'package:JsxposedX/feature/ai/domain/models/ai_thinking_markup.dart';
import 'package:JsxposedX/feature/ai/domain/models/ai_tool_call.dart';
import 'package:JsxposedX/feature/ai/domain/repositories/chat/ai_chat_action_repository.dart';
import 'package:JsxposedX/feature/ai/domain/services/ai_chat_context_assembler.dart';
import 'package:JsxposedX/feature/ai/domain/services/ai_multimodal_message_codec.dart';
import 'package:JsxposedX/feature/ai/domain/services/prompt_builder.dart';
import 'package:JsxposedX/feature/ai/domain/services/tool_executor.dart';
import 'package:JsxposedX/feature/ai/presentation/providers/chat/ai_chat_query_provider.dart';
import 'package:JsxposedX/feature/ai/presentation/providers/config/ai_config_query_provider.dart';
import 'package:JsxposedX/feature/ai/presentation/states/ai_chat_action_state.dart';
import 'package:JsxposedX/feature/apk_analysis/presentation/providers/apk_analysis_query_provider.dart';
import 'package:JsxposedX/feature/so_analysis/presentation/providers/so_analysis_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'ai_chat_action_provider.g.dart';

@Riverpod(keepAlive: true)
Future<bool> aiStatus(Ref ref) async {
  final config = ref.watch(aiConfigProvider).value;
  if (config == null || config.apiUrl.isEmpty) {
    return false;
  }

  try {
    await ref.read(aiChatActionRepositoryProvider).testConnection(config);
    return true;
  } catch (_) {
    return false;
  }
}

@riverpod
AiChatActionDatasource aiChatActionDatasource(Ref ref) {
  final httpService = ref.watch(httpServiceProvider);
  final storage = ref.watch(piniaStorageLocalProvider);
  return AiChatActionDatasource(httpService: httpService, storage: storage);
}

@riverpod
AiChatActionRepository aiChatActionRepository(Ref ref) {
  final dataSource = ref.watch(aiChatActionDatasourceProvider);
  return AiChatActionRepositoryImpl(dataSource: dataSource);
}

@riverpod
class AiChatAction extends _$AiChatAction {
  static const String _sessionSummaryPrefix = '[session_summary]';
  static const int _contextHardBudgetChars = 16000;
  static const int _contextTargetBudgetChars = 9000;
  static const int _recentUserRoundsToKeep = 3;
  static const int _toolResultProtocolMaxChars = 900;

  bool _isDisposed = false;
  bool _stopRequested = false;
  final StreamController<String> _streamingContentController =
      StreamController<String>.broadcast();
  final StreamController<bool> _streamingThinkingController =
      StreamController<bool>.broadcast();
  StreamSubscription? _activeResponseSubscription;
  Completer<_CollectedAssistantResponse>? _activeResponseCompleter;
  CancelToken? _activeRequestCancelToken;
  String _latestStreamingContent = '';
  String _latestStreamingThinkingContent = '';
  final AiChatContextAssembler _contextAssembler = AiChatContextAssembler();

  Stream<String> get streamingContentStream =>
      _streamingContentController.stream;
  Stream<bool> get streamingThinkingStream =>
      _streamingThinkingController.stream;

  @override
  AiChatActionState build({required String packageName}) {
    _isDisposed = false;
    ref.onDispose(() {
      _isDisposed = true;
      _activeRequestCancelToken?.cancel('provider_disposed');
      _activeResponseSubscription?.cancel();
      _streamingContentController.close();
      _streamingThinkingController.close();
    });
    Future.microtask(() {
      if (!_isDisposed) {
        _initSessions();
      }
    });
    return const AiChatActionState();
  }

  void beginSessionInitialization() {
    _clearStreamingContent();
    _clearStreamingThinking();
    state = state.copyWith(
      sessionInitState: AiSessionInitState.initializing,
      error: null,
      lastResponseIssue: null,
      apkSessionId: null,
      dexPaths: const [],
    );
  }

  void markSessionReady() {
    _clearStreamingThinking();
    state = state.copyWith(
      sessionInitState: AiSessionInitState.ready,
      error: null,
      lastResponseIssue: null,
    );
  }

  void markSessionInitFailed(String message) {
    _clearStreamingContent();
    _clearStreamingThinking();
    state = state.copyWith(
      sessionInitState: AiSessionInitState.failed,
      error: message,
      lastResponseIssue: AiResponseIssue.toolInitError,
      isStreaming: false,
      apkSessionId: null,
      dexPaths: const [],
    );
  }

  void setSystemPrompt(String prompt) {
    state = state.copyWith(
      systemPrompt: prompt,
      sessionContext: state.sessionContext.copyWith(sessionRules: prompt),
    );
  }

  void setApkSession(String sessionId, List<String> dexPaths) {
    state = state.copyWith(
      apkSessionId: sessionId,
      dexPaths: List<String>.unmodifiable(dexPaths),
    );
  }

  Future<void> _initSessions() async {
    try {
      final sessions = await getSessionsAsync();
      if (_isDisposed || sessions.isEmpty) {
        return;
      }

      final lastActiveSessionId = await ref
          .read(aiChatQueryRepositoryProvider)
          .getLastActiveSessionId(packageName);
      if (_isDisposed) {
        return;
      }

      final initialSessionId =
          lastActiveSessionId != null &&
              sessions.any((session) => session.id == lastActiveSessionId)
          ? lastActiveSessionId
          : sessions.first.id;
      await switchSession(initialSessionId);
    } catch (_) {
      if (_isDisposed) {
        return;
      }
      state = state.copyWith(
        error: 'AI 会话加载失败',
        isStreaming: false,
      );
    }
  }

  Future<List<AiSession>> getSessionsAsync() async {
    final sessions = await ref
        .read(aiChatQueryRepositoryProvider)
        .getSessions(packageName);
    sessions.sort(
      (left, right) => right.lastUpdateTime.compareTo(left.lastUpdateTime),
    );
    if (_isDisposed) {
      return sessions;
    }
    state = state.copyWith(sessions: List<AiSession>.unmodifiable(sessions));
    return sessions;
  }

  List<AiSession> getSessions() => state.sessions;

  Future<void> switchSession(String sessionId) async {
    _clearStreamingContent();
    _clearStreamingThinking();
    final protocolMessages = await ref
        .read(aiChatQueryRepositoryProvider)
        .getChatHistory(packageName, sessionId);
    final storedContext = await ref
        .read(aiChatQueryRepositoryProvider)
        .getSessionContext(packageName, sessionId);
    final storedPadiChatOptions = await ref
        .read(aiChatQueryRepositoryProvider)
        .getPadiChatOptions(packageName, sessionId);
    if (_isDisposed) {
      return;
    }

    final contextAssembly = _buildPersistedContextAssembly(
      protocolMessages: protocolMessages,
      previousContext: storedContext,
      config: ref.read(aiConfigProvider).value,
      lastError: null,
    );
    final displayMessages = _buildDisplayMessagesFromProtocol(
      contextAssembly.sanitizedProtocolMessages,
    );
    state = state.copyWith(
      currentSessionId: sessionId,
      protocolMessages: List<AiMessage>.unmodifiable(
        contextAssembly.sanitizedProtocolMessages,
      ),
      messages: List<AiMessage>.unmodifiable(displayMessages),
      visibleMessageCount: 10,
      error: null,
      isStreaming: false,
      lastResponseIssue: null,
      sessionContext: contextAssembly.context,
      contextStats: contextAssembly.context.stats,
      contextVersion: contextAssembly.context.version,
      currentPadiChatOptions:
          storedPadiChatOptions ?? PadiChatOptions.defaults(),
    );
    await ref
        .read(aiChatActionRepositoryProvider)
        .saveLastActiveSessionId(packageName, sessionId);
    await _saveChatHistory();
  }

  void loadMore() {
    if (state.visibleMessageCount >= state.totalVisibleMessagesCount) {
      return;
    }

    state = state.copyWith(
      visibleMessageCount: (state.visibleMessageCount + 10).clamp(
        0,
        state.totalVisibleMessagesCount,
      ),
    );
  }

  Future<void> createSession(String name) async {
    final sessionId = const Uuid().v4();
    final defaultPadiChatOptions = PadiChatOptions.defaults();
    final session = AiSession(
      id: sessionId,
      name: name,
      packageName: packageName,
      lastUpdateTime: DateTime.now(),
      lastMessage: '',
    );

    final updatedSessions = [session, ...state.sessions];
    await ref
        .read(aiChatActionRepositoryProvider)
        .saveSessions(packageName, updatedSessions);

    state = state.copyWith(
      currentSessionId: sessionId,
      sessions: List<AiSession>.unmodifiable(updatedSessions),
      protocolMessages: const [],
      messages: const [],
      visibleMessageCount: 10,
      error: null,
      isStreaming: false,
      lastResponseIssue: null,
      sessionContext: AiChatSessionContext(
        sessionRules: state.systemPrompt ?? '',
      ),
      contextStats: const AiChatContextStats(),
      contextVersion: AiChatSessionContext.currentVersion,
      currentPadiChatOptions: defaultPadiChatOptions,
    );

    await ref
        .read(aiChatActionRepositoryProvider)
        .savePadiChatOptions(packageName, sessionId, defaultPadiChatOptions);
    await ref
        .read(aiChatActionRepositoryProvider)
        .saveLastActiveSessionId(packageName, sessionId);
    await _saveChatHistory();
  }

  Future<void> send(String text) async {
    if (text.trim().isEmpty || state.isStreaming) {
      return;
    }
    _stopRequested = false;

    if (state.currentSessionId == null) {
      await createSession(
        '新对话 ${DateTime.now().hour}:${DateTime.now().minute}',
      );
    }

    if (state.sessionInitState == AiSessionInitState.initializing) {
      state = state.copyWith(
        error: '逆向会话仍在初始化，请稍后再试。',
        lastResponseIssue: AiResponseIssue.toolInitError,
      );
      return;
    }

    if (state.sessionInitState == AiSessionInitState.failed) {
      state = state.copyWith(
        error: state.error ?? '逆向会话初始化失败，当前无法发送消息。',
        lastResponseIssue: AiResponseIssue.toolInitError,
      );
      return;
    }

    final config = ref.read(aiConfigProvider).value;
    if (config == null) {
      state = state.copyWith(error: 'AI 配置未加载', isStreaming: false);
      return;
    }
    if (AiMultimodalMessageCodec.hasImageAttachments(text) &&
        _looksExplicitlyTextOnlyModel(config.moduleName)) {
      state = state.copyWith(
        error: '当前模型不支持图片理解，请切换到支持视觉的模型后再发送图片。',
        isStreaming: false,
        lastResponseIssue: AiResponseIssue.parseError,
      );
      return;
    }

    await _beginUserTurn(
      config: config,
      userMessage: AiMessage(
        id: const Uuid().v4(),
        role: 'user',
        content: text,
      ),
      baseProtocolMessages: state.protocolMessages,
      retriesRemaining: 2,
      recoveryMode: AiChatRecoveryMode.retryLastTurn,
    );
  }

  Future<void> editUserMessageAndResend({
    required String messageId,
    required String updatedText,
  }) async {
    if (state.isStreaming) {
      return;
    }

    final config = ref.read(aiConfigProvider).value;
    if (config == null) {
      state = state.copyWith(error: 'AI 配置未加载', isStreaming: false);
      return;
    }

    final protocolIndex = state.protocolMessages.indexWhere(
      (message) => message.id == messageId && message.role == 'user',
    );
    if (protocolIndex == -1) {
      return;
    }

    final originalMessage = state.protocolMessages[protocolIndex];
    if (!AiMultimodalMessageCodec.canEditText(originalMessage.content)) {
      return;
    }

    final nextContent = AiMultimodalMessageCodec.replaceUserText(
      originalMessage.content,
      updatedText,
    );
    if (nextContent.trim().isEmpty) {
      return;
    }
    if (AiMultimodalMessageCodec.hasImageAttachments(nextContent) &&
        _looksExplicitlyTextOnlyModel(config.moduleName)) {
      state = state.copyWith(
        error: '当前模型不支持图片理解，请切换到支持视觉的模型后再发送图片。',
        isStreaming: false,
        lastResponseIssue: AiResponseIssue.parseError,
      );
      return;
    }

    final updatedUserMessage = originalMessage.copyWith(content: nextContent);
    final baseProtocolMessages = state.protocolMessages
        .take(protocolIndex)
        .toList(growable: false);
    await _beginUserTurn(
      config: config,
      userMessage: updatedUserMessage,
      baseProtocolMessages: baseProtocolMessages,
      retriesRemaining: 2,
      recoveryMode: AiChatRecoveryMode.retryLastTurn,
    );
  }

  void revealMessage(String messageId) {
    final index = state.messages.indexWhere((message) => message.id == messageId);
    if (index == -1) {
      return;
    }
    final requiredVisibleCount = state.messages.length - index;
    if (requiredVisibleCount <= state.visibleMessageCount) {
      return;
    }
    state = state.copyWith(
      visibleMessageCount: requiredVisibleCount.clamp(
        0,
        state.totalVisibleMessagesCount,
      ),
    );
  }

  Future<void> _runAssistantTurn({
    required AiConfig config,
    required List<AiMessage> protocolMessages,
    required String placeholderId,
    required int retriesRemaining,
    List<Map<String, dynamic>>? toolsJson,
    AiChatRecoveryMode recoveryMode = AiChatRecoveryMode.none,
  }) async {
    final contextAssembly = _assembleContext(
      protocolMessages: protocolMessages,
      previousContext: state.sessionContext,
      config: config,
      recoveryMode: recoveryMode,
      lastError: null,
    );
    final response = await _collectAssistantResponse(
      config: config,
      requestMessages: contextAssembly.requestMessages,
      toolsJson: toolsJson,
    );
    if (_isDisposed) {
      return;
    }

    if (_stopRequested || response.userStopped) {
      await _finishStoppedAssistantTurn(
        config: config,
        protocolMessages: contextAssembly.sanitizedProtocolMessages,
        placeholderId: placeholderId,
        partialContent: response.content,
      );
      return;
    }

    if (response.issue == AiResponseIssue.emptyResponse &&
        retriesRemaining > 0) {
      await _runAssistantTurn(
        config: config,
        protocolMessages: contextAssembly.sanitizedProtocolMessages,
        placeholderId: placeholderId,
        retriesRemaining: retriesRemaining - 1,
        toolsJson: toolsJson,
        recoveryMode: recoveryMode,
      );
      return;
    }

    if (response.issue == AiResponseIssue.emptyResponse) {
      _markDisplayMessageError(
        placeholderId,
        'AI 未返回有效内容，请稍后重试。',
        AiResponseIssue.emptyResponse,
      );
      return;
    }

    if (response.issue == AiResponseIssue.parseError) {
      _markDisplayMessageError(
        placeholderId,
        response.errorMessage ?? 'AI 响应格式异常。',
        AiResponseIssue.parseError,
      );
      return;
    }

    if (response.issue == AiResponseIssue.networkError) {
      _markDisplayMessageError(
        placeholderId,
        response.errorMessage ?? 'AI 请求失败。',
        AiResponseIssue.networkError,
      );
      return;
    }

    if (response.issue == AiResponseIssue.partialResponse) {
      final partialContent = response.content.isEmpty
          ? (response.errorMessage ?? 'AI 响应中断，内容可能不完整。')
          : _composeDisplayContent(
              thinkingContent: response.thinkingContent,
              answerContent: response.content,
            );
      _updateDisplayMessage(
        placeholderId,
        content: partialContent,
        isError: true,
      );
      state = state.copyWith(
        isStreaming: false,
        error: response.errorMessage ?? 'AI 响应中断，内容可能不完整。',
        lastResponseIssue: AiResponseIssue.partialResponse,
      );
      _syncContextState(
        protocolMessages: contextAssembly.sanitizedProtocolMessages,
        config: config,
        lastError: response.errorMessage,
        recoveryMode: recoveryMode,
      );
      await _saveChatHistory();
      return;
    }

    if (response.toolCalls != null && response.toolCalls!.isNotEmpty) {
      await _handleToolCalls(
        config: config,
        protocolMessages: contextAssembly.sanitizedProtocolMessages,
        placeholderId: placeholderId,
        initialContent: response.content,
        initialDisplayContent: _composeDisplayContent(
          thinkingContent: response.thinkingContent,
          answerContent: response.content,
        ),
        toolCalls: response.toolCalls!,
        toolsJson: toolsJson,
      );
      return;
    }

    _finishAssistantMessage(
      placeholderId,
      _composeDisplayContent(
        thinkingContent: response.thinkingContent,
        answerContent: response.content,
      ),
      protocolMessages: [
        ...contextAssembly.sanitizedProtocolMessages,
        AiMessage(
          id: const Uuid().v4(),
          role: 'assistant',
          content: response.content,
        ),
      ],
    );
  }

  Future<void> _handleToolCalls({
    required AiConfig config,
    required List<AiMessage> protocolMessages,
    required String placeholderId,
    required List<Map<String, dynamic>> toolCalls,
    required String initialContent,
    required String initialDisplayContent,
    List<Map<String, dynamic>>? toolsJson,
  }) async {
    final toolExecutor = _getToolExecutor();
    if (toolExecutor == null) {
      _markDisplayMessageError(
        placeholderId,
        '逆向会话未初始化完成，无法执行工具调用。',
        AiResponseIssue.toolInitError,
      );
      return;
    }

    final assistantToolMessage = AiMessage(
      id: const Uuid().v4(),
      role: 'assistant',
      content: initialContent,
      toolCalls: toolCalls,
    );
    var nextProtocolMessages = [...protocolMessages, assistantToolMessage];
    state = state.copyWith(
      protocolMessages: List<AiMessage>.unmodifiable(nextProtocolMessages),
    );
    _syncContextState(
      protocolMessages: nextProtocolMessages,
      config: config,
      recoveryMode: AiChatRecoveryMode.resumeToolPhase,
    );

    if (initialDisplayContent.isNotEmpty) {
      _updateDisplayMessage(placeholderId, content: initialDisplayContent);
    } else {
      _removeDisplayMessage(placeholderId);
    }

    final parsedCalls = toolCalls
        .map(AiToolCall.fromJson)
        .toList(growable: false);
    for (final call in parsedCalls) {
      if (_stopRequested) {
        await _finishStoppedToolPhase(config: config);
        return;
      }

      final bubbleId = const Uuid().v4();
      _appendDisplayMessage(
        AiMessage(
          id: bubbleId,
          role: 'assistant',
          content:
              '调用 `${call.name}`${call.arguments.isNotEmpty ? '(${call.arguments.entries.map((entry) => '${entry.key}: ${entry.value}').join(', ')})' : ''}...',
          isToolResultBubble: true,
        ),
      );

      final result = await toolExecutor.execute(call);
      _updateDisplayMessage(
        bubbleId,
        content:
            '${result.success ? '✅' : '❌'} `${call.name}`:\n\n${result.content}',
      );

      if (_stopRequested) {
        await _finishStoppedToolPhase(config: config);
        return;
      }

      nextProtocolMessages = [
        ...state.protocolMessages,
        AiMessage.toolResult(
          toolCallId: result.toolCallId,
          content: _buildToolResultProtocolSummary(
            call: call,
            content: result.content,
            success: result.success,
          ),
        ),
      ];
      state = state.copyWith(
        protocolMessages: List<AiMessage>.unmodifiable(nextProtocolMessages),
      );
      _syncContextState(
        protocolMessages: nextProtocolMessages,
        config: config,
        recoveryMode: AiChatRecoveryMode.resumeToolPhase,
      );

      if (!result.success && _isCriticalTool(call.name)) {
        final errorMessage = AiMessage(
          id: const Uuid().v4(),
          role: 'assistant',
          content: '关键工具 `${call.name}` 执行失败，无法继续分析。',
          isError: true,
        );
        _appendDisplayMessage(errorMessage);
        state = state.copyWith(
          isStreaming: false,
          error: errorMessage.content,
          lastResponseIssue: AiResponseIssue.toolInitError,
        );
        _syncContextState(
          protocolMessages: state.protocolMessages,
          config: config,
          lastError: errorMessage.content,
          recoveryMode: AiChatRecoveryMode.resumeToolPhase,
        );
        await _saveChatHistory();
        return;
      }
    }

    await _saveChatHistory();

    if (_stopRequested) {
      await _finishStoppedToolPhase(config: config);
      return;
    }

    final newPlaceholder = AiMessage(
      id: const Uuid().v4(),
      role: 'assistant',
      content: '',
    );
    _appendDisplayMessage(newPlaceholder);

    await _runAssistantTurn(
      config: config,
      protocolMessages: state.protocolMessages,
      placeholderId: newPlaceholder.id,
      retriesRemaining: 2,
      toolsJson: toolsJson,
      recoveryMode: AiChatRecoveryMode.resumeToolPhase,
    );
  }

  Future<_CollectedAssistantResponse> _collectAssistantResponse({
    required AiConfig config,
    required List<AiMessage> requestMessages,
    List<Map<String, dynamic>>? toolsJson,
  }) async {
    final cancelToken = CancelToken();
    _activeRequestCancelToken = cancelToken;
    final stream = ref
        .read(aiChatActionRepositoryProvider)
        .getChatStream(
          config: config,
          messages: requestMessages,
          padiChatOptions: _resolvePadiChatOptionsForConfig(config),
          tools: toolsJson,
          cancelToken: cancelToken,
        );

    final contentBuffer = StringBuffer();
    final thinkingBuffer = StringBuffer();
    List<Map<String, dynamic>>? toolCalls;
    var sawChunk = false;
    final completer = Completer<_CollectedAssistantResponse>();
    _activeResponseCompleter = completer;
    _latestStreamingContent = '';
    _clearStreamingThinking();

    try {
      _activeResponseSubscription = stream.listen(
        (chunk) {
          if (_isDisposed) {
            return;
          }

          if (chunk.isThinking) {
            sawChunk = true;
            _pushStreamingThinking(true);
            if (chunk.content.isNotEmpty) {
              thinkingBuffer.write(chunk.content);
              _latestStreamingThinkingContent = thinkingBuffer.toString();
              _pushStreamingContent(
                _composeDisplayContent(
                  thinkingContent: _latestStreamingThinkingContent,
                  answerContent: _latestStreamingContent,
                ),
              );
            }
            return;
          }

          sawChunk = true;
          if (chunk.hasToolCalls) {
            toolCalls = chunk.toolCalls;
            return;
          }

          if (chunk.content.isNotEmpty) {
            _pushStreamingThinking(false);
            contentBuffer.write(chunk.content);
            _latestStreamingContent = contentBuffer.toString();
            _pushStreamingContent(
              _composeDisplayContent(
                thinkingContent: _latestStreamingThinkingContent,
                answerContent: _latestStreamingContent,
              ),
            );
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          if (completer.isCompleted) {
            return;
          }

          final bufferedContent = contentBuffer.toString();
          if (error is PlatformException) {
            if (bufferedContent.isNotEmpty) {
              completer.complete(
                _CollectedAssistantResponse(
                  content: bufferedContent,
                  thinkingContent: thinkingBuffer.toString(),
                  issue: AiResponseIssue.partialResponse,
                  errorMessage: _describePlatformException(error),
                ),
              );
              return;
            }
            completer.complete(
              _CollectedAssistantResponse(
                content: bufferedContent,
                thinkingContent: thinkingBuffer.toString(),
                issue: _classifyPlatformIssue(error),
                errorMessage: _describePlatformException(error),
              ),
            );
            return;
          }

          if (bufferedContent.isNotEmpty) {
            completer.complete(
              _CollectedAssistantResponse(
                content: bufferedContent,
                thinkingContent: thinkingBuffer.toString(),
                issue: AiResponseIssue.partialResponse,
                errorMessage: error.toString(),
              ),
            );
            return;
          }

          completer.complete(
            _CollectedAssistantResponse(
              content: '',
              issue: AiResponseIssue.networkError,
              errorMessage: error.toString(),
            ),
          );
        },
        onDone: () {
          if (completer.isCompleted) {
            return;
          }

          final fullContent = contentBuffer.toString();
          if (!sawChunk &&
              (toolCalls == null || (toolCalls?.isEmpty ?? true)) &&
              fullContent.isEmpty) {
            completer.complete(
              const _CollectedAssistantResponse(
                content: '',
                issue: AiResponseIssue.emptyResponse,
              ),
            );
            return;
          }

          if (fullContent.isEmpty &&
              (toolCalls == null || (toolCalls?.isEmpty ?? true))) {
            completer.complete(
              const _CollectedAssistantResponse(
                content: '',
                issue: AiResponseIssue.emptyResponse,
              ),
            );
            return;
          }

          completer.complete(
            _CollectedAssistantResponse(
              content: fullContent,
              thinkingContent: thinkingBuffer.toString(),
              toolCalls: toolCalls,
            ),
          );
        },
        cancelOnError: false,
      );

      return await completer.future;
    } finally {
      if (identical(_activeRequestCancelToken, cancelToken)) {
        _activeRequestCancelToken = null;
      }
      if (identical(_activeResponseCompleter, completer)) {
        _activeResponseCompleter = null;
      }
      _activeResponseSubscription = null;
      _latestStreamingContent = '';
      _latestStreamingThinkingContent = '';
      _clearStreamingThinking();
    }
  }

  List<AiMessage> _buildRequestMessages(
    List<AiMessage> protocolMessages,
    AiConfig config,
  ) {
    final historyMessages = _selectProtocolWindow(protocolMessages, config);
    return [
      if (state.systemPrompt != null && state.systemPrompt!.isNotEmpty)
        AiMessage(
          id: const Uuid().v4(),
          role: 'system',
          content: state.systemPrompt!,
        ),
      ...historyMessages,
    ];
  }

  List<AiMessage> _selectProtocolWindow(
    List<AiMessage> protocolMessages,
    AiConfig config,
  ) {
    final summaryMessage = _findLatestSessionSummary(protocolMessages);
    final workingMessages = protocolMessages
        .where((message) => !_isSessionSummary(message))
        .toList(growable: false);
    final maxRounds = config.memoryRounds <= 0
        ? 0
        : config.memoryRounds.toInt();
    if (maxRounds <= 0 || workingMessages.isEmpty) {
      return List<AiMessage>.unmodifiable([
        if (summaryMessage != null) summaryMessage,
        ...workingMessages,
      ]);
    }

    var userRounds = 0;
    var startIndex = 0;
    for (var index = workingMessages.length - 1; index >= 0; index--) {
      if (workingMessages[index].role == 'user') {
        userRounds++;
        if (userRounds >= maxRounds) {
          startIndex = index;
          break;
        }
      }
    }
    return List<AiMessage>.unmodifiable([
      if (summaryMessage != null) summaryMessage,
      ...workingMessages.sublist(startIndex),
    ]);
  }

  List<Map<String, dynamic>>? _buildToolsJson() {
    if (state.apkSessionId == null || state.apkSessionId!.isEmpty) {
      return null;
    }
    if (state.sessionInitState != AiSessionInitState.ready) {
      return null;
    }

    final isZh = state.systemPrompt?.contains('你是') ?? true;
    final apiType = ref.read(aiConfigProvider).value?.apiType ?? AiApiType.openai;
    return PromptBuilder(
      isZh: isZh,
    ).withTools().withSoTools().buildToolsJson(apiType: apiType);
  }

  Future<void> retryByMessageId(String messageId) async {
    if (state.isStreaming) {
      return;
    }

    final displayIndex = state.messages.indexWhere(
      (message) => message.id == messageId,
    );
    if (displayIndex == -1) {
      return;
    }

    final displayMessage = state.messages[displayIndex];
    if (_isResumeToolPhaseEligible(displayMessage, displayIndex)) {
      await _restoreFromCheckpointAndRun(
        recoveryMode: AiChatRecoveryMode.resumeToolPhase,
      );
      return;
    }

    if (_isContinueEligible(displayMessage, displayIndex)) {
      await _continueFromPartialMessage(displayMessage: displayMessage);
      return;
    }

    await _restoreFromCheckpointAndRun(
      recoveryMode: AiChatRecoveryMode.retryLastTurn,
    );
  }

  Future<void> _continueFromPartialMessage({
    required AiMessage displayMessage,
  }) async {
    final config = ref.read(aiConfigProvider).value;
    if (config == null) {
      state = state.copyWith(error: 'AI 配置未加载', isStreaming: false);
      return;
    }

    final checkpoint = state.sessionContext.checkpoint;
    if (checkpoint == null || checkpoint.lastUserMessage == null) {
      await _restoreFromCheckpointAndRun(
        recoveryMode: AiChatRecoveryMode.retryLastTurn,
      );
      return;
    }

    final partialContent = AiThinkingMarkup.strip(displayMessage.content);
    final continuationProtocolMessages = List<AiMessage>.from(
      checkpoint.protocolMessages,
    );
    final lastUserIndex = continuationProtocolMessages.lastIndexWhere(
      (message) => message.id == checkpoint.lastUserMessage!.id,
    );
    if (lastUserIndex == -1) {
      await _restoreFromCheckpointAndRun(
        recoveryMode: AiChatRecoveryMode.retryLastTurn,
      );
      return;
    }

    final updatedUserMessage = continuationProtocolMessages[lastUserIndex]
        .copyWith(
          content: AiMultimodalMessageCodec.appendUserText(
            continuationProtocolMessages[lastUserIndex].content,
            _buildContinuationPrompt(partialContent),
          ),
        );
    continuationProtocolMessages[lastUserIndex] = updatedUserMessage;
    final displayMessages = [
      ..._buildDisplayMessagesFromProtocol(checkpoint.protocolMessages),
      displayMessage.copyWith(isError: false),
    ];
    final placeholder = AiMessage(
      id: const Uuid().v4(),
      role: 'assistant',
      content: '',
    );
    final contextAssembly = _assembleContext(
      protocolMessages: continuationProtocolMessages,
      previousContext: state.sessionContext,
      config: config,
      recoveryMode: AiChatRecoveryMode.continueGeneration,
    );
    final checkpointForContinuation = checkpoint.copyWith(
      protocolMessages: contextAssembly.sanitizedProtocolMessages,
      recoveryMode: AiChatRecoveryMode.continueGeneration,
    );
    state = state.copyWith(
      messages: List<AiMessage>.unmodifiable([...displayMessages, placeholder]),
      protocolMessages: List<AiMessage>.unmodifiable(
        contextAssembly.sanitizedProtocolMessages,
      ),
      isStreaming: true,
      error: null,
      lastResponseIssue: null,
      sessionContext: contextAssembly.context.copyWith(
        checkpoint: checkpointForContinuation,
      ),
      contextStats: contextAssembly.context.stats,
      contextVersion: contextAssembly.context.version,
    );
    await _saveChatHistory();

    try {
      await _runAssistantTurn(
        config: config,
        protocolMessages: contextAssembly.sanitizedProtocolMessages,
        placeholderId: placeholder.id,
        retriesRemaining: 1,
        toolsJson: _buildToolsJson(),
        recoveryMode: AiChatRecoveryMode.continueGeneration,
      );
    } catch (error) {
      _markDisplayMessageError(
        placeholder.id,
        _describeThrownError(error),
        AiResponseIssue.networkError,
      );
    }
  }

  Future<void> retryLastTurn() async {
    if (state.isStreaming || !state.hasUserMessages) {
      return;
    }

    final lastUserMessage = state.messages.lastWhere(
      (message) => message.role == 'user',
    );
    await retryByMessageId(lastUserMessage.id);
  }

  Future<bool> compactContext() async {
    final config = ref.read(aiConfigProvider).value;
    if (state.protocolMessages.isEmpty) {
      return false;
    }
    final previousStats = state.contextStats;
    _syncContextState(
      protocolMessages: state.protocolMessages,
      config: config,
      forceCompact: true,
      recoveryMode: state.sessionContext.taskState.lastRecoveryMode,
    );
    await _saveChatHistory();
    return state.contextStats.didCompact || state.contextStats != previousStats;
  }

  @Deprecated('Use retryByMessageId instead.')
  Future<void> retry(int index) async {
    final visibleMessages = state.visibleMessages;
    if (index < 0 || index >= visibleMessages.length) {
      return;
    }
    await retryByMessageId(visibleMessages[index].id);
  }

  Future<void> deleteSession(String sessionId) async {
    await ref
        .read(aiChatActionRepositoryProvider)
        .deleteSession(packageName, sessionId);

    final updatedSessions = List<AiSession>.from(state.sessions)
      ..removeWhere((session) => session.id == sessionId);
    await ref
        .read(aiChatActionRepositoryProvider)
        .saveSessions(packageName, updatedSessions);

    if (state.currentSessionId == sessionId) {
      if (updatedSessions.isNotEmpty) {
        state = state.copyWith(
          sessions: List<AiSession>.unmodifiable(updatedSessions),
        );
        await switchSession(updatedSessions.first.id);
      } else {
        state = state.copyWith(
          isStreaming: false,
          messages: const [],
          protocolMessages: const [],
          sessions: const [],
          currentSessionId: null,
          sessionContext: AiChatSessionContext(
            sessionRules: state.systemPrompt ?? '',
          ),
          contextStats: const AiChatContextStats(),
          contextVersion: AiChatSessionContext.currentVersion,
          currentPadiChatOptions: PadiChatOptions.defaults(),
        );
        await ref
            .read(aiChatActionRepositoryProvider)
            .clearLastActiveSessionId(packageName);
      }
    } else {
      state = state.copyWith(
        sessions: List<AiSession>.unmodifiable(updatedSessions),
      );
    }
  }

  void resetStreaming() {
    _clearStreamingThinking();
    state = state.copyWith(isStreaming: false);
  }

  Future<void> stopStreaming() async {
    if (!state.isStreaming) {
      return;
    }

    _stopRequested = true;
    final partialContent = _latestStreamingContent;
    final hasPendingToolPhase = state.sessionContext.hasPendingToolPhase;
    if (!hasPendingToolPhase && partialContent.isNotEmpty) {
      _replaceLatestAssistantPlaceholder(
        content: partialContent,
        isError: false,
      );
    } else if (!hasPendingToolPhase) {
      _removeLatestAssistantPlaceholder();
    }
    state = state.copyWith(
      isStreaming: false,
      error: null,
      lastResponseIssue: null,
    );
    _activeRequestCancelToken?.cancel('user_stopped');
    _activeRequestCancelToken = null;
    _clearStreamingContent();
    _clearStreamingThinking();
    await _activeResponseSubscription?.cancel();
    _activeResponseSubscription = null;

    final completer = _activeResponseCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete(
        _CollectedAssistantResponse(
          content: partialContent,
          userStopped: true,
        ),
      );
    }
  }

  Future<String> testConnection(AiConfig config) {
    return ref.read(aiChatActionRepositoryProvider).testConnection(config);
  }

  Future<void> updatePadiChatOptions({
    String? model,
    String? reasoningEffort,
  }) async {
    final sessionId = state.currentSessionId;
    if (sessionId == null) {
      return;
    }

    final nextOptions = state.currentPadiChatOptions.copyWith(
      model: model,
      reasoningEffort: reasoningEffort,
    );
    state = state.copyWith(currentPadiChatOptions: nextOptions);
    await ref
        .read(aiChatActionRepositoryProvider)
        .savePadiChatOptions(packageName, sessionId, nextOptions);
  }

  Future<void> deleteHistory() async {
    if (state.currentSessionId != null) {
      await deleteSession(state.currentSessionId!);
    }
  }

  Future<void> clear() async {
    await createSession('新对话 ${DateTime.now().hour}:${DateTime.now().minute}');
  }

  PadiChatOptions? _resolvePadiChatOptionsForConfig(AiConfig config) {
    if (!_shouldUsePadiChatOptions(config)) {
      return null;
    }
    return state.currentPadiChatOptions;
  }

  bool _shouldUsePadiChatOptions(AiConfig config) {
    return config.apiType == AiApiType.openaiResponses &&
        config.id == builtinAiConfigId;
  }

  Future<void> _saveChatHistory() async {
    final sessionId = state.currentSessionId;
    if (sessionId == null) {
      return;
    }

    try {
      await ref
          .read(aiChatActionRepositoryProvider)
          .saveChatHistory(packageName, sessionId, state.protocolMessages);
      await ref
          .read(aiChatActionRepositoryProvider)
          .saveSessionContext(packageName, sessionId, state.sessionContext);
      await ref
          .read(aiChatActionRepositoryProvider)
          .savePadiChatOptions(
            packageName,
            sessionId,
            state.currentPadiChatOptions,
          );

      final sessionIndex = state.sessions.indexWhere(
        (session) => session.id == sessionId,
      );
      if (sessionIndex == -1) {
        return;
      }

      const lastMessage = '';
      final updatedSessions = List<AiSession>.from(state.sessions);
      updatedSessions[sessionIndex] = updatedSessions[sessionIndex].copyWith(
        lastUpdateTime: DateTime.now(),
        lastMessage: lastMessage,
      );
      state = state.copyWith(
        sessions: List<AiSession>.unmodifiable(updatedSessions),
      );
      await ref
          .read(aiChatActionRepositoryProvider)
          .saveSessions(packageName, updatedSessions);
    } catch (_) {
      // Keep UI responsive even if persistence fails.
    }
  }

  List<AiMessage> _buildDisplayMessagesFromProtocol(
    List<AiMessage> protocolMessages,
  ) {
    return protocolMessages
        .where((message) => message.shouldDisplayInChatList)
        .toList(growable: false);
  }

  Future<void> _beginUserTurn({
    required AiConfig config,
    required AiMessage userMessage,
    required List<AiMessage> baseProtocolMessages,
    required int retriesRemaining,
    required AiChatRecoveryMode recoveryMode,
  }) async {
    final placeholder = AiMessage(
      id: const Uuid().v4(),
      role: 'assistant',
      content: '',
    );
    final protocolMessages = [...baseProtocolMessages, userMessage];
    final contextAssembly = _assembleContext(
      protocolMessages: protocolMessages,
      previousContext: state.sessionContext,
      config: config,
      recoveryMode: recoveryMode,
    );
    final checkpoint = AiChatCheckpoint(
      createdAtIso: DateTime.now().toIso8601String(),
      lastUserMessage: userMessage,
      protocolMessages: contextAssembly.sanitizedProtocolMessages,
      sessionMemorySnapshot: contextAssembly.context.sessionMemory,
      taskStateSnapshot: contextAssembly.context.taskState,
      toolTraceSnapshot: contextAssembly.context.toolTrace,
      recoveryMode: recoveryMode,
    );
    state = state.copyWith(
      protocolMessages: List<AiMessage>.unmodifiable(
        contextAssembly.sanitizedProtocolMessages,
      ),
      messages: List<AiMessage>.unmodifiable([
        ..._buildDisplayMessagesFromProtocol(
          contextAssembly.sanitizedProtocolMessages,
        ),
        placeholder,
      ]),
      isStreaming: true,
      error: null,
      lastResponseIssue: null,
      sessionContext: contextAssembly.context.copyWith(checkpoint: checkpoint),
      contextStats: contextAssembly.context.stats,
      contextVersion: contextAssembly.context.version,
    );
    await _saveChatHistory();

    try {
      _latestStreamingContent = '';
      await _runAssistantTurn(
        config: config,
        protocolMessages: contextAssembly.sanitizedProtocolMessages,
        placeholderId: placeholder.id,
        toolsJson: _buildToolsJson(),
        retriesRemaining: retriesRemaining,
        recoveryMode: recoveryMode,
      );
    } catch (error) {
      _markDisplayMessageError(
        placeholder.id,
        '发送失败：${_describeThrownError(error)}',
        AiResponseIssue.networkError,
      );
    }
  }

  Future<List<AiMessage>> _prepareProtocolMessages(
    List<AiMessage> protocolMessages,
    AiConfig config, {
    bool forceCompact = false,
  }) async {
    final sanitizedMessages = _sanitizeProtocolMessages(protocolMessages);
    final shouldCompact =
        forceCompact ||
        _estimateProtocolSize(sanitizedMessages) > _contextHardBudgetChars;
    if (!shouldCompact) {
      if (!_sameMessages(protocolMessages, sanitizedMessages)) {
        state = state.copyWith(
          protocolMessages: List<AiMessage>.unmodifiable(sanitizedMessages),
        );
        await _saveChatHistory();
      }
      return sanitizedMessages;
    }

    final compactedMessages = _compactProtocolMessages(sanitizedMessages);
    if (_sameMessages(protocolMessages, compactedMessages)) {
      return compactedMessages;
    }

    state = state.copyWith(
      protocolMessages: List<AiMessage>.unmodifiable(compactedMessages),
    );
    await _saveChatHistory();
    return compactedMessages;
  }

  List<AiMessage> _sanitizeProtocolMessages(List<AiMessage> protocolMessages) {
    final latestSummary = _findLatestSessionSummary(protocolMessages);
    final sanitized = <AiMessage>[
      if (latestSummary != null) latestSummary,
    ];
    final pendingToolCallIds = <String>{};
    var awaitingToolResults = false;

    for (final message in protocolMessages) {
      if (_isSessionSummary(message)) {
        continue;
      }
      if (message.role == 'assistant') {
        pendingToolCallIds
          ..clear()
          ..addAll(_extractToolCallIds(message.toolCalls));
        awaitingToolResults = message.hasToolCalls;
        sanitized.add(message);
        continue;
      }
      if (message.role == 'tool') {
        if (!awaitingToolResults) {
          continue;
        }
        final toolCallId = message.toolCallId;
        if (pendingToolCallIds.isNotEmpty) {
          if (toolCallId == null || !pendingToolCallIds.remove(toolCallId)) {
            continue;
          }
          if (pendingToolCallIds.isEmpty) {
            awaitingToolResults = false;
          }
        }
        sanitized.add(
          message.copyWith(
            content: _summarizeToolProtocolContent(message.content),
          ),
        );
      } else {
        pendingToolCallIds.clear();
        awaitingToolResults = false;
        sanitized.add(message);
      }
    }
    return List<AiMessage>.unmodifiable(sanitized);
  }

  List<AiMessage> _compactProtocolMessages(List<AiMessage> protocolMessages) {
    final latestSummary = _findLatestSessionSummary(protocolMessages);
    final workingMessages = protocolMessages
        .where((message) => !_isSessionSummary(message))
        .toList(growable: false);
    if (workingMessages.isEmpty) {
      return latestSummary == null ? workingMessages : [latestSummary];
    }

    final recentMessages = _selectRecentMessagesForCompaction(workingMessages);
    final cutoffIndex = workingMessages.length - recentMessages.length;
    final olderMessages = workingMessages.sublist(0, cutoffIndex);
    if (olderMessages.isEmpty) {
      return List<AiMessage>.unmodifiable([
        if (latestSummary != null) latestSummary,
        ...workingMessages,
      ]);
    }

    final mergedSummary = _mergeSessionSummary(
      existingSummary: latestSummary?.content,
      olderMessages: olderMessages,
    );
    final compacted = <AiMessage>[
      AiMessage(
        id: latestSummary?.id ?? const Uuid().v4(),
        role: 'system',
        content: mergedSummary,
      ),
      ...recentMessages,
    ];

    while (_estimateProtocolSize(compacted) > _contextTargetBudgetChars &&
        compacted.length > 2) {
      compacted.removeAt(1);
    }

    return List<AiMessage>.unmodifiable(compacted);
  }

  List<AiMessage> _selectRecentMessagesForCompaction(
    List<AiMessage> protocolMessages,
  ) {
    var userRounds = 0;
    var startIndex = 0;
    for (var index = protocolMessages.length - 1; index >= 0; index--) {
      if (protocolMessages[index].role == 'user') {
        userRounds++;
        if (userRounds >= _recentUserRoundsToKeep) {
          startIndex = index;
          break;
        }
      }
    }
    return List<AiMessage>.from(protocolMessages.sublist(startIndex));
  }

  String _mergeSessionSummary({
    String? existingSummary,
    required List<AiMessage> olderMessages,
  }) {
    final sections = _parseSessionSummarySections(existingSummary);
    final pendingNotes = <String>[];

    for (final message in olderMessages) {
      final summaryContent = _summaryContent(message);
      if (summaryContent.trim().isEmpty) {
        continue;
      }
      final normalized = _truncateForSummary(
        summaryContent.replaceAll('\r', ' ').replaceAll('\n', ' ').trim(),
      );
      if (normalized.isEmpty) {
        continue;
      }
      if (message.role == 'user') {
        _addUniqueNote(sections.userNeeds, normalized);
        if (_looksLikeQuestion(normalized)) {
          _addUniqueNote(pendingNotes, normalized);
        }
      } else if (message.role == 'tool') {
        _addUniqueNote(sections.toolFindings, normalized);
      } else if (message.role == 'assistant' && !message.hasToolCalls) {
        _addUniqueNote(sections.knownConclusions, normalized);
      }
    }

    final buffer = StringBuffer(_sessionSummaryPrefix);
    _writeSummarySection(
      buffer,
      title: '历史诉求',
      notes: sections.userNeeds.take(6),
    );
    _writeSummarySection(
      buffer,
      title: '已知结论',
      notes: sections.knownConclusions.take(6),
    );
    _writeSummarySection(
      buffer,
      title: '工具发现',
      notes: sections.toolFindings.take(8),
    );

    final unresolved = pendingNotes.where(
      (note) =>
          !sections.knownConclusions.any((item) => item.contains(note)) &&
          !sections.toolFindings.any((item) => item.contains(note)),
    );
    for (final note in unresolved.take(4)) {
      _addUniqueNote(sections.nextSteps, note);
    }
    _writeSummarySection(
      buffer,
      title: '待继续',
      notes: sections.nextSteps.take(4),
    );
    return buffer.toString().trim();
  }

  String _buildToolResultProtocolSummary({
    required AiToolCall call,
    required String content,
    required bool success,
  }) {
    final argumentSummary = call.arguments.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join(', ');
    final resultSummary = _summarizeToolProtocolContent(content);
    return '${success ? 'success' : 'failure'} ${call.name}'
        '${argumentSummary.isEmpty ? '' : ' ($argumentSummary)'}\n$resultSummary';
  }

  String _summarizeToolProtocolContent(String content) {
    final cleaned = content.trim();
    if (cleaned.isEmpty) {
      return '';
    }
    final lines = cleaned
        .replaceAll('\r', '')
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
    if (lines.isEmpty) {
      return '';
    }

    final summary = lines.take(8).join('\n');
    if (summary.length <= _toolResultProtocolMaxChars) {
      return summary;
    }
    return '${summary.substring(0, _toolResultProtocolMaxChars)}...';
  }

  int _estimateProtocolSize(List<AiMessage> messages) {
    var total = state.systemPrompt?.length ?? 0;
    for (final message in messages) {
      total += message.role.length;
      total += message.content.length;
      if (message.toolCalls != null) {
        total += message.toolCalls.toString().length;
      }
    }
    return total;
  }

  AiMessage? _findLatestSessionSummary(List<AiMessage> messages) {
    for (var index = messages.length - 1; index >= 0; index--) {
      if (_isSessionSummary(messages[index])) {
        return messages[index];
      }
    }
    return null;
  }

  bool _isSessionSummary(AiMessage message) {
    return message.role == 'system' &&
        message.content.startsWith(_sessionSummaryPrefix);
  }

  String _stripSessionSummaryPrefix(String content) {
    return content.replaceFirst(_sessionSummaryPrefix, '').trim();
  }

  String _truncateForSummary(String text) {
    if (text.length <= 180) {
      return text;
    }
    return '${text.substring(0, 180)}...';
  }

  String _summaryContent(AiMessage message) {
    if (message.role != 'user') {
      return message.content;
    }
    return AiMultimodalMessageCodec.toSemanticText(
      message.content,
      isZh: true,
    );
  }

  String _buildContinuationPrompt(String partialContent) {
    return '你上一条回答因为网络中断未完成。请从中断处继续，不要重复已经输出的内容。'
        '如果必须衔接，请只补充后续部分。\n\n'
        '已输出内容如下：\n$partialContent';
  }

  List<String> _extractToolCallIds(List<Map<String, dynamic>>? toolCalls) {
    if (toolCalls == null || toolCalls.isEmpty) {
      return const [];
    }
    return toolCalls
        .map((toolCall) => toolCall['id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toList(growable: false);
  }

  bool _endsWithToolContext(List<AiMessage> protocolMessages) {
    for (var index = protocolMessages.length - 1; index >= 0; index--) {
      final message = protocolMessages[index];
      if (message.role == 'tool') {
        return true;
      }
      if (message.role == 'assistant' && message.hasToolCalls) {
        return true;
      }
      if (message.role == 'assistant' || message.role == 'user') {
        return false;
      }
    }
    return false;
  }

  List<AiMessage> _buildContinuationProtocolMessages(
    List<AiMessage> protocolMessages,
    String partialContent,
  ) {
    if (_endsWithToolContext(protocolMessages)) {
      return protocolMessages;
    }

    final updatedMessages = List<AiMessage>.from(protocolMessages);
    for (var index = updatedMessages.length - 1; index >= 0; index--) {
      final candidate = updatedMessages[index];
      if (candidate.role != 'user') {
        continue;
      }
      updatedMessages[index] = candidate.copyWith(
        content: AiMultimodalMessageCodec.appendUserText(
          candidate.content,
          _buildContinuationPrompt(partialContent),
        ),
      );
      return List<AiMessage>.unmodifiable(updatedMessages);
    }
    return List<AiMessage>.unmodifiable(updatedMessages);
  }

  String _describePlatformException(PlatformException error) {
    final message = error.message?.trim();
    final details = error.details;
    final combinedText = [
      if (message != null && message.isNotEmpty) message,
      if (details != null) details.toString(),
    ].join('\n');
    if (_isVisionUnsupportedErrorText(combinedText)) {
      return '当前模型不支持图片理解，请切换到支持视觉的模型后再发送图片。';
    }
    if (details == null) {
      return message == null || message.isEmpty ? error.code : message;
    }

    String detailText;
    if (details is String) {
      detailText = details.trim();
    } else {
      detailText = details.toString().trim();
    }

    if (detailText.isEmpty) {
      return message == null || message.isEmpty ? error.code : message;
    }
    if (message == null || message.isEmpty) {
      return detailText;
    }
    return '$message\n$detailText';
  }

  bool _isVisionUnsupportedErrorText(String text) {
    final normalized = text.toLowerCase();
    return normalized.contains('not a vlm') ||
        normalized.contains('vision language model') ||
        normalized.contains('text-only prompts') ||
        normalized.contains('does not support image') ||
        normalized.contains('model does not support vision') ||
        normalized.contains('image input is not enabled') ||
        normalized.contains('multimodal') && normalized.contains('not support');
  }

  bool _looksExplicitlyTextOnlyModel(String modelName) {
    final normalized = modelName.toLowerCase();
    return normalized.contains('embedding') ||
        normalized.contains('rerank') ||
        normalized.contains('bge') ||
        normalized.contains('instruct') ||
        normalized.contains('text-') ||
        normalized.contains('coder') ||
        normalized.contains('claude-2') ||
        normalized.contains('claude-instant');
  }

  String _mergeContinuationContent(String existing, String continuation) {
    final previous = existing.trimRight();
    final next = continuation.trimLeft();
    if (next.isEmpty) {
      return previous;
    }
    if (previous.isEmpty) {
      return next;
    }
    if (next.startsWith(previous)) {
      return next;
    }

    final maxOverlap = previous.length < next.length
        ? previous.length
        : next.length;
    for (var overlap = maxOverlap; overlap >= 8; overlap--) {
      final previousSuffix = previous.substring(previous.length - overlap);
      final nextPrefix = next.substring(0, overlap);
      if (previousSuffix == nextPrefix) {
        return '$previous${next.substring(overlap)}';
      }
    }

    return '$previous$next';
  }

  _SessionSummarySections _parseSessionSummarySections(String? summary) {
    final sections = _SessionSummarySections();
    if (summary == null || summary.isEmpty) {
      return sections;
    }

    String? currentTitle;
    final lines = _stripSessionSummaryPrefix(summary)
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty);

    for (final line in lines) {
      if (line.endsWith('：')) {
        currentTitle = line.substring(0, line.length - 1);
        continue;
      }
      if (!line.startsWith('- ')) {
        continue;
      }
      final note = line.substring(2).trim();
      if (note.isEmpty) {
        continue;
      }

      switch (currentTitle) {
        case '历史诉求':
          _addUniqueNote(sections.userNeeds, note);
          break;
        case '已知结论':
          _addUniqueNote(sections.knownConclusions, note);
          break;
        case '工具发现':
          _addUniqueNote(sections.toolFindings, note);
          break;
        case '待继续':
          _addUniqueNote(sections.nextSteps, note);
          break;
        default:
          _addUniqueNote(sections.knownConclusions, note);
          break;
      }
    }

    return sections;
  }

  void _writeSummarySection(
    StringBuffer buffer, {
    required String title,
    required Iterable<String> notes,
  }) {
    final items = notes
        .map((note) => note.trim())
        .where((note) => note.isNotEmpty)
        .toList(growable: false);
    if (items.isEmpty) {
      return;
    }

    buffer
      ..writeln()
      ..writeln('$title：');
    for (final note in items) {
      buffer.writeln('- $note');
    }
  }

  void _addUniqueNote(List<String> notes, String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return;
    }
    if (notes.any((item) => item == normalized)) {
      return;
    }
    notes.add(normalized);
  }

  bool _looksLikeQuestion(String text) {
    return text.contains('?') ||
        text.contains('？') ||
        text.startsWith('请') ||
        text.startsWith('分析') ||
        text.startsWith('找') ||
        text.startsWith('定位');
  }

  bool _sameMessages(List<AiMessage> left, List<AiMessage> right) {
    if (left.length != right.length) {
      return false;
    }
    for (var index = 0; index < left.length; index++) {
      final a = left[index];
      final b = right[index];
      if (a.role != b.role ||
          a.content != b.content ||
          a.isError != b.isError ||
          a.toolCallId != b.toolCallId ||
          a.isToolResultBubble != b.isToolResultBubble) {
        return false;
      }
    }
    return true;
  }

  ToolExecutor? _getToolExecutor() {
    final sessionId = state.apkSessionId;
    if (sessionId == null || sessionId.isEmpty) {
      return null;
    }

    return ToolExecutor(
      repo: ref.read(apkAnalysisQueryRepositoryProvider),
      soDataSource: ref.read(soAnalysisDatasourceProvider),
      sessionId: sessionId,
      dexPaths: state.dexPaths,
    );
  }

  bool _isCriticalTool(String toolName) {
    return const {'get_manifest'}.contains(toolName);
  }

  void _finishAssistantMessage(
    String placeholderId,
    String content, {
    required List<AiMessage> protocolMessages,
  }) {
    _updateDisplayMessage(placeholderId, content: content, isError: false);
    final config = ref.read(aiConfigProvider).value;
    state = state.copyWith(
      protocolMessages: List<AiMessage>.unmodifiable(protocolMessages),
      isStreaming: false,
      error: null,
      lastResponseIssue: null,
    );
    _syncContextState(
      protocolMessages: protocolMessages,
      config: config,
      lastError: null,
      recoveryMode: AiChatRecoveryMode.none,
    );
    _saveChatHistory();
  }

  void _markDisplayMessageError(
    String placeholderId,
    String message,
    AiResponseIssue issue,
  ) {
    _updateDisplayMessage(placeholderId, content: message, isError: true);
    final config = ref.read(aiConfigProvider).value;
    _clearStreamingThinking();
    state = state.copyWith(
      isStreaming: false,
      error: message,
      lastResponseIssue: issue,
    );
    _syncContextState(
      protocolMessages: state.protocolMessages,
      config: config,
      lastError: message,
      recoveryMode: state.sessionContext.taskState.lastRecoveryMode,
    );
    _saveChatHistory();
  }

  void _appendDisplayMessage(AiMessage message) {
    state = state.copyWith(
      messages: List<AiMessage>.unmodifiable([...state.messages, message]),
    );
  }

  void _removeDisplayMessage(String messageId) {
    final updatedMessages = List<AiMessage>.from(state.messages)
      ..removeWhere((message) => message.id == messageId);
    state = state.copyWith(
      messages: List<AiMessage>.unmodifiable(updatedMessages),
    );
  }

  void _removeLatestAssistantPlaceholder() {
    final updatedMessages = List<AiMessage>.from(state.messages);
    for (var index = updatedMessages.length - 1; index >= 0; index--) {
      final message = updatedMessages[index];
      if (message.role == 'assistant' &&
          !message.isToolResultBubble &&
          !message.isError &&
          message.content.isEmpty) {
        updatedMessages.removeAt(index);
        state = state.copyWith(
          messages: List<AiMessage>.unmodifiable(updatedMessages),
        );
        return;
      }
    }
  }

  void _updateDisplayMessage(
    String messageId, {
    required String content,
    bool? isError,
  }) {
    final updatedMessages = List<AiMessage>.from(state.messages);
    final index = updatedMessages.indexWhere(
      (message) => message.id == messageId,
    );
    if (index == -1) {
      return;
    }

    updatedMessages[index] = updatedMessages[index].copyWith(
      content: content,
      isError: isError ?? updatedMessages[index].isError,
    );
    state = state.copyWith(
      messages: List<AiMessage>.unmodifiable(updatedMessages),
    );
  }

  void _replaceLatestAssistantPlaceholder({
    required String content,
    required bool isError,
  }) {
    final updatedMessages = List<AiMessage>.from(state.messages);
    for (var index = updatedMessages.length - 1; index >= 0; index--) {
      final message = updatedMessages[index];
      if (message.role != 'assistant' ||
          message.isToolResultBubble ||
          message.isError) {
        continue;
      }
      updatedMessages[index] = message.copyWith(
        content: content,
        isError: isError,
      );
      state = state.copyWith(
        messages: List<AiMessage>.unmodifiable(updatedMessages),
      );
      return;
    }

    _appendDisplayMessage(
      AiMessage(
        id: const Uuid().v4(),
        role: 'assistant',
        content: content,
        isError: isError,
      ),
    );
  }

  Future<void> _finishStoppedAssistantTurn({
    required AiConfig config,
    required List<AiMessage> protocolMessages,
    required String placeholderId,
    required String partialContent,
  }) async {
    final normalizedContent = partialContent.trim();
    final hasPendingToolPhase = state.sessionContext.hasPendingToolPhase;
    var nextProtocolMessages = protocolMessages;

    if (!hasPendingToolPhase && normalizedContent.isNotEmpty) {
      _updateDisplayMessage(
        placeholderId,
        content: normalizedContent,
        isError: false,
      );
      nextProtocolMessages = [
        ...protocolMessages,
        AiMessage(
          id: const Uuid().v4(),
          role: 'assistant',
          content: normalizedContent,
        ),
      ];
    } else if (!hasPendingToolPhase) {
      _removeDisplayMessage(placeholderId);
    }

    state = state.copyWith(
      protocolMessages: List<AiMessage>.unmodifiable(nextProtocolMessages),
      isStreaming: false,
      error: null,
      lastResponseIssue: null,
    );
    _syncContextState(
      protocolMessages: nextProtocolMessages,
      config: config,
      lastError: null,
      recoveryMode: AiChatRecoveryMode.none,
    );
    _stopRequested = false;
    await _saveChatHistory();
  }

  Future<void> _finishStoppedToolPhase({
    required AiConfig config,
  }) async {
    state = state.copyWith(
      isStreaming: false,
      error: null,
      lastResponseIssue: null,
    );
    _syncContextState(
      protocolMessages: state.protocolMessages,
      config: config,
      lastError: null,
      recoveryMode: AiChatRecoveryMode.none,
    );
    _stopRequested = false;
    await _saveChatHistory();
  }

  void _pushStreamingContent(String content) {
    if (_streamingContentController.isClosed) {
      return;
    }
    _streamingContentController.add(content);
  }

  void _pushStreamingThinking(bool isThinking) {
    if (_streamingThinkingController.isClosed) {
      return;
    }
    _streamingThinkingController.add(isThinking);
  }

  void _clearStreamingContent() {
    if (_streamingContentController.isClosed) {
      return;
    }
    _streamingContentController.add('');
    _latestStreamingContent = '';
    _latestStreamingThinkingContent = '';
  }

  String _composeDisplayContent({
    required String thinkingContent,
    required String answerContent,
  }) {
    return AiThinkingMarkup.compose(
      thinking: thinkingContent,
      answer: answerContent,
    );
  }

  void _clearStreamingThinking() {
    if (_streamingThinkingController.isClosed) {
      return;
    }
    _streamingThinkingController.add(false);
  }

  AiChatContextAssembly _assembleContext({
    required List<AiMessage> protocolMessages,
    AiChatSessionContext? previousContext,
    AiConfig? config,
    bool forceCompact = false,
    String? lastError,
    AiChatRecoveryMode recoveryMode = AiChatRecoveryMode.none,
  }) {
    final recentRounds = _resolveRecentRounds(config);
    final tokenBudget = _resolveTokenBudget(config);
    return _contextAssembler.assemble(
      protocolMessages: protocolMessages,
      sessionRules: state.systemPrompt ?? previousContext?.sessionRules ?? '',
      tokenBudget: tokenBudget,
      recentRounds: recentRounds,
      previousContext: previousContext,
      forceCompact: forceCompact,
      lastError: lastError,
      recoveryMode: recoveryMode,
    );
  }

  void _syncContextState({
    required List<AiMessage> protocolMessages,
    AiConfig? config,
    bool forceCompact = false,
    String? lastError,
    AiChatRecoveryMode recoveryMode = AiChatRecoveryMode.none,
  }) {
    final assembly = _buildPersistedContextAssembly(
      protocolMessages: protocolMessages,
      previousContext: state.sessionContext,
      config: config,
      forceCompact: forceCompact,
      lastError: lastError,
      recoveryMode: recoveryMode,
    );
    state = state.copyWith(
      protocolMessages: List<AiMessage>.unmodifiable(
        assembly.sanitizedProtocolMessages,
      ),
      sessionContext: assembly.context.copyWith(
        checkpoint: state.sessionContext.checkpoint,
      ),
      contextStats: assembly.context.stats,
      contextVersion: assembly.context.version,
    );
  }

  AiChatContextAssembly _buildPersistedContextAssembly({
    required List<AiMessage> protocolMessages,
    AiChatSessionContext? previousContext,
    AiConfig? config,
    bool forceCompact = false,
    String? lastError,
    AiChatRecoveryMode recoveryMode = AiChatRecoveryMode.none,
  }) {
    var assembly = _assembleContext(
      protocolMessages: protocolMessages,
      previousContext: previousContext,
      config: config,
      forceCompact: forceCompact,
      lastError: lastError,
      recoveryMode: recoveryMode,
    );
    final sanitizedMessages = assembly.sanitizedProtocolMessages;
    final shouldCompactStoredProtocol =
        forceCompact ||
        _estimateProtocolSize(sanitizedMessages) > _contextTargetBudgetChars;
    if (!shouldCompactStoredProtocol) {
      return assembly;
    }

    final compactedMessages = _compactProtocolMessages(sanitizedMessages);
    if (_sameMessages(sanitizedMessages, compactedMessages)) {
      return assembly;
    }

    assembly = _assembleContext(
      protocolMessages: compactedMessages,
      previousContext: previousContext,
      config: config,
      forceCompact: forceCompact,
      lastError: lastError,
      recoveryMode: recoveryMode,
    );
    return assembly;
  }

  int _resolveRecentRounds(AiConfig? config) {
    if (config == null) {
      return 3;
    }
    final rounds = config.memoryRounds <= 0 ? 1 : config.memoryRounds.toInt();
    return rounds < 1 ? 1 : rounds;
  }

  int _resolveTokenBudget(AiConfig? config) {
    if (config == null || config.maxToken <= 0) {
      return 6000;
    }
    final estimate = config.maxToken * 6;
    if (estimate < 2400) {
      return 2400;
    }
    if (estimate > 12000) {
      return 12000;
    }
    return estimate;
  }

  bool _isContinueEligible(AiMessage displayMessage, int displayIndex) {
    return displayMessage.role == 'assistant' &&
        displayMessage.isError &&
        state.lastResponseIssue == AiResponseIssue.partialResponse &&
        displayIndex == state.messages.length - 1 &&
        displayMessage.content.trim().isNotEmpty &&
        !state.sessionContext.hasPendingToolPhase;
  }

  bool _isResumeToolPhaseEligible(AiMessage displayMessage, int displayIndex) {
    return displayMessage.role == 'assistant' &&
        displayMessage.isError &&
        state.lastResponseIssue == AiResponseIssue.partialResponse &&
        displayIndex == state.messages.length - 1 &&
        state.sessionContext.hasPendingToolPhase;
  }

  Future<void> _restoreFromCheckpointAndRun({
    required AiChatRecoveryMode recoveryMode,
  }) async {
    final config = ref.read(aiConfigProvider).value;
    final checkpoint = state.sessionContext.checkpoint;
    if (config == null || checkpoint == null || checkpoint.protocolMessages.isEmpty) {
      return;
    }

    final restoredProtocolMessages = List<AiMessage>.from(
      checkpoint.protocolMessages,
    );
    final restoredDisplayMessages = _buildDisplayMessagesFromProtocol(
      restoredProtocolMessages,
    );
    final placeholder = AiMessage(
      id: const Uuid().v4(),
      role: 'assistant',
      content: '',
    );
    final contextAssembly = _assembleContext(
      protocolMessages: restoredProtocolMessages,
      previousContext: state.sessionContext.copyWith(
        checkpoint: checkpoint,
      ),
      config: config,
      recoveryMode: recoveryMode,
    );
    state = state.copyWith(
      messages: List<AiMessage>.unmodifiable([
        ...restoredDisplayMessages,
        placeholder,
      ]),
      protocolMessages: List<AiMessage>.unmodifiable(
        contextAssembly.sanitizedProtocolMessages,
      ),
      isStreaming: true,
      error: null,
      lastResponseIssue: null,
      sessionContext: contextAssembly.context.copyWith(checkpoint: checkpoint),
      contextStats: contextAssembly.context.stats,
      contextVersion: contextAssembly.context.version,
    );
    await _saveChatHistory();
    await _runAssistantTurn(
      config: config,
      protocolMessages: contextAssembly.sanitizedProtocolMessages,
      placeholderId: placeholder.id,
      retriesRemaining: 1,
      toolsJson: _buildToolsJson(),
      recoveryMode: recoveryMode,
    );
  }

  String _describeThrownError(Object error) {
    if (error is PlatformException) {
      return _describePlatformException(error);
    }
    return error.toString();
  }

  AiResponseIssue _classifyPlatformIssue(PlatformException error) {
    final code = error.code.toLowerCase();
    if (code.contains('parse')) {
      return AiResponseIssue.parseError;
    }
    return AiResponseIssue.networkError;
  }
}

class _SessionSummarySections {
  final List<String> userNeeds = [];
  final List<String> knownConclusions = [];
  final List<String> toolFindings = [];
  final List<String> nextSteps = [];
}

class _CollectedAssistantResponse {
  const _CollectedAssistantResponse({
    required this.content,
    this.thinkingContent = '',
    this.toolCalls,
    this.issue,
    this.errorMessage,
    this.userStopped = false,
  });

  final String content;
  final String thinkingContent;
  final List<Map<String, dynamic>>? toolCalls;
  final AiResponseIssue? issue;
  final String? errorMessage;
  final bool userStopped;
}
