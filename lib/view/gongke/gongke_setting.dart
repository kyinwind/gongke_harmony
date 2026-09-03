import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:gongke/database.dart';
import '../../main.dart';
import '../../comm/pdf_view.dart';
import '../../comm/pub_tools.dart';
import 'package:my_flutter_app_tools/my_flutter_app_tools.dart';
import 'package:flutter/services.dart';
import '../../comm/widget_sync_hooks.dart';
import '../../comm/gongke_type_presentation.dart';

class GongKeSettingPage extends StatefulWidget {
  const GongKeSettingPage({super.key});

  @override
  State<GongKeSettingPage> createState() => _GongKeSettingPageState();
}

class _GongKeSettingPageState extends State<GongKeSettingPage> {
  late String date;
  late Map<String, List<GongKeItemData>> groupedCurrentMonthRecords;
  late Function() updateCallback;
  late List<GongKeItemData> dayRecords;
  // 按发愿ID分组
  Map<int, List<GongKeItemData>> dayRecordsGroupedByFaYuan = {};

  // 添加一个Map来存储本地状态
  final Map<int, bool> _switchStates = {};

  bool _canEdit = false;
  bool _showCompleteButton = false;

  Future<void> _setAllComplete() async {
    // 将当天所有任务标记为完成
    await globalDB.managers.gongKeItem
        .filter((item) => item.gongKeDay.equals(date))
        .update((o) => o(isComplete: const Value(true)));
    await syncTaskAndCalendarCards();
  }

  void _updateEditState(String dateStr) {
    final today = DateUtils.dateOnly(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));
    final inputDate = DateUtils.dateOnly(DateTime.parse(dateStr));

