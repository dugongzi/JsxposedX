import 'package:JsxposedX/core/models/ai_message.dart';
import 'package:JsxposedX/feature/ai/domain/models/ai_chat_session_context.dart';
import 'package:JsxposedX/feature/ai/domain/services/ai_chat_context_budget_estimator.dart';
import 'package:JsxposedX/feature/ai/domain/services/ai_multimodal_message_codec.dart';
import 'package:uuid/uuid.dart';

class AiChatContextAssembler {
  AiChatContextAssembler({
    AiChatContextBudgetEstimator? estimator,
  }) : _estimator = estimator ?? const AiChatContextBudgetEstimator();

  static const String legacySummaryPrefix = '[session_summary]';

  final AiChatContextBudgetEstimator _estimator;

  AiChatContextAssembly assemble({
    required List<AiMessage> protocolMessages,
    required String sessionRules,
    required int tokenBudget,
    required int recentRounds,
    AiChatSessionContext? previousContext,
    bool forceCompact = false,
    String? lastError,
    AiChatRecoveryMode recoveryMode = AiChatRecoveryMode.none,
  }) {
    final sanitized = _sanitizeProtocolMessages(protocolMessages);
    final legacySummary = _findLatestLegacySummary(protocolMessages);
    final selectedRecent = _selectRecentWindow(
      sanitized.messages,
      recentRounds: recentRounds,
    );
    final olderMessages = sanitized.messages.take(
      sanitized.messages.length - selectedRecent.length,
    ).toList(growable: false);
    final memory = _buildSessionMemory(
      olderMessages: olderMessages,
      legacySummary: legacySummary?.content,
      recentMessages: selectedRecent,
      lastError: lastError,
    );
    final toolTrace = _buildToolTrace(sanitized.messages);
    final taskState = _buildTaskState(
      recentMessages: selectedRecent,
      sessionMemory: memory,
      toolTrace: toolTrace,
      lastError: lastError,
      recoveryMode: recoveryMode == AiChatRecoveryMode.none
          ? previousContext?.taskState.lastRecoveryMode ??
              AiChatRecoveryMode.none
          : recoveryMode,
    );

    final memoryMessage = _buildMemorySystemMessage(memory);
    final taskMessage = _buildTaskSystemMessage(taskState, toolTrace);
    var recentMessages = List<AiMessage>.from(selectedRecent);
    var requestMessages = _buildRequestMessages(
      sessionRules: sessionRules,
      memoryMessage: memoryMessage,
      taskMessage: taskMessage,
      recentMessages: recentMessages,
    );

    var didCompact = forceCompact || olderMessages.isNotEmpty;
    while (requestMessages.isNotEmpty &&
        _estimator.estimateMessagesTokens(requestMessages) > tokenBudget &&
        recentMessages.isNotEmpty) {
      final nextRecent = _dropOldestTurn(recentMessages);
      if (nextRecent.length == recentMessages.length) {
        break;
      }
      recentMessages = nextRecent;
      requestMessages = _buildRequestMessages(
        sessionRules: sessionRules,
        memoryMessage: memoryMessage,
        taskMessage: taskMessage,
        recentMessages: recentMessages,
      );
      didCompact = true;
    }

    final includedLayers = <String>[
      if (sessionRules.trim().isNotEmpty) 'rules',
      if (memory.hasContent) 'memory',
      if (taskState.hasContent) 'task',
      if (recentMessages.isNotEmpty) 'recent',
      if (recentMessages.any((message) => message.role == 'tool') ||
          toolTrace.hasPendingToolResults)
        'tools',
    ];
    final estimatedTokens = _estimator.estimateMessagesTokens(requestMessages);
    final stats = AiChatContextStats(
      tokenBudget: tokenBudget,
      estimatedTokens: estimatedTokens,
      remainingTokens: tokenBudget - estimatedTokens < 0
          ? 0
          : tokenBudget - estimatedTokens,
      didCompact: didCompact,
      compactReason: didCompact
          ? (forceCompact ? 'manual' : 'budget')
          : null,
      repairedToolContext: sanitized.repairedToolContext,
      migratedLegacySummary: legacySummary != null,
      recentRoundsKept: _countUserRounds(recentMessages),
      includedLayers: List<String>.unmodifiable(includedLayers),
    );

    final context = AiChatSessionContext(
      version: AiChatSessionContext.currentVersion,
      sessionRules: sessionRules,
      sessionMemory: memory,
      taskState: taskState,
      recentMessages: List<AiMessage>.unmodifiable(recentMessages),
      toolTrace: toolTrace,
      checkpoint: previousContext?.checkpoint,
      stats: stats,
      migratedFromLegacySummary: legacySummary != null,
    );

    return AiChatContextAssembly(
      sanitizedProtocolMessages: List<AiMessage>.unmodifiable(
        sanitized.messages,
      ),
      requestMessages: List<AiMessage>.unmodifiable(requestMessages),
      context: context,
    );
  }

