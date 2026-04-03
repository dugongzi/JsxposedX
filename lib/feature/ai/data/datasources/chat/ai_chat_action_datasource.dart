import 'dart:convert';

import 'package:JsxposedX/core/enums/ai_api_type.dart';
import 'package:JsxposedX/core/models/ai_config.dart';
import 'package:JsxposedX/core/network/http_service.dart';
import 'package:JsxposedX/core/providers/pinia_provider.dart';
import 'package:JsxposedX/feature/ai/data/models/ai_message_dto.dart';
import 'package:JsxposedX/feature/ai/data/models/ai_session_dto.dart';
import 'package:JsxposedX/feature/ai/domain/models/ai_chat_session_context.dart';
import 'package:JsxposedX/feature/ai/domain/models/padi_chat_options.dart';
import 'package:JsxposedX/feature/ai/domain/services/ai_multimodal_message_codec.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const String openAiResponsesReasoningProtocolPrefix =
    '[responses_reasoning_item]';

class AiChatActionDatasource {
  AiChatActionDatasource({
    required HttpService httpService,
    required PiniaStorage storage,
  }) : _httpService = httpService,
       _storage = storage;

  final HttpService _httpService;
  final PiniaStorage _storage;

  static const String _sessionIndexKeyPrefix = 'ai_v2_sessions_';
  static const String _chatSpacePrefix = 'ai_v2_chat_';
  static const String _chatConfigSpacePrefix = 'ai_v2_chat_config_';
  static const String _chatContentKey = 'messages';
  static const String _chatContextKey = 'context';
  static const String _chatConfigKey = 'config';
  static const String _padiChatOptionsKey = 'padi_chat_options';
  static const Duration _streamReceiveTimeout = Duration(minutes: 5);
  static const String _defaultResponsesReasoningEffort = 'medium';

  Stream<AiMessageDto> postChatStream({
    required AiConfig config,
    required List<AiMessageDto> messages,
    PadiChatOptions? padiChatOptions,
    List<Map<String, dynamic>>? tools,
    CancelToken? cancelToken,
  }) {
    switch (config.apiType) {
      case AiApiType.openai:
        return _postOpenAiChatCompletionsStream(
          config: config,
          messages: messages,
          tools: tools,
          cancelToken: cancelToken,
        );
      case AiApiType.openaiResponses:
        return _postOpenAiResponsesStream(
          config: config,
          messages: messages,
          padiChatOptions: padiChatOptions,
          tools: tools,
          cancelToken: cancelToken,
        );
      case AiApiType.anthropic:
        return _postAnthropicChatStream(
          config: config,
          messages: messages,
          tools: tools,
          cancelToken: cancelToken,
        );
    }
  }

  Future<String> testConnection(AiConfig config) {
    switch (config.apiType) {
      case AiApiType.openai:
        return _testOpenAiChatCompletionsConnection(config);
      case AiApiType.openaiResponses:
        return _testOpenAiResponsesConnection(config);
      case AiApiType.anthropic:
        return _testAnthropicConnection(config);
    }
  }

  Future<void> saveSessionsIndex(
    String packageName,
    List<AiSessionDto> sessionsDtos,
  ) async {
    final json = jsonEncode(sessionsDtos.map((e) => e.toJson()).toList());
    await _storage.setString(_getSessionIndexKey(packageName), json);
  }

  Future<void> saveLastActiveSessionId(
    String packageName,
    String sessionId,
  ) async {
    await _storage.setString(
      _chatConfigKey,
      sessionId,
      space: _getChatConfigSpace(packageName),
    );
  }

  Future<void> clearLastActiveSessionId(String packageName) async {
    await _storage.remove(
      _chatConfigKey,
      space: _getChatConfigSpace(packageName),
    );
  }

  Future<void> saveChatHistory(
    String packageName,
    String sessionId,
    List<AiMessageDto> messagesDtos,
  ) async {
    final json = jsonEncode(messagesDtos.map((e) => e.toStorageJson()).toList());
    await _storage.setString(
      _chatContentKey,
      json,
      space: _getChatSpace(sessionId, packageName),
    );
  }

  Future<void> saveSessionContext(
    String packageName,
    String sessionId,
    AiChatSessionContext context,
  ) async {
    await _storage.setString(
      _chatContextKey,
      jsonEncode(context.toStorageJson()),
      space: _getChatSpace(sessionId, packageName),
    );
  }

  Future<void> savePadiChatOptions(
    String packageName,
    String sessionId,
    PadiChatOptions options,
  ) async {
    await _storage.setString(
      _padiChatOptionsKey,
      jsonEncode(options.toJson()),
      space: _getChatSpace(sessionId, packageName),
    );
  }

  Future<void> removeChatHistory(String packageName, String sessionId) async {
    await _storage.clear(space: _getChatSpace(sessionId, packageName));
  }

  String _getSessionIndexKey(String packageName) =>
      '$_sessionIndexKeyPrefix$packageName';

  String _getChatSpace(String sessionId, String packageName) =>
      '$_chatSpacePrefix${sessionId}_$packageName';

