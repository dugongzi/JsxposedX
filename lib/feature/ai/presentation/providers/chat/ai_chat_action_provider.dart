import 'dart:async';

import 'package:JsxposedX/core/models/ai_config.dart';
import 'package:JsxposedX/core/models/ai_message.dart';
import 'package:JsxposedX/core/models/ai_session.dart';
import 'package:JsxposedX/core/network/http_service.dart';
import 'package:JsxposedX/core/providers/pinia_provider.dart';
import 'package:JsxposedX/feature/ai/data/datasources/chat/ai_chat_action_datasource.dart';
import 'package:JsxposedX/feature/ai/data/repositories/chat/ai_chat_action_repository_impl.dart';
import 'package:JsxposedX/feature/ai/domain/models/ai_response_issue.dart';
import 'package:JsxposedX/feature/ai/domain/models/ai_session_init_state.dart';
import 'package:JsxposedX/feature/ai/domain/models/ai_tool_call.dart';
import 'package:JsxposedX/feature/ai/domain/repositories/chat/ai_chat_action_repository.dart';
import 'package:JsxposedX/feature/ai/domain/services/prompt_builder.dart';
import 'package:JsxposedX/feature/ai/domain/services/tool_executor.dart';
import 'package:JsxposedX/feature/ai/presentation/providers/chat/ai_chat_query_provider.dart';
import 'package:JsxposedX/feature/ai/presentation/providers/config/ai_config_query_provider.dart';
import 'package:JsxposedX/feature/ai/presentation/states/ai_chat_action_state.dart';
import 'package:JsxposedX/feature/apk_analysis/presentation/providers/apk_analysis_query_provider.dart';
import 'package:JsxposedX/feature/so_analysis/presentation/providers/so_analysis_provider.dart';
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
  bool _isDisposed = false;
  bool _stopRequested = false;
  final StreamController<String> _streamingContentController =
      StreamController<String>.broadcast();
  StreamSubscription? _activeResponseSubscription;
  Completer<_CollectedAssistantResponse>? _activeResponseCompleter;
  String _latestStreamingContent = '';

  Stream<String> get streamingContentStream =>
      _streamingContentController.stream;

  @override
  AiChatActionState build({required String packageName}) {
    _isDisposed = false;
    ref.onDispose(() {
      _isDisposed = true;
      _activeResponseSubscription?.cancel();
      _streamingContentController.close();
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
    state = state.copyWith(
      sessionInitState: AiSessionInitState.initializing,
      error: null,
      lastResponseIssue: null,
      apkSessionId: null,
      dexPaths: const [],
    );
  }

  void markSessionReady() {
    state = state.copyWith(
      sessionInitState: AiSessionInitState.ready,
      error: null,
      lastResponseIssue: null,
    );
  }

  void markSessionInitFailed(String message) {
    _clearStreamingContent();
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
    state = state.copyWith(systemPrompt: prompt);
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
    final protocolMessages = await ref
        .read(aiChatQueryRepositoryProvider)
        .getChatHistory(packageName, sessionId);
    if (_isDisposed) {
      return;
    }

    final displayMessages = _buildDisplayMessagesFromProtocol(protocolMessages);
    state = state.copyWith(
      currentSessionId: sessionId,
      protocolMessages: List<AiMessage>.unmodifiable(protocolMessages),
      messages: List<AiMessage>.unmodifiable(displayMessages),
      visibleMessageCount: 10,
      error: null,
      isStreaming: false,
      lastResponseIssue: null,
    );
    await ref
        .read(aiChatActionRepositoryProvider)
        .saveLastActiveSessionId(packageName, sessionId);
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
    );

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

    final userMessage = AiMessage(
      id: const Uuid().v4(),
      role: 'user',
      content: text,
    );
    final placeholder = AiMessage(
      id: const Uuid().v4(),
      role: 'assistant',
      content: '',
    );

    final protocolMessages = [...state.protocolMessages, userMessage];
    final displayMessages = [...state.messages, userMessage, placeholder];
    state = state.copyWith(
      protocolMessages: List<AiMessage>.unmodifiable(protocolMessages),
      messages: List<AiMessage>.unmodifiable(displayMessages),
      isStreaming: true,
      error: null,
      lastResponseIssue: null,
    );

    try {
      _latestStreamingContent = '';
      await _runAssistantTurn(
        config: config,
        protocolMessages: protocolMessages,
        placeholderId: placeholder.id,
        toolsJson: _buildToolsJson(),
        retriesRemaining: 2,
      );
    } catch (error) {
      _markDisplayMessageError(
        placeholder.id,
        '发送失败：$error',
        AiResponseIssue.networkError,
      );
    }
  }

  Future<void> _runAssistantTurn({
    required AiConfig config,
    required List<AiMessage> protocolMessages,
    required String placeholderId,
    required int retriesRemaining,
    List<Map<String, dynamic>>? toolsJson,
  }) async {
    final requestMessages = _buildRequestMessages(protocolMessages, config);
    final response = await _collectAssistantResponse(
      config: config,
      requestMessages: requestMessages,
      toolsJson: toolsJson,
    );
    if (_isDisposed) {
      return;
    }

    if (response.issue == AiResponseIssue.emptyResponse &&
        retriesRemaining > 0) {
      await _runAssistantTurn(
        config: config,
        protocolMessages: protocolMessages,
        placeholderId: placeholderId,
        retriesRemaining: retriesRemaining - 1,
        toolsJson: toolsJson,
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
          : response.content;
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
      await _saveChatHistory();
      return;
    }

    if (response.toolCalls != null && response.toolCalls!.isNotEmpty) {
      await _handleToolCalls(
        config: config,
        protocolMessages: protocolMessages,
        placeholderId: placeholderId,
        initialContent: response.content,
        toolCalls: response.toolCalls!,
        toolsJson: toolsJson,
      );
      return;
    }

    _finishAssistantMessage(
      placeholderId,
      response.content,
      protocolMessages: [
        ...protocolMessages,
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

    if (initialContent.isNotEmpty) {
      _updateDisplayMessage(placeholderId, content: initialContent);
    } else {
      _removeDisplayMessage(placeholderId);
    }

    final parsedCalls = toolCalls
        .map(AiToolCall.fromJson)
        .toList(growable: false);
    for (final call in parsedCalls) {
      if (_stopRequested) {
        state = state.copyWith(
          isStreaming: false,
          error: '已停止生成。',
          lastResponseIssue: AiResponseIssue.partialResponse,
        );
        await _saveChatHistory();
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
        state = state.copyWith(
          isStreaming: false,
          error: '已停止生成。',
          lastResponseIssue: AiResponseIssue.partialResponse,
        );
        await _saveChatHistory();
        return;
      }

      nextProtocolMessages = [
        ...state.protocolMessages,
        AiMessage.toolResult(
          toolCallId: result.toolCallId,
          content: result.content,
        ),
      ];
      state = state.copyWith(
        protocolMessages: List<AiMessage>.unmodifiable(nextProtocolMessages),
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
        await _saveChatHistory();
        return;
      }
    }

    await _saveChatHistory();

    if (_stopRequested) {
      state = state.copyWith(
        isStreaming: false,
        error: '已停止生成。',
        lastResponseIssue: AiResponseIssue.partialResponse,
      );
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
    );
  }

  Future<_CollectedAssistantResponse> _collectAssistantResponse({
    required AiConfig config,
    required List<AiMessage> requestMessages,
    List<Map<String, dynamic>>? toolsJson,
  }) async {
    final stream = ref
        .read(aiChatActionRepositoryProvider)
        .getChatStream(
          config: config,
          messages: requestMessages,
          tools: toolsJson,
        );

    final contentBuffer = StringBuffer();
    List<Map<String, dynamic>>? toolCalls;
    var sawChunk = false;
    final completer = Completer<_CollectedAssistantResponse>();
    _activeResponseCompleter = completer;
    _latestStreamingContent = '';

    try {
      _activeResponseSubscription = stream.listen(
        (chunk) {
          if (_isDisposed) {
            return;
          }

          sawChunk = true;
          if (chunk.hasToolCalls) {
            toolCalls = chunk.toolCalls;
            return;
          }

          if (chunk.content.isNotEmpty) {
            contentBuffer.write(chunk.content);
            _latestStreamingContent = contentBuffer.toString();
            _pushStreamingContent(_latestStreamingContent);
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
                  issue: AiResponseIssue.partialResponse,
                  errorMessage: error.message ?? 'AI 响应中断。',
                ),
              );
              return;
            }
            completer.complete(
              _CollectedAssistantResponse(
                content: bufferedContent,
                issue: _classifyPlatformIssue(error),
                errorMessage: error.message,
              ),
            );
            return;
          }

          if (bufferedContent.isNotEmpty) {
            completer.complete(
              _CollectedAssistantResponse(
                content: bufferedContent,
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
              toolCalls: toolCalls,
            ),
          );
        },
        cancelOnError: false,
      );

      return await completer.future;
    } finally {
      if (identical(_activeResponseCompleter, completer)) {
        _activeResponseCompleter = null;
      }
      _activeResponseSubscription = null;
      _latestStreamingContent = '';
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
    final maxRounds = config.memoryRounds <= 0
        ? 0
        : config.memoryRounds.toInt();
    if (maxRounds <= 0 || protocolMessages.isEmpty) {
      return List<AiMessage>.unmodifiable(protocolMessages);
    }

    var userRounds = 0;
    var startIndex = 0;
    for (var index = protocolMessages.length - 1; index >= 0; index--) {
      if (protocolMessages[index].role == 'user') {
        userRounds++;
        if (userRounds >= maxRounds) {
          startIndex = index;
          break;
        }
      }
    }
    return List<AiMessage>.unmodifiable(protocolMessages.sublist(startIndex));
  }

  List<Map<String, dynamic>>? _buildToolsJson() {
    if (state.apkSessionId == null || state.apkSessionId!.isEmpty) {
      return null;
    }
    if (state.sessionInitState != AiSessionInitState.ready) {
      return null;
    }

    final isZh = state.systemPrompt?.contains('你是') ?? true;
    return PromptBuilder(isZh: isZh).withTools().withSoTools().buildToolsJson();
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
    String? retryText;
    if (displayMessage.role == 'user') {
      retryText = displayMessage.content;
    } else {
      for (var index = displayIndex - 1; index >= 0; index--) {
        final candidate = state.messages[index];
        if (candidate.role == 'user') {
          retryText = candidate.content;
          break;
        }
      }
    }

    if (retryText == null || retryText.trim().isEmpty) {
      return;
    }

    var retryUserDisplayIndex = displayIndex;
    if (displayMessage.role != 'user') {
      for (var index = displayIndex - 1; index >= 0; index--) {
        if (state.messages[index].role == 'user') {
          retryUserDisplayIndex = index;
          break;
        }
      }
    }

    var retryUserProtocolIndex = state.protocolMessages.length;
    for (var index = state.protocolMessages.length - 1; index >= 0; index--) {
      final candidate = state.protocolMessages[index];
      if (candidate.role == 'user' && candidate.content == retryText) {
        retryUserProtocolIndex = index;
        break;
      }
    }

    final nextDisplayMessages = retryUserDisplayIndex <= 0
        ? const <AiMessage>[]
        : List<AiMessage>.from(state.messages.sublist(0, retryUserDisplayIndex));
    final nextProtocolMessages = retryUserProtocolIndex <= 0
        ? const <AiMessage>[]
        : List<AiMessage>.from(
            state.protocolMessages.sublist(0, retryUserProtocolIndex),
          );

    state = state.copyWith(
      messages: List<AiMessage>.unmodifiable(nextDisplayMessages),
      protocolMessages: List<AiMessage>.unmodifiable(nextProtocolMessages),
      error: null,
      lastResponseIssue: null,
    );
    await send(retryText);
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
    state = state.copyWith(isStreaming: false);
  }

  Future<void> stopStreaming() async {
    if (!state.isStreaming) {
      return;
    }

    _stopRequested = true;
    final partialContent = _latestStreamingContent;
    await _activeResponseSubscription?.cancel();
    _activeResponseSubscription = null;
    _clearStreamingContent();

    final completer = _activeResponseCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete(
        _CollectedAssistantResponse(
          content: partialContent,
          issue: AiResponseIssue.partialResponse,
          errorMessage: '已停止生成。',
        ),
      );
    } else {
      _appendDisplayMessage(
        AiMessage(
          id: const Uuid().v4(),
          role: 'assistant',
          content: '已停止生成。',
          isError: true,
        ),
      );
      state = state.copyWith(
        isStreaming: false,
        error: '已停止生成。',
        lastResponseIssue: AiResponseIssue.partialResponse,
      );
    }
  }

  Future<String> testConnection(AiConfig config) {
    return ref.read(aiChatActionRepositoryProvider).testConnection(config);
  }

  Future<void> deleteHistory() async {
    if (state.currentSessionId != null) {
      await deleteSession(state.currentSessionId!);
    }
  }

  Future<void> clear() async {
    await createSession('新对话 ${DateTime.now().hour}:${DateTime.now().minute}');
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
    state = state.copyWith(
      protocolMessages: List<AiMessage>.unmodifiable(protocolMessages),
      isStreaming: false,
      error: null,
      lastResponseIssue: null,
    );
    _saveChatHistory();
  }

  void _markDisplayMessageError(
    String placeholderId,
    String message,
    AiResponseIssue issue,
  ) {
    _updateDisplayMessage(placeholderId, content: message, isError: true);
    state = state.copyWith(
      isStreaming: false,
      error: message,
      lastResponseIssue: issue,
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

  void _pushStreamingContent(String content) {
    if (_streamingContentController.isClosed) {
      return;
    }
    _streamingContentController.add(content);
  }

  void _clearStreamingContent() {
    if (_streamingContentController.isClosed) {
      return;
    }
    _streamingContentController.add('');
  }

  AiResponseIssue _classifyPlatformIssue(PlatformException error) {
    final code = error.code.toLowerCase();
    if (code.contains('parse')) {
      return AiResponseIssue.parseError;
    }
    return AiResponseIssue.networkError;
  }
}

class _CollectedAssistantResponse {
  const _CollectedAssistantResponse({
    required this.content,
    this.toolCalls,
    this.issue,
    this.errorMessage,
  });

  final String content;
  final List<Map<String, dynamic>>? toolCalls;
  final AiResponseIssue? issue;
  final String? errorMessage;
}
