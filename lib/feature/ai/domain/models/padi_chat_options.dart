class PadiChatOptions {
  const PadiChatOptions({
    required this.model,
    required this.reasoningEffort,
  });

  final String model;
  final String reasoningEffort;

  static const String defaultModel = 'gpt-5.4';
  static const String defaultReasoningEffort = 'medium';
  static const String effortNone = 'none';
  static const String effortLow = 'low';
  static const String effortMedium = 'medium';
  static const String effortHigh = 'high';
  static const String effortXHigh = 'xhigh';

  static const List<String> models = [
    'gpt-5.4',
    'gpt-5.3-codex',
    'gpt-5.2-codex',
    'gpt-5.1-codex',
  ];

  static const Map<String, List<String>> supportedEffortsByModel = {
    'gpt-5.4': [effortNone, effortLow, effortMedium, effortHigh, effortXHigh],
    'gpt-5.3-codex': [effortLow, effortMedium, effortHigh, effortXHigh],
    'gpt-5.2-codex': [effortLow, effortMedium, effortHigh],
    'gpt-5.1-codex': [effortLow, effortMedium, effortHigh],
  };

  factory PadiChatOptions.defaults() {
    return const PadiChatOptions(
      model: defaultModel,
      reasoningEffort: defaultReasoningEffort,
    );
  }

  factory PadiChatOptions.fromJson(Map<String, dynamic> json) {
    final rawModel = json['model']?.toString() ?? defaultModel;
    final model = models.contains(rawModel) ? rawModel : defaultModel;
    final rawEffort =
        json['reasoningEffort']?.toString() ?? defaultReasoningEffort;
    return PadiChatOptions(
      model: model,
      reasoningEffort: normalizeEffort(model, rawEffort),
    );
  }

  Map<String, dynamic> toJson() => {
    'model': model,
    'reasoningEffort': reasoningEffort,
  };

  PadiChatOptions copyWith({
    String? model,
    String? reasoningEffort,
  }) {
    final nextModel = model ?? this.model;
    return PadiChatOptions(
      model: nextModel,
      reasoningEffort: normalizeEffort(
        nextModel,
        reasoningEffort ?? this.reasoningEffort,
      ),
    );
  }

  static List<String> supportedEffortsForModel(String model) {
    return supportedEffortsByModel[model] ??
        supportedEffortsByModel[defaultModel]!;
  }

  static String normalizeEffort(String model, String effort) {
    final supported = supportedEffortsForModel(model);
    if (supported.contains(effort)) {
      return effort;
    }
    if (supported.contains(defaultReasoningEffort)) {
      return defaultReasoningEffort;
    }
    return supported.first;
  }
}