  String _getChatConfigSpace(String packageName) =>
      '$_chatConfigSpacePrefix$packageName';

  Stream<AiMessageDto> _postOpenAiChatCompletionsStream({
    required AiConfig config,
    required List<AiMessageDto> messages,
    List<Map<String, dynamic>>? tools,
    CancelToken? cancelToken,
  }) async* {
    final request = <String, dynamic>{
      'model': config.moduleName,
      'messages': messages.map(_mapOpenAiMessage).toList(),
      'stream': true,
      'temperature': config.temperature,
      'max_tokens': config.maxToken,
      if (tools != null && tools.isNotEmpty) 'tools': tools,
    };

    try {
      final response = await _httpService.dio.post(
        config.fullApiUrl,
        data: request,
        cancelToken: cancelToken,
        options: Options(
          responseType: ResponseType.stream,
          receiveTimeout: _streamReceiveTimeout,
          headers: {
            if (config.apiKey.isNotEmpty) 'Authorization': 'Bearer ${config.apiKey}',
            'Content-Type': 'application/json',
            'Accept': 'text/event-stream',
          },
        ),
      );

      await _ensureSuccessfulResponse(response);

      final stream =
          (response.data.stream as Stream).cast<List<int>>().transform(utf8.decoder);
      var buffered = '';
      var isDone = false;
      final toolCallsAccum = <int, Map<String, dynamic>>{};

      await for (final chunk in stream) {
        if (isDone) {
          break;
        }

        buffered += chunk;
        final lines = buffered.split('\n');
        buffered = lines.removeLast();

        for (final rawLine in lines) {
          final line = rawLine.trim();
          if (line.isEmpty || !line.startsWith('data:')) {
            continue;
          }

          final data = line.substring(5).trim();
          if (data.isEmpty) {
            continue;
          }

          if (data == '[DONE]') {
            isDone = true;
            yield* _yieldValidatedOpenAiToolCalls(toolCallsAccum);
            break;
          }

          final decoded = _tryDecodeJson(data);
          if (decoded is! Map<String, dynamic>) {
            continue;
          }

          final choices = decoded['choices'];
          if (choices is! List || choices.isEmpty) {
            continue;
          }

          final delta = choices.first['delta'];
          if (delta is! Map<String, dynamic>) {
            continue;
          }

          final reasoningContent =
              delta['reasoning_content']?.toString() ??
              delta['reasoning']?.toString();
          if ((reasoningContent?.isNotEmpty ?? false)) {
            yield AiMessageDto(
              role: 'assistant',
              content: reasoningContent!,
              isThinking: true,
            );
          }

          final content = delta['content']?.toString();
          if (content != null && content.isNotEmpty) {
            yield AiMessageDto(role: 'assistant', content: content);
          }

          final toolCalls = delta['tool_calls'];
          if (toolCalls is List) {
            _accumulateOpenAiToolCalls(toolCallsAccum, toolCalls);
          }
        }
      }

      if (!isDone && buffered.trim().isNotEmpty) {
        final tail = buffered.trim();
        if (tail.startsWith('data:')) {
          final data = tail.substring(5).trim();
          if (data == '[DONE]') {
            yield* _yieldValidatedOpenAiToolCalls(toolCallsAccum);
          } else {
            final decoded = _tryDecodeJson(data);
            if (decoded is Map<String, dynamic>) {
              final choices = decoded['choices'];
              if (choices is List && choices.isNotEmpty) {
                final delta = choices.first['delta'];
                if (delta is Map<String, dynamic>) {
                  final content = delta['content']?.toString();
                  if (content != null && content.isNotEmpty) {
                    yield AiMessageDto(role: 'assistant', content: content);
                  }
                  final toolCalls = delta['tool_calls'];
                  if (toolCalls is List) {
                    _accumulateOpenAiToolCalls(toolCallsAccum, toolCalls);
                    yield* _yieldValidatedOpenAiToolCalls(toolCallsAccum);
                  }
                }
              }
            }
          }
        }
      }
    } on DioException catch (error) {
      throw await _buildPlatformExceptionFromDio(
        error,
        fallbackMessage: 'AI request failed',
      );
    } on PlatformException {
      rethrow;
    } catch (error) {
      throw PlatformException(
        code: 'unknown_error',
        message: error.toString(),
      );
    }
  }

