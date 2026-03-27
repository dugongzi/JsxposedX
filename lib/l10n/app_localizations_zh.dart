// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'JSXPOSEDX';

  @override
  String get appSubtitle => '基于 Xposed Frida 的跨平台Hook调试工具';

  @override
  String get home => '首页';

  @override
  String get project => '项目';

  @override
  String get repository => '仓库';

  @override
  String get settings => '设置';

  @override
  String get language => '语言';

  @override
  String get theme => '主题';

  @override
  String get lightTheme => '浅色主题';

  @override
  String get darkTheme => '深色主题';

  @override
  String get chinese => '简体中文';

  @override
  String get english => 'English';

  @override
  String get confirm => '确认';

  @override
  String get cancel => '取消';

  @override
  String get save => '保存';

  @override
  String get delete => '删除';

  @override
  String get edit => '编辑';

  @override
  String get add => '添加';

  @override
  String get search => '搜索';

  @override
  String get loading => '加载中...';

  @override
  String get success => '成功';

  @override
  String get error => '错误';

  @override
  String get warning => '警告';

  @override
  String get info => '信息';

  @override
  String get hookStatus => 'Hook 状态';

  @override
  String get hookEnabled => 'Hook 已启用';

  @override
  String get hookDisabled => 'Hook 未启用';

  @override
  String get moduleInfo => '模块信息';

  @override
  String get version => '版本';

  @override
  String get about => '关于';

  @override
  String get community => '社区';

  @override
  String get officialCommunity => '获取教程与社区支持';

  @override
  String get forum => '论坛';

  @override
  String get visitForum => '进入论坛';

  @override
  String get joinDiscord => '加入 Discord';

  @override
  String get joinQQGroup => '加入 QQ 群';

  @override
  String get followAuthor => '关注作者';

  @override
  String get creatorPlatforms => '获取教程';

  @override
  String get morePlatforms => '查看更多平台';

  @override
  String pageNotFound(String error) {
    return '页面未找到: $error';
  }

  @override
  String get backToHome => '返回首页';

  @override
  String get retry => '重试';

  @override
  String get loadFailedMessage => '加载失败，请重试';

  @override
  String get activated => '已激活';

  @override
  String get notActivated => '未激活';

  @override
  String get fridaPartial => '局部';

  @override
  String get fridaGlobal => '全局';

  @override
  String get fridaUnknown => '未知';

  @override
  String get fridaNotInstalledShort => '未安装';

  @override
  String get fridaInitAbnormal => '初始化异常';

  @override
  String get fridaStatusEnabled => '已启用';

  @override
  String get fridaStatusDisabled => '已禁用';

  @override
  String get fridaTargetDisabled => '目标关闭';

  @override
  String get fridaEffective => '已生效';

  @override
  String get zygiskFridaModuleNotInstalled => 'Zygisk Frida 模块未安装';

  @override
  String get systemVersion => '系统版本';

  @override
  String get sdkVersion => 'SDK版本';

  @override
  String get deviceModel => '设备型号';

  @override
  String get systemStorage => '系统存储';

  @override
  String get cpuArchitecture => 'CPU架构';

  @override
  String get frameworkPackageName => '框架包名';

  @override
  String get copy => '复制';

  @override
  String get selectAll => '全选';

  @override
  String get cut => '剪切';

  @override
  String get paste => '粘贴';

  @override
  String get comment => '注释';

  @override
  String get codeCopied => '代码已复制到剪贴板';

  @override
  String get totalStorage => '总存';

  @override
  String get available => '可用';

  @override
  String get softwareIcon => '软件图标';

  @override
  String get needRootPermission => '你必须授予Root权限';

  @override
  String get pleaseActivateXposed => '请先激活Xposed,随意勾选一个模块即可';

  @override
  String get initFrida => '初始化Frida';

  @override
  String get homeTitleAI => 'AI';

  @override
  String get homeTitleRoot => 'Root';

  @override
  String get homeTitleXposed => 'Xposed';

  @override
  String get homeTitleFrida => 'Frida';

  @override
  String get themeColor => '主题配色';

  @override
  String get selectThemeColor => '选择皮肤颜色';

  @override
  String get aiConfig => 'AI 配置';

  @override
  String get aiConfigTitle => 'AI 设置';

  @override
  String get aiBaseUrl => 'API 地址';

  @override
  String get aiBaseUrlHint => '请输入 API 地址';

  @override
  String get aiApiKeyHint => '请输入 API Key';

  @override
  String get aiMaxTokens => '最大 Token';

  @override
  String get aiMaxTokensHint => '请输入最大 Token 数量';

  @override
  String get aiModelName => '模型名称';

  @override
  String get aiModelNameHint => '请输入模型名称';

  @override
  String get aiTemperature => '温度 (Temperature)';

  @override
  String get aiMemoryRounds => '对话记忆轮数';

  @override
  String cannotBeEmpty(Object field) {
    return '$field不能为空';
  }

  @override
  String get saveSuccess => '保存成功';

  @override
  String get test => '测试';

  @override
  String get selectApp => '选择应用';

  @override
  String get showSystemApps => '显示系统应用';

  @override
  String get searchAppsPlaceholder => '全局搜索应用名称或包名...';

  @override
  String loadedCount(int loaded, int total) {
    return '加载: $loaded / 符合: $total';
  }

  @override
  String get systemAppLabel => '系统';

  @override
  String alreadySelected(Object name) {
    return '已选择: $name';
  }

  @override
  String get notice => '公告';

  @override
  String get updateAvailableTitle => '发现新版本';

  @override
  String get updateContentTitle => '更新内容';

  @override
  String get updateNow => '立即更新';

  @override
  String get updateContentFallback => '• 修复已知问题\n• 优化用户体验\n• 提升应用性能';

  @override
  String get noRelatedApps => '没有找到相关应用';

  @override
  String get projectListEmpty => '暂无项目，去首页创建一个吧';

  @override
  String projectLoadFailed(Object error) {
    return '加载失败: $error';
  }

  @override
  String get confirmDelete => '确认删除?';

  @override
  String get xposedProject => 'Xposed 项目';

  @override
  String get fridaProject => 'Frida 项目';

  @override
  String get quickFunctions => '快捷功能';

  @override
  String get aiReverse => 'AI 逆向';

  @override
  String get qfPageTitle => '快捷功能';

  @override
  String get qfSectionBasic => '基础功能';

  @override
  String get qfSectionEnv => '环境功能';

  @override
  String get qfSectionCrypto => '加密分析';

  @override
  String get qfRemoveDialogs => '去除弹窗';

  @override
  String get qfRemoveScreenshotDetection => '去除截屏/录屏检测';

  @override
  String get qfRemoveCaptureDetection => '去除抓包检测';

  @override
  String get qfInjectTip => '注入提示';

  @override
  String get qfModifiedVersion => '去除更新';

  @override
  String get qfHideXposed => '隐藏 Xposed';

  @override
  String get qfHideRoot => '隐藏 Root';

  @override
  String get qfHideApps => '隐藏应用列表';

  @override
  String get qfAlgorithmicTracking => '算法追踪';

  @override
  String get keywordManagement => '关键词管理';

  @override
  String get addKeyword => '添加关键词';

  @override
  String get keywordPlaceholder => '输入关键词...';

  @override
  String get noKeywords => '暂无关键词';

  @override
  String get noData => '暂无数据';

  @override
  String get encrypt => '加密';

  @override
  String get decrypt => '解密';

  @override
  String get detailInfo => '详情信息';

  @override
  String get inputLabel => '输入';

  @override
  String get outputLabel => '输出';

  @override
  String get algorithmLabel => '算法';

  @override
  String get keyLabel => '密钥';

  @override
  String get ivLabel => 'IV 向量';

  @override
  String get stackLabel => '方法堆栈';

  @override
  String get plaintextLabel => '明文';

  @override
  String get hexLabel => 'HEX';

  @override
  String get base64Label => 'Base64';

  @override
  String get fingerprintLabel => '指纹';

  @override
  String get clear => '清空';

  @override
  String get clearConfirm => '确定要清空所有算法追踪日志吗？此操作不可恢复。';

  @override
  String get searchPlaceholder => '搜索算法、内容或堆栈...';

  @override
  String get visualRulesTab => '可视化规则 (Visual)';

  @override
  String get codeSourceTab => '底层源码 (Code)';

  @override
  String get noVisualRules => '暂无可视化规则';

  @override
  String get addRuleBtn => '添加新拦截规则';

  @override
  String get ruleConfig => '拦截配置项';

  @override
  String get targetFingerprint => '目标指纹 (Fingerprint)';

  @override
  String get interceptDirection => '拦截方向 (Direction)';

  @override
  String get directionInput => '加密前 (Input)';

  @override
  String get directionOutput => '解密后 (Output)';

  @override
  String get specifyAlgorithm => '指定算法 (可选)';

  @override
  String get anyAlgorithm => '全部算法 (Any)';

  @override
  String get replaceData => '替换为 (明文)';

  @override
  String get replaceDataHint => '填入你期望篡改的数据...';

  @override
  String get aiNotActivated => 'AI未激活，请先配置AI大模型';

  @override
  String get aiSwitchSession => '切换会话';

  @override
  String get aiNewSession => '新建会话';

  @override
  String get aiSessionName => '会话名称';

  @override
  String get aiSessionNameHint => '请输入会话名称...';

  @override
  String get aiDeleteHistory => '清除历史';

  @override
  String get aiDeleteConfirmTitle => '确认删除';

  @override
  String get aiDeleteConfirmContent => '这将永久删除该应用的所有聊天记录，确定吗？';

  @override
  String get aiIdentifying => '正在识别...';

  @override
  String get aiGetInfo => '正在获取信息...';

  @override
  String get aiChatInputHint => '有问题尽管问我...';

  @override
  String get aiReverseSessionInitializingHint => '逆向会话初始化中…';

  @override
  String get aiReverseSessionInitFailedHint => '逆向会话初始化失败，当前不可发送';

  @override
  String get aiReverseSessionInitializingBanner => '逆向会话初始化中，完成前将阻止发送。';

  @override
  String get aiReverseSessionInitFailedBanner => '逆向会话初始化失败，当前不可发送。';

  @override
  String get aiStopGeneration => '停止生成';

  @override
  String get aiRetryLastTurn => '重试上一轮';

  @override
  String get aiRetryInitialization => '重试初始化';

  @override
  String get aiUnavailableToSend => '不可发送';

  @override
  String get aiReverseTabChat => '对话';

  @override
  String get aiReverseTabAnalysis => '分析';

  @override
  String get aiReverseOpenAnalysis => 'APK目录';

  @override
  String get aiReverseBackToChat => '返回对话';

  @override
  String get aiAssistantTitle => '我是你的 AI 逆向助手';

  @override
  String get aiAssistantSubtitle => '您可以询问清单分析、加固检测等专业问题';

  @override
  String get aiMessageSendFailed => '消息发送失败，请检查网络或配置';

  @override
  String get aiCodeCopied => '代码已复制到剪贴板';

  @override
  String get aiOneClickCopy => '一键复制';

  @override
  String get aiAnalyzeManifest => '分析 Manifest';

  @override
  String get aiHardeningDetection => '加固检测';

  @override
  String get aiExportInterfaces => '导出接口';

  @override
  String get aiFindHookPoints => '寻找 Hook 点';

  @override
  String get aiTestConnecting => '正在测试连接...';

  @override
  String aiTestSuccess(Object result) {
    return '测试成功！收到回复: \n$result';
  }

  @override
  String aiTestFailed(Object error) {
    return '测试失败: $error';
  }

  @override
  String get aiSavingAndTesting => '正在保存并测试连通性...';

  @override
  String aiSaveFailed(Object error) {
    return '配置保存失败（连接测试未通过）: \n$error';
  }

  @override
  String aiShowMoreMessages(Object count) {
    return '显示更早的消息 ($count)';
  }

  @override
  String aiToolUnknown(String toolName) {
    return '未知工具: $toolName';
  }

  @override
  String get aiToolCallFailed => '工具调用失败，请发送关键词\"继续\"重试';

  @override
  String get aiToolCalling => '正在调用工具...';

  @override
  String aiToolReading(String toolName) {
    return '正在读取 $toolName...';
  }

  @override
  String get aiToolNameManifest => '清单';

  @override
  String get aiToolNameDecompile => '反编译';

  @override
  String get aiToolNameSmali => 'Smali';

  @override
  String get aiToolNameSearch => '搜索';

  @override
  String get aiToolNamePackages => '包信息';

  @override
  String get aiToolNameClasses => '类信息';

  @override
  String get aiContinueKeyword => '继续';

  @override
  String get projectCreate => '创建';

  @override
  String projectCreated(Object name) {
    return '项目已创建: $name';
  }

  @override
  String get projectName => '项目名称';

  @override
  String get projectNameHint => '请输入项目名称';

  @override
  String get projectType => '项目类型';

  @override
  String get newProject => '创建项目';

  @override
  String get visualType => '可视化';

  @override
  String get traditionalType => '传统';

  @override
  String get xposedScripts => 'Xposed 脚本列表';

  @override
  String get projectNameEmpty => '项目名称不能为空';

  @override
  String get formatCode => '格式化代码';

  @override
  String get find => '查找';

  @override
  String get replace => '替换';

  @override
  String get replaceWith => '替换为...';

  @override
  String get matchCase => '区分大小写';

  @override
  String get regex => '正则表达式';

  @override
  String get prevMatch => '上一个';

  @override
  String get nextMatch => '下一个';

  @override
  String get close => '关闭';

  @override
  String get replaceAll => '全部替换';

  @override
  String get searchCode => '搜索代码...';

  @override
  String get toggleReplace => '切换替换模式';

  @override
  String get aiConfigList => '配置列表';

  @override
  String get aiConfigNew => '新建';

  @override
  String get aiConfigCurrent => '当前';

  @override
  String get aiConfigEmpty => '暂无配置，请填写下方表单保存';

  @override
  String get aiConfigEditTitle => '编辑配置';

  @override
  String get aiConfigNewTitle => '新建配置';

  @override
  String get aiConfigName => '配置名称';

  @override
  String get aiConfigNameHint => '例如：OpenAI GPT-4';

  @override
  String get aiConfigSwitch => '切换到此配置';

  @override
  String get aiConfigDelete => '删除配置';

  @override
  String aiConfigDeleteConfirm(String name) {
    return '确认删除 \'$name\' 配置？';
  }

  @override
  String get aiApiType => 'API 类型';

  @override
  String get aiApiTypeOpenAI => 'OpenAI';

  @override
  String get aiApiTypeAnthropic => 'Anthropic Claude';

  @override
  String get aiTutorial => '教程';

  @override
  String get terminal => '控制台';

  @override
  String get terminalFilterHint => '二次过滤...';

  @override
  String get autoScroll => '自动滚屏';

  @override
  String get clearPanel => '清空面板';

  @override
  String get noLogs => '暂无日志';

  @override
  String get noLogsFiltered => '过滤后无匹配';

  @override
  String get logcatFullscreen => '全屏';

  @override
  String get apiManual => '手册';

  @override
  String get aiApiManualTitle => 'API AI 助手';

  @override
  String get aiApiManualSubtitle => '向我提问 JsxposedX API 用法';

  @override
  String get visualEditorTab => '可视化';

  @override
  String get codeEditorTab => '代码';

  @override
  String get addBlock => '添加 Block';

  @override
  String get noBlocks => '暂无 Hook Block';

  @override
  String get noBlocksHint => '点击下方按钮添加第一个 Block';

  @override
  String get blockHookMethod => 'Hook 方法';

  @override
  String get blockHookMethodDesc => 'Hook 一个方法，支持 before/after/replace 回调';

  @override
  String get blockHookConstructor => 'Hook 构造函数';

  @override
  String get blockHookConstructorDesc => 'Hook 一个类的构造函数';

  @override
  String get blockReturnConst => '返回常量';

  @override
  String get blockReturnConstDesc => '强制方法返回一个固定值';

  @override
  String get blockLogParams => '打印参数';

  @override
  String get blockLogParamsDesc => '打印方法的所有参数和返回值';

  @override
  String get blockSetField => '修改字段';

  @override
  String get blockSetFieldDesc => '修改字段值（静态或实例）';

  @override
  String get blockCustomCode => '自定义代码';

  @override
  String get blockCustomCodeDesc => '编写自由 JavaScript 代码';

  @override
  String get blockClassName => '类名';

  @override
  String get blockClassNameHint => '如 com.example.MyClass';

  @override
  String get blockMethodName => '方法名';

  @override
  String get blockMethodNameHint => '如 login';

  @override
  String get blockParamTypes => '参数类型';

  @override
  String get blockParamTypesHint => '逗号分隔，如 int, java.lang.String, boolean';

  @override
  String get blockTiming => '时机';

  @override
  String get blockTimingBefore => '之前';

  @override
  String get blockTimingAfter => '之后';

  @override
  String get blockTimingReplace => '替换';

  @override
  String get blockConstValue => '返回值';

  @override
  String get blockConstValueHint => '如 true';

  @override
  String get blockConstType => '值类型';

  @override
  String get blockFieldName => '字段名';

  @override
  String get blockFieldNameHint => '如 isVip';

  @override
  String get blockFieldValue => '字段值';

  @override
  String get blockFieldValueHint => '如 true';

  @override
  String get blockIsStaticField => '静态字段';

  @override
  String get blockCustomJs => 'JavaScript 代码';

  @override
  String get blockCustomJsHint => 'Jx.log(\"hello\");';

  @override
  String get blockSelectType => '选择 Block 类型';

  @override
  String get blockHookBefore => 'Hook Before';

  @override
  String get blockHookAfter => 'Hook After';

  @override
  String get blockHookReplace => 'Hook Replace';

  @override
  String get blockBeforeConstructor => '构造前';

  @override
  String get blockAfterConstructor => '构造后';

  @override
  String get blockLog => '日志';

  @override
  String get blockLogException => '异常日志';

  @override
  String get blockConsoleLog => 'Console 日志';

  @override
  String get blockStackTrace => '调用栈';

  @override
  String get blockGetField => '读取字段';

  @override
  String get blockGetInt => '读取 Int';

  @override
  String get blockSetInt => '设置 Int';

  @override
  String get blockGetBool => '读取 Bool';

  @override
  String get blockSetBool => '设置 Bool';

  @override
  String get blockGetArg => '获取参数';

  @override
  String get blockSetArg => '修改参数';

  @override
  String get blockGetResult => '获取返回值';

  @override
  String get blockSetResult => '修改返回值';

  @override
  String get blockCallMethod => '调用方法';

  @override
  String get blockCallStatic => '调用静态方法';

  @override
  String get blockNewInstance => '创建实例';

  @override
  String get blockIf => '条件判断';

  @override
  String get blockForLoop => '循环';

  @override
  String get blockVarAssign => '变量赋值';

  @override
  String get blockToast => 'Toast 提示';

  @override
  String get blockGetApplication => '获取 Application';

  @override
  String get blockGetPackageName => '获取包名';

  @override
  String get blockGetSharedPrefs => '获取 SharedPrefs';

  @override
  String get blockGetPrefString => '读取 Pref 字符串';

  @override
  String get blockGetBuild => '获取 Build 信息';

  @override
  String get blockStartActivity => '启动 Activity';

  @override
  String get blockFindClass => '查找类';

  @override
  String get blockMessage => '消息';

  @override
  String get blockMessageHint => '日志内容';

  @override
  String get blockTag => '标签';

  @override
  String get blockTagHint => '如 Net.request';

  @override
  String get blockValue => '值';

  @override
  String get blockValueHint => '如 true';

  @override
  String get blockIndex => '索引';

  @override
  String get blockIndexHint => '如 0';

  @override
  String get blockVarName => '变量名';

  @override
  String get blockVarNameHint => '如 result';

  @override
  String get blockArgs => '参数';

  @override
  String get blockArgsHint => '逗号分隔，如 arg0, \"hello\", 123';

  @override
  String get blockCondition => '条件';

  @override
  String get blockConditionHint => '如 x > 0';

  @override
  String get blockFrom => '起始';

  @override
  String get blockFromHint => '如 0';

  @override
  String get blockTo => '结束';

  @override
  String get blockToHint => '如 10';

  @override
  String get blockConstTypeHint => '选择类型';

  @override
  String get blockPrefsName => 'Prefs 名';

  @override
  String get blockPrefsNameHint => '如 app_config';

  @override
  String get blockPrefKey => 'Key';

  @override
  String get blockPrefKeyHint => '如 token';

  @override
  String get blockSlotBody => '执行体';

  @override
  String get blockSlotBefore => '之前';

  @override
  String get blockSlotAfter => '之后';

  @override
  String get blockSlotThen => '满足条件';

  @override
  String get blockSlotElse => '否则';

  @override
  String get blockConsoleWarn => 'Console 警告';

  @override
  String get blockConsoleError => 'Console 错误';

  @override
  String get blockGetClassName => '获取类名';

  @override
  String get blockCallMethodTyped => '调用方法 (指定类型)';

  @override
  String get blockCallStaticAuto => '调用静态方法 (自动推断)';

  @override
  String get blockNewInstanceTyped => '创建实例 (指定类型)';

  @override
  String get blockGetPrefInt => '读取 Pref 整数';

  @override
  String get blockGetPrefBool => '读取 Pref 布尔';

  @override
  String get blockGetSystemProp => '获取系统属性';

  @override
  String get blockLoadClass => '加载类';

  @override
  String get blockHookAllMethods => 'Hook 所有重载';

  @override
  String get blockHookAllConstructors => 'Hook 所有构造';

  @override
  String get blockUnhook => '移除 Hook';

  @override
  String get blockGetLong => '读取 Long';

  @override
  String get blockSetLong => '设置 Long';

  @override
  String get blockGetFloat => '读取 Float';

  @override
  String get blockSetFloat => '设置 Float';

  @override
  String get blockGetDouble => '读取 Double';

  @override
  String get blockSetDouble => '设置 Double';

  @override
  String get blockGetThrowable => '获取异常';

  @override
  String get blockSetThrowable => '设置异常';

  @override
  String get blockGetMethods => '获取方法列表';

  @override
  String get blockGetFields => '获取字段列表';

  @override
  String get blockInstanceOf => '类型检查';

  @override
  String get blockSetExtra => '设置附加数据';

  @override
  String get blockGetExtra => '获取附加数据';

  @override
  String get pickVariable => '选择变量';

  @override
  String get contextVariables => '上下文变量';

  @override
  String get userVariables => '用户变量';

  @override
  String get noVariablesAvailable => '暂无可用变量';

  @override
  String get collapseAll => '全部折叠';

  @override
  String get expandAll => '全部展开';

  @override
  String get importScript => '导入';

  @override
  String get selectScriptType => '选择脚本类型';

  @override
  String get traditionalScriptDesc => '传统Hook脚本';

  @override
  String get visualScriptDesc => '可视化脚本';

  @override
  String get saveScript => '保存';

  @override
  String get exportScript => '导出';

  @override
  String get scriptSaved => '脚本已保存';

  @override
  String get scriptExported => '脚本已导出';

  @override
  String get reservedScriptFileName => '内部保留文件名，请更换文件名';

  @override
  String aiScriptSavedTo(String target, String name) {
    return '已保存到 $target: $name';
  }

  @override
  String aiScriptSaveFailed(String error) {
    return '保存失败: $error';
  }

  @override
  String get manifestBasicInfo => '基本信息';

  @override
  String get manifestPackage => '包名';

  @override
  String get manifestMinSdk => '最低 SDK';

  @override
  String get manifestTargetSdk => '目标 SDK';

  @override
  String get manifestDebuggable => '可调试';

  @override
  String get manifestAllowBackup => '允许备份';

  @override
  String manifestPermissions(int count) {
    return '权限 ($count)';
  }

  @override
  String get manifestNoPermissions => '无权限';

  @override
  String get manifestActivities => 'Activity';

  @override
  String get manifestServices => 'Service';

  @override
  String get manifestReceivers => 'Receiver';

  @override
  String get manifestProviders => 'Provider';

  @override
  String manifestNoItems(String name) {
    return '无 $name';
  }

  @override
  String get manifestExported => '已导出';

  @override
  String get apkNoAiSession => '未关联 AI 分析会话';

  @override
  String get apkAiAnalyze => 'AI分析';

  @override
  String apkSentToAi(String name) {
    return '已发送到 AI：分析 $name';
  }

  @override
  String apkAnalyzeSmaliPrompt(String className) {
    return '请分析 $className 的 Smali 代码，解释逻辑并给出可能的 Hook 点。';
  }

  @override
  String apkAnalyzeJavaPrompt(String className) {
    return '请分析 $className 的反编译 Java 代码，解释逻辑并给出可能的 Hook 点。';
  }

  @override
  String get undo => '撤销';

  @override
  String get redo => '重做';

  @override
  String get sendToAi => '发送给AI';

  @override
  String get pressBackAgainToExit => '再按一次返回退出';

  @override
  String apkAnalyzeSelectedCode(
    String className,
    String language,
    String code,
  ) {
    return '以下是 $className 的 $language 代码片段，请帮我分析：\n\n$code';
  }

  @override
  String get dexSearchHint => '搜索类名...';

  @override
  String dexNoClassFound(String keyword) {
    return '未找到包含 \"$keyword\" 的类';
  }

  @override
  String dexCopied(String name) {
    return '已复制: $name';
  }

  @override
  String get dexCopyShortName => '复制类名';

  @override
  String get dexCopyFullName => '复制全限定类名';

  @override
  String get soAskAi => '询问AI';

  @override
  String soSentToAi(String name) {
    return '已发送给 AI：分析 $name';
  }

  @override
  String get lsposedNotAvailable => 'LSPosed 服务不可用，请确保模块已在 LSPosed 中激活并重启应用';

  @override
  String lsposedAddingScope(String name) {
    return '正在请求添加 $name 到作用域...';
  }

  @override
  String lsposedScopeRequestedCheckNotification(String name) {
    return '已请求添加 $name 到作用域，请查看通知栏并允许';
  }

  @override
  String lsposedAddFailed(String name) {
    return '添加 $name 失败';
  }

  @override
  String get lsposedAddFailedService => '添加失败: LSPosed 服务不可用';
}