  List<AiMessage> _buildRequestMessages({
    required String sessionRules,
    required AiMessage? memoryMessage,
    required AiMessage? taskMessage,
    required List<AiMessage> recentMessages,
  }) {
    return [
      if (sessionRules.trim().isNotEmpty)
        AiMessage(
          id: const Uuid().v4(),
          role: 'system',
          content: sessionRules.trim(),
        ),
      if (memoryMessage != null) memoryMessage,
      if (taskMessage != null) taskMessage,
      ...recentMessages,
    ];
  }

  _SanitizedMessages _sanitizeProtocolMessages(List<AiMessage> protocolMessages) {
    final sanitized = <AiMessage>[];
    final pendingToolCallIds = <String>{};
    var awaitingToolResults = false;
    var repairedToolContext = false;

    for (final message in protocolMessages) {
      if (_isLegacySummary(message)) {
        continue;
      }
      if (message.role == 'assistant') {
        pendingToolCallIds
          ..clear()
          ..addAll(_extractToolCallIds(message.toolCalls));
        awaitingToolResults = message.hasToolCalls;
        sanitized.add(message);
        continue;
      }
      if (message.role == 'tool') {
        if (!awaitingToolResults) {
          repairedToolContext = true;
          continue;
        }
        final toolCallId = message.toolCallId;
        if (pendingToolCallIds.isNotEmpty) {
          if (toolCallId == null || !pendingToolCallIds.remove(toolCallId)) {
            repairedToolContext = true;
            continue;
          }
          if (pendingToolCallIds.isEmpty) {
            awaitingToolResults = false;
          }
        }
        sanitized.add(message);
        continue;
      }
      if (awaitingToolResults) {
        pendingToolCallIds.clear();
        awaitingToolResults = false;
      }
      sanitized.add(message);
    }

    return _SanitizedMessages(
      messages: sanitized,
      repairedToolContext: repairedToolContext,
    );
  }

  AiMessage? _findLatestLegacySummary(List<AiMessage> messages) {
    for (var index = messages.length - 1; index >= 0; index--) {
      final message = messages[index];
      if (_isLegacySummary(message)) {
        return message;
      }
    }
    return null;
  }

  bool _isLegacySummary(AiMessage message) {
    return message.role == 'system' &&
        message.content.startsWith(legacySummaryPrefix);
  }

  List<AiMessage> _selectRecentWindow(
    List<AiMessage> messages, {
    required int recentRounds,
  }) {
    if (messages.isEmpty) {
      return const [];
    }
    final roundsToKeep = recentRounds <= 0 ? 1 : recentRounds;
    var userRounds = 0;
    var startIndex = 0;
    for (var index = messages.length - 1; index >= 0; index--) {
      if (messages[index].role == 'user') {
        userRounds++;
        if (userRounds >= roundsToKeep) {
          startIndex = index;
          break;
        }
      }
    }
    return List<AiMessage>.from(messages.sublist(startIndex));
  }