  Stream<AiMessageDto> _postOpenAiResponsesStream({
    required AiConfig config,
    required List<AiMessageDto> messages,
    PadiChatOptions? padiChatOptions,
    List<Map<String, dynamic>>? tools,
    CancelToken? cancelToken,
  }) async* {
    final instructions = _buildResponsesInstructions(messages);
    final effectiveModel = padiChatOptions?.model ?? config.moduleName;
    final effectiveReasoningEffort =
        padiChatOptions?.reasoningEffort ?? _defaultResponsesReasoningEffort;
    final request = <String, dynamic>{
      'model': effectiveModel,
      'input': _mapResponsesInput(messages),
      'stream': true,
      'store': false,
      'include': const ['reasoning.encrypted_content'],
      'reasoning': {
        'effort': effectiveReasoningEffort,
      },
      'max_output_tokens': config.maxToken,
      if (tools != null && tools.isNotEmpty)
        'tools': tools.map(_normalizeOpenAiResponsesTool).toList(growable: false),
    };

    try {
      final response = await _httpService.dio.post(
        config.fullApiUrl,
        data: request,
        cancelToken: cancelToken,
        options: Options(
          responseType: ResponseType.stream,
          receiveTimeout: _streamReceiveTimeout,
          headers: {
            if (config.apiKey.isNotEmpty) 'Authorization': 'Bearer ${config.apiKey}',
            'Content-Type': 'application/json',
            'Accept': 'text/event-stream',
          },
        ),
      );

      await _ensureSuccessfulResponse(response);

      final stream =
          (response.data.stream as Stream).cast<List<int>>().transform(utf8.decoder);
      var buffered = '';
      final toolCallsAccum = <String, Map<String, dynamic>>{};

      await for (final chunk in stream) {
        buffered += chunk;
        final lines = buffered.split('\n');
        buffered = lines.removeLast();

        for (final rawLine in lines) {
          final line = rawLine.trim();
          if (line.isEmpty || !line.startsWith('data:')) {
            continue;
          }

          final data = line.substring(5).trim();
          if (data.isEmpty || data == '[DONE]') {
            continue;
          }

          final decoded = _tryDecodeJson(data);
          if (decoded is! Map<String, dynamic>) {
            continue;
          }

          final eventType = decoded['type']?.toString() ?? '';
          switch (eventType) {
            case 'response.output_text.delta':
              final delta = decoded['delta']?.toString();
              if (delta != null && delta.isNotEmpty) {
                yield AiMessageDto(role: 'assistant', content: delta);
              }
              break;
            case 'response.reasoning_text.delta':
            case 'response.reasoning_summary_text.delta':
              final delta = decoded['delta']?.toString();
              if (delta != null && delta.isNotEmpty) {
                yield AiMessageDto(
                  role: 'assistant',
                  content: delta,
                  isThinking: true,
                );
              }
              break;
            case 'response.function_call_arguments.delta':
              final itemId = decoded['item_id']?.toString();
              if (itemId == null || itemId.isEmpty) {
                break;
              }
              final current = toolCallsAccum.putIfAbsent(itemId, () {
                return {
                  'id': decoded['call_id']?.toString() ?? itemId,
                  'type': 'function',
                  'function': {
                    'name': decoded['name']?.toString() ?? '',
                    'arguments': <String, dynamic>{},
                  },
                  '_argBuffer': StringBuffer(),
                };
              });
              final callId = decoded['call_id']?.toString();
              if (callId != null && callId.isNotEmpty) {
                current['id'] = callId;
              }
              final delta = decoded['delta']?.toString() ?? '';
              if (delta.isNotEmpty) {
                (current['_argBuffer'] as StringBuffer).write(delta);
              }
              break;
            case 'response.function_call_arguments.done':
              final itemId = decoded['item_id']?.toString();
              if (itemId == null || itemId.isEmpty) {
                break;
              }
              final current = toolCallsAccum.putIfAbsent(itemId, () {
                return {
                  'id': decoded['call_id']?.toString() ?? itemId,
                  'type': 'function',
                  'function': {
                    'name': decoded['name']?.toString() ?? '',
                    'arguments': <String, dynamic>{},
                  },
                };
              });
              final function = current['function'] as Map<String, dynamic>;
              final name = decoded['name']?.toString();
              if (name != null && name.isNotEmpty) {
                function['name'] = name;
              }
              final callId = decoded['call_id']?.toString();
              if (callId != null && callId.isNotEmpty) {
                current['id'] = callId;
              }
              final rawArguments = decoded['arguments']?.toString().trim() ?? '';
              if (rawArguments.isNotEmpty) {
                final parsedArgs = _tryDecodeJson(rawArguments);
                function['arguments'] = parsedArgs is Map<String, dynamic>
                    ? parsedArgs
                    : rawArguments;
              }
              break;
            case 'response.output_item.done':
              final item = decoded['item'];
              if (item is! Map<String, dynamic>) {
                break;
              }
              final itemType = item['type']?.toString();
              if (itemType == 'reasoning') {
                yield AiMessageDto(
                  role: 'system',
                  content: OpenAiResponsesReasoningItemCodec.encode(item),
                );
                break;
              }
              if (itemType == 'function_call') {
                final itemId = item['id']?.toString() ?? '';
                if (itemId.isEmpty) {
                  break;
                }
                final current = toolCallsAccum.putIfAbsent(itemId, () {
                  return {
                    'id': item['call_id']?.toString() ?? itemId,
                    'type': 'function',
                    'function': {
                      'name': item['name']?.toString() ?? '',
                      'arguments': <String, dynamic>{},
                    },
                  };
                });
                final function = current['function'] as Map<String, dynamic>;
                final rawArguments = item['arguments']?.toString().trim() ?? '';
                if (rawArguments.isNotEmpty) {
                  final parsedArgs = _tryDecodeJson(rawArguments);
                  function['arguments'] = parsedArgs is Map<String, dynamic>
                      ? parsedArgs
                      : rawArguments;
                }
                final callId = item['call_id']?.toString();
                if (callId != null && callId.isNotEmpty) {
                  current['id'] = callId;
                }
                final name = item['name']?.toString();
                if (name != null && name.isNotEmpty) {
                  function['name'] = name;
                }
              }
              break;
          }
        }
      }

      if (toolCallsAccum.isNotEmpty) {
        yield* _yieldValidatedResponsesToolCalls(toolCallsAccum);
      }
    } on DioException catch (error) {
      throw await _buildPlatformExceptionFromDio(
        error,
        fallbackMessage: 'AI request failed',
      );
    } on PlatformException {
      rethrow;
    } catch (error) {
      throw PlatformException(
        code: 'unknown_error',
        message: error.toString(),
      );
    }
  }

