import 'package:flutter/material.dart';
import 'package:my_flutter_app_tools/my_flutter_app_tools.dart';
import '../../comm/date_tools.dart';
import '../../comm/gongke_type_presentation.dart';
import '../../main.dart';

class GongKeStatPage extends StatefulWidget {
  const GongKeStatPage({super.key});

  @override
  State<GongKeStatPage> createState() => _GongKeStatPageState();
}

class _GongKeStatPageState extends State<GongKeStatPage> {
  // 日期范围控制
  late DateTime _startDate;
  late DateTime _endDate;

  // 统计数据
  int totalDays = 0; // 总天数
  int planDays = 0; // 计划做功课的天数
  int practiceDays = 0; // 坚持做功课的天数
  Map<String, int> gongkeStats = {};

  @override
  void initState() {
    super.initState();
    // 初始化日期范围（今天到一个月前）
    _endDate = DateTime.now();
    _startDate = _endDate.subtract(const Duration(days: 30));
    _loadStats();
  }

  Future<void> _loadStats() async {
    final start = DateUtils.dateOnly(_startDate);
    final end = DateUtils.dateOnly(_endDate);
    // 计算总天数
    totalDays = end.difference(start).inDays + 1;

    final records = await globalDB.select(globalDB.gongKeItem).get();
    // 过滤出在指定日期范围内的记录
    final filteredRecords = records.where((record) {
      final recordDate = DateTime.parse(record.gongKeDay);
      return !recordDate.isBefore(start) && !recordDate.isAfter(end);
    }).toList();
    // 统计计划做功课的天数（去重）
    final planDates =
        filteredRecords.map((e) => e.gongKeDay).toSet(); // 使用 Set 去重
    planDays = planDates.length;
    // 统计功课天数（去重，只统计已完成的记录）
    final practiceDates = filteredRecords
        .where((record) => record.isComplete)
        .map((e) => e.gongKeDay)
        .toSet();
    practiceDays = practiceDates.length;
    // 按类型和名称分组统计功课数量
    gongkeStats.clear();
    for (var record in filteredRecords) {
      if (record.isComplete) {
        final key = '${record.gongketype}|${record.name}';
        gongkeStats[key] = (gongkeStats[key] ?? 0) + record.cnt.toInt();
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  Widget _buildDateRangePicker() {
    final design = RcmTheme.of(context);
    return Container(
      padding: EdgeInsets.all(design.spacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(design.radius.lg),
        border: Border.all(color: design.colors.primary.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: design.colors.accentSoft,
                foregroundColor: design.colors.primary,
                child: const Icon(Icons.date_range_rounded),
              ),
              SizedBox(width: design.spacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('统计时间范围',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          )),
                  Text('点击日期可重新选择',
                      style: TextStyle(
                          color: design.textSecondaryOf(context),
                          fontSize: 13)),
                ],
              ),
            ],
          ),
          SizedBox(height: design.spacing.md),
          Row(
            children: [
              Expanded(
                child: _dateButton(
                  label: '开始日期',
                  date: _startDate,
                  onTap: _selectStartDate,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: design.spacing.sm),
                child: Icon(Icons.arrow_forward_rounded,
                    size: 20, color: design.textSecondaryOf(context)),
              ),
              Expanded(
                child: _dateButton(
                  label: '截止日期',
                  date: _endDate,
                  onTap: _selectEndDate,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dateButton({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    final design = RcmTheme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(design.radius.md),
      child: Container(
        padding: EdgeInsets.all(design.spacing.sm),
        decoration: BoxDecoration(
          color: design.colors.accentSoft,
          borderRadius: BorderRadius.circular(design.radius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    color: design.textSecondaryOf(context), fontSize: 12)),
            const SizedBox(height: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(DateTools.getDateStringByDate(date),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: _endDate,
    );
    if (date == null || !mounted) return;
    setState(() => _startDate = date);
    await _loadStats();
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now(),
    );
    if (date == null || !mounted) return;
    setState(() => _endDate = date);
    await _loadStats();
  }

  Widget _buildStatistics() {
    final design = RcmTheme.of(context);
    final completionRate = planDays == 0 ? 0 : practiceDays / planDays;
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(design.spacing.md),
          decoration: BoxDecoration(
            color: design.colors.accentSoft,
            borderRadius: BorderRadius.circular(design.radius.lg),
            border: Border.all(color: design.colors.primary.withOpacity(0.14)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 76,
                    height: 76,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox.expand(
                          child: CircularProgressIndicator(
                            value: completionRate.toDouble(),
                            strokeWidth: 7,
                            backgroundColor:
                                design.colors.primary.withOpacity(0.12),
                            color: design.colors.primary,
                          ),
                        ),
                        Text('${(completionRate * 100).round()}%',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                  SizedBox(width: design.spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('坚持完成率',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(
                          planDays == 0
                              ? '这段时间没有安排功课'
                              : '计划 $planDays 天，已坚持 $practiceDays 天',
                          style:
                              TextStyle(color: design.textSecondaryOf(context)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: design.spacing.md),
              Row(
                children: [
                  Expanded(
                      child: _metric('统计天数', '$totalDays', '天',
                          Icons.calendar_month_outlined)),
                  Expanded(
                      child: _metric(
                          '计划天数', '$planDays', '天', Icons.event_note_outlined)),
                  Expanded(
                      child: _metric('坚持天数', '$practiceDays', '天',
                          Icons.local_fire_department_outlined)),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: design.spacing.md),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(design.spacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(design.radius.lg),
            border: Border.all(color: design.colors.primary.withOpacity(0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.bar_chart_rounded, color: design.colors.primary),
                  const SizedBox(width: 8),
                  Text('已完成功课',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          )),
                ],
              ),
              SizedBox(height: design.spacing.sm),
              if (gongkeStats.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: design.spacing.lg),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.inbox_outlined,
                            size: 44, color: design.textSecondaryOf(context)),
                        const SizedBox(height: 8),
                        Text('所选时间内暂无已完成功课',
                            style: TextStyle(
                                color: design.textSecondaryOf(context))),
                      ],
                    ),
                  ),
                )
              else
                ...gongkeStats.entries.map((entry) {
                  final separator = entry.key.indexOf('|');
                  final type = separator < 0
                      ? 'others'
                      : entry.key.substring(0, separator);
                  final name = separator < 0
                      ? entry.key
                      : entry.key.substring(separator + 1);
                  final presentation = GongKeTypePresentation.of(type);
                  return Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: EdgeInsets.all(design.spacing.sm),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withOpacity(0.45),
                      borderRadius: BorderRadius.circular(design.radius.md),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: design.colors.accentSoft,
                          foregroundColor: design.colors.primary,
                          child: Icon(presentation.icon, size: 21),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              Text(presentation.label,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: design.textSecondaryOf(context))),
                            ],
                          ),
                        ),
                        Text('${entry.value} ${presentation.unit}',
                            style: TextStyle(
                                color: design.colors.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _metric(String label, String value, String unit, IconData icon) {
    final design = RcmTheme.of(context);
    return Column(
      children: [
        Icon(icon, size: 20, color: design.colors.primary),
        const SizedBox(height: 4),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                  text: value,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800)),
              TextSpan(text: ' $unit', style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
        Text(label,
            style: TextStyle(
                color: design.textSecondaryOf(context), fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final design = RcmTheme.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('功课统计'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          design.spacing.md,
          design.spacing.xs,
          design.spacing.md,
          design.spacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('修持回顾',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    )),
            const SizedBox(height: 4),
            Text('查看一段时间内的坚持情况和功课总量',
                style: TextStyle(color: design.textSecondaryOf(context))),
            SizedBox(height: design.spacing.md),
            _buildDateRangePicker(),
            SizedBox(height: design.spacing.md),
            _buildStatistics(),
          ],
        ),
      ),
    );
  }
}

// 添加一个辅助类来处理统计数据
class GongKeStats {
  final String type;
  final String name;
  final int count;

  GongKeStats({required this.type, required this.name, required this.count});
}
