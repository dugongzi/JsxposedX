import 'package:JsxposedX/core/models/ai_message.dart';
import 'package:JsxposedX/core/models/ai_session.dart';
import 'package:JsxposedX/feature/ai/domain/models/ai_chat_session_context.dart';
import 'package:JsxposedX/feature/ai/domain/models/padi_chat_options.dart';

/// AI 对话查询仓储接口
abstract class AiChatQueryRepository {
  Future<List<AiSession>> getSessions(String packageName);

  Future<List<AiMessage>> getChatHistory(String packageName, String sessionId);

  Future<AiChatSessionContext?> getSessionContext(
    String packageName,
    String sessionId,
  );

  Future<PadiChatOptions?> getPadiChatOptions(
    String packageName,
    String sessionId,
  );

  Future<String?> getLastActiveSessionId(String packageName);
}
