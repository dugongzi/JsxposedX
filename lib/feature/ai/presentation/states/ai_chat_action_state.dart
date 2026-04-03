import 'package:JsxposedX/core/models/ai_message.dart';
import 'package:JsxposedX/core/models/ai_session.dart';
import 'package:JsxposedX/feature/ai/domain/models/ai_chat_session_context.dart';
import 'package:JsxposedX/feature/ai/domain/models/padi_chat_options.dart';
import 'package:JsxposedX/feature/ai/domain/models/ai_response_issue.dart';
import 'package:JsxposedX/feature/ai/domain/models/ai_session_init_state.dart';

class AiChatActionState {
  const AiChatActionState({
    this.messages = const [],
    this.protocolMessages = const [],
    this.sessions = const [],
    this.isStreaming = false,
    this.error,
    this.currentSessionId,
    this.systemPrompt,
    this.apkSessionId,
    this.dexPaths = const [],
    this.visibleMessageCount = 10,
    this.lastResponseIssue,
    this.sessionInitState = AiSessionInitState.ready,
    this.sessionContext = const AiChatSessionContext(),
    this.contextStats = const AiChatContextStats(),
    this.contextVersion = AiChatSessionContext.currentVersion,
    this.currentPadiChatOptions = const PadiChatOptions(
      model: PadiChatOptions.defaultModel,
      reasoningEffort: PadiChatOptions.defaultReasoningEffort,
    ),
  });

  final List<AiMessage> messages;
  final List<AiMessage> protocolMessages;
  final List<AiSession> sessions;
  final bool isStreaming;
  final String? error;
  final String? currentSessionId;
  final String? systemPrompt;
  final String? apkSessionId;
  final List<String> dexPaths;
  final int visibleMessageCount;
  final AiResponseIssue? lastResponseIssue;
  final AiSessionInitState sessionInitState;
  final AiChatSessionContext sessionContext;
  final AiChatContextStats contextStats;
  final int contextVersion;
  final PadiChatOptions currentPadiChatOptions;

  String get currentPadiModel => currentPadiChatOptions.model;

  String get currentPadiReasoningEffort =>
      currentPadiChatOptions.reasoningEffort;

  List<AiMessage> get visibleMessages {
    if (messages.length <= visibleMessageCount) {
      return List<AiMessage>.unmodifiable(messages);
    }
    return List<AiMessage>.unmodifiable(
      messages.sublist(messages.length - visibleMessageCount),
    );
  }

  int get totalVisibleMessagesCount => messages.length;

  bool get canSend =>
      !isStreaming &&
      sessionInitState != AiSessionInitState.initializing &&
      sessionInitState != AiSessionInitState.failed;

  bool get hasUserMessages => messages.any((message) => message.role == 'user');

  bool get canRetryLastTurn =>
      !isStreaming && hasUserMessages && lastResponseIssue != null;

  bool get canContinueGeneration =>
      canRetryLastTurn &&
      lastResponseIssue == AiResponseIssue.partialResponse &&
      !sessionContext.hasPendingToolPhase;

  bool get canResumeToolPhase =>
      canRetryLastTurn &&
      lastResponseIssue == AiResponseIssue.partialResponse &&
      sessionContext.hasPendingToolPhase;

  AiMessage? get latestSessionSummary {
    if (!sessionContext.sessionMemory.hasContent) {
      return null;
    }
    final buffer = StringBuffer('[session_summary]');
    void write(String title, List<String> items) {
      if (items.isEmpty) {
        return;
      }
      buffer
        ..writeln()
        ..writeln('$title：');
      for (final item in items) {
        buffer.writeln('- $item');
      }
    }

    write('历史诉求', sessionContext.sessionMemory.userGoals);
    write('已知结论', sessionContext.sessionMemory.confirmedFacts);
    write('工具发现', sessionContext.sessionMemory.toolFindings);
    write('待继续', sessionContext.sessionMemory.openHypotheses);
    write('阻塞', sessionContext.sessionMemory.blockers);
    return AiMessage(
      id: 'context-summary',
      role: 'system',
      content: buffer.toString().trim(),
    );
  }

  bool get hasSessionSummary => latestSessionSummary != null;

  AiChatActionState copyWith({
    List<AiMessage>? messages,
    List<AiMessage>? protocolMessages,
    List<AiSession>? sessions,
    bool? isStreaming,
    Object? error = _sentinel,
    Object? currentSessionId = _sentinel,
    Object? systemPrompt = _sentinel,
    Object? apkSessionId = _sentinel,
    List<String>? dexPaths,
    int? visibleMessageCount,
    Object? lastResponseIssue = _sentinel,
    AiSessionInitState? sessionInitState,
    AiChatSessionContext? sessionContext,
    AiChatContextStats? contextStats,
    int? contextVersion,
    PadiChatOptions? currentPadiChatOptions,
  }) {
    return AiChatActionState(
      messages: messages ?? this.messages,
      protocolMessages: protocolMessages ?? this.protocolMessages,
      sessions: sessions ?? this.sessions,
      isStreaming: isStreaming ?? this.isStreaming,
      error: identical(error, _sentinel) ? this.error : error as String?,
      currentSessionId: identical(currentSessionId, _sentinel)
          ? this.currentSessionId
          : currentSessionId as String?,
      systemPrompt: identical(systemPrompt, _sentinel)
          ? this.systemPrompt
          : systemPrompt as String?,
      apkSessionId: identical(apkSessionId, _sentinel)
          ? this.apkSessionId
          : apkSessionId as String?,
      dexPaths: dexPaths ?? this.dexPaths,
      visibleMessageCount: visibleMessageCount ?? this.visibleMessageCount,
      lastResponseIssue: identical(lastResponseIssue, _sentinel)
          ? this.lastResponseIssue
          : lastResponseIssue as AiResponseIssue?,
      sessionInitState: sessionInitState ?? this.sessionInitState,
      sessionContext: sessionContext ?? this.sessionContext,
      contextStats: contextStats ?? this.contextStats,
      contextVersion: contextVersion ?? this.contextVersion,
      currentPadiChatOptions:
          currentPadiChatOptions ?? this.currentPadiChatOptions,
    );
  }
}

const Object _sentinel = Object();
