import 'package:JsxposedX/core/models/ai_message.dart';
import 'package:JsxposedX/core/models/ai_session.dart';
import 'package:JsxposedX/feature/ai/data/datasources/chat/ai_chat_query_datasource.dart';
import 'package:JsxposedX/feature/ai/domain/models/ai_chat_session_context.dart';
import 'package:JsxposedX/feature/ai/domain/models/padi_chat_options.dart';
import 'package:JsxposedX/feature/ai/domain/repositories/chat/ai_chat_query_repository.dart';

/// AI 对话查询仓储实现（负责 DTO -> Entity 显式映射）
class AiChatQueryRepositoryImpl implements AiChatQueryRepository {
  final AiChatQueryDatasource dataSource;

  AiChatQueryRepositoryImpl({required this.dataSource});

  @override
  Future<List<AiSession>> getSessions(String packageName) async {
    final dtos = await dataSource.getSessions(packageName);
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<List<AiMessage>> getChatHistory(
    String packageName,
    String sessionId,
  ) async {
    final dtos = await dataSource.getChatHistory(packageName, sessionId);
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<AiChatSessionContext?> getSessionContext(
    String packageName,
    String sessionId,
  ) {
    return dataSource.getSessionContext(packageName, sessionId);
  }

  @override
  Future<PadiChatOptions?> getPadiChatOptions(
    String packageName,
    String sessionId,
  ) {
    return dataSource.getPadiChatOptions(packageName, sessionId);
  }

  @override
  Future<String?> getLastActiveSessionId(String packageName) async {
    return await dataSource.getLastActiveSessionId(packageName);
  }
}
