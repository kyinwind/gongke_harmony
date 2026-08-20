import 'package:app_help_center/app_help_center.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../comm/external_launcher_tools.dart';

const String _feedbackEmail = 'yangxuehui@outlook.com';
const String _supportUrl =
    'https://my.feishu.cn/wiki/Px4OwS67Eia7ZNkVtWJchBpSnVg';

/// 鸿蒙版帮助中心配置。
///
/// 公告、版本和 FAQ 均为本地内容；App 自身不发起任何远程请求。
final AppHelpCenterConfig harmonyHelpConfig = AppHelpCenterConfig(
  appName: '诵经助手',
  refreshRemoteOnOpen: false,
  remoteAnnouncementsUrl: null,
  remoteVersionSupplementUrl: null,
  remoteFaqUrl: null,
  announcements: [
    HelpAnnouncement(
      id: 'welcome_harmony_v112',
      title: '欢迎使用诵经助手',
      message:
          '诵经助手是一款帮助佛友管理与记录日常佛学修行功课的免费工具。应用提供发愿向导、功课日历、功课统计、诵经、电子木鱼、念佛念咒计数、打坐计时、每日开示和语音引导拜忏等功能。\n\n如果您遇到问题或有改进建议，可以通过帮助中心的邮件反馈联系我们。',
      publishedAt: DateTime(2026, 8, 20),
      level: HelpAnnouncementLevel.info,
      isPinned: true,
    ),
  ],
  versionHistory: [
    VersionHistoryItem(
      versionName: 'v1.1.2',
      publishedAt: DateTime(2026, 8, 21),
      changes: '今日开示卡片支持滑动查看内容。\n增加本地帮助中心。',
    ),
    VersionHistoryItem(
      versionName: 'v1.1.1',
      publishedAt: DateTime(2026, 8, 15),
      changes: '增加桌面卡片和开示功能。',
    ),
    VersionHistoryItem(
      versionName: 'v1.0.8',
      publishedAt: DateTime(2026, 8, 5),
      changes: '电子木鱼增加十念法。',
    ),
    VersionHistoryItem(
      versionName: 'v1.0.7',
      publishedAt: DateTime(2026, 4, 5),
      changes: '增加听书功能。',
    ),
    VersionHistoryItem(
      versionName: 'v1.0.6',
      publishedAt: DateTime(2025, 9, 9),
      changes: '功课设定界面、开示界面增加分享功能。',
    ),
    VersionHistoryItem(
      versionName: 'v1.0.5',
      publishedAt: DateTime(2025, 8, 30),
      changes: '诵经时可以播放电子木鱼。',
    ),
    VersionHistoryItem(
      versionName: 'v1.0.3',
      publishedAt: DateTime(2025, 7, 29),
      changes: '增加欢迎页面。\n增加经书、善书和开示文件导入功能。',
    ),
    VersionHistoryItem(
      versionName: 'v1.0.0',
      publishedAt: DateTime(2025, 7, 19),
      changes: '准备上架应用商店。\n增加华严经。',
    ),
    VersionHistoryItem(
      versionName: 'v0.9.7',
      publishedAt: DateTime(2025, 7, 12),
      changes: '增加打坐计时功能。\n增加善书。',
    ),
    VersionHistoryItem(
      versionName: 'v0.9.6',
      publishedAt: DateTime(2025, 7, 4),
      changes: '完善双页显示和缩略图显示。',
    ),
    VersionHistoryItem(
      versionName: 'v0.9.4',
      publishedAt: DateTime(2025, 6, 26),
      changes: '听书功能支持 Windows 平台。\n增加坐禅系列电子书。\n经书和善书按名称排序。',
    ),
    VersionHistoryItem(
      versionName: 'v0.9.3',
      publishedAt: DateTime(2025, 6, 23),
      changes: '增加听书功能。\n更换饼图组件。',
    ),
    VersionHistoryItem(
      versionName: 'v0.9.2',
      publishedAt: DateTime(2025, 6, 17),
      changes: '完善首页、开示录和拜忏显示。',
    ),
    VersionHistoryItem(
      versionName: 'v0.9.1',
      publishedAt: DateTime(2025, 6, 11),
      changes: '完善 PDF 显示，增加善书页面。',
    ),
    VersionHistoryItem(
      versionName: 'v0.9.0',
      publishedAt: DateTime(2025, 6, 8),
      changes: '首次发布。',
    ),
  ],
  faqItems: [
    const HelpFaqItem(
      id: 'why_no_builtin_sutras',
      question: '为什么没有内置经书，需要自己导入？',
      answer: '诵经助手定位为本地运行的工具类 App，不提供在线宗教内容。您可以把自己合法持有的 PDF 经书通过文件选择器导入后使用。',
    ),
    const HelpFaqItem(
      id: 'how_to_import',
      question: '如何导入经书、善书和开示？',
      answer: '在对应页面打开导入功能：经书和善书选择 PDF 文件，开示录选择 JSON 文件。导入完成后，内容保存在本机应用数据中。',
    ),
    const HelpFaqItem(
      id: 'how_to_feedback',
      question: '如何提交问题或建议？',
      answer: '点击帮助中心的“反馈”，填写内容后选择提交，系统会打开本机邮件 App，并自动填写收件人、主题和正文。',
    ),
  ],
  feedback: const HelpFeedbackConfig(
    submitHandler: _openFeedbackEmail,
    subject: '诵经助手意见反馈',
    includeSystemInfo: true,
    allowChannelSelection: false,
    allowScreenshots: false,
  ),
  supportUrl: null,
  onOpenSupport: _openTechnicalSupport,
  ratingUrl: null,
  reviewPrompt: null,
  includeDefaultQuickLinks: true,
  copyOverrides: const {
    'feedback.custom': '邮件',
  },
);