    setState(() {
      // 只有今天和昨天可以编辑。直接比较完整日期，避免每月 1 日或
      // 每年 1 月 1 日时，昨天因月份/年份不同而被错误禁用。
      _canEdit = DateUtils.isSameDay(inputDate, today) ||
          DateUtils.isSameDay(inputDate, yesterday);

      // 同样的条件控制按钮显示
      _showCompleteButton = _canEdit;
    });
  }

  Future<void> _refreshAllData() async {
    //print(
    //  '--------------------------------GongKeSettingPage _refreshAllData开始--------------------------------',
    //);
    // 初始化编辑状态
    _updateEditState(date);

    dayRecords = groupedCurrentMonthRecords[date] ?? [];
    // 按发愿ID分组
    dayRecordsGroupedByFaYuan.clear();
    for (var record in dayRecords) {
      if (!dayRecordsGroupedByFaYuan.containsKey(record.fayuanId)) {
        dayRecordsGroupedByFaYuan[record.fayuanId] = [];
      }
      dayRecordsGroupedByFaYuan[record.fayuanId]!.add(record);
    }
    //print('${dayRecordsGroupedByFaYuan.toString()}');
    // 初始化开关状态
    for (var record in dayRecords) {
      _switchStates[record.id] = record.isComplete;
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    date = args['date'] as String;
    groupedCurrentMonthRecords =
        args['groupedRecords'] as Map<String, List<GongKeItemData>>;
    updateCallback = args['updateCallback'] as Function();
    _refreshAllData();
  }

  @override
  Widget build(BuildContext context) {
    final design = RcmTheme.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('功课设置'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            design.spacing.md,
            design.spacing.xs,
            design.spacing.md,
            design.spacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '当天功课',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              SizedBox(height: design.spacing.xxs),
              Text(
                _canEdit ? '记录当天的修持完成情况' : '仅可修改今天和昨天的功课',
                style: design.typography.body15.copyWith(
                  color: design.textSecondaryOf(context),
                ),
              ),
              SizedBox(height: design.spacing.md),
              _buildDateCard(),
              SizedBox(height: design.spacing.md),
              _buildTaskList(),
              SizedBox(height: design.spacing.md),
              _buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateCard() {
    final design = RcmTheme.of(context);
    final completed =
        dayRecords.where((item) => _switchStates[item.id] == true).length;
    final total = dayRecords.length;
    final progress = total == 0 ? 0.0 : completed / total;
    return Container(
      padding: EdgeInsets.all(design.spacing.md),
      decoration: BoxDecoration(
        color: design.colors.accentSoft,
        borderRadius: BorderRadius.circular(design.radius.lg),
        border: Border.all(color: design.colors.primary.withOpacity(0.16)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: design.colors.primary,
                  borderRadius: BorderRadius.circular(design.radius.sm),
                ),
                child: const Icon(Icons.calendar_today_outlined,
                    color: Colors.white, size: 22),
              ),
              SizedBox(width: design.spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('功课日期',
                        style: design.typography.caption.copyWith(
                          color: design.textSecondaryOf(context),
                        )),
                    const SizedBox(height: 2),
                    Text(date,
                        style: design.typography.body15Strong.copyWith(
                          color: design.textPrimaryOf(context),
                        )),
                  ],
                ),
              ),
              RcmBadge(
                '$completed / $total 已完成',
                style: completed == total && total > 0
                    ? RcmBadgeStyle.success
                    : RcmBadgeStyle.accent,
              ),
            ],
          ),
          SizedBox(height: design.spacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: design.colors.primary.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(
                completed == total && total > 0
                    ? design.colors.success
                    : design.colors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 跳转到PDF页面
  void _navigateToPdfView(JingShuData jingshu) async {
    //根据pdfname找到经书
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              PdfViewerPage(jingshu: jingshu, startPageIndex: 1)),
    );
  }

  Widget _buildTaskList() {
    final design = RcmTheme.of(context);
    return Expanded(
      child: dayRecordsGroupedByFaYuan.isEmpty
          ? Center(
              child: Text(
                '当天没有功课',
                style: design.typography.body15.copyWith(
                  color: design.textSecondaryOf(context),
                ),
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: dayRecordsGroupedByFaYuan.length,
              separatorBuilder: (_, __) => SizedBox(height: design.spacing.sm),
              itemBuilder: (context, index) {
                int fayuanId = dayRecordsGroupedByFaYuan.keys.elementAt(index);
                List<GongKeItemData> fayuanItems =
                    dayRecordsGroupedByFaYuan[fayuanId]!;

                return Container(
                  decoration: BoxDecoration(
                    color: design.cardBackgroundOf(context),
                    borderRadius: BorderRadius.circular(design.radius.lg),
                    border: Border.all(color: design.borderOf(context)),
                    boxShadow: [design.shadow.boxShadow],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          design.spacing.md,
                          design.spacing.md,
                          design.spacing.md,
                          design.spacing.xs,
                        ),
                        child: FutureBuilder<FaYuanData?>(
                          future: (globalDB.select(globalDB.faYuan)
                                ..where((tbl) => tbl.id.equals(fayuanId)))
                              .getSingleOrNull(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return const SizedBox();
                            return Row(
                              children: [
                                Icon(Icons.auto_awesome,
                                    size: 18, color: design.colors.primary),
                                SizedBox(width: design.spacing.xs),
                                Expanded(
                                  child: Text(
                                    snapshot.data?.name ?? '',
                                    style:
                                        design.typography.sectionTitle.copyWith(
                                      color: design.textPrimaryOf(context),
                                    ),
                                  ),
                                ),
                                Text(
                                  '${fayuanItems.where((item) => _switchStates[item.id] == true).length}/${fayuanItems.length}',
                                  style: design.typography.caption.copyWith(
                                    color: design.textSecondaryOf(context),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      ...fayuanItems.asMap().entries.map((entry) {
                        final item = entry.value;
                        return Column(
                          children: [
                            if (entry.key > 0)
                              Divider(
                                  height: 1, color: design.borderOf(context)),
                            _buildTaskRow(item),
                          ],
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
    );
  }

  bool _hasDetailPage(GongKeItemData item) =>
      item.gongketype == 'songjing' ||
      item.gongketype == 'nianzhou' ||
      item.gongketype == 'nianshenghao' ||
      item.gongketype == 'dazuo';

  Future<void> _openTask(GongKeItemData item) async {
    if (!_canEdit) return;
    switch (item.gongketype) {
      case 'songjing':
        _navigateToPdfView(await getJingShuByName(item.name));
        break;
      case 'nianzhou':
        await Navigator.pushNamed(
          context,
          '/GongKe/GongKeSetting/nianzhou',
          arguments: {
            'gongkeitem': item,
            'onUpdated': () async {
              await updateCallback();
              await _refreshAllData();
            },
          },
        );
        break;
      case 'nianshenghao':
        await Navigator.pushNamed(
          context,
          '/GongKe/GongKeSetting/nianshenghao',
          arguments: {'gongkeitem': item},
        );
        break;
      case 'dazuo':
        await Navigator.pushNamed(
          context,
          '/GongKe/GongKeSetting/dazuo',
          arguments: {'gongkeitem': item},
        );
        break;
    }
  }

  Widget _buildTaskRow(GongKeItemData item) {
    final design = RcmTheme.of(context);
    final presentation = GongKeTypePresentation.of(item.gongketype);
    final complete = _switchStates[item.id] ?? false;
    final hasDetails = _hasDetailPage(item);
    return InkWell(
      onTap: _canEdit && hasDetails ? () => _openTask(item) : null,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: design.spacing.md,
          vertical: design.spacing.sm,
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: complete
                    ? design.colors.success.withOpacity(0.12)
                    : design.colors.accentSoft,
                borderRadius: BorderRadius.circular(design.radius.sm),
              ),
              child: Icon(
                presentation.icon,
                size: 20,
                color: complete ? design.colors.success : design.colors.primary,
              ),
            ),
            SizedBox(width: design.spacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: design.typography.body15Strong.copyWith(
                      color: design.textPrimaryOf(context),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${presentation.label} · 目标 ${item.cnt} ${presentation.unit}',
                    style: design.typography.caption.copyWith(
                      color: design.textSecondaryOf(context),
                    ),
                  ),
                ],
              ),
            ),
            if (hasDetails) ...[
              SizedBox(width: design.spacing.xs),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: design.textTertiaryOf(context),
              ),
            ],
            SizedBox(width: design.spacing.xs),
            Switch(
              value: complete,
              activeColor: design.colors.primary,
              onChanged: _canEdit
                  ? (value) async {
                      setState(() => _switchStates[item.id] = value);
                      await globalDB.managers.gongKeItem
                          .filter((t) => t.id.equals(item.id))
                          .update((o) => o(isComplete: Value(value)));
                      await syncTaskAndCalendarCards();
                      updateCallback();
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons() {
    // 如果不显示按钮，直接返回空容器
    if (!_showCompleteButton) {
      return const SizedBox.shrink();
    }

    final design = RcmTheme.of(context);
    return Row(
      children: [
        Expanded(
          child: RcmButton(
            icon: Icons.done_all,
            text: '全部完成',
            onPressed: _canEdit
                ? () async {
                    if (!mounted) return;
                    await _setAllComplete();
                    if (!mounted) return;
                    Navigator.pop(context);
                    updateCallback();
                  }
                : null,
          ),
        ),
        SizedBox(width: design.spacing.sm),
        Expanded(
          child: RcmButton(
            role: RcmButtonRole.secondary,
            icon: Icons.copy_outlined,
            text: '复制报课文本',
            onPressed: () {
              String gongkeText = '!!';
              for (var record in dayRecords) {
                if (_switchStates[record.id] == true) {
                  gongkeText += '${record.name}${record.cnt},';
                }
              }
              Clipboard.setData(ClipboardData(text: gongkeText));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('已复制到剪贴板')));
            },
          ),
        ),
      ],
    );
  }
}
