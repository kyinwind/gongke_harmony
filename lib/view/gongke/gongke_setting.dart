import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:gongke/database.dart';
import '../../main.dart';
import '../../comm/pdf_view.dart';
import '../../comm/pub_tools.dart';
import 'package:flutter/services.dart';

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

  void _setAllComplete() async {
    // 将当天所有任务标记为完成
    await globalDB.managers.gongKeItem
        .filter((item) => item.gongKeDay.equals(date))
        .update((o) => o(isComplete: const Value(true)));
  }

  void _updateEditState(String dateStr) {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final inputDate = DateTime.parse(dateStr);

    setState(() {
      // 只有今天和昨天可以编辑
      _canEdit =
          inputDate.year == today.year &&
          inputDate.month == today.month &&
          (inputDate.day == today.day || inputDate.day == yesterday.day);

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
    return Scaffold(
      appBar: AppBar(title: Text('功课设置')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  '当天功课完成情况设定',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                IconButton(
                  icon: const Icon(Icons.share),
                  color: Colors.blue,
                  iconSize: 35,
                  onPressed: () {
                    // 跳转到新增页面
                    Navigator.pushNamed(context, '/ShareCardPage');
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),
            _buildDateCard(),
            const SizedBox(height: 12),
            _buildTaskList(),
            const SizedBox(height: 12),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  String getGongkeItemLabel(GongKeItemData item) {
    return '${getLabelSafely(item.gongketype)}: ${item.name} ${item.cnt} ${getDanWei(item.gongketype)}';
  }

  Widget _buildDateCard() {
    return Card(
      color: const Color(0xFFF5F6FA),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined),
            const SizedBox(width: 8),
            const Text("功课设定："),
            const Spacer(),
            Text(date, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  // 跳转到PDF页面
  void _navigateToPdfView(JingShuData jingshu) async {
    //根据pdfname找到经书
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PdfViewerPage(jingshu: jingshu)),
    );
  }

  Widget _buildTaskList() {
    return Expanded(
      child: Card(
        color: const Color(0xFFF5F6FA),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListView.builder(
          itemCount: dayRecordsGroupedByFaYuan.length,
          itemBuilder: (context, index) {
            int fayuanId = dayRecordsGroupedByFaYuan.keys.elementAt(index);
            List<GongKeItemData> fayuanItems =
                dayRecordsGroupedByFaYuan[fayuanId]!;

            return Column(
              children: [
                // 发愿标题
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(16.0),
                  child: FutureBuilder<FaYuanData?>(
                    future: globalDB.managers.faYuan
                        .filter((f) => f.id.equals(fayuanId))
                        .getSingleOrNull(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox();
                      return Text(
                        snapshot.data?.name ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                // 功课项目列表
                ...fayuanItems.map(
                  (item) => SwitchListTile(
                    value: _switchStates[item.id] ?? false,
                    onChanged: _canEdit
                        ? (value) async {
                            setState(() {
                              _switchStates[item.id] = value;
                            });
                            await globalDB.managers.gongKeItem
                                .filter((t) => t.id.equals(item.id))
                                .update((o) => o(isComplete: Value(value)));
                            updateCallback();
                          }
                        : null,
                    title: LayoutBuilder(
                      builder: (context, constraints) {
                        return Container(
                          width: constraints.maxWidth,
                          child: GestureDetector(
                            onTap: () async {
                              if (!_canEdit) return;
                              switch (item.gongketype) {
                                case 'songjing':
                                  JingShuData jingshu = await getJingShuByName(
                                    item.name,
                                  );
                                  _navigateToPdfView(jingshu);
                                  break;
                                case 'nianzhou':
                                  Navigator.pushNamed(
                                    context,
                                    '/GongKe/GongKeSetting/nianzhou',
                                    arguments: {
                                      'gongkeitem': item,
                                      'onUpdated': () async {
                                        // 这里是你希望子页面执行完后调用的刷新函数
                                        await updateCallback(); //先让gongke页面刷新数据，更新groupedCurrentMonthRecords
                                        await _refreshAllData(); // 再刷新当前页面数据
                                        setState(() {});
                                      },
                                    },
                                  );
                                  break;
                                case 'nianshenghao':
                                  Navigator.pushNamed(
                                    context,
                                    '/GongKe/GongKeSetting/nianshenghao',
                                    arguments: {'gongkeitem': item},
                                  );
                                  break;
                                case 'ketou':
                                  break;
                                case 'baichan':
                                  break;
                                case 'dazuo':
                                  Navigator.pushNamed(
                                    context,
                                    '/GongKe/GongKeSetting/dazuo',
                                    arguments: {'gongkeitem': item},
                                  );
                                  break;
                                default:
                                  // 其他类型不做处理
                                  break;
                              }
                            },
                            child: Text(
                              getGongkeItemLabel(item),
                              style: TextStyle(
                                color:
                                    item.gongketype == 'songjing' ||
                                        item.gongketype == 'nianzhou' ||
                                        item.gongketype == 'nianshenghao' ||
                                        item.gongketype == 'dazuo'
                                    ? Colors.blue
                                    : Colors.black,
                              ),
                              softWrap: true,
                              maxLines: 2, // 允许最多2行
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      },
                    ),
                    subtitle: Text(
                      _switchStates[item.id] == true ? '已完成' : '未完成',
                    ),
                    secondary: const Icon(Icons.chevron_right),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 0,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildButtons() {
    // 如果不显示按钮，直接返回空容器
    if (!_showCompleteButton) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        const SizedBox(width: 30),
        Expanded(
          flex: 2,
          child: Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 200,
              child: ElevatedButton(
                style: AppButtonStyle.primaryButton,
                onPressed: _canEdit
                    ? () {
                        if (!mounted) return;
                        _setAllComplete();
                        Navigator.pop(context);
                        updateCallback();
                      }
                    : null, // 不可编辑时禁用按钮
                child: const Text(
                  '全部完成',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 30),
        Expanded(
          flex: 2,
          child: Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 200,
              child: ElevatedButton(
                style: AppButtonStyle.primaryButton,
                onPressed: () {
                  String gongkeText = '!!';
                  for (var record in dayRecords) {
                    if (record.isComplete) {
                      gongkeText += '${record.name}${record.cnt},';
                    }
                  }
                  Clipboard.setData(ClipboardData(text: gongkeText));
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('已复制到剪贴板')));
                },
                child: const Text(
                  '报课文本',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 30),
      ],
    );
  }
}
