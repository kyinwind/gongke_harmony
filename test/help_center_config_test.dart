import 'package:app_help_center/app_help_center.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gongke/view/help/help_center_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('gongke/external_launcher');
  final launchedLinks = <String>[];

  setUp(() {
    launchedLinks.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'launch');
      launchedLinks
          .add((call.arguments as Map<Object?, Object?>)['link']! as String);
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('help center configuration is local-only', () {
    expect(harmonyHelpConfig.refreshRemoteOnOpen, isFalse);
    expect(harmonyHelpConfig.remoteAnnouncementsUrl, isNull);
    expect(harmonyHelpConfig.remoteVersionSupplementUrl, isNull);
    expect(harmonyHelpConfig.remoteFaqUrl, isNull);
    expect(harmonyHelpConfig.announcements, isNotEmpty);
    expect(harmonyHelpConfig.versionHistory, isNotEmpty);
    expect(harmonyHelpConfig.faqItems, isNotEmpty);
    expect(
      harmonyHelpConfig.announcements.every((item) => item.linkUrl == null),
      isTrue,
    );

    final feedback = harmonyHelpConfig.feedback!;
    expect(feedback.email, isNull);
    expect(feedback.webFormUrl, isNull);
    expect(feedback.discordWebhookUrl, isNull);
    expect(feedback.dingTalkWebhookUrl, isNull);
    expect(feedback.allowScreenshots, isFalse);
    expect(feedback.availableChannels, [HelpFeedbackChannel.custom]);
    expect(harmonyHelpConfig.supportUrl, isNull);
    expect(harmonyHelpConfig.ratingUrl, isNull);
  });

  test('feedback opens the local mail app through the OHOS channel', () async {
    await harmonyHelpConfig.feedback!.submitHandler!(
      const HelpFeedbackPayload(
        content: '测试反馈内容',
        contact: '测试联系人',
        systemInfo: 'HarmonyOS test',
      ),
    );

    expect(launchedLinks, hasLength(1));
    final uri = Uri.parse(launchedLinks.single);
    expect(uri.scheme, 'mailto');
    expect(uri.path, 'yangxuehui@outlook.com');
    expect(uri.queryParameters['subject'], '诵经助手意见反馈');
    expect(uri.queryParameters['body'], contains('测试反馈内容'));
  });

  test('technical support opens through the OHOS channel', () async {
    await harmonyHelpConfig.onOpenSupport!();

    expect(launchedLinks, hasLength(1));
    expect(Uri.parse(launchedLinks.single).scheme, 'https');
    expect(
      launchedLinks.single,
      'https://my.feishu.cn/wiki/Px4OwS67Eia7ZNkVtWJchBpSnVg',
    );
  });

  testWidgets('settings entry opens the help center page', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: HelpCenterEntryTile()),
      ),
    );

    await tester.tap(find.text('打开帮助中心'));
    await tester.pumpAndSettle();

    expect(find.byType(HarmonyHelpCenterPage), findsOneWidget);
  });
}
