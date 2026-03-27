import 'package:JsxposedX/core/models/ai_message.dart';
import 'package:JsxposedX/core/models/ai_session.dart';
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
    );
  }
}

const Object _sentinel = Object();
