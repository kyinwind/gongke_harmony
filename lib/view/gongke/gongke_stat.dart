import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' hide Column;
import '../../database.dart';
import '../../comm/date_tools.dart';
import '../../main.dart';
import '../../comm/pub_tools.dart';

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
    // 计算总天数
    totalDays = _endDate.difference(_startDate).inDays + 1;

    final records = await globalDB.managers.gongKeItem.get();
    // 过滤出在指定日期范围内的记录
    final filteredRecords = records.where((record) {
      final recordDate = DateTime.parse(record.gongKeDay);
      return recordDate.isAfter(_startDate.subtract(const Duration(days: 1))) &&
          recordDate.isBefore(_endDate);
    }).toList();
    // 统计计划做功课的天数（去重）
    final planDates = filteredRecords
        .map((e) => e.gongKeDay)
        .toSet(); // 使用 Set 去重
    planDays = planDates.length;
    // 统计功课天数（去重，只统计已完成的记录）
    final practiceDates = filteredRecords
        .where((record) => record.isComplete)
        .map((e) => e.gongKeDay)
        .toSet();
    practiceDays = practiceDates.length;
    print(practiceDates.toString());
    // 按类型和名称分组统计功课数量
    gongkeStats.clear();
    for (var record in filteredRecords) {
      if (record.isComplete) {
        final key = '${getLabelSafely(record.gongketype)}:${record.name}';
        gongkeStats[key] = (gongkeStats[key] ?? 0) + record.cnt.toInt();
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  Widget _buildDateRangePicker() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('选择统计时间范围:', style: TextStyle(fontSize: 16)),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: '起始日期'),
                    controller: TextEditingController(
                      text: DateTools.getDateStringByDate(_startDate),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime(2020),
                        lastDate: _endDate,
                      );
                      if (date != null) {
                        setState(() {
                          _startDate = date;
                          _loadStats();
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: '截止日期'),
                    controller: TextEditingController(
                      text: DateTools.getDateStringByDate(_endDate),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _endDate,
                        firstDate: _startDate,
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _endDate = date;
                          _loadStats();
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    return Card(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '一、时间统计\n从${DateTools.getDateStringByDate(_startDate)}到${DateTools.getDateStringByDate(_endDate)}'
                '共$totalDays天,$planDays天做了功课计划，其中有$practiceDays天坚持做了功课',
              ),
              const SizedBox(height: 16),
              const Text('二、功课完成情况：\n在此期间您共:'),
              const SizedBox(height: 8),
              ...gongkeStats.entries.map((entry) {
                final parts = entry.key.split(':');
                return Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 8),
                  child: Text(
                    '${parts[0]}: ${parts[1]} ${entry.value}${getDanWeiByLabel(parts[0])}',
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('功课统计')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDateRangePicker(),
            const SizedBox(height: 16),
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