  Stream<AiMessageDto> _postAnthropicChatStream({
    required AiConfig config,
    required List<AiMessageDto> messages,
    List<Map<String, dynamic>>? tools,
    CancelToken? cancelToken,
  }) async* {
    String? system;
    final payloadMessages = <Map<String, dynamic>>[];

    for (final message in messages) {
      if (message.role == 'system') {
        system = message.content;
        continue;
      }

      payloadMessages.add(_mapAnthropicMessage(message));
    }

    final request = <String, dynamic>{
      'model': config.moduleName,
      'messages': payloadMessages,
      'max_tokens': config.maxToken,
      'temperature': config.temperature,
      'stream': true,
      if (system != null && system.isNotEmpty) 'system': system,
      if (tools != null && tools.isNotEmpty)
        'tools': tools.map(_normalizeAnthropicTool).toList(growable: false),
    };

    try {
      final response = await _httpService.dio.post(
        config.fullApiUrl,
        data: request,
        cancelToken: cancelToken,
        options: Options(
          responseType: ResponseType.stream,
          receiveTimeout: _streamReceiveTimeout,
          headers: {
            'x-api-key': config.apiKey,
            'anthropic-version': '2023-06-01',
            'Content-Type': 'application/json',
            'Accept': 'text/event-stream',
          },
        ),
      );

      await _ensureSuccessfulResponse(response);

      final stream =
          (response.data.stream as Stream).cast<List<int>>().transform(utf8.decoder);
      var buffered = '';
      final toolCalls = <Map<String, dynamic>>[];
      final toolArgumentBuffers = <int, StringBuffer>{};
      String? stopReason;

      await for (final chunk in stream) {
        buffered += chunk;
        final lines = buffered.split('\n');
        buffered = lines.removeLast();

        for (final rawLine in lines) {
          final line = rawLine.trim();
          if (line.isEmpty || !line.startsWith('data:')) {
            continue;
          }

          final data = line.substring(5).trim();
          if (data.isEmpty) {
            continue;
          }

          final decoded = _tryDecodeJson(data);
          if (decoded is! Map<String, dynamic>) {
            continue;
          }

          final type = decoded['type']?.toString();
          if (type == 'content_block_start') {
            final contentBlock = decoded['content_block'];
            if (contentBlock is Map<String, dynamic> &&
                contentBlock['type'] == 'thinking') {
              yield AiMessageDto(
                role: 'assistant',
                isThinking: true,
              );
              continue;
            }
            if (contentBlock is Map<String, dynamic> &&
                contentBlock['type'] == 'tool_use') {
              final index = toolCalls.length;
              toolCalls.add({
                'id': contentBlock['id']?.toString() ?? '',
                'type': 'function',
                'function': {
                  'name': contentBlock['name']?.toString() ?? '',
                  'arguments': '{}',
                },
              });
              toolArgumentBuffers[index] = StringBuffer();
            }
            continue;
          }

          if (type == 'content_block_delta') {
            final delta = decoded['delta'];
            if (delta is! Map<String, dynamic>) {
              continue;
            }

            final deltaType = delta['type']?.toString();
            if (deltaType == 'text_delta') {
              final text = delta['text']?.toString();
              if (text != null && text.isNotEmpty) {
                yield AiMessageDto(role: 'assistant', content: text);
              }
              continue;
            }

            if (deltaType == 'thinking_delta') {
              final thinkingText = delta['thinking']?.toString() ?? '';
              yield AiMessageDto(
                role: 'assistant',
                content: thinkingText,
                isThinking: true,
              );
              continue;
            }

            if (deltaType == 'input_json_delta' && toolCalls.isNotEmpty) {
              final currentIndex = toolCalls.length - 1;
              toolArgumentBuffers[currentIndex]?.write(
                delta['partial_json']?.toString() ?? '',
              );
            }
            continue;
          }

          if (type == 'message_delta') {
            final delta = decoded['delta'];
            if (delta is Map<String, dynamic>) {
              final nextStopReason = delta['stop_reason']?.toString();
              if (nextStopReason != null && nextStopReason.isNotEmpty) {
                stopReason = nextStopReason;
              }
            }
            continue;
          }

          if (type == 'message_stop') {
            for (var index = 0; index < toolCalls.length; index++) {
              final rawArgs = toolArgumentBuffers[index]?.toString().trim() ?? '';
              if (rawArgs.isEmpty) {
                toolCalls[index]['function']['arguments'] = '{}';
                continue;
              }

              final decodedArgs = _tryDecodeJson(rawArgs);
              if (decodedArgs is Map<String, dynamic>) {
                toolCalls[index]['function']['arguments'] = jsonEncode(decodedArgs);
              } else {
                throw PlatformException(
                  code: 'parse_error',
                  message: 'Anthropic tool input JSON parse failed',
                  details: rawArgs,
                );
              }
            }

            if (toolCalls.isNotEmpty) {
              yield AiMessageDto(
                role: 'assistant',
                content: '',
                toolCalls: toolCalls,
              );
            }
            if (stopReason == 'pause_turn' || stopReason == 'max_tokens') {
              throw PlatformException(
                code: stopReason ?? 'partial_response',
                message: stopReason == 'pause_turn'
                    ? 'Anthropic 响应暂停，需要继续生成。'
                    : 'Anthropic 达到当前输出上限，需要继续生成。',
              );
            }
            return;
          }
        }
      }

      if (buffered.trim().isNotEmpty) {
        final tail = buffered.trim();
        if (tail.startsWith('data:')) {
          final data = tail.substring(5).trim();
          final decoded = _tryDecodeJson(data);
          if (decoded is Map<String, dynamic> &&
              decoded['type']?.toString() == 'message_stop' &&
              toolCalls.isNotEmpty) {
            for (var index = 0; index < toolCalls.length; index++) {
              final rawArgs = toolArgumentBuffers[index]?.toString().trim() ?? '';
              toolCalls[index]['function']['arguments'] =
                  rawArgs.isEmpty ? '{}' : rawArgs;
            }
            yield AiMessageDto(role: 'assistant', content: '', toolCalls: toolCalls);
            return;
          }
        }
      }

      if (stopReason == 'pause_turn' || stopReason == 'max_tokens') {
        throw PlatformException(
          code: stopReason ?? 'partial_response',
          message: stopReason == 'pause_turn'
              ? 'Anthropic 响应暂停，需要继续生成。'
              : 'Anthropic 达到当前输出上限，需要继续生成。',
        );
      }
    } on DioException catch (error) {
      throw await _buildPlatformExceptionFromDio(
        error,
        fallbackMessage: 'AI request failed',
      );
    } on PlatformException {
      rethrow;
    } catch (error) {
      throw PlatformException(
        code: 'unknown_error',
        message: error.toString(),
      );
    }
  }