  List<AiMessage> _dropOldestTurn(List<AiMessage> messages) {
    if (messages.length <= 1) {
      return List<AiMessage>.from(messages);
    }
    if (_countUserRounds(messages) <= 1) {
      return List<AiMessage>.from(messages);
    }
    for (var index = 1; index < messages.length; index++) {
      if (messages[index].role == 'user') {
        return List<AiMessage>.from(messages.sublist(index));
      }
    }
    return List<AiMessage>.from(messages.sublist(1));
  }

  AiChatSessionMemory _buildSessionMemory({
    required List<AiMessage> olderMessages,
    required String? legacySummary,
    required List<AiMessage> recentMessages,
    required String? lastError,
  }) {
    final memory = _MemoryAccumulator();
    _parseLegacySummary(memory, legacySummary);

    for (final message in olderMessages) {
      _ingestMessage(memory, message);
    }
    for (final message in recentMessages.take(
      recentMessages.length > 2 ? 2 : recentMessages.length,
    )) {
      if (message.role == 'tool') {
        _addUnique(memory.toolFindings, _truncate(message.content, 180));
      }
    }
    if (lastError != null && lastError.trim().isNotEmpty) {
      _addUnique(memory.blockers, _truncate(lastError, 180));
    }

    return AiChatSessionMemory(
      userGoals: List<String>.unmodifiable(memory.userGoals),
      confirmedFacts: List<String>.unmodifiable(memory.confirmedFacts),
      openHypotheses: List<String>.unmodifiable(memory.openHypotheses),
      toolFindings: List<String>.unmodifiable(memory.toolFindings),
      blockers: List<String>.unmodifiable(memory.blockers),
    );
  }

  void _ingestMessage(_MemoryAccumulator memory, AiMessage message) {
    final normalized = _truncate(
      _semanticContent(message).replaceAll('\r', ' ').replaceAll('\n', ' ').trim(),
      180,
    );
    if (normalized.isEmpty) {
      return;
    }
    if (message.role == 'user') {
      _addUnique(memory.userGoals, normalized);
      if (_looksLikeHypothesis(normalized)) {
        _addUnique(memory.openHypotheses, normalized);
      }
      return;
    }
    if (message.role == 'tool') {
      _addUnique(memory.toolFindings, normalized);
      return;
    }
    if (message.role == 'assistant' && !message.hasToolCalls) {
      if (message.isError) {
        _addUnique(memory.blockers, normalized);
      } else {
        _addUnique(memory.confirmedFacts, normalized);
      }
    }
  }

  void _parseLegacySummary(_MemoryAccumulator memory, String? summary) {
    if (summary == null || summary.isEmpty) {
      return;
    }

    String? currentTitle;
    final lines = summary
        .replaceFirst(legacySummaryPrefix, '')
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty);

