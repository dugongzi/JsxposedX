// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'JSXPOSEDX';

  @override
  String get appSubtitle =>
      'Cross-platform Hook debugging tool based on Xposed Frida';

  @override
  String get home => 'Home';

  @override
  String get project => 'Project';

  @override
  String get repository => 'Repository';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get lightTheme => 'Light Theme';

  @override
  String get darkTheme => 'Dark Theme';

  @override
  String get chinese => '简体中文';

  @override
  String get english => 'English';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get search => 'Search';

  @override
  String get loading => 'Loading...';

  @override
  String get success => 'Success';

  @override
  String get error => 'Error';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Info';

  @override
  String get hookStatus => 'Hook Status';

  @override
  String get hookEnabled => 'Hook Enabled';

  @override
  String get hookDisabled => 'Hook Disabled';

  @override
  String get moduleInfo => 'Module Info';

  @override
  String get version => 'Version';

  @override
  String get about => 'About';

  @override
  String get community => 'Community';

  @override
  String get officialCommunity => 'Get tutorials and community support';

  @override
  String get forum => 'Forum';

  @override
  String get visitForum => 'Visit Forum';

  @override
  String get joinDiscord => 'Join Discord';

  @override
  String get joinQQGroup => 'Join QQ Group';

  @override
  String get followAuthor => 'Follow the Author';

  @override
  String get creatorPlatforms => 'Get Tutorials';

  @override
  String get morePlatforms => 'More Platforms';

  @override
  String pageNotFound(String error) {
    return 'Page Not Found: $error';
  }

  @override
  String get backToHome => 'Back to Home';

  @override
  String get retry => 'Retry';

  @override
  String get loadFailedMessage => 'Load failed, please retry';

  @override
  String get activated => 'Activated';

  @override
  String get notActivated => 'Not Activated';

  @override
  String get fridaPartial => 'Partial';

  @override
  String get fridaGlobal => 'Global';

  @override
  String get fridaUnknown => 'Unknown';

  @override
  String get fridaNotInstalledShort => 'Not installed';

  @override
  String get fridaInitAbnormal => 'Initialization error';

  @override
  String get fridaStatusEnabled => 'Enabled';

  @override
  String get fridaStatusDisabled => 'Disabled';

  @override
  String get fridaTargetDisabled => 'Target disabled';

  @override
  String get fridaEffective => 'Active';

  @override
  String get zygiskFridaModuleNotInstalled =>
      'Zygisk Frida module is not installed';

  @override
  String get systemVersion => 'System Version';

  @override
  String get sdkVersion => 'SDK Version';

  @override
  String get deviceModel => 'Device Model';

  @override
  String get systemStorage => 'System Storage';

  @override
  String get cpuArchitecture => 'CPU Architecture';

  @override
  String get frameworkPackageName => 'Framework Package Name';

  @override
  String get copy => 'Copy';

  @override
  String get selectAll => 'Select All';

  @override
  String get cut => 'Cut';

  @override
  String get paste => 'Paste';

  @override
  String get comment => 'Comment';

  @override
  String get codeCopied => 'Code copied to clipboard';

  @override
  String get totalStorage => 'Total';

  @override
  String get available => 'Available';

  @override
  String get softwareIcon => 'Software Icon';

  @override
  String get needRootPermission => 'You must grant Root permission';

  @override
  String get pleaseActivateXposed => 'Please activate Xposed first';

  @override
  String get initFrida => 'Initialize Frida';

  @override
  String get homeTitleAI => 'AI';

  @override
  String get homeTitleRoot => 'Root';

  @override
  String get homeTitleXposed => 'Xposed';

  @override
  String get homeTitleFrida => 'Frida';

  @override
  String get themeColor => 'Theme Color';

  @override
  String get selectThemeColor => 'Select Theme Color';

  @override
  String get aiConfig => 'AI Configuration';

  @override
  String get aiConfigTitle => 'AI Settings';

  @override
  String get aiBaseUrl => 'API Base URL';

  @override
  String get aiBaseUrlHint => 'Enter API Base URL';

  @override
  String get aiApiKeyHint => 'Enter API Key';

  @override
  String get aiMaxTokens => 'Max Tokens';

  @override
  String get aiMaxTokensHint => 'Enter maximum tokens';

  @override
  String get aiModelName => 'Model Name';

  @override
  String get aiModelNameHint => 'Enter model name';

  @override
  String get aiTemperature => 'Temperature';

  @override
  String get aiMemoryRounds => 'Memory Rounds';

  @override
  String cannotBeEmpty(Object field) {
    return '$field cannot be empty';
  }

  @override
  String get saveSuccess => 'Save Success';

  @override
  String get test => 'Test';

  @override
  String get selectApp => 'Select App';

  @override
  String get showSystemApps => 'Show System Apps';

  @override
  String get searchAppsPlaceholder => 'Global search app name or package...';

  @override
  String loadedCount(int loaded, int total) {
    return 'Loaded: $loaded / Match: $total';
  }

  @override
  String get systemAppLabel => 'System';

  @override
  String alreadySelected(Object name) {
    return 'Selected: $name';
  }

  @override
  String get notice => 'Notice';

  @override
  String get updateAvailableTitle => 'New Version Available';

  @override
  String get updateContentTitle => 'What\'s New';

  @override
  String get updateNow => 'Update Now';

  @override
  String get updateContentFallback =>
      '• Fix known issues\n• Improve user experience\n• Enhance app performance';

  @override
  String get noRelatedApps => 'No related apps found';

  @override
  String get projectListEmpty =>
      'No projects yet, create one from the home page';

  @override
  String projectLoadFailed(Object error) {
    return 'Load failed: $error';
  }

  @override
  String get confirmDelete => 'Confirm delete?';

  @override
  String get xposedProject => 'Xposed Project';

  @override
  String get fridaProject => 'Frida Project';

  @override
  String get quickFunctions => 'Quick Functions';

  @override
  String get aiReverse => 'AI Cracker';

  @override
  String get qfPageTitle => 'Quick Functions';

  @override
  String get qfSectionBasic => 'Basic';

  @override
  String get qfSectionEnv => 'Environment';

  @override
  String get qfSectionCrypto => 'Crypto Analysis';

  @override
  String get qfRemoveDialogs => 'Remove Dialogs';

  @override
  String get qfRemoveScreenshotDetection =>
      'Bypass Screenshot/Recording Detection';

  @override
  String get qfRemoveCaptureDetection => 'Bypass Capture Detection';

  @override
  String get qfInjectTip => 'Injection Tip';

  @override
  String get qfModifiedVersion => 'Remove Updates';

  @override
  String get qfHideXposed => 'Hide Xposed';

  @override
  String get qfHideRoot => 'Hide Root';

  @override
  String get qfHideApps => 'Hide App List';

  @override
  String get qfAlgorithmicTracking => 'Algorithm Tracking';

  @override
  String get keywordManagement => 'Keyword Management';

  @override
  String get addKeyword => 'Add Keyword';

  @override
  String get keywordPlaceholder => 'Enter keyword...';

  @override
  String get noKeywords => 'No keywords';

  @override
  String get noData => 'No data';

  @override
  String get encrypt => 'Encrypt';

  @override
  String get decrypt => 'Decrypt';

  @override
  String get detailInfo => 'Detail Info';

  @override
  String get inputLabel => 'Input';

  @override
  String get outputLabel => 'Output';

  @override
  String get algorithmLabel => 'Algorithm';

  @override
  String get keyLabel => 'Key';

  @override
  String get ivLabel => 'IV Vector';

  @override
  String get stackLabel => 'Stack';

  @override
  String get plaintextLabel => 'Plaintext';

  @override
  String get hexLabel => 'HEX';

  @override
  String get base64Label => 'Base64';

  @override
  String get fingerprintLabel => 'Fingerprint';

  @override
  String get clear => 'Clear';

  @override
  String get clearConfirm =>
      'Are you sure you want to clear all algorithm tracking logs? This action cannot be undone.';

  @override
  String get searchPlaceholder => 'Search algorithm, content or stack...';

  @override
  String get visualRulesTab => 'Visual Rules';

  @override
  String get codeSourceTab => 'Code Source';

  @override
  String get noVisualRules => 'No visual rules configured';

  @override
  String get addRuleBtn => 'Add Intercept Rule';

  @override
  String get ruleConfig => 'Rule Configuration';

  @override
  String get targetFingerprint => 'Target Fingerprint';

  @override
  String get interceptDirection => 'Intercept Direction';

  @override
  String get directionInput => 'Pre-encryption (Input)';

  @override
  String get directionOutput => 'Post-decryption (Output)';

  @override
  String get specifyAlgorithm => 'Specify Algorithm';

  @override
  String get anyAlgorithm => 'Any Algorithm (All)';

  @override
  String get replaceData => 'Replace With (Plaintext)';

  @override
  String get replaceDataHint => 'Enter the data you want to mutate...';

  @override
  String get aiNotActivated => 'AI not activated. Please configure AI model.';

  @override
  String get aiSwitchSession => 'Switch Session';

  @override
  String get aiNewSession => 'New Session';

  @override
  String get aiSessionName => 'Session Name';

  @override
  String get aiSessionNameHint => 'Enter session name...';

  @override
  String get aiDeleteHistory => 'Clear History';

  @override
  String get aiDeleteConfirmTitle => 'Confirm Delete';

  @override
  String get aiDeleteConfirmContent =>
      'This will permanently delete all chat history for this app. Are you sure?';

  @override
  String get aiIdentifying => 'Identifying...';

  @override
  String get aiGetInfo => 'Fetching info...';

  @override
  String get aiChatInputHint => 'Ask me anything...';

  @override
  String get aiReverseSessionInitializingHint =>
      'Reverse session is initializing…';

  @override
  String get aiReverseSessionInitFailedHint =>
      'Reverse session initialization failed. Sending is unavailable.';

  @override
  String get aiReverseSessionInitializingBanner =>
      'Reverse session is initializing. Sending is disabled until it completes.';

  @override
  String get aiReverseSessionInitFailedBanner =>
      'Reverse session initialization failed. Sending is currently unavailable.';

  @override
  String get aiStopGeneration => 'Stop generation';

  @override
  String get aiCompressContext => 'Compress context';

  @override
  String get aiContext => 'Context';

  @override
  String get aiContextTitle => 'Context';

  @override
  String get aiContextBudget => 'Context budget';

  @override
  String get aiContextRemaining => 'Remaining budget';

  @override
  String get aiContextLayers => 'Assembled layers';

  @override
  String get aiContextRecentRounds => 'Recent raw rounds';

  @override
  String get aiContextCheckpoint => 'Latest checkpoint';

  @override
  String get aiContextNoCheckpoint => 'No checkpoint yet';

  @override
  String get aiContextCheckpointTime => 'Updated at';

  @override
  String get aiContextCheckpointPrompt => 'Latest user input';

  @override
  String get aiContextCheckpointMode => 'Recovery mode';

  @override
  String get aiContextLastError => 'Last error';

  @override
  String get aiContextNoError => 'No error';

  @override
  String get aiContextMigration => 'Session migration';

  @override
  String get aiContextMigrationDone => 'Migrated from legacy session';

  @override
  String get aiContextMigrationNone =>
      'This session already uses the new structure';

  @override
  String get aiContextCompression => 'Compression';

  @override
  String get aiContextCompactReasonBudget => 'Budget limit reached';

  @override
  String get aiContextCompactReasonManual => 'Manual compression';

  @override
  String get aiContextCompactReasonNone => 'No compression';

  @override
  String get aiContextToolTrace => 'Tool trace';

  @override
  String get aiContextToolTracePending => 'Pending tool phase exists';

  @override
  String get aiContextToolTraceClear => 'Tool chain is complete';

  @override
  String get aiContextMemory => 'Structured summary';

  @override
  String get aiContextGoals => 'User goals';

  @override
  String get aiContextFacts => 'Confirmed facts';

  @override
  String get aiContextHypotheses => 'Open hypotheses';

  @override
  String get aiContextFindings => 'Tool findings';

  @override
  String get aiContextTaskCurrent => 'Current step';

  @override
  String get aiContextTaskNext => 'Next step';

  @override
  String get aiContextTaskBlockers => 'Blockers / errors';

  @override
  String get aiViewSummary => 'View summary';

  @override
  String get aiSummaryTitle => 'Session summary';

  @override
  String get aiSummaryEmpty => 'No summary content is available yet.';

  @override
  String get aiContextCompressed => 'Context compressed';

  @override
  String get aiContextAlreadyCompact => 'Context is already compact';

  @override
  String get aiRetryLastTurn => 'Retry last turn';

  @override
  String get aiRetryInitialization => 'Retry initialization';

  @override
  String get aiContinue => 'Continue';

  @override
  String get aiResumeToolPhase => 'Resume tool phase';

  @override
  String get aiRecoveryModeRetry => 'Retry last turn';

  @override
  String get aiRecoveryModeContinue => 'Continue generation';

  @override
  String get aiRecoveryModeTool => 'Resume tool phase';

  @override
  String get aiUnavailableToSend => 'Unavailable';

  @override
  String get aiReverseTabChat => 'Chat';

  @override
  String get aiReverseTabAnalysis => 'Analysis';

  @override
  String get aiReverseOpenAnalysis => 'APK Files';

  @override
  String get aiReverseBackToChat => 'Back to chat';

  @override
  String get aiAssistantTitle => 'I am your AI Reverse Assistant';

  @override
  String get aiAssistantSubtitle =>
      'You can ask about manifest analysis, hardening detection, etc.';

  @override
  String get aiMessageSendFailed =>
      'Message failed to send. Please check your network or configuration.';

  @override
  String get aiCodeCopied => 'Code copied to clipboard';

  @override
  String get aiOneClickCopy => 'Copy Code';

  @override
  String get aiAnalyzeManifest => 'Analyze Manifest';

  @override
  String get aiHardeningDetection => 'Hardening Detection';

  @override
  String get aiExportInterfaces => 'Export Interfaces';

  @override
  String get aiFindHookPoints => 'Find Hook Points';

  @override
  String get aiTestConnecting => 'Testing connection...';

  @override
  String aiTestSuccess(Object result) {
    return 'Test successful! Received reply: \n$result';
  }

  @override
  String aiTestFailed(Object error) {
    return 'Test failed: $error';
  }

  @override
  String get aiSavingAndTesting => 'Saving and testing connectivity...';

  @override
  String aiSaveFailed(Object error) {
    return 'Save failed (Connection test failed): \n$error';
  }

  @override
  String aiShowMoreMessages(Object count) {
    return 'Show earlier messages ($count)';
  }

  @override
  String aiToolUnknown(String toolName) {
    return 'Unknown tool: $toolName';
  }

  @override
  String get aiToolCallFailed =>
      'Tool call failed. Please send keyword \'continue\' to retry';

  @override
  String get aiToolCalling => 'Calling tool...';

  @override
  String aiToolReading(String toolName) {
    return 'Reading $toolName...';
  }

  @override
  String get aiToolNameManifest => 'Manifest';

  @override
  String get aiToolNameDecompile => 'Decompile';

  @override
  String get aiToolNameSmali => 'Smali';

  @override
  String get aiToolNameSearch => 'Search';

  @override
  String get aiToolNamePackages => 'Packages';

  @override
  String get aiToolNameClasses => 'Classes';

  @override
  String get aiContinueKeyword => 'continue';

  @override
  String get projectCreate => 'Create';

  @override
  String projectCreated(Object name) {
    return 'Project created: $name';
  }

  @override
  String get projectName => 'Project Name';

  @override
  String get projectNameHint => 'Please enter project name';

  @override
  String get projectType => 'Project Type';

  @override
  String get newProject => 'Create Project';

  @override
  String get visualType => 'Visual';

  @override
  String get traditionalType => 'Traditional';

  @override
  String get xposedScripts => 'Xposed Scripts';

  @override
  String get projectNameEmpty => 'Project name cannot be empty';

  @override
  String get formatCode => 'Format Code';

  @override
  String get find => 'Find';

  @override
  String get replace => 'Replace';

  @override
  String get replaceWith => 'Replace with...';

  @override
  String get matchCase => 'Match Case';

  @override
  String get regex => 'Regex';

  @override
  String get prevMatch => 'Previous';

  @override
  String get nextMatch => 'Next';

  @override
  String get close => 'Close';

  @override
  String get replaceAll => 'Replace All';

  @override
  String get searchCode => 'Search code...';

  @override
  String get toggleReplace => 'Toggle Replace';

  @override
  String get aiConfigList => 'Config List';

  @override
  String get aiConfigNew => 'New';

  @override
  String get aiConfigCurrent => 'Current';

  @override
  String get aiConfigEmpty => 'No config yet, fill in the form below to save';

  @override
  String get aiConfigEditTitle => 'Edit Config';

  @override
  String get aiConfigNewTitle => 'New Config';

  @override
  String get aiConfigName => 'Config Name';

  @override
  String get aiConfigNameHint => 'e.g. OpenAI GPT-4';

  @override
  String get aiConfigSwitch => 'Switch to this config';

  @override
  String get aiConfigDelete => 'Delete config';

  @override
  String aiConfigDeleteConfirm(String name) {
    return 'Delete config \'$name\'?';
  }

  @override
  String get aiApiType => 'API Type';

  @override
  String get aiApiTypeOpenAI => 'OpenAI Compatible';

  @override
  String get aiApiTypeOpenAIResponses => 'OpenAI Responses';

  @override
  String get aiApiTypeAnthropic => 'Anthropic Claude';

  @override
  String get aiTutorial => 'Tutorial';

  @override
  String get aiBuiltinConfigName => 'PadiApi';

  @override
  String get aiBuiltinUseConfig => 'Use Built-in Endpoint';

  @override
  String get aiBuiltinSwitching => 'Switching to built-in default endpoint';

  @override
  String get aiApiKeyConfigured => 'API Key configured';

  @override
  String get aiApiKeyNotConfigured => 'API Key not configured';

  @override
  String get aiPadiModelLabel => 'Model';

  @override
  String get aiPadiReasoningLabel => 'Thinking';

  @override
  String get aiPadiEffortNone => 'Minimal';

  @override
  String get aiPadiEffortLow => 'Low';

  @override
  String get aiPadiEffortMedium => 'Medium';

  @override
  String get aiPadiEffortHigh => 'High';

  @override
  String get aiPadiEffortXHigh => 'Extreme';

  @override
  String get aiPadiOptionsExpand => 'Expand';

  @override
  String get aiPadiOptionsCollapse => 'Collapse';

  @override
  String aiCurrentStatus(String status) {
    return 'Status: $status';
  }

  @override
  String aiCurrentInterface(String name) {
    return 'Current endpoint: $name';
  }

  @override
  String get terminal => 'Terminal';

  @override
  String get terminalFilterHint => 'Secondary Filter...';

  @override
  String get autoScroll => 'Auto Scroll';

  @override
  String get clearPanel => 'Clear Panel';

  @override
  String get noLogs => 'No output yet';

  @override
  String get noLogsFiltered => 'No matching logs';

  @override
  String get logcatFullscreen => 'Fullscreen';

  @override
  String get apiManual => 'Manual';

  @override
  String get aiApiManualTitle => 'API AI Assistant';

  @override
  String get aiApiManualSubtitle => 'Ask me about JsxposedX API usage';

  @override
  String get visualEditorTab => 'Visual';

  @override
  String get codeEditorTab => 'Code';

  @override
  String get addBlock => 'Add Block';

  @override
  String get noBlocks => 'No hook blocks yet';

  @override
  String get noBlocksHint => 'Tap the button below to add your first block';

  @override
  String get blockHookMethod => 'Hook Method';

  @override
  String get blockHookMethodDesc =>
      'Hook a method with before/after/replace callback';

  @override
  String get blockHookConstructor => 'Hook Constructor';

  @override
  String get blockHookConstructorDesc => 'Hook a class constructor';

  @override
  String get blockReturnConst => 'Return Constant';

  @override
  String get blockReturnConstDesc =>
      'Force a method to return a constant value';

  @override
  String get blockLogParams => 'Log Params';

  @override
  String get blockLogParamsDesc =>
      'Log all parameters and return value of a method';

  @override
  String get blockSetField => 'Set Field';

  @override
  String get blockSetFieldDesc => 'Modify a field value (static or instance)';

  @override
  String get blockCustomCode => 'Custom Code';

  @override
  String get blockCustomCodeDesc => 'Write free-form JavaScript code';

  @override
  String get blockClassName => 'Class Name';

  @override
  String get blockClassNameHint => 'e.g. com.example.MyClass';

  @override
  String get blockMethodName => 'Method Name';

  @override
  String get blockMethodNameHint => 'e.g. login';

  @override
  String get blockParamTypes => 'Parameter Types';

  @override
  String get blockParamTypesHint =>
      'comma-separated, e.g. int, java.lang.String, boolean';

  @override
  String get blockTiming => 'Timing';

  @override
  String get blockTimingBefore => 'Before';

  @override
  String get blockTimingAfter => 'After';

  @override
  String get blockTimingReplace => 'Replace';

  @override
  String get blockConstValue => 'Return Value';

  @override
  String get blockConstValueHint => 'e.g. true';

  @override
  String get blockConstType => 'Value Type';

  @override
  String get blockFieldName => 'Field Name';

  @override
  String get blockFieldNameHint => 'e.g. isVip';

  @override
  String get blockFieldValue => 'Field Value';

  @override
  String get blockFieldValueHint => 'e.g. true';

  @override
  String get blockIsStaticField => 'Static Field';

  @override
  String get blockCustomJs => 'JavaScript Code';

  @override
  String get blockCustomJsHint => 'Jx.log(\"hello\");';

  @override
  String get blockSelectType => 'Select Block Type';

  @override
  String get blockHookBefore => 'Hook Before';

  @override
  String get blockHookAfter => 'Hook After';

  @override
  String get blockHookReplace => 'Hook Replace';

  @override
  String get blockBeforeConstructor => 'Before Constructor';

  @override
  String get blockAfterConstructor => 'After Constructor';

  @override
  String get blockLog => 'Log';

  @override
  String get blockLogException => 'Log Exception';

  @override
  String get blockConsoleLog => 'Console Log';

  @override
  String get blockStackTrace => 'Stack Trace';

  @override
  String get blockGetField => 'Get Field';

  @override
  String get blockGetInt => 'Get Int';

  @override
  String get blockSetInt => 'Set Int';

  @override
  String get blockGetBool => 'Get Bool';

  @override
  String get blockSetBool => 'Set Bool';

  @override
  String get blockGetArg => 'Get Arg';

  @override
  String get blockSetArg => 'Set Arg';

  @override
  String get blockGetResult => 'Get Result';

  @override
  String get blockSetResult => 'Set Result';

  @override
  String get blockCallMethod => 'Call Method';

  @override
  String get blockCallStatic => 'Call Static';

  @override
  String get blockNewInstance => 'New Instance';

  @override
  String get blockIf => 'If / Else';

  @override
  String get blockForLoop => 'For Loop';

  @override
  String get blockVarAssign => 'Variable';

  @override
  String get blockToast => 'Toast';

  @override
  String get blockGetApplication => 'Get Application';

  @override
  String get blockGetPackageName => 'Get Package Name';

  @override
  String get blockGetSharedPrefs => 'Get SharedPrefs';

  @override
  String get blockGetPrefString => 'Get Pref String';

  @override
  String get blockGetBuild => 'Get Build Info';

  @override
  String get blockStartActivity => 'Start Activity';

  @override
  String get blockFindClass => 'Find Class';

  @override
  String get blockMessage => 'Message';

  @override
  String get blockMessageHint => 'Log content';

  @override
  String get blockTag => 'Tag';

  @override
  String get blockTagHint => 'e.g. Net.request';

  @override
  String get blockValue => 'Value';

  @override
  String get blockValueHint => 'e.g. true';

  @override
  String get blockIndex => 'Index';

  @override
  String get blockIndexHint => 'e.g. 0';

  @override
  String get blockVarName => 'Var Name';

  @override
  String get blockVarNameHint => 'e.g. result';

  @override
  String get blockArgs => 'Args';

  @override
  String get blockArgsHint => 'comma-separated, e.g. arg0, \"hello\", 123';

  @override
  String get blockCondition => 'Condition';

  @override
  String get blockConditionHint => 'e.g. x > 0';

  @override
  String get blockFrom => 'From';

  @override
  String get blockFromHint => 'e.g. 0';

  @override
  String get blockTo => 'To';

  @override
  String get blockToHint => 'e.g. 10';

  @override
  String get blockConstTypeHint => 'Select type';

  @override
  String get blockPrefsName => 'Prefs Name';

  @override
  String get blockPrefsNameHint => 'e.g. app_config';

  @override
  String get blockPrefKey => 'Key';

  @override
  String get blockPrefKeyHint => 'e.g. token';

  @override
  String get blockSlotBody => 'Body';

  @override
  String get blockSlotBefore => 'Before';

  @override
  String get blockSlotAfter => 'After';

  @override
  String get blockSlotThen => 'Then';

  @override
  String get blockSlotElse => 'Else';

  @override
  String get blockConsoleWarn => 'Console Warn';

  @override
  String get blockConsoleError => 'Console Error';

  @override
  String get blockGetClassName => 'Get Class Name';

  @override
  String get blockCallMethodTyped => 'Call Method (Typed)';

  @override
  String get blockCallStaticAuto => 'Call Static (Auto)';

  @override
  String get blockNewInstanceTyped => 'New Instance (Typed)';

  @override
  String get blockGetPrefInt => 'Get Pref Int';

  @override
  String get blockGetPrefBool => 'Get Pref Bool';

  @override
  String get blockGetSystemProp => 'Get System Property';

  @override
  String get blockLoadClass => 'Load Class';

  @override
  String get blockHookAllMethods => 'Hook All Overloads';

  @override
  String get blockHookAllConstructors => 'Hook All Constructors';

  @override
  String get blockUnhook => 'Remove Hook';

  @override
  String get blockGetLong => 'Get Long';

  @override
  String get blockSetLong => 'Set Long';

  @override
  String get blockGetFloat => 'Get Float';

  @override
  String get blockSetFloat => 'Set Float';

  @override
  String get blockGetDouble => 'Get Double';

  @override
  String get blockSetDouble => 'Set Double';

  @override
  String get blockGetThrowable => 'Get Throwable';

  @override
  String get blockSetThrowable => 'Set Throwable';

  @override
  String get blockGetMethods => 'Get Methods';

  @override
  String get blockGetFields => 'Get Fields';

  @override
  String get blockInstanceOf => 'Instance Of';

  @override
  String get blockSetExtra => 'Set Extra Data';

  @override
  String get blockGetExtra => 'Get Extra Data';

  @override
  String get pickVariable => 'Pick Variable';

  @override
  String get contextVariables => 'Context Variables';

  @override
  String get userVariables => 'User Variables';

  @override
  String get noVariablesAvailable => 'No variables available';

  @override
  String get collapseAll => 'Collapse All';

  @override
  String get expandAll => 'Expand All';

  @override
  String get importScript => 'Import';

  @override
  String get selectScriptType => 'Select Script Type';

  @override
  String get traditionalScriptDesc => 'Traditional Hook Script';

  @override
  String get visualScriptDesc => 'Visual Script';

  @override
  String get saveScript => 'Save';

  @override
  String get exportScript => 'Export';

  @override
  String get scriptSaved => 'Script saved';

  @override
  String get scriptExported => 'Script exported';

  @override
  String get reservedScriptFileName =>
      'Reserved internal file name. Please use a different file name';

  @override
  String aiScriptSavedTo(String target, String name) {
    return 'Saved to $target: $name';
  }

  @override
  String aiScriptSaveFailed(String error) {
    return 'Save failed: $error';
  }

  @override
  String get manifestBasicInfo => 'Basic Info';

  @override
  String get manifestPackage => 'Package';

  @override
  String get manifestMinSdk => 'Min SDK';

  @override
  String get manifestTargetSdk => 'Target SDK';

  @override
  String get manifestDebuggable => 'Debuggable';

  @override
  String get manifestAllowBackup => 'Allow Backup';

  @override
  String manifestPermissions(int count) {
    return 'Permissions ($count)';
  }

  @override
  String get manifestNoPermissions => 'No permissions';

  @override
  String get manifestActivities => 'Activities';

  @override
  String get manifestServices => 'Services';

  @override
  String get manifestReceivers => 'Receivers';

  @override
  String get manifestProviders => 'Providers';

  @override
  String manifestNoItems(String name) {
    return 'No $name';
  }

  @override
  String get manifestExported => 'exported';

  @override
  String get apkNoAiSession => 'No AI session linked';

  @override
  String get apkAiAnalyze => 'AI Analyze';

  @override
  String apkSentToAi(String name) {
    return 'Sent to AI: analyzing $name';
  }

  @override
  String apkAnalyzeSmaliPrompt(String className) {
    return 'Please analyze the Smali code of $className, explain the logic and suggest possible Hook points.';
  }

  @override
  String apkAnalyzeJavaPrompt(String className) {
    return 'Please analyze the decompiled Java code of $className, explain the logic and suggest possible Hook points.';
  }

  @override
  String get undo => 'Undo';

  @override
  String get redo => 'Redo';

  @override
  String get sendToAi => 'Send to AI';

  @override
  String get pressBackAgainToExit => 'Press back again to exit';

  @override
  String apkAnalyzeSelectedCode(
    String className,
    String language,
    String code,
  ) {
    return 'The following is a $language code snippet from $className, please help me analyze it:\n\n$code';
  }

  @override
  String get dexSearchHint => 'Search class name...';

  @override
  String dexNoClassFound(String keyword) {
    return 'No class found containing \"$keyword\"';
  }

  @override
  String dexCopied(String name) {
    return 'Copied: $name';
  }

  @override
  String get dexCopyShortName => 'Copy Class Name';

  @override
  String get dexCopyFullName => 'Copy Fully Qualified Name';

  @override
  String get soAskAi => 'Ask AI';

  @override
  String soSentToAi(String name) {
    return 'Sent to AI: analyzing $name';
  }

  @override
  String get lsposedNotAvailable =>
      'LSPosed service unavailable. Make sure the module is activated in LSPosed and restart the app.';

  @override
  String lsposedAddingScope(String name) {
    return 'Requesting to add $name to scope...';
  }

  @override
  String lsposedScopeRequestedCheckNotification(String name) {
    return 'Scope request sent for $name. Check your notification bar to approve.';
  }

  @override
  String lsposedAddFailed(String name) {
    return 'Failed to add $name';
  }

  @override
  String get lsposedAddFailedService =>
      'Add failed: LSPosed service unavailable';
}