  Future<String> _testOpenAiChatCompletionsConnection(AiConfig config) async {
    return _testStreamingConnection(
      url: config.fullApiUrl,
      headers: {
        if (config.apiKey.isNotEmpty) 'Authorization': 'Bearer ${config.apiKey}',
        'Content-Type': 'application/json',
        'Accept': 'text/event-stream',
      },
      request: {
        'model': config.moduleName,
        'messages': const [
          {'role': 'user', 'content': 'Hi'},
        ],
        'stream': true,
        'temperature': 0.0,
        'max_tokens': 1,
      },
    );
  }

  Future<String> _testOpenAiResponsesConnection(AiConfig config) async {
    return _testRequestConnection(
      url: config.fullApiUrl,
      headers: {
        if (config.apiKey.isNotEmpty) 'Authorization': 'Bearer ${config.apiKey}',
        'Content-Type': 'application/json',
        'Accept': 'text/event-stream',
      },
      request: {
        'model': config.moduleName,
        'input': 'Hi',
        'stream': true,
        'store': false,
        'reasoning': const {
          'effort': _defaultResponsesReasoningEffort,
        },
        'max_output_tokens': 1,
      },
    );
  }

  Future<String> _testAnthropicConnection(AiConfig config) async {
    return _testStreamingConnection(
      url: config.fullApiUrl,
      headers: {
        'x-api-key': config.apiKey,
        'anthropic-version': '2023-06-01',
        'Content-Type': 'application/json',
        'Accept': 'text/event-stream',
      },
      request: {
        'model': config.moduleName,
        'messages': const [
          {'role': 'user', 'content': 'Hi'},
        ],
        'stream': true,
        'temperature': 0.0,
        'max_tokens': 1,
      },
    );
  }