    for (final line in lines) {
      if (line.endsWith('：')) {
        currentTitle = line.substring(0, line.length - 1);
        continue;
      }
      if (!line.startsWith('- ')) {
        continue;
      }
      final note = line.substring(2).trim();
      if (note.isEmpty) {
        continue;
      }
      switch (currentTitle) {
        case '历史诉求':
          _addUnique(memory.userGoals, note);
          break;
        case '已知结论':
          _addUnique(memory.confirmedFacts, note);
          break;
        case '工具发现':
          _addUnique(memory.toolFindings, note);
          break;
        case '待继续':
          _addUnique(memory.openHypotheses, note);
          break;
        default:
          _addUnique(memory.confirmedFacts, note);
      }
    }
  }

  AiToolExecutionTrace _buildToolTrace(List<AiMessage> messages) {
    AiMessage? lastAssistantToolCall;
    final resultSummaries = <String, String>{};
    final argumentSummaries = <String, String>{};
    var sawFollowupAssistant = false;

    for (var index = messages.length - 1; index >= 0; index--) {
      final message = messages[index];
      if (message.role == 'assistant' && !message.hasToolCalls) {
        if (lastAssistantToolCall != null) {
          sawFollowupAssistant = true;
          break;
        }
        continue;
      }
      if (message.role == 'tool') {
        final toolCallId = message.toolCallId;
        if (toolCallId != null && toolCallId.isNotEmpty) {
          resultSummaries[toolCallId] = _truncate(message.content, 200);
        }
        continue;
      }
      if (message.role == 'assistant' && message.hasToolCalls) {
        lastAssistantToolCall = message;
        final toolCalls = message.toolCalls ?? const [];
        for (final toolCall in toolCalls) {
          final id = toolCall['id']?.toString() ?? '';
          if (id.isEmpty) {
            continue;
          }
          final function = toolCall['function'] as Map<String, dynamic>? ?? const {};
          argumentSummaries[id] = _truncate(
            function['arguments']?.toString() ?? '',
            180,
          );
        }
        break;
      }
    }

    if (lastAssistantToolCall == null) {
      return const AiToolExecutionTrace();
    }

    final toolCallIds = _extractToolCallIds(lastAssistantToolCall.toolCalls);
    final allResultsPresent = toolCallIds.every(resultSummaries.containsKey);
    return AiToolExecutionTrace(
      assistantToolCallMessage: lastAssistantToolCall,
      toolCallIds: List<String>.unmodifiable(toolCallIds),
      argumentSummaries: Map<String, String>.unmodifiable(argumentSummaries),
      resultSummaries: Map<String, String>.unmodifiable(resultSummaries),
      isComplete: sawFollowupAssistant || allResultsPresent,
      canReplay: true,
    );
  }

  AiChatTaskState _buildTaskState({
    required List<AiMessage> recentMessages,
    required AiChatSessionMemory sessionMemory,
    required AiToolExecutionTrace toolTrace,
    required String? lastError,
    required AiChatRecoveryMode recoveryMode,
  }) {
    String? currentStep;
    String? nextStep;
    String? recentSuccessStep;
    String? lastUserGoal;

    for (var index = recentMessages.length - 1; index >= 0; index--) {
      final message = recentMessages[index];
      if (lastUserGoal == null && message.role == 'user') {
        lastUserGoal = _truncate(_semanticContent(message).trim(), 180);
      }
      if (recentSuccessStep == null &&
          message.role == 'assistant' &&
          !message.isError &&
          !message.hasToolCalls &&
          _semanticContent(message).trim().isNotEmpty) {
        recentSuccessStep = _truncate(_semanticContent(message).trim(), 180);
      }
      if (currentStep == null &&
          message.role == 'assistant' &&
          _semanticContent(message).trim().isNotEmpty &&
          !message.hasToolCalls) {
        currentStep = _truncate(_semanticContent(message).trim(), 180);
      }
      if (nextStep == null &&
          message.role == 'user' &&
          _semanticContent(message).trim().isNotEmpty) {
        nextStep = _truncate(_semanticContent(message).trim(), 180);
      }
    }

    if (toolTrace.hasPendingToolResults) {
      currentStep ??= '恢复未完成的工具调用阶段';
    }

    return AiChatTaskState(
      currentStep: currentStep,
      nextStep: nextStep,
      recentSuccessStep: recentSuccessStep,
      lastError: lastError,
      lastUserGoal: lastUserGoal ??
          (sessionMemory.userGoals.isNotEmpty ? sessionMemory.userGoals.last : null),
      lastRecoveryMode: recoveryMode,
    );
  }

  AiMessage? _buildMemorySystemMessage(AiChatSessionMemory memory) {
    if (!memory.hasContent) {
      return null;
    }
    final buffer = StringBuffer('[context_memory]');
    _writeSection(buffer, '用户目标', memory.userGoals.take(4));
    _writeSection(buffer, '已确认事实', memory.confirmedFacts.take(6));
    _writeSection(buffer, '未确认假设', memory.openHypotheses.take(4));
    _writeSection(buffer, '工具发现', memory.toolFindings.take(6));
    _writeSection(buffer, '阻塞/错误', memory.blockers.take(4));
    return AiMessage(
      id: const Uuid().v4(),
      role: 'system',
      content: buffer.toString().trim(),
    );
  }

  AiMessage? _buildTaskSystemMessage(
    AiChatTaskState taskState,
    AiToolExecutionTrace toolTrace,
  ) {
    if (!taskState.hasContent && !toolTrace.hasPendingToolResults) {
      return null;
    }
    final buffer = StringBuffer('[task_state]');
    if (taskState.currentStep?.trim().isNotEmpty ?? false) {
      buffer
        ..writeln()
        ..writeln('当前步骤：${taskState.currentStep}');
    }
    if (taskState.nextStep?.trim().isNotEmpty ?? false) {
      buffer.writeln('下一步：${taskState.nextStep}');
    }
    if (taskState.recentSuccessStep?.trim().isNotEmpty ?? false) {
      buffer.writeln('最近成功步骤：${taskState.recentSuccessStep}');
    }
    if (taskState.lastError?.trim().isNotEmpty ?? false) {
      buffer.writeln('最近错误：${taskState.lastError}');
    }
    if (toolTrace.hasPendingToolResults) {
      buffer.writeln('工具阶段：存在未完成工具调用，优先恢复工具闭环。');
    }
    return AiMessage(
      id: const Uuid().v4(),
      role: 'system',
      content: buffer.toString().trim(),
    );
  }

  void _writeSection(
    StringBuffer buffer,
    String title,
    Iterable<String> items,
  ) {
    final normalized = items
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
    if (normalized.isEmpty) {
      return;
    }
    buffer
      ..writeln()
      ..writeln('$title：');
    for (final item in normalized) {
      buffer.writeln('- $item');
    }
  }

  int _countUserRounds(List<AiMessage> messages) {
    return messages.where((message) => message.role == 'user').length;
  }

  List<String> _extractToolCallIds(List<Map<String, dynamic>>? toolCalls) {
    if (toolCalls == null || toolCalls.isEmpty) {
      return const [];
    }
    return toolCalls
        .map((toolCall) => toolCall['id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toList(growable: false);
  }

  bool _looksLikeHypothesis(String text) {
    return text.contains('?') ||
        text.contains('？') ||
        text.startsWith('请') ||
        text.startsWith('分析') ||
        text.startsWith('找') ||
        text.startsWith('定位');
  }

  void _addUnique(List<String> items, String value) {
    final normalized = value.trim();
    if (normalized.isEmpty || items.contains(normalized)) {
      return;
    }
    items.add(normalized);
  }

  String _truncate(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }

  String _semanticContent(AiMessage message) {
    if (message.role != 'user') {
      return message.content;
    }
    return AiMultimodalMessageCodec.toSemanticText(
      message.content,
      isZh: true,
    );
  }
}

class AiChatContextAssembly {
  const AiChatContextAssembly({
    required this.sanitizedProtocolMessages,
    required this.requestMessages,
    required this.context,
  });

  final List<AiMessage> sanitizedProtocolMessages;
  final List<AiMessage> requestMessages;
  final AiChatSessionContext context;
}

class _SanitizedMessages {
  const _SanitizedMessages({
    required this.messages,
    required this.repairedToolContext,
  });

  final List<AiMessage> messages;
  final bool repairedToolContext;
}

class _MemoryAccumulator {
  final List<String> userGoals = [];
  final List<String> confirmedFacts = [];
  final List<String> openHypotheses = [];
  final List<String> toolFindings = [];
  final List<String> blockers = [];
}
