import 'package:JsxposedX/core/models/ai_config.dart';
import 'package:JsxposedX/core/models/ai_message.dart';
import 'package:JsxposedX/core/models/ai_session.dart';
import 'package:JsxposedX/feature/ai/data/datasources/chat/ai_chat_action_datasource.dart';
import 'package:JsxposedX/feature/ai/data/models/ai_message_dto.dart';
import 'package:JsxposedX/feature/ai/data/models/ai_session_dto.dart';
import 'package:JsxposedX/feature/ai/domain/models/ai_chat_session_context.dart';
import 'package:JsxposedX/feature/ai/domain/models/padi_chat_options.dart';
import 'package:JsxposedX/feature/ai/domain/repositories/chat/ai_chat_action_repository.dart';
import 'package:dio/dio.dart';

class AiChatActionRepositoryImpl implements AiChatActionRepository {
  AiChatActionRepositoryImpl({required this.dataSource});

  final AiChatActionDatasource dataSource;

  @override
  Stream<AiMessage> getChatStream({
    required AiConfig config,
    required List<AiMessage> messages,
    PadiChatOptions? padiChatOptions,
    List<Map<String, dynamic>>? tools,
    CancelToken? cancelToken,
  }) {
    final messageDtos = messages
        .map(
          (message) => AiMessageDto(
            id: message.id,
            role: message.role,
            content: message.content,
            isThinking: message.isThinking,
            toolCalls: message.toolCalls,
            toolCallId: message.toolCallId,
            isError: message.isError,
            isToolResultBubble: message.isToolResultBubble,
          ),
        )
        .toList(growable: false);

    return dataSource
        .postChatStream(
          config: config,
          messages: messageDtos,
          padiChatOptions: padiChatOptions,
          tools: tools,
          cancelToken: cancelToken,
        )
        .map((dto) => dto.toEntity());
  }

  @override
  Future<String> testConnection(AiConfig config) {
    return dataSource.testConnection(config);
  }

  @override
  Future<void> saveSessions(String packageName, List<AiSession> sessions) {
    final dtos = sessions
        .map(
          (session) => AiSessionDto(
            id: session.id,
            name: session.name,
            packageName: session.packageName,
            lastUpdateTime: session.lastUpdateTime.toIso8601String(),
            lastMessage: session.lastMessage,
          ),
        )
        .toList(growable: false);
    return dataSource.saveSessionsIndex(packageName, dtos);
  }

  @override
  Future<void> saveChatHistory(
    String packageName,
    String sessionId,
    List<AiMessage> messages,
  ) {
    final dtos = messages
        .map(
          (message) => AiMessageDto(
            id: message.id,
            role: message.role,
            content: message.content,
            isThinking: message.isThinking,
            toolCalls: message.toolCalls,
            toolCallId: message.toolCallId,
            isError: message.isError,
            isToolResultBubble: message.isToolResultBubble,
          ),
        )
        .toList(growable: false);
    return dataSource.saveChatHistory(packageName, sessionId, dtos);
  }

  @override
  Future<void> saveSessionContext(
    String packageName,
    String sessionId,
    AiChatSessionContext context,
  ) {
    return dataSource.saveSessionContext(packageName, sessionId, context);
  }

  @override
  Future<void> savePadiChatOptions(
    String packageName,
    String sessionId,
    PadiChatOptions options,
  ) {
    return dataSource.savePadiChatOptions(packageName, sessionId, options);
  }

  @override
  Future<void> saveLastActiveSessionId(String packageName, String sessionId) {
    return dataSource.saveLastActiveSessionId(packageName, sessionId);
  }

  @override
  Future<void> clearLastActiveSessionId(String packageName) {
    return dataSource.clearLastActiveSessionId(packageName);
  }

  @override
  Future<void> deleteSession(String packageName, String sessionId) {
    return dataSource.removeChatHistory(packageName, sessionId);
  }
}