  Future<String> _testStreamingConnection({
    required String url,
    required Map<String, dynamic> request,
    required Map<String, String> headers,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      final response = await _httpService.dio.post(
        url,
        data: request,
        options: Options(
          responseType: ResponseType.stream,
          headers: headers,
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      await _ensureSuccessfulResponse(response);

      final stream = response.data.stream as Stream<List<int>>;
      await for (final chunk in stream) {
        if (chunk.isEmpty) {
          continue;
        }

        stopwatch.stop();
        final responseTime = stopwatch.elapsedMilliseconds;
        return responseTime < 6000
            ? 'Connection successful (${responseTime}ms)'
            : 'Connection successful but latency is high (${responseTime}ms)';
      }

      throw PlatformException(
        code: 'no_data',
        message: 'No response data received',
      );
    } on DioException catch (error) {
      stopwatch.stop();
      throw await _buildPlatformExceptionFromDio(
        error,
        fallbackMessage: 'Connection failed',
      );
    } on PlatformException {
      rethrow;
    } catch (error) {
      stopwatch.stop();
      throw PlatformException(
        code: 'unknown_error',
        message: error.toString(),
      );
    }
  }

  Future<String> _testRequestConnection({
    required String url,
    required Map<String, dynamic> request,
    required Map<String, String> headers,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      final response = await _httpService.dio.post(
        url,
        data: request,
        options: Options(
          responseType: ResponseType.json,
          headers: headers,
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      await _ensureSuccessfulResponse(response);
      stopwatch.stop();
      final responseTime = stopwatch.elapsedMilliseconds;
      return responseTime < 6000
          ? 'Connection successful (${responseTime}ms)'
          : 'Connection successful but latency is high (${responseTime}ms)';
    } on DioException catch (error) {
      stopwatch.stop();
      throw await _buildPlatformExceptionFromDio(
        error,
        fallbackMessage: 'Connection failed',
      );
    } on PlatformException {
      rethrow;
    } catch (error) {
      stopwatch.stop();
      throw PlatformException(
        code: 'unknown_error',
        message: error.toString(),
      );
    }
  }

  Future<void> _ensureSuccessfulResponse(Response<dynamic> response) async {
    final statusCode = response.statusCode;
    if (statusCode != null && statusCode >= 200 && statusCode < 300) {
      return;
    }

    final details = await _extractResponseData(response.data);

    throw PlatformException(
      code: 'http_error',
      message: 'HTTP ${response.statusCode}: ${response.statusMessage ?? 'Unknown error'}',
      details: details,
    );
  }

  Future<PlatformException> _buildPlatformExceptionFromDio(
    DioException error, {
    required String fallbackMessage,
  }) async {
    final details = await _extractResponseData(error.response?.data);
    final resolvedMessage = _resolveDioMessage(
      error: error,
      fallbackMessage: fallbackMessage,
      details: details,
    );
    return PlatformException(
      code: error.type.name,
      message: resolvedMessage,
      details: details,
    );
  }

  String _resolveDioMessage({
    required DioException error,
    required String fallbackMessage,
    required Object? details,
  }) {
    final baseMessage = error.message?.trim();
    final detailText = details?.toString().trim() ?? '';
    if (baseMessage == null || baseMessage.isEmpty) {
      return detailText.isEmpty ? fallbackMessage : detailText;
    }
    if (detailText.isEmpty) {
      return baseMessage;
    }
    if (baseMessage.contains(detailText)) {
      return baseMessage;
    }
    return '$baseMessage\n$detailText';
  }

  Future<Object?> _extractResponseData(Object? data) async {
    if (data == null) {
      return null;
    }
    if (data is ResponseBody) {
      final bytes = await data.stream.expand((chunk) => chunk).toList();
      final decodedText = utf8.decode(bytes, allowMalformed: true).trim();
      if (decodedText.isEmpty) {
        return null;
      }
      final decodedJson = _tryDecodeJson(decodedText);
      return decodedJson ?? decodedText;
    }
    if (data is List<int>) {
      final decodedText = utf8.decode(data, allowMalformed: true).trim();
      if (decodedText.isEmpty) {
        return null;
      }
      final decodedJson = _tryDecodeJson(decodedText);
      return decodedJson ?? decodedText;
    }
    return data;
  }

  dynamic _tryDecodeJson(String data) {
    try {
      return jsonDecode(data);
    } catch (_) {
      return null;
    }
  }

  void _accumulateOpenAiToolCalls(
    Map<int, Map<String, dynamic>> toolCallsAccum,
    List<dynamic> toolCalls,
  ) {
    for (final rawCall in toolCalls) {
      if (rawCall is! Map<String, dynamic>) {
        continue;
      }

      final index = rawCall['index'] as int? ?? 0;
      final current = toolCallsAccum.putIfAbsent(index, () {
        return {
          'id': rawCall['id']?.toString() ?? '',
          'type': 'function',
          'function': {
            'name': rawCall['function']?['name']?.toString() ?? '',
            'arguments': <String, dynamic>{},
          },
        };
      });

      final function = current['function'] as Map<String, dynamic>;
      final functionPayload = rawCall['function'];
      if (functionPayload is Map<String, dynamic>) {
        final name = functionPayload['name']?.toString();
        if (name != null && name.isNotEmpty) {
          function['name'] = name;
        }

        final argumentsChunk = functionPayload['arguments']?.toString() ?? '';
        if (argumentsChunk.isNotEmpty) {
          final parsedArgs = _tryDecodeJson(argumentsChunk);
          if (parsedArgs is Map<String, dynamic>) {
            final args = function['arguments'] as Map<String, dynamic>;
            args.addAll(parsedArgs);
          } else {
            final argBuffer = current.putIfAbsent('_argBuffer', () => StringBuffer());
            (argBuffer as StringBuffer).write(argumentsChunk);
          }
        }
      }

      final id = rawCall['id']?.toString();
      if (id != null && id.isNotEmpty) {
        current['id'] = id;
      }
    }
  }

  Stream<AiMessageDto> _yieldValidatedOpenAiToolCalls(
    Map<int, Map<String, dynamic>> toolCallsAccum,
  ) async* {
    if (toolCallsAccum.isEmpty) {
      return;
    }

    final validated = <Map<String, dynamic>>[];
    for (final call in toolCallsAccum.values) {
      final function = call['function'] as Map<String, dynamic>;
      final arguments = function['arguments'];
      if (call['_argBuffer'] is StringBuffer) {
        final raw = (call['_argBuffer'] as StringBuffer).toString().trim();
        if (raw.isNotEmpty) {
          final parsedArgs = _tryDecodeJson(raw);
          if (parsedArgs is Map<String, dynamic>) {
            (arguments as Map<String, dynamic>).addAll(parsedArgs);
          }
        }
      }

      function['arguments'] = arguments is Map<String, dynamic>
          ? jsonEncode(arguments)
          : '{}';
      call.remove('_argBuffer');
      validated.add(call);
    }

    if (validated.isNotEmpty) {
      yield AiMessageDto(role: 'assistant', content: '', toolCalls: validated);
    }
  }

  Map<String, dynamic> _mapAnthropicMessage(AiMessageDto message) {
    if (message.role == 'tool' && message.toolCallId != null) {
      return {
        'role': 'user',
        'content': [
          {
            'type': 'tool_result',
            'tool_use_id': message.toolCallId,
            'content': message.content,
          },
        ],
      };
    }

    if (message.toolCalls != null && message.toolCalls!.isNotEmpty) {
      final content = <Map<String, dynamic>>[];
      if (message.content.trim().isNotEmpty) {
        content.add({
          'type': 'text',
          'text': message.content,
        });
      }
      content.addAll(
        message.toolCalls!.map((toolCall) {
          final function = toolCall['function'] as Map<String, dynamic>? ?? {};
          final rawArguments = function['arguments'];
          return {
            'type': 'tool_use',
            'id': toolCall['id'],
            'name': function['name'],
            'input': rawArguments is String
                ? (_tryDecodeJson(rawArguments) ?? <String, dynamic>{})
                : (rawArguments ?? <String, dynamic>{}),
          };
        }),
      );
      return {
        'role': 'assistant',
        'content': content,
      };
    }

    if (message.role == 'user' &&
        AiMultimodalMessageCodec.isEncoded(message.content)) {
      return {
        'role': 'user',
        'content': AiMultimodalMessageCodec.toAnthropicContent(
          message.content,
          isZh: true,
        ),
      };
    }

    return {
      'role': message.role,
      'content': message.content,
    };
  }

  Map<String, dynamic> _mapOpenAiMessage(AiMessageDto message) {
    if (message.role == 'user' &&
        AiMultimodalMessageCodec.isEncoded(message.content)) {
      return {
        'role': message.role,
        'content': AiMultimodalMessageCodec.toOpenAiContent(
          message.content,
          isZh: true,
        ),
      };
    }

    return message.toJson();
  }

  List<Map<String, dynamic>> _mapResponsesInput(List<AiMessageDto> messages) {
    return OpenAiResponsesPayloadComposer.buildInput(messages);
  }

  String _buildResponsesInstructions(List<AiMessageDto> messages) {
    return OpenAiResponsesPayloadComposer.buildInstructions(messages);
  }

  Map<String, dynamic> _normalizeOpenAiResponsesTool(Map<String, dynamic> tool) {
    if (tool['type']?.toString() == 'function' && tool.containsKey('name')) {
      return Map<String, dynamic>.from(tool);
    }

    final function = tool['function'];
    if (function is Map<String, dynamic>) {
      return {
        'type': 'function',
        'name': function['name']?.toString() ?? '',
        'description': function['description']?.toString() ?? '',
        'parameters': Map<String, dynamic>.from(
          function['parameters'] as Map? ?? const <String, dynamic>{},
        ),
      };
    }

    return Map<String, dynamic>.from(tool);
  }

  Stream<AiMessageDto> _yieldValidatedResponsesToolCalls(
    Map<String, Map<String, dynamic>> toolCallsAccum,
  ) async* {
    if (toolCallsAccum.isEmpty) {
      return;
    }

    final validated = <Map<String, dynamic>>[];
    for (final call in toolCallsAccum.values) {
      final function = call['function'] as Map<String, dynamic>;
      var arguments = function['arguments'];
      if (call['_argBuffer'] is StringBuffer) {
        final raw = (call['_argBuffer'] as StringBuffer).toString().trim();
        if (raw.isNotEmpty) {
          final parsedArgs = _tryDecodeJson(raw);
          arguments = parsedArgs is Map<String, dynamic> ? parsedArgs : raw;
        }
      }

      function['arguments'] = arguments is Map<String, dynamic>
          ? jsonEncode(arguments)
          : arguments?.toString() ?? '{}';
      call.remove('_argBuffer');
      validated.add(call);
    }

    if (validated.isNotEmpty) {
      yield AiMessageDto(role: 'assistant', content: '', toolCalls: validated);
    }
  }

  Map<String, dynamic> _normalizeAnthropicTool(Map<String, dynamic> tool) {
    if (tool.containsKey('name') && tool.containsKey('input_schema')) {
      return Map<String, dynamic>.from(tool);
    }

    final function = tool['function'];
    if (function is Map<String, dynamic>) {
      return {
        'name': function['name']?.toString() ?? '',
        'description': function['description']?.toString() ?? '',
        'input_schema': Map<String, dynamic>.from(
          function['parameters'] as Map? ?? const <String, dynamic>{},
        ),
      };
    }

    return Map<String, dynamic>.from(tool);
  }
}

@visibleForTesting
final class OpenAiResponsesPayloadComposer {
  static const List<String> _internalInstructionPrefixes = <String>[
    '[context_memory]',
    '[task_state]',
    '[session_summary]',
    openAiResponsesReasoningProtocolPrefix,
  ];

  static List<Map<String, dynamic>> buildInput(List<AiMessageDto> messages) {
    final input = <Map<String, dynamic>>[];

    for (final message in messages) {
      final reasoningItem =
          OpenAiResponsesReasoningItemCodec.tryDecode(message.content);
      if (reasoningItem != null) {
        input.add(reasoningItem);
        continue;
      }

      if (message.role == 'system' || message.role == 'developer') {
        input.add({
          'type': 'message',
          'role': 'developer',
          'content': <Map<String, dynamic>>[
            {
              'type': 'input_text',
              'text': message.content,
            },
          ],
        });
        continue;
      }

      if (message.role == 'tool') {
        final toolCallId = message.toolCallId?.trim();
        if (toolCallId == null || toolCallId.isEmpty) {
          continue;
        }
        input.add({
          'type': 'function_call_output',
          'call_id': toolCallId,
          'output': message.content,
        });
        continue;
      }

      if (message.hasToolCalls) {
        if (message.content.trim().isNotEmpty) {
          input.add(mapMessage(message));
        }
        for (final toolCall in message.toolCalls!) {
          final function = toolCall['function'] as Map<String, dynamic>? ?? {};
          final callId = toolCall['id']?.toString().trim() ?? '';
          final name = function['name']?.toString().trim() ?? '';
          if (callId.isEmpty || name.isEmpty) {
            continue;
          }
          input.add({
            'type': 'function_call',
            'call_id': callId,
            'name': name,
            'arguments': function['arguments']?.toString() ?? '{}',
          });
        }
        continue;
      }

      input.add(mapMessage(message));
    }

    return input;
  }

  static String buildInstructions(List<AiMessageDto> messages) {
    return '';
  }

  static Map<String, dynamic> mapMessage(AiMessageDto message) {
    final normalizedRole = message.role == 'assistant' ? 'assistant' : 'user';
    final contentType = normalizedRole == 'assistant' ? 'output_text' : 'input_text';
    if (normalizedRole == 'user' &&
        AiMultimodalMessageCodec.isEncoded(message.content)) {
      return {
        'type': 'message',
        'role': normalizedRole,
        'content': toResponsesContent(message.content),
      };
    }

    return {
      'type': 'message',
      'role': normalizedRole,
      'content': <Map<String, dynamic>>[
        {
          'type': contentType,
          'text': message.content,
        },
      ],
    };
  }

  static List<Map<String, dynamic>> toResponsesContent(String content) {
    final openAiContent = AiMultimodalMessageCodec.toOpenAiContent(
      content,
      isZh: true,
    );
    return openAiContent.map((part) {
      final type = part['type']?.toString() ?? 'text';
      switch (type) {
        case 'image_url':
          final imagePayload = part['image_url'];
          return {
            'type': 'input_image',
            'image_url': imagePayload is Map<String, dynamic>
                ? imagePayload['url']?.toString() ?? ''
                : '',
          };
        case 'text':
        default:
          return {
            'type': 'input_text',
            'text': part['text']?.toString() ?? '',
          };
      }
    }).toList(growable: false);
  }

  static bool _isInternalInstruction(String content) {
    return _internalInstructionPrefixes.any(content.startsWith);
  }
}

final class OpenAiResponsesReasoningItemCodec {
  static String encode(Map<String, dynamic> item) {
    return '$openAiResponsesReasoningProtocolPrefix${jsonEncode(item)}';
  }

  static bool isEncoded(String content) {
    return content.startsWith(openAiResponsesReasoningProtocolPrefix);
  }

  static Map<String, dynamic>? tryDecode(String content) {
    if (!isEncoded(content)) {
      return null;
    }
    try {
      final raw = content.substring(openAiResponsesReasoningProtocolPrefix.length);
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}
