import 'dart:io';
import 'dart:ui' as ui;

import 'package:easy_design_system/easy_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

import '../../comm/date_tools.dart';
import '../../comm/gongke_type_presentation.dart';
import '../../comm/harmony_share_service.dart';
import '../../database.dart';
import '../../main.dart';
import '../../viewmodel/current_record.dart';

class GongKeSharePage extends StatefulWidget {
  const GongKeSharePage({super.key});

  @override
  State<GongKeSharePage> createState() => _GongKeSharePageState();
}

class _GongKeSharePageState extends State<GongKeSharePage> {
  late String _date;
  late List<GongKeItemData> _dayRecords;
  late Map<int, bool> _switchStates;
  late Map<int, List<GongKeItemData>> _dayRecordsGroupedByFaYuan;

  CurrentRecord? _todayTip;
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  bool _isSharing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _date = (args?['date'] as String?) ?? DateTools.getStringByCurrentDate();
    _dayRecords = args?['dayRecords'] as List<GongKeItemData>? ?? [];
    _switchStates = args?['switchStates'] as Map<int, bool>? ?? {};
    _dayRecordsGroupedByFaYuan =
        (args?['dayRecordsGroupedByFaYuan'] as Map<int, List<GongKeItemData>>?) ?? {};
    _loadTodayTip();
  }

  Future<void> _loadTodayTip() async {
    final tip = await getCurrentRecord();
    if (!mounted) return;
    setState(() {
      _todayTip = tip;
    });
  }

  bool get _hasTipData =>
      _todayTip != null && _todayTip!.id > 0 && _todayTip!.content != '暂时无数据';

  Future<void> _shareScreenshot() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);
    try {
      final boundary = _repaintBoundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final buffer = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File(
          '${tempDir.path}/gongke_share_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(buffer);
      await const HarmonyShareService().shareFile(
        title: '诵经助手-功课分享',
        path: file.path,
        utd: 'general.image',
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('分享失败：$error')));
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    final completed =
        _dayRecords.where((item) => _switchStates[item.id] == true).length;
    final total = _dayRecords.length;
    final progress = total == 0 ? 0.0 : completed / total;

    return Scaffold(
      backgroundColor: scheme.pageBackground,
      appBar: AppBar(
        title: const Text('分享功课'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.spacing.lg,
                vertical: tokens.spacing.md,
              ),
              child: RepaintBoundary(
                key: _repaintBoundaryKey,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(tokens.spacing.lg),
                  decoration: BoxDecoration(
                    color: scheme.cardBackground,
                    borderRadius: BorderRadius.circular(tokens.radius.lg),
                    border: Border.all(color: scheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGongkeHeader(tokens, scheme, completed, total, progress),
                      if (_dayRecordsGroupedByFaYuan.isNotEmpty) ...[
                        SizedBox(height: tokens.spacing.md),
                        _buildGongkeList(tokens, scheme),
                      ],
                      if (_hasTipData) ...[
                        SizedBox(height: tokens.spacing.lg),
                        Divider(color: scheme.border, height: 1),
                        SizedBox(height: tokens.spacing.md),
                        _buildTipSection(tokens, scheme),
                      ],
                      SizedBox(height: tokens.spacing.xl),
                      _buildBranding(tokens, scheme),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _buildShareButton(tokens),
        ],
      ),
    );
  }

  Widget _buildGongkeHeader(
    EdsDesignTokens tokens,
    EdsColorScheme scheme,
    int completed,
    int total,
    double progress,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: tokens.colors.primary,
                borderRadius: BorderRadius.circular(tokens.radius.sm),
              ),
              child: const Icon(Icons.calendar_today_outlined,
                  color: Colors.white, size: 22),
            ),
            SizedBox(width: tokens.spacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '功课日期',
                    style: tokens.typography.caption
                        .copyWith(color: scheme.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _date,
                    style: tokens.typography.body
                        .copyWith(color: scheme.textPrimary),
                  ),
                ],
              ),
            ),
            EdsBadge(
              '$completed / $total 已完成',
              style: completed == total && total > 0
                  ? EdsBadgeStyle.success
                  : EdsBadgeStyle.accent,
            ),
          ],
        ),
        SizedBox(height: tokens.spacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
              backgroundColor: tokens.colors.primary.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(
              completed == total && total > 0
                  ? tokens.colors.success
                  : tokens.colors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGongkeList(EdsDesignTokens tokens, EdsColorScheme scheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _dayRecordsGroupedByFaYuan.entries.map((entry) {
        final fayuanId = entry.key;
        final fayuanItems = entry.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<FaYuanData?>(
              future: (globalDB.select(globalDB.faYuan)
                    ..where((tbl) => tbl.id.equals(fayuanId)))
                  .getSingleOrNull(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: tokens.spacing.xs),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome,
                          size: 18, color: tokens.colors.primary),
                      SizedBox(width: tokens.spacing.xs),
                      Expanded(
                        child: Text(
                          snapshot.data?.name ?? '',
                          style: tokens.typography.sectionTitle
                              .copyWith(color: scheme.textPrimary),
                        ),
                      ),
                      Text(
                        '${fayuanItems.where((item) => _switchStates[item.id] == true).length}/${fayuanItems.length}',
                        style: tokens.typography.caption
                            .copyWith(color: scheme.textSecondary),
                      ),
                    ],
                  ),
                );
              },
            ),
            ...fayuanItems.map((item) {
              final presentation = GongKeTypePresentation.of(item.gongketype);
              final complete = _switchStates[item.id] ?? false;
              return Padding(
                padding: EdgeInsets.symmetric(vertical: tokens.spacing.xxs),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: complete
                            ? tokens.colors.success.withValues(alpha: 0.12)
                            : tokens.colors.primary.withValues(alpha: 0.08),
                        borderRadius:
                            BorderRadius.circular(tokens.radius.sm),
                      ),
                      child: Icon(
                        presentation.icon,
                        size: 18,
                        color: complete
                            ? tokens.colors.success
                            : tokens.colors.primary,
                      ),
                    ),
                    SizedBox(width: tokens.spacing.sm),
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tokens.typography.body.copyWith(
                          color: scheme.textPrimary,
                          decoration:
                              complete ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                    SizedBox(width: tokens.spacing.xs),
                    Text(
                      '${presentation.label} · ${item.cnt} ${presentation.unit}',
                      style: tokens.typography.caption
                          .copyWith(color: scheme.textSecondary),
                    ),
                    SizedBox(width: tokens.spacing.xs),
                    Icon(
                      complete ? Icons.check_circle : Icons.radio_button_unchecked,
                      size: 20,
                      color: complete
                          ? tokens.colors.success
                          : scheme.textSecondary,
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTipSection(EdsDesignTokens tokens, EdsColorScheme scheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.chat_bubble_outline, size: 18, color: tokens.colors.primary),
            SizedBox(width: tokens.spacing.xs),
            Text(
              '今日开示',
              style: tokens.typography.sectionTitle.copyWith(
                color: scheme.textPrimary,
              ),
            ),
            SizedBox(width: tokens.spacing.xs),
            Text(
              '《${_todayTip!.bookName}》',
              style: tokens.typography.caption.copyWith(
                color: scheme.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: tokens.spacing.sm),
        Text(
          _todayTip!.content,
          style: tokens.typography.body.copyWith(
            color: scheme.textPrimary,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildBranding(EdsDesignTokens tokens, EdsColorScheme scheme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/icon.png',
              width: 36,
              height: 36,
            ),
            SizedBox(width: tokens.spacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '诵经助手',
                  style: tokens.typography.body.copyWith(
                    color: scheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '鸿蒙应用商店下载',
                  style: tokens.typography.caption.copyWith(
                    color: scheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShareButton(EdsDesignTokens tokens) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          tokens.spacing.lg,
          tokens.spacing.sm,
          tokens.spacing.lg,
          tokens.spacing.md,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: EdsButton(
            '分享',
            role: EdsButtonRole.primary,
            action: _isSharing ? null : _shareScreenshot,
          ),
        ),
      ),
    );
  }
}
