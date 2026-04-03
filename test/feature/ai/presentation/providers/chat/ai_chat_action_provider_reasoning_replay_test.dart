import 'dart:collection';

import 'package:JsxposedX/core/enums/ai_api_type.dart';
import 'package:JsxposedX/core/models/ai_config.dart';
import 'package:JsxposedX/core/models/ai_message.dart';
import 'package:JsxposedX/core/models/ai_session.dart';
import 'package:JsxposedX/feature/ai/data/datasources/chat/ai_chat_action_datasource.dart';
import 'package:JsxposedX/feature/ai/data/models/ai_message_dto.dart';
import 'package:JsxposedX/feature/ai/domain/models/ai_chat_session_context.dart';
import 'package:JsxposedX/feature/ai/domain/models/padi_chat_options.dart';
import 'package:JsxposedX/feature/ai/domain/repositories/chat/ai_chat_action_repository.dart';
import 'package:JsxposedX/feature/ai/domain/repositories/chat/ai_chat_query_repository.dart';
import 'package:JsxposedX/feature/ai/domain/repositories/config/ai_config_query_repository.dart';
import 'package:JsxposedX/feature/ai/presentation/providers/chat/ai_chat_action_provider.dart';
import 'package:JsxposedX/feature/ai/presentation/providers/chat/ai_chat_query_provider.dart';
import 'package:JsxposedX/feature/ai/presentation/providers/config/ai_config_query_provider.dart';
import 'package:JsxposedX/feature/apk_analysis/domain/repositories/apk_analysis_query_repository.dart';
import 'package:JsxposedX/feature/apk_analysis/presentation/providers/apk_analysis_query_provider.dart';
import 'package:JsxposedX/feature/so_analysis/data/datasources/so_analysis_datasource.dart';
import 'package:JsxposedX/feature/so_analysis/presentation/providers/so_analysis_provider.dart';
import 'package:JsxposedX/generated/apk_analysis.g.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  test('replays reasoning items on the next user turn after a tool-call round', () async {
    final firstReasoning = OpenAiResponsesReasoningItemCodec.encode(const {
      'id': 'rs_1',
      'type': 'reasoning',
      'encrypted_content': 'encrypted_1',
    });
    final secondReasoning = OpenAiResponsesReasoningItemCodec.encode(const {
      'id': 'rs_2',
      'type': 'reasoning',
      'encrypted_content': 'encrypted_2',
    });
    final toolCall = <Map<String, dynamic>>[
      {
        'id': 'call_1',
        'type': 'function',
        'function': {
          'name': 'search_classes',
          'arguments': '{"keyword":"vip"}',
        },
      },
    ];

    final fakeActionRepo = _FakeAiChatActionRepository(
      queuedStreams: Queue<List<AiMessage>>.from([
        [
          AiMessage(
            id: 'reasoning-first',
            role: 'system',
            content: firstReasoning,
          ),
          AiMessage.assistantToolCalls(toolCall),
        ],
        [
          AiMessage(
            id: 'reasoning-second',
            role: 'system',
            content: secondReasoning,
          ),
          AiMessage(
            id: 'assistant-final',
            role: 'assistant',
            content: 'VIP 已处理完',
          ),
        ],
        [
          AiMessage(
            id: 'assistant-next',
            role: 'assistant',
            content: '继续分析',
          ),
        ],
      ]),
    );

    final container = ProviderContainer(
      overrides: [
        aiChatActionRepositoryProvider.overrideWithValue(fakeActionRepo),
        aiChatQueryRepositoryProvider.overrideWithValue(_FakeAiChatQueryRepository()),
        aiConfigQueryRepositoryProvider.overrideWithValue(
          _FakeAiConfigQueryRepository(
            const AiConfig(
              id: 'test-responses',
              name: 'Responses',
              apiKey: 'sk-test',
              apiUrl: 'https://example.com/v1',
              moduleName: 'gpt-5.4',
              maxToken: 4096,
              temperature: 1,
              memoryRounds: 6,
              apiType: AiApiType.openaiResponses,
            ),
          ),
        ),
        apkAnalysisQueryRepositoryProvider.overrideWithValue(
          _FakeApkAnalysisQueryRepository(),
        ),
        soAnalysisDatasourceProvider.overrideWithValue(_FakeSoAnalysisDatasource()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(aiConfigProvider.future);
    final notifier = container.read(
      aiChatActionProvider(packageName: 'com.test.app').notifier,
    );
    notifier.setApkSession('apk-session', const ['classes.dex']);
    notifier.markSessionReady();

    await notifier.send('帮我写一个hook vip的脚本');
    await notifier.send('帮我看看');

    expect(fakeActionRepo.capturedRequests.length, 3);

    final replayMessages = fakeActionRepo.capturedRequests[2];
    final replayInput = OpenAiResponsesPayloadComposer.buildInput(
      replayMessages.map(_toDto).toList(growable: false),
    );
    final toolOutputs = replayInput
        .where((item) => item['type'] == 'function_call_output')
        .toList(growable: false);

    expect(
      replayInput.where((item) => item['type'] == 'reasoning').length,
      2,
    );
    expect(toolOutputs, hasLength(1));
    expect(
      toolOutputs.single,
      {
        'type': 'function_call_output',
        'call_id': 'call_1',
        'output': '共找到 1 个匹配类：\ncom.example.VipManager',
      },
    );
  });
}

