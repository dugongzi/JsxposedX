import 'package:JsxposedX/feature/ai/data/datasources/chat/ai_chat_action_datasource.dart';
import 'package:JsxposedX/feature/ai/data/models/ai_message_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {


  group('OpenAiResponsesPayloadComposer.buildInput', () {
    test('builds canonical multi-turn responses history', () {
      final messages = [
        const AiMessageDto(role: 'system', content: '会进入 input 的 developer角色'),
        const AiMessageDto(role: 'user', content: '第一问'),
        const AiMessageDto(role: 'assistant', content: '第一答'),
        const AiMessageDto(role: 'user', content: '第二问'),
      ];

      final input = OpenAiResponsesPayloadComposer.buildInput(messages);

      expect(input, [
        {
          'type': 'message',
          'role': 'developer',
          'content': [
            {'type': 'input_text', 'text': '会进入 input 的 developer角色'},
          ],
        },
        {
          'type': 'message',
          'role': 'user',
          'content': [
            {'type': 'input_text', 'text': '第一问'},
          ],
        },
        {
          'type': 'message',
          'role': 'assistant',
          'content': [
            {'type': 'output_text', 'text': '第一答'},
          ],
        },
        {
          'type': 'message',
          'role': 'user',
          'content': [
            {'type': 'input_text', 'text': '第二问'},
          ],
        },
      ]);
    });

    test('keeps tool call ordering and skips invalid tool call entries', () {
      final messages = [
        AiMessageDto(
          role: 'assistant',
          content: '先查一下',
          toolCalls: [
            {
              'id': 'call_1',
              'type': 'function',
              'function': {
                'name': 'search_classes',
                'arguments': '{"keyword":"vip"}',
              },
            },
            {
              'id': '',
              'type': 'function',
              'function': {
                'name': 'broken_call',
                'arguments': '{}',
              },
            },
          ],
        ),
        AiMessageDto.toolResult(
          toolCallId: 'call_1',
          content: 'success',
        ),
        const AiMessageDto(role: 'user', content: '继续'),
      ];

      final input = OpenAiResponsesPayloadComposer.buildInput(messages);

      expect(input, [
        {
          'type': 'message',
          'role': 'assistant',
          'content': [
            {'type': 'output_text', 'text': '先查一下'},
          ],
        },
        {
          'type': 'function_call',
          'call_id': 'call_1',
          'name': 'search_classes',
          'arguments': '{"keyword":"vip"}',
        },
        {
          'type': 'function_call_output',
          'call_id': 'call_1',
          'output': 'success',
        },
        {
          'type': 'message',
          'role': 'user',
          'content': [
            {'type': 'input_text', 'text': '继续'},
          ],
        },
      ]);
    });

    test('keeps adjacent user messages as separate items', () {
      final messages = [
        const AiMessageDto(role: 'user', content: 'Ok，你看看还有什么可以hook的'),
        const AiMessageDto(role: 'user', content: '1'),
      ];

      final input = OpenAiResponsesPayloadComposer.buildInput(messages);

      expect(input, [
        {
          'type': 'message',
          'role': 'user',
          'content': [
            {'type': 'input_text', 'text': 'Ok，你看看还有什么可以hook的'},
          ],
        },
        {
          'type': 'message',
          'role': 'user',
          'content': [
            {'type': 'input_text', 'text': '1'},
          ],
        },
      ]);
    });

    test('replays stored reasoning items before tool results', () {
      final reasoningContent = OpenAiResponsesReasoningItemCodec.encode(const {
        'id': 'rs_1',
        'type': 'reasoning',
        'encrypted_content': 'encrypted_blob',
      });
      final messages = [
        AiMessageDto(role: 'system', content: reasoningContent),
        AiMessageDto.toolResult(
          toolCallId: 'call_1',
          content: 'success',
        ),
      ];

      final input = OpenAiResponsesPayloadComposer.buildInput(messages);

      expect(input, [
        {
          'id': 'rs_1',
          'type': 'reasoning',
          'encrypted_content': 'encrypted_blob',
        },
        {
          'type': 'function_call_output',
          'call_id': 'call_1',
          'output': 'success',
        },
      ]);
    });
  });
}