final AppHelpCenterController helpCenterController = AppHelpCenterController(
  config: harmonyHelpConfig,
);

Future<void> _openFeedbackEmail(HelpFeedbackPayload payload) async {
  final uri = Uri(
    scheme: 'mailto',
    path: _feedbackEmail,
    queryParameters: {
      'subject': harmonyHelpConfig.feedback?.subject ?? '诵经助手意见反馈',
      'body': payload.combinedContent,
    },
  );
  await ExternalLauncherTools.launch(uri.toString());
}

Future<void> _openTechnicalSupport() async {
  await ExternalLauncherTools.launch(_supportUrl);
}

Future<void> initHelpCenter() async {
  await helpCenterController.load(refreshRemote: false);
}

class HarmonyHelpCenterPage extends StatelessWidget {
  const HarmonyHelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppHelpCenterPage(
      config: harmonyHelpConfig,
      controller: helpCenterController,
    );
  }
}

class HelpCenterEntryTile extends StatefulWidget {
  const HelpCenterEntryTile({super.key});

  @override
  State<HelpCenterEntryTile> createState() => _HelpCenterEntryTileState();
}

class _HelpCenterEntryTileState extends State<HelpCenterEntryTile> {
  bool _refreshScheduled = false;

  @override
  void initState() {
    super.initState();
    helpCenterController.addListener(_handleControllerChange);
  }

  @override
  void dispose() {
    helpCenterController.removeListener(_handleControllerChange);
    super.dispose();
  }

  void _handleControllerChange() {
    if (!mounted) {
      return;
    }
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
      setState(() {});
      return;
    }
    if (_refreshScheduled) {
      return;
    }
    _refreshScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshScheduled = false;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: const Icon(Icons.help_outline),
        title: const Text('打开帮助中心'),
        subtitle: const Text('公告、版本历史、常见问题和意见反馈'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (helpCenterController.hasUnreadContent)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const HarmonyHelpCenterPage(),
            ),
          );
        },
      ),
    );
  }
}
