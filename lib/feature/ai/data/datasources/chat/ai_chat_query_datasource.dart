import 'dart:convert';

import 'package:JsxposedX/core/providers/pinia_provider.dart';
import 'package:JsxposedX/feature/ai/data/models/ai_message_dto.dart';
import 'package:JsxposedX/feature/ai/data/models/ai_session_dto.dart';
import 'package:JsxposedX/feature/ai/domain/models/ai_chat_session_context.dart';
import 'package:JsxposedX/feature/ai/domain/models/padi_chat_options.dart';

class AiChatQueryDatasource {
  AiChatQueryDatasource({required PiniaStorage storage}) : _storage = storage;

  final PiniaStorage _storage;

  static const String _sessionIndexKeyPrefix = 'ai_v2_sessions_';
  static const String _chatSpacePrefix = 'ai_v2_chat_';
  static const String _chatConfigSpacePrefix = 'ai_v2_chat_config_';
  static const String _chatContentKey = 'messages';
  static const String _chatContextKey = 'context';
  static const String _chatConfigKey = 'config';
  static const String _padiChatOptionsKey = 'padi_chat_options';

  Future<List<AiSessionDto>> getSessions(String packageName) async {
    final json = await _storage.getString(_getSessionIndexKey(packageName));
    if (json.isEmpty) {
      return [];
    }

    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list
          .map((item) => AiSessionDto.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
    } catch (_) {
      return [];
    }
  }

  Future<String?> getLastActiveSessionId(String packageName) async {
    final sessionId = await _storage.getString(
      _chatConfigKey,
      space: _getChatConfigSpace(packageName),
    );
    if (sessionId.isEmpty) {
      return null;
    }
    return sessionId;
  }

  Future<List<AiMessageDto>> getChatHistory(
    String packageName,
    String sessionId,
  ) async {
    final json = await _storage.getString(
      _chatContentKey,
      space: _getChatSpace(sessionId, packageName),
    );
    if (json.isEmpty) {
      return [];
    }

    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list
          .map((item) => AiMessageDto.fromStorageJson(item as Map<String, dynamic>))
          .toList(growable: false);
    } catch (_) {
      return [];
    }
  }

  Future<AiChatSessionContext?> getSessionContext(
    String packageName,
    String sessionId,
  ) async {
    final json = await _storage.getString(
      _chatContextKey,
      space: _getChatSpace(sessionId, packageName),
    );
    if (json.isEmpty) {
      return null;
    }

    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      return AiChatSessionContext.fromStorageJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<PadiChatOptions?> getPadiChatOptions(
    String packageName,
    String sessionId,
  ) async {
    final json = await _storage.getString(
      _padiChatOptionsKey,
      space: _getChatSpace(sessionId, packageName),
    );
    if (json.isEmpty) {
      return null;
    }

    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      return PadiChatOptions.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  String _getSessionIndexKey(String packageName) =>
      '$_sessionIndexKeyPrefix$packageName';

  String _getChatSpace(String sessionId, String packageName) =>
      '$_chatSpacePrefix${sessionId}_$packageName';

  String _getChatConfigSpace(String packageName) =>
      '$_chatConfigSpacePrefix$packageName';
}
