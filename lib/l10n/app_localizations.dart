import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// 应用名称
  ///
  /// In zh, this message translates to:
  /// **'JSXPOSEDX'**
  String get appName;

  /// 应用副标题
  ///
  /// In zh, this message translates to:
  /// **'基于 Xposed Frida 的跨平台Hook调试工具'**
  String get appSubtitle;

  /// 首页标题
  ///
  /// In zh, this message translates to:
  /// **'首页'**
  String get home;

  /// 项目
  ///
  /// In zh, this message translates to:
  /// **'项目'**
  String get project;

  /// 仓库
  ///
  /// In zh, this message translates to:
  /// **'仓库'**
  String get repository;

  /// 设置页面
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings;

  /// 语言设置
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get language;

  /// 主题设置
  ///
  /// In zh, this message translates to:
  /// **'主题'**
  String get theme;

  /// 浅色主题
  ///
  /// In zh, this message translates to:
  /// **'浅色主题'**
  String get lightTheme;

  /// 深色主题
  ///
  /// In zh, this message translates to:
  /// **'深色主题'**
  String get darkTheme;

  /// 中文
  ///
  /// In zh, this message translates to:
  /// **'简体中文'**
  String get chinese;

  /// 英文
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get english;

  /// 确认按钮
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get confirm;

  /// 取消按钮
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// 保存按钮
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save;

  /// 删除按钮
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// 编辑按钮
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get edit;

  /// 添加按钮
  ///
  /// In zh, this message translates to:
  /// **'添加'**
  String get add;

  /// 搜索
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get search;

  /// 加载提示
  ///
  /// In zh, this message translates to:
  /// **'加载中...'**
  String get loading;

  /// 成功提示
  ///
  /// In zh, this message translates to:
  /// **'成功'**
  String get success;

  /// 错误提示
  ///
  /// In zh, this message translates to:
  /// **'错误'**
  String get error;

  /// 警告提示
  ///
  /// In zh, this message translates to:
  /// **'警告'**
  String get warning;

  /// 信息提示
  ///
  /// In zh, this message translates to:
  /// **'信息'**
  String get info;

  /// Hook状态
  ///
  /// In zh, this message translates to:
  /// **'Hook 状态'**
  String get hookStatus;

  /// Hook已启用
  ///
  /// In zh, this message translates to:
  /// **'Hook 已启用'**
  String get hookEnabled;

  /// Hook未启用
  ///
  /// In zh, this message translates to:
  /// **'Hook 未启用'**
  String get hookDisabled;

  /// 模块信息
  ///
  /// In zh, this message translates to:
  /// **'模块信息'**
  String get moduleInfo;

  /// 版本号
  ///
  /// In zh, this message translates to:
  /// **'版本'**
  String get version;

  /// 关于页面
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get about;

  /// 社区分组标题
  ///
  /// In zh, this message translates to:
  /// **'社区'**
  String get community;

  /// 官方社区说明
  ///
  /// In zh, this message translates to:
  /// **'获取教程与社区支持'**
  String get officialCommunity;

  /// 论坛
  ///
  /// In zh, this message translates to:
  /// **'论坛'**
  String get forum;

  /// 进入论坛按钮
  ///
  /// In zh, this message translates to:
  /// **'进入论坛'**
  String get visitForum;

  /// 加入 Discord 按钮
  ///
  /// In zh, this message translates to:
  /// **'加入 Discord'**
  String get joinDiscord;

  /// 加入 QQ 群按钮
  ///
  /// In zh, this message translates to:
  /// **'加入 QQ 群'**
  String get joinQQGroup;

  /// 关注作者分组标题
  ///
  /// In zh, this message translates to:
  /// **'关注作者'**
  String get followAuthor;

  /// 作者平台入口
  ///
  /// In zh, this message translates to:
  /// **'获取教程'**
  String get creatorPlatforms;

  /// 查看更多平台
  ///
  /// In zh, this message translates to:
  /// **'查看更多平台'**
  String get morePlatforms;

  /// 404页面标题
  ///
  /// In zh, this message translates to:
  /// **'页面未找到: {error}'**
  String pageNotFound(String error);

  /// 返回首页按钮
  ///
  /// In zh, this message translates to:
  /// **'返回首页'**
  String get backToHome;

  /// 重试按钮
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get retry;

  /// 加载失败提示
  ///
  /// In zh, this message translates to:
  /// **'加载失败，请重试'**
  String get loadFailedMessage;

  /// 已激活状态
  ///
  /// In zh, this message translates to:
  /// **'已激活'**
  String get activated;

  /// 未激活状态
  ///
  /// In zh, this message translates to:
  /// **'未激活'**
  String get notActivated;

  /// Frida 局部状态
  ///
  /// In zh, this message translates to:
  /// **'局部'**
  String get fridaPartial;

  /// Frida 全局状态
  ///
  /// In zh, this message translates to:
  /// **'全局'**
  String get fridaGlobal;

  /// 未知状态
  ///
  /// In zh, this message translates to:
  /// **'未知'**
  String get fridaUnknown;

  /// Frida 未安装简短状态
  ///
  /// In zh, this message translates to:
  /// **'未安装'**
  String get fridaNotInstalledShort;

  /// Frida 初始化异常状态
  ///
  /// In zh, this message translates to:
  /// **'初始化异常'**
  String get fridaInitAbnormal;

  /// Frida 启用状态
  ///
  /// In zh, this message translates to:
  /// **'已启用'**
  String get fridaStatusEnabled;

  /// Frida 禁用状态
  ///
  /// In zh, this message translates to:
  /// **'已禁用'**
  String get fridaStatusDisabled;

  /// Frida 目标关闭状态
  ///
  /// In zh, this message translates to:
  /// **'目标关闭'**
  String get fridaTargetDisabled;

  /// Frida 已生效状态
  ///
  /// In zh, this message translates to:
  /// **'已生效'**
  String get fridaEffective;

  /// Zygisk Frida 模块未安装提示
  ///
  /// In zh, this message translates to:
  /// **'Zygisk Frida 模块未安装'**
  String get zygiskFridaModuleNotInstalled;

  /// No description provided for @systemVersion.
  ///
  /// In zh, this message translates to:
  /// **'系统版本'**
  String get systemVersion;

  /// No description provided for @sdkVersion.
  ///
  /// In zh, this message translates to:
  /// **'SDK版本'**
  String get sdkVersion;

  /// No description provided for @deviceModel.
  ///
  /// In zh, this message translates to:
  /// **'设备型号'**
  String get deviceModel;

  /// No description provided for @systemStorage.
  ///
  /// In zh, this message translates to:
  /// **'系统存储'**
  String get systemStorage;

  /// No description provided for @cpuArchitecture.
  ///
  /// In zh, this message translates to:
  /// **'CPU架构'**
  String get cpuArchitecture;

  /// No description provided for @frameworkPackageName.
  ///
  /// In zh, this message translates to:
  /// **'框架包名'**
  String get frameworkPackageName;

  /// No description provided for @copy.
  ///
  /// In zh, this message translates to:
  /// **'复制'**
  String get copy;

  /// No description provided for @selectAll.
  ///
  /// In zh, this message translates to:
  /// **'全选'**
  String get selectAll;

  /// No description provided for @cut.
  ///
  /// In zh, this message translates to:
  /// **'剪切'**
  String get cut;

  /// No description provided for @paste.
  ///
  /// In zh, this message translates to:
  /// **'粘贴'**
  String get paste;

  /// No description provided for @comment.
  ///
  /// In zh, this message translates to:
  /// **'注释'**
  String get comment;

  /// No description provided for @codeCopied.
  ///
  /// In zh, this message translates to:
  /// **'代码已复制到剪贴板'**
  String get codeCopied;

  /// No description provided for @totalStorage.
  ///
  /// In zh, this message translates to:
  /// **'总存'**
  String get totalStorage;

  /// No description provided for @available.
  ///
  /// In zh, this message translates to:
  /// **'可用'**
  String get available;

  /// No description provided for @softwareIcon.
  ///
  /// In zh, this message translates to:
  /// **'软件图标'**
  String get softwareIcon;

  /// No description provided for @needRootPermission.
  ///
  /// In zh, this message translates to:
  /// **'你必须授予Root权限'**
  String get needRootPermission;

  /// No description provided for @pleaseActivateXposed.
  ///
  /// In zh, this message translates to:
  /// **'请先激活Xposed,随意勾选一个模块即可'**
  String get pleaseActivateXposed;

  /// No description provided for @initFrida.
  ///
  /// In zh, this message translates to:
  /// **'初始化Frida'**
  String get initFrida;

  /// No description provided for @homeTitleAI.
  ///
  /// In zh, this message translates to:
  /// **'AI'**
  String get homeTitleAI;

  /// No description provided for @homeTitleRoot.
  ///
  /// In zh, this message translates to:
  /// **'Root'**
  String get homeTitleRoot;

  /// No description provided for @homeTitleXposed.
  ///
  /// In zh, this message translates to:
  /// **'Xposed'**
  String get homeTitleXposed;

  /// No description provided for @homeTitleFrida.
  ///
  /// In zh, this message translates to:
  /// **'Frida'**
  String get homeTitleFrida;

  /// No description provided for @themeColor.
  ///
  /// In zh, this message translates to:
  /// **'主题配色'**
  String get themeColor;

  /// No description provided for @selectThemeColor.
  ///
  /// In zh, this message translates to:
  /// **'选择皮肤颜色'**
  String get selectThemeColor;

  /// No description provided for @aiConfig.
  ///
  /// In zh, this message translates to:
  /// **'AI 配置'**
  String get aiConfig;

  /// No description provided for @aiConfigTitle.
  ///
  /// In zh, this message translates to:
  /// **'AI 设置'**
  String get aiConfigTitle;

  /// No description provided for @aiBaseUrl.
  ///
  /// In zh, this message translates to:
  /// **'API 地址'**
  String get aiBaseUrl;

  /// No description provided for @aiBaseUrlHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入 API 地址'**
  String get aiBaseUrlHint;

  /// No description provided for @aiApiKeyHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入 API Key'**
  String get aiApiKeyHint;

  /// No description provided for @aiMaxTokens.
  ///
  /// In zh, this message translates to:
  /// **'最大 Token'**
  String get aiMaxTokens;

  /// No description provided for @aiMaxTokensHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入最大 Token 数量'**
  String get aiMaxTokensHint;

  /// No description provided for @aiModelName.
  ///
  /// In zh, this message translates to:
  /// **'模型名称'**
  String get aiModelName;

  /// No description provided for @aiModelNameHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入模型名称'**
  String get aiModelNameHint;

  /// No description provided for @aiTemperature.
  ///
  /// In zh, this message translates to:
  /// **'温度 (Temperature)'**
  String get aiTemperature;

  /// No description provided for @aiMemoryRounds.
  ///
  /// In zh, this message translates to:
  /// **'对话记忆轮数'**
  String get aiMemoryRounds;

  /// No description provided for @cannotBeEmpty.
  ///
  /// In zh, this message translates to:
  /// **'{field}不能为空'**
  String cannotBeEmpty(Object field);

  /// No description provided for @saveSuccess.
  ///
  /// In zh, this message translates to:
  /// **'保存成功'**
  String get saveSuccess;

  /// No description provided for @test.
  ///
  /// In zh, this message translates to:
  /// **'测试'**
  String get test;

  /// No description provided for @selectApp.
  ///
  /// In zh, this message translates to:
  /// **'选择应用'**
  String get selectApp;

  /// No description provided for @showSystemApps.
  ///
  /// In zh, this message translates to:
  /// **'显示系统应用'**
  String get showSystemApps;

  /// No description provided for @searchAppsPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'全局搜索应用名称或包名...'**
  String get searchAppsPlaceholder;

  /// No description provided for @loadedCount.
  ///
  /// In zh, this message translates to:
  /// **'加载: {loaded} / 符合: {total}'**
  String loadedCount(int loaded, int total);

  /// No description provided for @systemAppLabel.
  ///
  /// In zh, this message translates to:
  /// **'系统'**
  String get systemAppLabel;

  /// No description provided for @alreadySelected.
  ///
  /// In zh, this message translates to:
  /// **'已选择: {name}'**
  String alreadySelected(Object name);

  /// No description provided for @notice.
  ///
  /// In zh, this message translates to:
  /// **'公告'**
  String get notice;

  /// No description provided for @updateAvailableTitle.
  ///
  /// In zh, this message translates to:
  /// **'发现新版本'**
  String get updateAvailableTitle;

  /// No description provided for @updateContentTitle.
  ///
  /// In zh, this message translates to:
  /// **'更新内容'**
  String get updateContentTitle;

  /// No description provided for @updateNow.
  ///
  /// In zh, this message translates to:
  /// **'立即更新'**
  String get updateNow;

  /// No description provided for @updateContentFallback.
  ///
  /// In zh, this message translates to:
  /// **'• 修复已知问题\n• 优化用户体验\n• 提升应用性能'**
  String get updateContentFallback;

  /// No description provided for @noRelatedApps.
  ///
  /// In zh, this message translates to:
  /// **'没有找到相关应用'**
  String get noRelatedApps;

  /// No description provided for @projectListEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无项目，去首页创建一个吧'**
  String get projectListEmpty;

  /// No description provided for @projectLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败: {error}'**
  String projectLoadFailed(Object error);

  /// No description provided for @confirmDelete.
  ///
  /// In zh, this message translates to:
  /// **'确认删除?'**
  String get confirmDelete;

  /// No description provided for @xposedProject.
  ///
  /// In zh, this message translates to:
  /// **'Xposed 项目'**
  String get xposedProject;

  /// No description provided for @fridaProject.
  ///
  /// In zh, this message translates to:
  /// **'Frida 项目'**
  String get fridaProject;

  /// No description provided for @quickFunctions.
  ///
  /// In zh, this message translates to:
  /// **'快捷功能'**
  String get quickFunctions;

  /// No description provided for @aiReverse.
  ///
  /// In zh, this message translates to:
  /// **'AI 逆向'**
  String get aiReverse;

  /// No description provided for @qfPageTitle.
  ///
  /// In zh, this message translates to:
  /// **'快捷功能'**
  String get qfPageTitle;

  /// No description provided for @qfSectionBasic.
  ///
  /// In zh, this message translates to:
  /// **'基础功能'**
  String get qfSectionBasic;

  /// No description provided for @qfSectionEnv.
  ///
  /// In zh, this message translates to:
  /// **'环境功能'**
  String get qfSectionEnv;

  /// No description provided for @qfSectionCrypto.
  ///
  /// In zh, this message translates to:
  /// **'加密分析'**
  String get qfSectionCrypto;

  /// No description provided for @qfRemoveDialogs.
  ///
  /// In zh, this message translates to:
  /// **'去除弹窗'**
  String get qfRemoveDialogs;

  /// No description provided for @qfRemoveScreenshotDetection.
  ///
  /// In zh, this message translates to:
  /// **'去除截屏/录屏检测'**
  String get qfRemoveScreenshotDetection;

  /// No description provided for @qfRemoveCaptureDetection.
  ///
  /// In zh, this message translates to:
  /// **'去除抓包检测'**
  String get qfRemoveCaptureDetection;

  /// No description provided for @qfInjectTip.
  ///
  /// In zh, this message translates to:
  /// **'注入提示'**
  String get qfInjectTip;

  /// No description provided for @qfModifiedVersion.
  ///
  /// In zh, this message translates to:
  /// **'去除更新'**
  String get qfModifiedVersion;

  /// No description provided for @qfHideXposed.
  ///
  /// In zh, this message translates to:
  /// **'隐藏 Xposed'**
  String get qfHideXposed;

  /// No description provided for @qfHideRoot.
  ///
  /// In zh, this message translates to:
  /// **'隐藏 Root'**
  String get qfHideRoot;

  /// No description provided for @qfHideApps.
  ///
  /// In zh, this message translates to:
  /// **'隐藏应用列表'**
  String get qfHideApps;

  /// No description provided for @qfAlgorithmicTracking.
  ///
  /// In zh, this message translates to:
  /// **'算法追踪'**
  String get qfAlgorithmicTracking;

  /// No description provided for @keywordManagement.
  ///
  /// In zh, this message translates to:
  /// **'关键词管理'**
  String get keywordManagement;

  /// No description provided for @addKeyword.
  ///
  /// In zh, this message translates to:
  /// **'添加关键词'**
  String get addKeyword;

  /// No description provided for @keywordPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'输入关键词...'**
  String get keywordPlaceholder;

  /// No description provided for @noKeywords.
  ///
  /// In zh, this message translates to:
  /// **'暂无关键词'**
  String get noKeywords;

  /// No description provided for @noData.
  ///
  /// In zh, this message translates to:
  /// **'暂无数据'**
  String get noData;

  /// No description provided for @encrypt.
  ///
  /// In zh, this message translates to:
  /// **'加密'**
  String get encrypt;

  /// No description provided for @decrypt.
  ///
  /// In zh, this message translates to:
  /// **'解密'**
  String get decrypt;

  /// No description provided for @detailInfo.
  ///
  /// In zh, this message translates to:
  /// **'详情信息'**
  String get detailInfo;

  /// No description provided for @inputLabel.
  ///
  /// In zh, this message translates to:
  /// **'输入'**
  String get inputLabel;

  /// No description provided for @outputLabel.
  ///
  /// In zh, this message translates to:
  /// **'输出'**
  String get outputLabel;

  /// No description provided for @algorithmLabel.
  ///
  /// In zh, this message translates to:
  /// **'算法'**
  String get algorithmLabel;

  /// No description provided for @keyLabel.
  ///
  /// In zh, this message translates to:
  /// **'密钥'**
  String get keyLabel;

  /// No description provided for @ivLabel.
  ///
  /// In zh, this message translates to:
  /// **'IV 向量'**
  String get ivLabel;

  /// No description provided for @stackLabel.
  ///
  /// In zh, this message translates to:
  /// **'方法堆栈'**
  String get stackLabel;

  /// No description provided for @plaintextLabel.
  ///
  /// In zh, this message translates to:
  /// **'明文'**
  String get plaintextLabel;

  /// No description provided for @hexLabel.
  ///
  /// In zh, this message translates to:
  /// **'HEX'**
  String get hexLabel;

  /// No description provided for @base64Label.
  ///
  /// In zh, this message translates to:
  /// **'Base64'**
  String get base64Label;

  /// No description provided for @fingerprintLabel.
  ///
  /// In zh, this message translates to:
  /// **'指纹'**
  String get fingerprintLabel;

  /// No description provided for @clear.
  ///
  /// In zh, this message translates to:
  /// **'清空'**
  String get clear;

  /// No description provided for @clearConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要清空所有算法追踪日志吗？此操作不可恢复。'**
  String get clearConfirm;

  /// No description provided for @searchPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'搜索算法、内容或堆栈...'**
  String get searchPlaceholder;

  /// No description provided for @visualRulesTab.
  ///
  /// In zh, this message translates to:
  /// **'可视化规则 (Visual)'**
  String get visualRulesTab;

  /// No description provided for @codeSourceTab.
  ///
  /// In zh, this message translates to:
  /// **'底层源码 (Code)'**
  String get codeSourceTab;

  /// No description provided for @noVisualRules.
  ///
  /// In zh, this message translates to:
  /// **'暂无可视化规则'**
  String get noVisualRules;

  /// No description provided for @addRuleBtn.
  ///
  /// In zh, this message translates to:
  /// **'添加新拦截规则'**
  String get addRuleBtn;

  /// No description provided for @ruleConfig.
  ///
  /// In zh, this message translates to:
  /// **'拦截配置项'**
  String get ruleConfig;

  /// No description provided for @targetFingerprint.
  ///
  /// In zh, this message translates to:
  /// **'目标指纹 (Fingerprint)'**
  String get targetFingerprint;

  /// No description provided for @interceptDirection.
  ///
  /// In zh, this message translates to:
  /// **'拦截方向 (Direction)'**
  String get interceptDirection;

  /// No description provided for @directionInput.
  ///
  /// In zh, this message translates to:
  /// **'加密前 (Input)'**
  String get directionInput;

  /// No description provided for @directionOutput.
  ///
  /// In zh, this message translates to:
  /// **'解密后 (Output)'**
  String get directionOutput;

  /// No description provided for @specifyAlgorithm.
  ///
  /// In zh, this message translates to:
  /// **'指定算法 (可选)'**
  String get specifyAlgorithm;

  /// No description provided for @anyAlgorithm.
  ///
  /// In zh, this message translates to:
  /// **'全部算法 (Any)'**
  String get anyAlgorithm;

  /// No description provided for @replaceData.
  ///
  /// In zh, this message translates to:
  /// **'替换为 (明文)'**
  String get replaceData;

  /// No description provided for @replaceDataHint.
  ///
  /// In zh, this message translates to:
  /// **'填入你期望篡改的数据...'**
  String get replaceDataHint;

  /// No description provided for @aiNotActivated.
  ///
  /// In zh, this message translates to:
  /// **'AI未激活，请先配置AI大模型'**
  String get aiNotActivated;

  /// No description provided for @aiSwitchSession.
  ///
  /// In zh, this message translates to:
  /// **'切换会话'**
  String get aiSwitchSession;

  /// No description provided for @aiNewSession.
  ///
  /// In zh, this message translates to:
  /// **'新建会话'**
  String get aiNewSession;

  /// No description provided for @aiSessionName.
  ///
  /// In zh, this message translates to:
  /// **'会话名称'**
  String get aiSessionName;

  /// No description provided for @aiSessionNameHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入会话名称...'**
  String get aiSessionNameHint;

  /// No description provided for @aiDeleteHistory.
  ///
  /// In zh, this message translates to:
  /// **'清除历史'**
  String get aiDeleteHistory;

  /// No description provided for @aiDeleteConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'确认删除'**
  String get aiDeleteConfirmTitle;

  /// No description provided for @aiDeleteConfirmContent.
  ///
  /// In zh, this message translates to:
  /// **'这将永久删除该应用的所有聊天记录，确定吗？'**
  String get aiDeleteConfirmContent;

  /// No description provided for @aiIdentifying.
  ///
  /// In zh, this message translates to:
  /// **'正在识别...'**
  String get aiIdentifying;

  /// No description provided for @aiGetInfo.
  ///
  /// In zh, this message translates to:
  /// **'正在获取信息...'**
  String get aiGetInfo;

  /// No description provided for @aiChatInputHint.
  ///
  /// In zh, this message translates to:
  /// **'有问题尽管问我...'**
  String get aiChatInputHint;

  /// No description provided for @aiReverseSessionInitializingHint.
  ///
  /// In zh, this message translates to:
  /// **'逆向会话初始化中…'**
  String get aiReverseSessionInitializingHint;

  /// No description provided for @aiReverseSessionInitFailedHint.
  ///
  /// In zh, this message translates to:
  /// **'逆向会话初始化失败，当前不可发送'**
  String get aiReverseSessionInitFailedHint;

  /// No description provided for @aiReverseSessionInitializingBanner.
  ///
  /// In zh, this message translates to:
  /// **'逆向会话初始化中，完成前将阻止发送。'**
  String get aiReverseSessionInitializingBanner;

  /// No description provided for @aiReverseSessionInitFailedBanner.
  ///
  /// In zh, this message translates to:
  /// **'逆向会话初始化失败，当前不可发送。'**
  String get aiReverseSessionInitFailedBanner;

  /// No description provided for @aiStopGeneration.
  ///
  /// In zh, this message translates to:
  /// **'停止生成'**
  String get aiStopGeneration;

  /// No description provided for @aiCompressContext.
  ///
  /// In zh, this message translates to:
  /// **'压缩上下文'**
  String get aiCompressContext;

  /// No description provided for @aiContext.
  ///
  /// In zh, this message translates to:
  /// **'上下文'**
  String get aiContext;

  /// No description provided for @aiContextTitle.
  ///
  /// In zh, this message translates to:
  /// **'上下文'**
  String get aiContextTitle;

  /// No description provided for @aiContextBudget.
  ///
  /// In zh, this message translates to:
  /// **'上下文预算'**
  String get aiContextBudget;

  /// No description provided for @aiContextRemaining.
  ///
  /// In zh, this message translates to:
  /// **'剩余预算'**
  String get aiContextRemaining;

  /// No description provided for @aiContextLayers.
  ///
  /// In zh, this message translates to:
  /// **'装配层'**
  String get aiContextLayers;

  /// No description provided for @aiContextRecentRounds.
  ///
  /// In zh, this message translates to:
  /// **'最近原始轮次'**
  String get aiContextRecentRounds;

  /// No description provided for @aiContextCheckpoint.
  ///
  /// In zh, this message translates to:
  /// **'最近检查点'**
  String get aiContextCheckpoint;

  /// No description provided for @aiContextNoCheckpoint.
  ///
  /// In zh, this message translates to:
  /// **'暂无检查点'**
  String get aiContextNoCheckpoint;

  /// No description provided for @aiContextCheckpointTime.
  ///
  /// In zh, this message translates to:
  /// **'更新时间'**
  String get aiContextCheckpointTime;

  /// No description provided for @aiContextCheckpointPrompt.
  ///
  /// In zh, this message translates to:
  /// **'最近用户输入'**
  String get aiContextCheckpointPrompt;

  /// No description provided for @aiContextCheckpointMode.
  ///
  /// In zh, this message translates to:
  /// **'恢复模式'**
  String get aiContextCheckpointMode;

  /// No description provided for @aiContextLastError.
  ///
  /// In zh, this message translates to:
  /// **'最近错误'**
  String get aiContextLastError;

  /// No description provided for @aiContextNoError.
  ///
  /// In zh, this message translates to:
  /// **'暂无错误'**
  String get aiContextNoError;

  /// No description provided for @aiContextMigration.
  ///
  /// In zh, this message translates to:
  /// **'会话迁移'**
  String get aiContextMigration;

  /// No description provided for @aiContextMigrationDone.
  ///
  /// In zh, this message translates to:
  /// **'已从旧会话迁移'**
  String get aiContextMigrationDone;

  /// No description provided for @aiContextMigrationNone.
  ///
  /// In zh, this message translates to:
  /// **'当前会话已使用新结构'**
  String get aiContextMigrationNone;

  /// No description provided for @aiContextCompression.
  ///
  /// In zh, this message translates to:
  /// **'压缩状态'**
  String get aiContextCompression;

  /// No description provided for @aiContextCompactReasonBudget.
  ///
  /// In zh, this message translates to:
  /// **'达到预算上限'**
  String get aiContextCompactReasonBudget;

  /// No description provided for @aiContextCompactReasonManual.
  ///
  /// In zh, this message translates to:
  /// **'手动压缩'**
  String get aiContextCompactReasonManual;

  /// No description provided for @aiContextCompactReasonNone.
  ///
  /// In zh, this message translates to:
  /// **'未触发压缩'**
  String get aiContextCompactReasonNone;

  /// No description provided for @aiContextToolTrace.
  ///
  /// In zh, this message translates to:
  /// **'工具轨迹'**
  String get aiContextToolTrace;

  /// No description provided for @aiContextToolTracePending.
  ///
  /// In zh, this message translates to:
  /// **'存在未完成工具阶段'**
  String get aiContextToolTracePending;

  /// No description provided for @aiContextToolTraceClear.
  ///
  /// In zh, this message translates to:
  /// **'工具链完整'**
  String get aiContextToolTraceClear;

  /// No description provided for @aiContextMemory.
  ///
  /// In zh, this message translates to:
  /// **'结构化摘要'**
  String get aiContextMemory;

  /// No description provided for @aiContextGoals.
  ///
  /// In zh, this message translates to:
  /// **'用户目标'**
  String get aiContextGoals;

  /// No description provided for @aiContextFacts.
  ///
  /// In zh, this message translates to:
  /// **'已确认事实'**
  String get aiContextFacts;

  /// No description provided for @aiContextHypotheses.
  ///
  /// In zh, this message translates to:
  /// **'未确认假设'**
  String get aiContextHypotheses;

  /// No description provided for @aiContextFindings.
  ///
  /// In zh, this message translates to:
  /// **'工具发现'**
  String get aiContextFindings;

  /// No description provided for @aiContextTaskCurrent.
  ///
  /// In zh, this message translates to:
  /// **'当前步骤'**
  String get aiContextTaskCurrent;

  /// No description provided for @aiContextTaskNext.
  ///
  /// In zh, this message translates to:
  /// **'下一步'**
  String get aiContextTaskNext;

  /// No description provided for @aiContextTaskBlockers.
  ///
  /// In zh, this message translates to:
  /// **'阻塞/错误'**
  String get aiContextTaskBlockers;

  /// No description provided for @aiViewSummary.
  ///
  /// In zh, this message translates to:
  /// **'查看摘要'**
  String get aiViewSummary;

  /// No description provided for @aiSummaryTitle.
  ///
  /// In zh, this message translates to:
  /// **'会话摘要'**
  String get aiSummaryTitle;

  /// No description provided for @aiSummaryEmpty.
  ///
  /// In zh, this message translates to:
  /// **'当前还没有可展示的摘要内容'**
  String get aiSummaryEmpty;

  /// No description provided for @aiContextCompressed.
  ///
  /// In zh, this message translates to:
  /// **'已压缩上下文'**
  String get aiContextCompressed;

  /// No description provided for @aiContextAlreadyCompact.
  ///
  /// In zh, this message translates to:
  /// **'当前上下文已经较精简'**
  String get aiContextAlreadyCompact;

  /// No description provided for @aiRetryLastTurn.
  ///
  /// In zh, this message translates to:
  /// **'重试上一轮'**
  String get aiRetryLastTurn;

  /// No description provided for @aiRetryInitialization.
  ///
  /// In zh, this message translates to:
  /// **'重试初始化'**
  String get aiRetryInitialization;

  /// No description provided for @aiContinue.
  ///
  /// In zh, this message translates to:
  /// **'继续'**
  String get aiContinue;

  /// No description provided for @aiResumeToolPhase.
  ///
  /// In zh, this message translates to:
  /// **'恢复工具阶段'**
  String get aiResumeToolPhase;

  /// No description provided for @aiRecoveryModeRetry.
  ///
  /// In zh, this message translates to:
  /// **'重试上一轮'**
  String get aiRecoveryModeRetry;

  /// No description provided for @aiRecoveryModeContinue.
  ///
  /// In zh, this message translates to:
  /// **'继续生成'**
  String get aiRecoveryModeContinue;

  /// No description provided for @aiRecoveryModeTool.
  ///
  /// In zh, this message translates to:
  /// **'恢复工具阶段'**
  String get aiRecoveryModeTool;

  /// No description provided for @aiUnavailableToSend.
  ///
  /// In zh, this message translates to:
  /// **'不可发送'**
  String get aiUnavailableToSend;

  /// No description provided for @aiReverseTabChat.
  ///
  /// In zh, this message translates to:
  /// **'对话'**
  String get aiReverseTabChat;

  /// No description provided for @aiReverseTabAnalysis.
  ///
  /// In zh, this message translates to:
  /// **'分析'**
  String get aiReverseTabAnalysis;

  /// No description provided for @aiReverseOpenAnalysis.
  ///
  /// In zh, this message translates to:
  /// **'APK目录'**
  String get aiReverseOpenAnalysis;

  /// No description provided for @aiReverseBackToChat.
  ///
  /// In zh, this message translates to:
  /// **'返回对话'**
  String get aiReverseBackToChat;

  /// No description provided for @aiAssistantTitle.
  ///
  /// In zh, this message translates to:
  /// **'我是你的 AI 逆向助手'**
  String get aiAssistantTitle;

  /// No description provided for @aiAssistantSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'您可以询问清单分析、加固检测等专业问题'**
  String get aiAssistantSubtitle;

  /// No description provided for @aiMessageSendFailed.
  ///
  /// In zh, this message translates to:
  /// **'消息发送失败，请检查网络或配置'**
  String get aiMessageSendFailed;

  /// No description provided for @aiCodeCopied.
  ///
  /// In zh, this message translates to:
  /// **'代码已复制到剪贴板'**
  String get aiCodeCopied;

  /// No description provided for @aiOneClickCopy.
  ///
  /// In zh, this message translates to:
  /// **'一键复制'**
  String get aiOneClickCopy;

  /// No description provided for @aiBubbleActionsTitle.
  ///
  /// In zh, this message translates to:
  /// **'气泡操作'**
  String get aiBubbleActionsTitle;

  /// No description provided for @aiBubbleCopyCurrent.
  ///
  /// In zh, this message translates to:
  /// **'复制当前内容'**
  String get aiBubbleCopyCurrent;

  /// No description provided for @aiBubbleSelectText.
  ///
  /// In zh, this message translates to:
  /// **'选择文本'**
  String get aiBubbleSelectText;

  /// No description provided for @aiBubbleUserTextTitle.
  ///
  /// In zh, this message translates to:
  /// **'用户消息'**
  String get aiBubbleUserTextTitle;

  /// No description provided for @aiBubbleAssistantTextTitle.
  ///
  /// In zh, this message translates to:
  /// **'AI 回复'**
  String get aiBubbleAssistantTextTitle;

  /// No description provided for @aiBubbleThinkingTitle.
  ///
  /// In zh, this message translates to:
  /// **'思考过程'**
  String get aiBubbleThinkingTitle;

  /// No description provided for @aiBubbleAnswerTitle.
  ///
  /// In zh, this message translates to:
  /// **'回答内容'**
  String get aiBubbleAnswerTitle;

  /// No description provided for @aiAnalyzeManifest.
  ///
  /// In zh, this message translates to:
  /// **'分析 Manifest'**
  String get aiAnalyzeManifest;

  /// No description provided for @aiHardeningDetection.
  ///
  /// In zh, this message translates to:
  /// **'加固检测'**
  String get aiHardeningDetection;

  /// No description provided for @aiExportInterfaces.
  ///
  /// In zh, this message translates to:
  /// **'导出接口'**
  String get aiExportInterfaces;

  /// No description provided for @aiFindHookPoints.
  ///
  /// In zh, this message translates to:
  /// **'寻找 Hook 点'**
  String get aiFindHookPoints;

  /// No description provided for @aiTestConnecting.
  ///
  /// In zh, this message translates to:
  /// **'正在测试连接...'**
  String get aiTestConnecting;

  /// No description provided for @aiTestSuccess.
  ///
  /// In zh, this message translates to:
  /// **'测试成功！收到回复: \n{result}'**
  String aiTestSuccess(Object result);

  /// No description provided for @aiTestFailed.
  ///
  /// In zh, this message translates to:
  /// **'测试失败: {error}'**
  String aiTestFailed(Object error);

  /// No description provided for @aiSavingAndTesting.
  ///
  /// In zh, this message translates to:
  /// **'正在保存并测试连通性...'**
  String get aiSavingAndTesting;

  /// No description provided for @aiSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'配置保存失败（连接测试未通过）: \n{error}'**
  String aiSaveFailed(Object error);

  /// No description provided for @aiShowMoreMessages.
  ///
  /// In zh, this message translates to:
  /// **'显示更早的消息 ({count})'**
  String aiShowMoreMessages(Object count);

  /// No description provided for @aiToolUnknown.
  ///
  /// In zh, this message translates to:
  /// **'未知工具: {toolName}'**
  String aiToolUnknown(String toolName);

  /// No description provided for @aiToolCallFailed.
  ///
  /// In zh, this message translates to:
  /// **'工具调用失败，请发送关键词\"继续\"重试'**
  String get aiToolCallFailed;

  /// No description provided for @aiToolCalling.
  ///
  /// In zh, this message translates to:
  /// **'正在调用工具...'**
  String get aiToolCalling;

  /// No description provided for @aiToolReading.
  ///
  /// In zh, this message translates to:
  /// **'正在读取 {toolName}...'**
  String aiToolReading(String toolName);

  /// No description provided for @aiToolNameManifest.
  ///
  /// In zh, this message translates to:
  /// **'清单'**
  String get aiToolNameManifest;

  /// No description provided for @aiToolNameDecompile.
  ///
  /// In zh, this message translates to:
  /// **'反编译'**
  String get aiToolNameDecompile;

  /// No description provided for @aiToolNameSmali.
  ///
  /// In zh, this message translates to:
  /// **'Smali'**
  String get aiToolNameSmali;

  /// No description provided for @aiToolNameSearch.
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get aiToolNameSearch;

  /// No description provided for @aiToolNamePackages.
  ///
  /// In zh, this message translates to:
  /// **'包信息'**
  String get aiToolNamePackages;

  /// No description provided for @aiToolNameClasses.
  ///
  /// In zh, this message translates to:
  /// **'类信息'**
  String get aiToolNameClasses;

  /// No description provided for @aiContinueKeyword.
  ///
  /// In zh, this message translates to:
  /// **'继续'**
  String get aiContinueKeyword;

  /// No description provided for @projectCreate.
  ///
  /// In zh, this message translates to:
  /// **'创建'**
  String get projectCreate;

  /// No description provided for @projectCreated.
  ///
  /// In zh, this message translates to:
  /// **'项目已创建: {name}'**
  String projectCreated(Object name);

  /// No description provided for @projectName.
  ///
  /// In zh, this message translates to:
  /// **'项目名称'**
  String get projectName;

  /// No description provided for @projectNameHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入项目名称'**
  String get projectNameHint;

  /// No description provided for @projectType.
  ///
  /// In zh, this message translates to:
  /// **'项目类型'**
  String get projectType;

  /// No description provided for @newProject.
  ///
  /// In zh, this message translates to:
  /// **'创建项目'**
  String get newProject;

  /// No description provided for @visualType.
  ///
  /// In zh, this message translates to:
  /// **'可视化'**
  String get visualType;

  /// No description provided for @traditionalType.
  ///
  /// In zh, this message translates to:
  /// **'传统'**
  String get traditionalType;

  /// No description provided for @xposedScripts.
  ///
  /// In zh, this message translates to:
  /// **'Xposed 脚本列表'**
  String get xposedScripts;

  /// No description provided for @projectNameEmpty.
  ///
  /// In zh, this message translates to:
  /// **'项目名称不能为空'**
  String get projectNameEmpty;

  /// No description provided for @formatCode.
  ///
  /// In zh, this message translates to:
  /// **'格式化代码'**
  String get formatCode;

  /// No description provided for @find.
  ///
  /// In zh, this message translates to:
  /// **'查找'**
  String get find;

  /// No description provided for @replace.
  ///
  /// In zh, this message translates to:
  /// **'替换'**
  String get replace;

  /// No description provided for @replaceWith.
  ///
  /// In zh, this message translates to:
  /// **'替换为...'**
  String get replaceWith;

  /// No description provided for @matchCase.
  ///
  /// In zh, this message translates to:
  /// **'区分大小写'**
  String get matchCase;

  /// No description provided for @regex.
  ///
  /// In zh, this message translates to:
  /// **'正则表达式'**
  String get regex;

  /// No description provided for @prevMatch.
  ///
  /// In zh, this message translates to:
  /// **'上一个'**
  String get prevMatch;

  /// No description provided for @nextMatch.
  ///
  /// In zh, this message translates to:
  /// **'下一个'**
  String get nextMatch;

  /// No description provided for @close.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get close;

  /// No description provided for @replaceAll.
  ///
  /// In zh, this message translates to:
  /// **'全部替换'**
  String get replaceAll;

  /// No description provided for @searchCode.
  ///
  /// In zh, this message translates to:
  /// **'搜索代码...'**
  String get searchCode;

  /// No description provided for @toggleReplace.
  ///
  /// In zh, this message translates to:
  /// **'切换替换模式'**
  String get toggleReplace;

  /// No description provided for @aiConfigList.
  ///
  /// In zh, this message translates to:
  /// **'配置列表'**
  String get aiConfigList;

  /// No description provided for @aiConfigNew.
  ///
  /// In zh, this message translates to:
  /// **'新建'**
  String get aiConfigNew;

  /// No description provided for @aiConfigCurrent.
  ///
  /// In zh, this message translates to:
  /// **'当前'**
  String get aiConfigCurrent;

  /// No description provided for @aiConfigEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无配置，请填写下方表单保存'**
  String get aiConfigEmpty;

  /// No description provided for @aiConfigEditTitle.
  ///
  /// In zh, this message translates to:
  /// **'编辑配置'**
  String get aiConfigEditTitle;

  /// No description provided for @aiConfigNewTitle.
  ///
  /// In zh, this message translates to:
  /// **'新建配置'**
  String get aiConfigNewTitle;

  /// No description provided for @aiConfigName.
  ///
  /// In zh, this message translates to:
  /// **'配置名称'**
  String get aiConfigName;

  /// No description provided for @aiConfigNameHint.
  ///
  /// In zh, this message translates to:
  /// **'例如：OpenAI GPT-4'**
  String get aiConfigNameHint;

  /// No description provided for @aiConfigSwitch.
  ///
  /// In zh, this message translates to:
  /// **'切换到此配置'**
  String get aiConfigSwitch;

  /// No description provided for @aiConfigDelete.
  ///
  /// In zh, this message translates to:
  /// **'删除配置'**
  String get aiConfigDelete;

  /// No description provided for @aiConfigDeleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确认删除 \'{name}\' 配置？'**
  String aiConfigDeleteConfirm(String name);

  /// No description provided for @aiApiType.
  ///
  /// In zh, this message translates to:
  /// **'API 类型'**
  String get aiApiType;

  /// No description provided for @aiApiTypeOpenAI.
  ///
  /// In zh, this message translates to:
  /// **'OpenAI'**
  String get aiApiTypeOpenAI;

  /// No description provided for @aiApiTypeOpenAIResponses.
  ///
  /// In zh, this message translates to:
  /// **'OpenAI Responses'**
  String get aiApiTypeOpenAIResponses;

  /// No description provided for @aiApiTypeAnthropic.
  ///
  /// In zh, this message translates to:
  /// **'Anthropic Claude'**
  String get aiApiTypeAnthropic;

  /// No description provided for @aiTutorial.
  ///
  /// In zh, this message translates to:
  /// **'教程'**
  String get aiTutorial;

  /// No description provided for @aiBuiltinConfigName.
  ///
  /// In zh, this message translates to:
  /// **'帕帝接口'**
  String get aiBuiltinConfigName;

  /// No description provided for @aiBuiltinUseConfig.
  ///
  /// In zh, this message translates to:
  /// **'使用内置接口'**
  String get aiBuiltinUseConfig;

  /// No description provided for @aiBuiltinSwitching.
  ///
  /// In zh, this message translates to:
  /// **'正在切换到内置默认接口'**
  String get aiBuiltinSwitching;

  /// No description provided for @aiBuyCardSecret.
  ///
  /// In zh, this message translates to:
  /// **'购买卡密'**
  String get aiBuyCardSecret;

  /// No description provided for @aiApiKeyConfigured.
  ///
  /// In zh, this message translates to:
  /// **'API Key 已配置'**
  String get aiApiKeyConfigured;

  /// No description provided for @aiApiKeyNotConfigured.
  ///
  /// In zh, this message translates to:
  /// **'API Key 未配置'**
  String get aiApiKeyNotConfigured;

  /// No description provided for @aiPadiModelLabel.
  ///
  /// In zh, this message translates to:
  /// **'模型'**
  String get aiPadiModelLabel;

  /// No description provided for @aiPadiReasoningLabel.
  ///
  /// In zh, this message translates to:
  /// **'思考深度'**
  String get aiPadiReasoningLabel;

  /// No description provided for @aiPadiEffortNone.
  ///
  /// In zh, this message translates to:
  /// **'极低'**
  String get aiPadiEffortNone;

  /// No description provided for @aiPadiEffortLow.
  ///
  /// In zh, this message translates to:
  /// **'低'**
  String get aiPadiEffortLow;

  /// No description provided for @aiPadiEffortMedium.
  ///
  /// In zh, this message translates to:
  /// **'中'**
  String get aiPadiEffortMedium;

  /// No description provided for @aiPadiEffortHigh.
  ///
  /// In zh, this message translates to:
  /// **'高'**
  String get aiPadiEffortHigh;

  /// No description provided for @aiPadiEffortXHigh.
  ///
  /// In zh, this message translates to:
  /// **'极高'**
  String get aiPadiEffortXHigh;

  /// No description provided for @aiPadiOptionsExpand.
  ///
  /// In zh, this message translates to:
  /// **'展开'**
  String get aiPadiOptionsExpand;

  /// No description provided for @aiPadiOptionsCollapse.
  ///
  /// In zh, this message translates to:
  /// **'收起'**
  String get aiPadiOptionsCollapse;

  /// No description provided for @aiCurrentStatus.
  ///
  /// In zh, this message translates to:
  /// **'当前状态：{status}'**
  String aiCurrentStatus(String status);

  /// No description provided for @aiCurrentInterface.
  ///
  /// In zh, this message translates to:
  /// **'当前接口：{name}'**
  String aiCurrentInterface(String name);

  /// No description provided for @terminal.
  ///
  /// In zh, this message translates to:
  /// **'控制台'**
  String get terminal;

  /// No description provided for @terminalFilterHint.
  ///
  /// In zh, this message translates to:
  /// **'二次过滤...'**
  String get terminalFilterHint;

  /// No description provided for @autoScroll.
  ///
  /// In zh, this message translates to:
  /// **'自动滚屏'**
  String get autoScroll;

  /// No description provided for @clearPanel.
  ///
  /// In zh, this message translates to:
  /// **'清空面板'**
  String get clearPanel;

  /// No description provided for @noLogs.
  ///
  /// In zh, this message translates to:
  /// **'暂无日志'**
  String get noLogs;

  /// No description provided for @noLogsFiltered.
  ///
  /// In zh, this message translates to:
  /// **'过滤后无匹配'**
  String get noLogsFiltered;

  /// No description provided for @logcatFullscreen.
  ///
  /// In zh, this message translates to:
  /// **'全屏'**
  String get logcatFullscreen;

  /// No description provided for @apiManual.
  ///
  /// In zh, this message translates to:
  /// **'手册'**
  String get apiManual;

  /// No description provided for @aiApiManualTitle.
  ///
  /// In zh, this message translates to:
  /// **'API AI 助手'**
  String get aiApiManualTitle;

  /// No description provided for @aiApiManualSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'向我提问 JsxposedX API 用法'**
  String get aiApiManualSubtitle;

  /// No description provided for @visualEditorTab.
  ///
  /// In zh, this message translates to:
  /// **'可视化'**
  String get visualEditorTab;

  /// No description provided for @codeEditorTab.
  ///
  /// In zh, this message translates to:
  /// **'代码'**
  String get codeEditorTab;

  /// No description provided for @addBlock.
  ///
  /// In zh, this message translates to:
  /// **'添加 Block'**
  String get addBlock;

  /// No description provided for @noBlocks.
  ///
  /// In zh, this message translates to:
  /// **'暂无 Hook Block'**
  String get noBlocks;

  /// No description provided for @noBlocksHint.
  ///
  /// In zh, this message translates to:
  /// **'点击下方按钮添加第一个 Block'**
  String get noBlocksHint;

  /// No description provided for @blockHookMethod.
  ///
  /// In zh, this message translates to:
  /// **'Hook 方法'**
  String get blockHookMethod;

  /// No description provided for @blockHookMethodDesc.
  ///
  /// In zh, this message translates to:
  /// **'Hook 一个方法，支持 before/after/replace 回调'**
  String get blockHookMethodDesc;

  /// No description provided for @blockHookConstructor.
  ///
  /// In zh, this message translates to:
  /// **'Hook 构造函数'**
  String get blockHookConstructor;

  /// No description provided for @blockHookConstructorDesc.
  ///
  /// In zh, this message translates to:
  /// **'Hook 一个类的构造函数'**
  String get blockHookConstructorDesc;

  /// No description provided for @blockReturnConst.
  ///
  /// In zh, this message translates to:
  /// **'返回常量'**
  String get blockReturnConst;

  /// No description provided for @blockReturnConstDesc.
  ///
  /// In zh, this message translates to:
  /// **'强制方法返回一个固定值'**
  String get blockReturnConstDesc;

  /// No description provided for @blockLogParams.
  ///
  /// In zh, this message translates to:
  /// **'打印参数'**
  String get blockLogParams;

  /// No description provided for @blockLogParamsDesc.
  ///
  /// In zh, this message translates to:
  /// **'打印方法的所有参数和返回值'**
  String get blockLogParamsDesc;

  /// No description provided for @blockSetField.
  ///
  /// In zh, this message translates to:
  /// **'修改字段'**
  String get blockSetField;

  /// No description provided for @blockSetFieldDesc.
  ///
  /// In zh, this message translates to:
  /// **'修改字段值（静态或实例）'**
  String get blockSetFieldDesc;

  /// No description provided for @blockCustomCode.
  ///
  /// In zh, this message translates to:
  /// **'自定义代码'**
  String get blockCustomCode;

  /// No description provided for @blockCustomCodeDesc.
  ///
  /// In zh, this message translates to:
  /// **'编写自由 JavaScript 代码'**
  String get blockCustomCodeDesc;

  /// No description provided for @blockClassName.
  ///
  /// In zh, this message translates to:
  /// **'类名'**
  String get blockClassName;

  /// No description provided for @blockClassNameHint.
  ///
  /// In zh, this message translates to:
  /// **'如 com.example.MyClass'**
  String get blockClassNameHint;

  /// No description provided for @blockMethodName.
  ///
  /// In zh, this message translates to:
  /// **'方法名'**
  String get blockMethodName;

  /// No description provided for @blockMethodNameHint.
  ///
  /// In zh, this message translates to:
  /// **'如 login'**
  String get blockMethodNameHint;

  /// No description provided for @blockParamTypes.
  ///
  /// In zh, this message translates to:
  /// **'参数类型'**
  String get blockParamTypes;

  /// No description provided for @blockParamTypesHint.
  ///
  /// In zh, this message translates to:
  /// **'逗号分隔，如 int, java.lang.String, boolean'**
  String get blockParamTypesHint;

  /// No description provided for @blockTiming.
  ///
  /// In zh, this message translates to:
  /// **'时机'**
  String get blockTiming;

  /// No description provided for @blockTimingBefore.
  ///
  /// In zh, this message translates to:
  /// **'之前'**
  String get blockTimingBefore;

  /// No description provided for @blockTimingAfter.
  ///
  /// In zh, this message translates to:
  /// **'之后'**
  String get blockTimingAfter;

  /// No description provided for @blockTimingReplace.
  ///
  /// In zh, this message translates to:
  /// **'替换'**
  String get blockTimingReplace;

  /// No description provided for @blockConstValue.
  ///
  /// In zh, this message translates to:
  /// **'返回值'**
  String get blockConstValue;

  /// No description provided for @blockConstValueHint.
  ///
  /// In zh, this message translates to:
  /// **'如 true'**
  String get blockConstValueHint;

  /// No description provided for @blockConstType.
  ///
  /// In zh, this message translates to:
  /// **'值类型'**
  String get blockConstType;

  /// No description provided for @blockFieldName.
  ///
  /// In zh, this message translates to:
  /// **'字段名'**
  String get blockFieldName;

  /// No description provided for @blockFieldNameHint.
  ///
  /// In zh, this message translates to:
  /// **'如 isVip'**
  String get blockFieldNameHint;

  /// No description provided for @blockFieldValue.
  ///
  /// In zh, this message translates to:
  /// **'字段值'**
  String get blockFieldValue;

  /// No description provided for @blockFieldValueHint.
  ///
  /// In zh, this message translates to:
  /// **'如 true'**
  String get blockFieldValueHint;

  /// No description provided for @blockIsStaticField.
  ///
  /// In zh, this message translates to:
  /// **'静态字段'**
  String get blockIsStaticField;

  /// No description provided for @blockCustomJs.
  ///
  /// In zh, this message translates to:
  /// **'JavaScript 代码'**
  String get blockCustomJs;

  /// No description provided for @blockCustomJsHint.
  ///
  /// In zh, this message translates to:
  /// **'Jx.log(\"hello\");'**
  String get blockCustomJsHint;

  /// No description provided for @blockSelectType.
  ///
  /// In zh, this message translates to:
  /// **'选择 Block 类型'**
  String get blockSelectType;

  /// No description provided for @blockHookBefore.
  ///
  /// In zh, this message translates to:
  /// **'Hook Before'**
  String get blockHookBefore;

  /// No description provided for @blockHookAfter.
  ///
  /// In zh, this message translates to:
  /// **'Hook After'**
  String get blockHookAfter;

  /// No description provided for @blockHookReplace.
  ///
  /// In zh, this message translates to:
  /// **'Hook Replace'**
  String get blockHookReplace;

  /// No description provided for @blockBeforeConstructor.
  ///
  /// In zh, this message translates to:
  /// **'构造前'**
  String get blockBeforeConstructor;

  /// No description provided for @blockAfterConstructor.
  ///
  /// In zh, this message translates to:
  /// **'构造后'**
  String get blockAfterConstructor;

  /// No description provided for @blockLog.
  ///
  /// In zh, this message translates to:
  /// **'日志'**
  String get blockLog;

  /// No description provided for @blockLogException.
  ///
  /// In zh, this message translates to:
  /// **'异常日志'**
  String get blockLogException;

  /// No description provided for @blockConsoleLog.
  ///
  /// In zh, this message translates to:
  /// **'Console 日志'**
  String get blockConsoleLog;

  /// No description provided for @blockStackTrace.
  ///
  /// In zh, this message translates to:
  /// **'调用栈'**
  String get blockStackTrace;

  /// No description provided for @blockGetField.
  ///
  /// In zh, this message translates to:
  /// **'读取字段'**
  String get blockGetField;

  /// No description provided for @blockGetInt.
  ///
  /// In zh, this message translates to:
  /// **'读取 Int'**
  String get blockGetInt;

  /// No description provided for @blockSetInt.
  ///
  /// In zh, this message translates to:
  /// **'设置 Int'**
  String get blockSetInt;

  /// No description provided for @blockGetBool.
  ///
  /// In zh, this message translates to:
  /// **'读取 Bool'**
  String get blockGetBool;

  /// No description provided for @blockSetBool.
  ///
  /// In zh, this message translates to:
  /// **'设置 Bool'**
  String get blockSetBool;

  /// No description provided for @blockGetArg.
  ///
  /// In zh, this message translates to:
  /// **'获取参数'**
  String get blockGetArg;

  /// No description provided for @blockSetArg.
  ///
  /// In zh, this message translates to:
  /// **'修改参数'**
  String get blockSetArg;

  /// No description provided for @blockGetResult.
  ///
  /// In zh, this message translates to:
  /// **'获取返回值'**
  String get blockGetResult;

  /// No description provided for @blockSetResult.
  ///
  /// In zh, this message translates to:
  /// **'修改返回值'**
  String get blockSetResult;

  /// No description provided for @blockCallMethod.
  ///
  /// In zh, this message translates to:
  /// **'调用方法'**
  String get blockCallMethod;

  /// No description provided for @blockCallStatic.
  ///
  /// In zh, this message translates to:
  /// **'调用静态方法'**
  String get blockCallStatic;

  /// No description provided for @blockNewInstance.
  ///
  /// In zh, this message translates to:
  /// **'创建实例'**
  String get blockNewInstance;

  /// No description provided for @blockIf.
  ///
  /// In zh, this message translates to:
  /// **'条件判断'**
  String get blockIf;

  /// No description provided for @blockForLoop.
  ///
  /// In zh, this message translates to:
  /// **'循环'**
  String get blockForLoop;

  /// No description provided for @blockVarAssign.
  ///
  /// In zh, this message translates to:
  /// **'变量赋值'**
  String get blockVarAssign;

  /// No description provided for @blockToast.
  ///
  /// In zh, this message translates to:
  /// **'Toast 提示'**
  String get blockToast;

  /// No description provided for @blockGetApplication.
  ///
  /// In zh, this message translates to:
  /// **'获取 Application'**
  String get blockGetApplication;

  /// No description provided for @blockGetPackageName.
  ///
  /// In zh, this message translates to:
  /// **'获取包名'**
  String get blockGetPackageName;

  /// No description provided for @blockGetSharedPrefs.
  ///
  /// In zh, this message translates to:
  /// **'获取 SharedPrefs'**
  String get blockGetSharedPrefs;

  /// No description provided for @blockGetPrefString.
  ///
  /// In zh, this message translates to:
  /// **'读取 Pref 字符串'**
  String get blockGetPrefString;

  /// No description provided for @blockGetBuild.
  ///
  /// In zh, this message translates to:
  /// **'获取 Build 信息'**
  String get blockGetBuild;

  /// No description provided for @blockStartActivity.
  ///
  /// In zh, this message translates to:
  /// **'启动 Activity'**
  String get blockStartActivity;

  /// No description provided for @blockFindClass.
  ///
  /// In zh, this message translates to:
  /// **'查找类'**
  String get blockFindClass;

  /// No description provided for @blockMessage.
  ///
  /// In zh, this message translates to:
  /// **'消息'**
  String get blockMessage;

  /// No description provided for @blockMessageHint.
  ///
  /// In zh, this message translates to:
  /// **'日志内容'**
  String get blockMessageHint;

  /// No description provided for @blockTag.
  ///
  /// In zh, this message translates to:
  /// **'标签'**
  String get blockTag;

  /// No description provided for @blockTagHint.
  ///
  /// In zh, this message translates to:
  /// **'如 Net.request'**
  String get blockTagHint;

  /// No description provided for @blockValue.
  ///
  /// In zh, this message translates to:
  /// **'值'**
  String get blockValue;

  /// No description provided for @blockValueHint.
  ///
  /// In zh, this message translates to:
  /// **'如 true'**
  String get blockValueHint;

  /// No description provided for @blockIndex.
  ///
  /// In zh, this message translates to:
  /// **'索引'**
  String get blockIndex;

  /// No description provided for @blockIndexHint.
  ///
  /// In zh, this message translates to:
  /// **'如 0'**
  String get blockIndexHint;

  /// No description provided for @blockVarName.
  ///
  /// In zh, this message translates to:
  /// **'变量名'**
  String get blockVarName;

  /// No description provided for @blockVarNameHint.
  ///
  /// In zh, this message translates to:
  /// **'如 result'**
  String get blockVarNameHint;

  /// No description provided for @blockArgs.
  ///
  /// In zh, this message translates to:
  /// **'参数'**
  String get blockArgs;

  /// No description provided for @blockArgsHint.
  ///
  /// In zh, this message translates to:
  /// **'逗号分隔，如 arg0, \"hello\", 123'**
  String get blockArgsHint;

  /// No description provided for @blockCondition.
  ///
  /// In zh, this message translates to:
  /// **'条件'**
  String get blockCondition;

  /// No description provided for @blockConditionHint.
  ///
  /// In zh, this message translates to:
  /// **'如 x > 0'**
  String get blockConditionHint;

  /// No description provided for @blockFrom.
  ///
  /// In zh, this message translates to:
  /// **'起始'**
  String get blockFrom;

  /// No description provided for @blockFromHint.
  ///
  /// In zh, this message translates to:
  /// **'如 0'**
  String get blockFromHint;

  /// No description provided for @blockTo.
  ///
  /// In zh, this message translates to:
  /// **'结束'**
  String get blockTo;

  /// No description provided for @blockToHint.
  ///
  /// In zh, this message translates to:
  /// **'如 10'**
  String get blockToHint;

  /// No description provided for @blockConstTypeHint.
  ///
  /// In zh, this message translates to:
  /// **'选择类型'**
  String get blockConstTypeHint;

  /// No description provided for @blockPrefsName.
  ///
  /// In zh, this message translates to:
  /// **'Prefs 名'**
  String get blockPrefsName;

  /// No description provided for @blockPrefsNameHint.
  ///
  /// In zh, this message translates to:
  /// **'如 app_config'**
  String get blockPrefsNameHint;

  /// No description provided for @blockPrefKey.
  ///
  /// In zh, this message translates to:
  /// **'Key'**
  String get blockPrefKey;

  /// No description provided for @blockPrefKeyHint.
  ///
  /// In zh, this message translates to:
  /// **'如 token'**
  String get blockPrefKeyHint;

  /// No description provided for @blockSlotBody.
  ///
  /// In zh, this message translates to:
  /// **'执行体'**
  String get blockSlotBody;

  /// No description provided for @blockSlotBefore.
  ///
  /// In zh, this message translates to:
  /// **'之前'**
  String get blockSlotBefore;

  /// No description provided for @blockSlotAfter.
  ///
  /// In zh, this message translates to:
  /// **'之后'**
  String get blockSlotAfter;

  /// No description provided for @blockSlotThen.
  ///
  /// In zh, this message translates to:
  /// **'满足条件'**
  String get blockSlotThen;

  /// No description provided for @blockSlotElse.
  ///
  /// In zh, this message translates to:
  /// **'否则'**
  String get blockSlotElse;

  /// No description provided for @blockConsoleWarn.
  ///
  /// In zh, this message translates to:
  /// **'Console 警告'**
  String get blockConsoleWarn;

  /// No description provided for @blockConsoleError.
  ///
  /// In zh, this message translates to:
  /// **'Console 错误'**
  String get blockConsoleError;

  /// No description provided for @blockGetClassName.
  ///
  /// In zh, this message translates to:
  /// **'获取类名'**
  String get blockGetClassName;

  /// No description provided for @blockCallMethodTyped.
  ///
  /// In zh, this message translates to:
  /// **'调用方法 (指定类型)'**
  String get blockCallMethodTyped;

  /// No description provided for @blockCallStaticAuto.
  ///
  /// In zh, this message translates to:
  /// **'调用静态方法 (自动推断)'**
  String get blockCallStaticAuto;

  /// No description provided for @blockNewInstanceTyped.
  ///
  /// In zh, this message translates to:
  /// **'创建实例 (指定类型)'**
  String get blockNewInstanceTyped;

  /// No description provided for @blockGetPrefInt.
  ///
  /// In zh, this message translates to:
  /// **'读取 Pref 整数'**
  String get blockGetPrefInt;

  /// No description provided for @blockGetPrefBool.
  ///
  /// In zh, this message translates to:
  /// **'读取 Pref 布尔'**
  String get blockGetPrefBool;

  /// No description provided for @blockGetSystemProp.
  ///
  /// In zh, this message translates to:
  /// **'获取系统属性'**
  String get blockGetSystemProp;

  /// No description provided for @blockLoadClass.
  ///
  /// In zh, this message translates to:
  /// **'加载类'**
  String get blockLoadClass;

  /// No description provided for @blockHookAllMethods.
  ///
  /// In zh, this message translates to:
  /// **'Hook 所有重载'**
  String get blockHookAllMethods;

  /// No description provided for @blockHookAllConstructors.
  ///
  /// In zh, this message translates to:
  /// **'Hook 所有构造'**
  String get blockHookAllConstructors;

  /// No description provided for @blockUnhook.
  ///
  /// In zh, this message translates to:
  /// **'移除 Hook'**
  String get blockUnhook;

  /// No description provided for @blockGetLong.
  ///
  /// In zh, this message translates to:
  /// **'读取 Long'**
  String get blockGetLong;

  /// No description provided for @blockSetLong.
  ///
  /// In zh, this message translates to:
  /// **'设置 Long'**
  String get blockSetLong;

  /// No description provided for @blockGetFloat.
  ///
  /// In zh, this message translates to:
  /// **'读取 Float'**
  String get blockGetFloat;

  /// No description provided for @blockSetFloat.
  ///
  /// In zh, this message translates to:
  /// **'设置 Float'**
  String get blockSetFloat;

  /// No description provided for @blockGetDouble.
  ///
  /// In zh, this message translates to:
  /// **'读取 Double'**
  String get blockGetDouble;

  /// No description provided for @blockSetDouble.
  ///
  /// In zh, this message translates to:
  /// **'设置 Double'**
  String get blockSetDouble;

  /// No description provided for @blockGetThrowable.
  ///
  /// In zh, this message translates to:
  /// **'获取异常'**
  String get blockGetThrowable;

  /// No description provided for @blockSetThrowable.
  ///
  /// In zh, this message translates to:
  /// **'设置异常'**
  String get blockSetThrowable;

  /// No description provided for @blockGetMethods.
  ///
  /// In zh, this message translates to:
  /// **'获取方法列表'**
  String get blockGetMethods;

  /// No description provided for @blockGetFields.
  ///
  /// In zh, this message translates to:
  /// **'获取字段列表'**
  String get blockGetFields;

  /// No description provided for @blockInstanceOf.
  ///
  /// In zh, this message translates to:
  /// **'类型检查'**
  String get blockInstanceOf;

  /// No description provided for @blockSetExtra.
  ///
  /// In zh, this message translates to:
  /// **'设置附加数据'**
  String get blockSetExtra;

  /// No description provided for @blockGetExtra.
  ///
  /// In zh, this message translates to:
  /// **'获取附加数据'**
  String get blockGetExtra;

  /// No description provided for @pickVariable.
  ///
  /// In zh, this message translates to:
  /// **'选择变量'**
  String get pickVariable;

  /// No description provided for @contextVariables.
  ///
  /// In zh, this message translates to:
  /// **'上下文变量'**
  String get contextVariables;

  /// No description provided for @userVariables.
  ///
  /// In zh, this message translates to:
  /// **'用户变量'**
  String get userVariables;

  /// No description provided for @noVariablesAvailable.
  ///
  /// In zh, this message translates to:
  /// **'暂无可用变量'**
  String get noVariablesAvailable;

  /// No description provided for @collapseAll.
  ///
  /// In zh, this message translates to:
  /// **'全部折叠'**
  String get collapseAll;

  /// No description provided for @expandAll.
  ///
  /// In zh, this message translates to:
  /// **'全部展开'**
  String get expandAll;

  /// No description provided for @importScript.
  ///
  /// In zh, this message translates to:
  /// **'导入'**
  String get importScript;

  /// No description provided for @selectScriptType.
  ///
  /// In zh, this message translates to:
  /// **'选择脚本类型'**
  String get selectScriptType;

  /// No description provided for @traditionalScriptDesc.
  ///
  /// In zh, this message translates to:
  /// **'传统Hook脚本'**
  String get traditionalScriptDesc;

  /// No description provided for @visualScriptDesc.
  ///
  /// In zh, this message translates to:
  /// **'可视化脚本'**
  String get visualScriptDesc;

  /// No description provided for @saveScript.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get saveScript;

  /// No description provided for @exportScript.
  ///
  /// In zh, this message translates to:
  /// **'导出'**
  String get exportScript;

  /// No description provided for @scriptSaved.
  ///
  /// In zh, this message translates to:
  /// **'脚本已保存'**
  String get scriptSaved;

  /// No description provided for @scriptExported.
  ///
  /// In zh, this message translates to:
  /// **'脚本已导出'**
  String get scriptExported;

  /// No description provided for @reservedScriptFileName.
  ///
  /// In zh, this message translates to:
  /// **'内部保留文件名，请更换文件名'**
  String get reservedScriptFileName;

  /// AI 气泡保存脚本成功提示
  ///
  /// In zh, this message translates to:
  /// **'已保存到 {target}: {name}'**
  String aiScriptSavedTo(String target, String name);

  /// AI 气泡保存脚本失败提示
  ///
  /// In zh, this message translates to:
  /// **'保存失败: {error}'**
  String aiScriptSaveFailed(String error);

  /// No description provided for @manifestBasicInfo.
  ///
  /// In zh, this message translates to:
  /// **'基本信息'**
  String get manifestBasicInfo;

  /// No description provided for @manifestPackage.
  ///
  /// In zh, this message translates to:
  /// **'包名'**
  String get manifestPackage;

  /// No description provided for @manifestMinSdk.
  ///
  /// In zh, this message translates to:
  /// **'最低 SDK'**
  String get manifestMinSdk;

  /// No description provided for @manifestTargetSdk.
  ///
  /// In zh, this message translates to:
  /// **'目标 SDK'**
  String get manifestTargetSdk;

  /// No description provided for @manifestDebuggable.
  ///
  /// In zh, this message translates to:
  /// **'可调试'**
  String get manifestDebuggable;

  /// No description provided for @manifestAllowBackup.
  ///
  /// In zh, this message translates to:
  /// **'允许备份'**
  String get manifestAllowBackup;

  /// No description provided for @manifestPermissions.
  ///
  /// In zh, this message translates to:
  /// **'权限 ({count})'**
  String manifestPermissions(int count);

  /// No description provided for @manifestNoPermissions.
  ///
  /// In zh, this message translates to:
  /// **'无权限'**
  String get manifestNoPermissions;

  /// No description provided for @manifestActivities.
  ///
  /// In zh, this message translates to:
  /// **'Activity'**
  String get manifestActivities;

  /// No description provided for @manifestServices.
  ///
  /// In zh, this message translates to:
  /// **'Service'**
  String get manifestServices;

  /// No description provided for @manifestReceivers.
  ///
  /// In zh, this message translates to:
  /// **'Receiver'**
  String get manifestReceivers;

  /// No description provided for @manifestProviders.
  ///
  /// In zh, this message translates to:
  /// **'Provider'**
  String get manifestProviders;

  /// No description provided for @manifestNoItems.
  ///
  /// In zh, this message translates to:
  /// **'无 {name}'**
  String manifestNoItems(String name);

  /// No description provided for @manifestExported.
  ///
  /// In zh, this message translates to:
  /// **'已导出'**
  String get manifestExported;

  /// No description provided for @apkNoAiSession.
  ///
  /// In zh, this message translates to:
  /// **'未关联 AI 分析会话'**
  String get apkNoAiSession;

  /// No description provided for @apkAiAnalyze.
  ///
  /// In zh, this message translates to:
  /// **'AI分析'**
  String get apkAiAnalyze;

  /// No description provided for @apkSentToAi.
  ///
  /// In zh, this message translates to:
  /// **'已发送到 AI：分析 {name}'**
  String apkSentToAi(String name);

  /// No description provided for @apkAnalyzeSmaliPrompt.
  ///
  /// In zh, this message translates to:
  /// **'请分析 {className} 的 Smali 代码，解释逻辑并给出可能的 Hook 点。'**
  String apkAnalyzeSmaliPrompt(String className);

  /// No description provided for @apkAnalyzeJavaPrompt.
  ///
  /// In zh, this message translates to:
  /// **'请分析 {className} 的反编译 Java 代码，解释逻辑并给出可能的 Hook 点。'**
  String apkAnalyzeJavaPrompt(String className);

  /// No description provided for @undo.
  ///
  /// In zh, this message translates to:
  /// **'撤销'**
  String get undo;

  /// No description provided for @redo.
  ///
  /// In zh, this message translates to:
  /// **'重做'**
  String get redo;

  /// No description provided for @sendToAi.
  ///
  /// In zh, this message translates to:
  /// **'发送给AI'**
  String get sendToAi;

  /// No description provided for @pressBackAgainToExit.
  ///
  /// In zh, this message translates to:
  /// **'再按一次返回退出'**
  String get pressBackAgainToExit;

  /// No description provided for @apkAnalyzeSelectedCode.
  ///
  /// In zh, this message translates to:
  /// **'以下是 {className} 的 {language} 代码片段，请帮我分析：\n\n{code}'**
  String apkAnalyzeSelectedCode(String className, String language, String code);

  /// No description provided for @dexSearchHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索类名...'**
  String get dexSearchHint;

  /// No description provided for @dexNoClassFound.
  ///
  /// In zh, this message translates to:
  /// **'未找到包含 \"{keyword}\" 的类'**
  String dexNoClassFound(String keyword);

  /// No description provided for @dexCopied.
  ///
  /// In zh, this message translates to:
  /// **'已复制: {name}'**
  String dexCopied(String name);

  /// No description provided for @dexCopyShortName.
  ///
  /// In zh, this message translates to:
  /// **'复制类名'**
  String get dexCopyShortName;

  /// No description provided for @dexCopyFullName.
  ///
  /// In zh, this message translates to:
  /// **'复制全限定类名'**
  String get dexCopyFullName;

  /// No description provided for @soAskAi.
  ///
  /// In zh, this message translates to:
  /// **'询问AI'**
  String get soAskAi;

  /// No description provided for @soSentToAi.
  ///
  /// In zh, this message translates to:
  /// **'已发送给 AI：分析 {name}'**
  String soSentToAi(String name);

  /// No description provided for @lsposedNotAvailable.
  ///
  /// In zh, this message translates to:
  /// **'LSPosed 服务不可用，请确保模块已在 LSPosed 中激活并重启应用'**
  String get lsposedNotAvailable;

  /// No description provided for @lsposedAddingScope.
  ///
  /// In zh, this message translates to:
  /// **'正在请求添加 {name} 到作用域...'**
  String lsposedAddingScope(String name);

  /// No description provided for @lsposedScopeRequestedCheckNotification.
  ///
  /// In zh, this message translates to:
  /// **'已请求添加 {name} 到作用域，请查看通知栏并允许'**
  String lsposedScopeRequestedCheckNotification(String name);

  /// No description provided for @lsposedAddFailed.
  ///
  /// In zh, this message translates to:
  /// **'添加 {name} 失败'**
  String lsposedAddFailed(String name);

  /// No description provided for @lsposedAddFailedService.
  ///
  /// In zh, this message translates to:
  /// **'添加失败: LSPosed 服务不可用'**
  String get lsposedAddFailedService;

  /// No description provided for @aiMethodDetail.
  ///
  /// In zh, this message translates to:
  /// **'方法详情'**
  String get aiMethodDetail;

  /// No description provided for @aiMethodName.
  ///
  /// In zh, this message translates to:
  /// **'方法名'**
  String get aiMethodName;

  /// No description provided for @aiMethodModifier.
  ///
  /// In zh, this message translates to:
  /// **'修饰符'**
  String get aiMethodModifier;

  /// No description provided for @aiMethodReturnType.
  ///
  /// In zh, this message translates to:
  /// **'返回类型'**
  String get aiMethodReturnType;

  /// No description provided for @aiMethodParams.
  ///
  /// In zh, this message translates to:
  /// **'参数列表'**
  String get aiMethodParams;

  /// No description provided for @aiMethodClass.
  ///
  /// In zh, this message translates to:
  /// **'所属类'**
  String get aiMethodClass;

  /// No description provided for @aiMethodHookHint.
  ///
  /// In zh, this message translates to:
  /// **'Hook 指引'**
  String get aiMethodHookHint;

  /// No description provided for @aiMethodCopyFull.
  ///
  /// In zh, this message translates to:
  /// **'复制完整类名.方法名'**
  String get aiMethodCopyFull;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