AiMessageDto _toDto(AiMessage message) {
  return AiMessageDto(
    id: message.id,
    role: message.role,
    content: message.content,
    isThinking: message.isThinking,
    toolCalls: message.toolCalls,
    toolCallId: message.toolCallId,
    isError: message.isError,
    isToolResultBubble: message.isToolResultBubble,
  );
}

final class _FakeAiConfigQueryRepository implements AiConfigQueryRepository {
  _FakeAiConfigQueryRepository(this._config);

  final AiConfig _config;

  @override
  Future<AiConfig> getConfig() async => _config;
}

final class _FakeAiChatQueryRepository implements AiChatQueryRepository {
  @override
  Future<List<AiSession>> getSessions(String packageName) async => const [];

  @override
  Future<List<AiMessage>> getChatHistory(String packageName, String sessionId) async =>
      const [];

  @override
  Future<AiChatSessionContext?> getSessionContext(
    String packageName,
    String sessionId,
  ) async => null;

  @override
  Future<PadiChatOptions?> getPadiChatOptions(
    String packageName,
    String sessionId,
  ) async => null;

  @override
  Future<String?> getLastActiveSessionId(String packageName) async => null;
}

final class _FakeAiChatActionRepository implements AiChatActionRepository {
  _FakeAiChatActionRepository({required Queue<List<AiMessage>> queuedStreams})
      : _queuedStreams = queuedStreams;

  final Queue<List<AiMessage>> _queuedStreams;
  final List<List<AiMessage>> capturedRequests = <List<AiMessage>>[];

  @override
  Stream<AiMessage> getChatStream({
    required AiConfig config,
    required List<AiMessage> messages,
    PadiChatOptions? padiChatOptions,
    List<Map<String, dynamic>>? tools,
    CancelToken? cancelToken,
  }) {
    capturedRequests.add(List<AiMessage>.from(messages));
    if (_queuedStreams.isEmpty) {
      return const Stream<AiMessage>.empty();
    }
    return Stream<AiMessage>.fromIterable(_queuedStreams.removeFirst());
  }

  @override
  Future<String> testConnection(AiConfig config) async => 'ok';

  @override
  Future<void> saveSessions(String packageName, List<AiSession> sessions) async {}

  @override
  Future<void> saveChatHistory(
    String packageName,
    String sessionId,
    List<AiMessage> messages,
  ) async {}

  @override
  Future<void> saveSessionContext(
    String packageName,
    String sessionId,
    AiChatSessionContext context,
  ) async {}

  @override
  Future<void> savePadiChatOptions(
    String packageName,
    String sessionId,
    PadiChatOptions options,
  ) async {}

  @override
  Future<void> saveLastActiveSessionId(String packageName, String sessionId) async {}

  @override
  Future<void> clearLastActiveSessionId(String packageName) async {}

  @override
  Future<void> deleteSession(String packageName, String sessionId) async {}
}

final class _FakeApkAnalysisQueryRepository implements ApkAnalysisQueryRepository {
  @override
  Future<List<String>> searchDexClasses(
    String sessionId,
    List<String> dexPaths,
    String keyword,
  ) async {
    return <String>['com.example.VipManager'];
  }

  @override
  Future<String> decompileClass(
    String sessionId,
    List<String> dexPaths,
    String className,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<List<ApkAsset>> getApkAssets(String sessionId) async {
    throw UnimplementedError();
  }

  @override
  Future<List<ApkAsset>> getApkAssetsAt(String sessionId, String path) async {
    throw UnimplementedError();
  }

  @override
  Future<List<DexClass>> getDexClasses(
    String sessionId,
    List<String> dexPaths,
    String packageName,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<List<String>> getDexPackages(
    String sessionId,
    List<String> dexPaths,
    String packagePrefix,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<String> getClassSmali(
    String sessionId,
    List<String> dexPaths,
    String className,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<ApkManifest> parseManifest(String sessionId) async {
    throw UnimplementedError();
  }
}

final class _FakeSoAnalysisDatasource extends SoAnalysisDatasource {}
