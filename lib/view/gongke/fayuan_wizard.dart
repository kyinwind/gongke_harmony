import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column;
//import 'package:gongke/database.dart';
//import '../../database.dart';
import '../../main.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../comm/date_tools.dart';
import '../../comm/shared_preferences.dart';
import '../../comm/pub_tools.dart';

class VMFaYuanData {
  String? name; // 发愿名称
  String? fodiziName; // 佛弟子名称
  DateTime? startDate; // 开始日期
  DateTime? endDate; // 结束日期
  List<VMGongKeItemOneDayData> gkiODList = []; // 每日功课列表
  String? yuanwang; // 愿望内容
  String? fayuanwen; // 发愿文

  bool isBaseValid() {
    return name?.isNotEmpty == true && fodiziName?.isNotEmpty == true;
  }

  bool isDateValid() {
    //print('isDateValid: startDate=$startDate, endDate=$endDate');
    if (startDate == null || endDate == null) return false;
    // 确保结束日期不早于开始日期
    if (endDate!.isBefore(startDate!)) return false;
    return true;
  }

  bool isGongKeValid() {
    return gkiODList.isNotEmpty;
  }

  int getDurationDays() {
    if (startDate == null || endDate == null) return 0;
    //为了计算相隔时间准确，要把起始时间的日期不变，时间部分归零。
    startDate = DateTime(startDate!.year, startDate!.month, startDate!.day);
    endDate = DateTime(endDate!.year, endDate!.month, endDate!.day);
    return endDate!.difference(startDate!).inDays + 1;
  }
}

class VMGongKeItemOneDayData {
  GongKeType gongketype; // 功课类型
  String name; // 功课名称
  int cnt; // 数量
  int idx; // 序号，表示在每日功课中的位置

  VMGongKeItemOneDayData({
    required this.gongketype,
    required this.name,
    required this.cnt,
    required this.idx,
  });
}

class FaYuanWizardPage extends StatefulWidget {
  const FaYuanWizardPage({super.key});

  @override
  State<FaYuanWizardPage> createState() => _FaYuanWizardPageState();
}

class _FaYuanWizardPageState extends State<FaYuanWizardPage> {
  String? actType; // 'A'表示新增，'M'表示修改
  int? fayuanId;

  int _currentStep = 0;
  final VMFaYuanData _data = VMFaYuanData();
  final _formKey = GlobalKey<FormState>();
  final List<int> _monthOptions = List.generate(12, (i) => i + 1);

  // 修改控制器的初始化方式
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  // 添加状态变量跟踪时长
  int _durationDays = 0;

  // 添加 controller 作为类成员
  late TextEditingController nameController;
  late TextEditingController fodiziNameController;
  // 添加初始化标记，避免重复初始化
  bool _initialized = false; // 添加初始化标记

  @override
  void initState() {
    super.initState();
    // 初始化 controllers
    nameController = TextEditingController();
    fodiziNameController = TextEditingController();
    // 不需要在这里初始化控制器了
    _data.startDate = DateTime.now();
  }

  @override
  void didChangeDependencies() {
    if (!_initialized) {
      // 只在首次初始化时执行
      super.didChangeDependencies();
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic> &&
          args['acttype'] != null &&
          args['fayuanId'] != null) {
        actType = args['acttype'];
        fayuanId = args['fayuanId'];
        _loadExistingData();
      } else {
        actType = 'A';
        fayuanId = null;
        _loadInitialValues();
      }
      _initialized = true; // 标记已初始化
    }
  }

  @override
  void dispose() {
    // 释放 controllers
    nameController.dispose();
    fodiziNameController.dispose();
    // 释放 controller
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  // 在加载数据后更新控制器的值
  Future<void> _loadExistingData() async {
    //print('--------------------------------_loadExistingData----');
    final fayuan = await globalDB.managers.faYuan
        .filter((t) => t.id(fayuanId!))
        .getSingle();

    // 移除这个 setState，使用单个 setState
    _data.name = fayuan.name;
    nameController.text = fayuan.name;
    _data.fodiziName = fayuan.fodiziname;
    fodiziNameController.text = fayuan.fodiziname;
    _data.startDate = fayuan.startDate;
    _data.endDate = fayuan.endDate;
    _data.yuanwang = fayuan.yuanwang;

    final items = await globalDB.managers.gongKeItemsOneDay
        .filter((t) => t.fayuanId(fayuanId!))
        .get();

    setState(() {
      // 在这里统一更新状态
      _data.gkiODList = items
          .map(
            (item) => VMGongKeItemOneDayData(
              gongketype: GongKeType.values.firstWhere(
                (t) => t.name == item.gongketype,
              ),
              name: item.name,
              cnt: item.cnt,
              idx: item.idx,
            ),
          )
          .toList();

      // 在最后调用一次 _updateDateControllers
      _updateDateControllers();
    });
  }

  // 修改 _loadInitialValues 方法
  Future<void> _loadInitialValues() async {
    // 1. 先获取所有异步数据
    final name = await getStringValue('fayuanName');
    final fodiziName = await getStringValue('fodiziName');
    final yuanwang = await getStringValue('yuanwang');
    late DateTime startDate, endDate;
    // 2. 获取当前日期作为默认起始日期
    startDate = DateTime.now();
    endDate = DateTools.getDateAfterDays(startDate, 30); // 默认30天后

    // 3. 在 setState 中同步更新状态
    setState(() {
      _data.name = name;
      nameController.text = name ?? '';
      _data.fodiziName = fodiziName;
      fodiziNameController.text = fodiziName ?? '';
      _data.yuanwang = yuanwang;
      // 如果没有有效的日期，则使用默认值
      _data.startDate ??= startDate;
      _data.endDate ??= endDate;

      //print('------------------loadInitialValues----');
      //print('startDate: $startDate');
      //print('endDate: $endDate');
      //print('_data.startDate: ${_data.startDate}');
      //print('_data.endDate: ${_data.endDate}');
      startDateController.text = DateTools.getStringByDate(_data.startDate!);
      endDateController.text = DateTools.getStringByDate(_data.endDate!);
    });
  }

  Widget _buildStep1() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(labelText: '发愿名称'),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return '请输入发愿名称';
              }
              return null;
            },
            onSaved: (value) {
              _data.name = value;
              saveStringValue('fayuanName', _data.name ?? '');
            },
          ),
          TextFormField(
            controller: fodiziNameController,
            decoration: const InputDecoration(labelText: '佛弟子名称'),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return '请输入佛弟子名称';
              }
              return null;
            },
            onSaved: (value) {
              _data.fodiziName = value;
              saveStringValue('fodiziName', _data.fodiziName ?? '');
            },
          ),
        ],
      ),
    );
  }

  // 修改 _updateDateControllers 方法
  void _updateDateControllers() {
    // print('Updating date controllers...');
    // print('1 Start Date: ${_data.startDate}');
    // print('1 End Date: ${_data.endDate}');
    // print('1 Duration Days: $_durationDays');
    startDateController.text = _data.startDate != null
        ? DateTools.getDateStringByDate(_data.startDate!)
        : '';
    endDateController.text = _data.endDate != null
        ? DateTools.getDateStringByDate(_data.endDate!)
        : '';
    _durationDays = _data.getDurationDays(); // 更新时长
    // print('2 Start Date: ${_data.startDate}');
    // print('2 End Date: ${_data.endDate}');
    // print('2 Duration Days: $_durationDays');
  }

  Widget _buildStep2() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                readOnly: true,
                controller: startDateController,
                decoration: const InputDecoration(labelText: '起始日期'),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _data.startDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setState(() {
                      _data.startDate = date;
                      _updateDateControllers(); // 更新显示
                    });
                    //print(_data.startDate);
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: '持续月数'),
                items: _monthOptions.map((month) {
                  return DropdownMenuItem(
                    value: month,
                    child: Text('$month个月'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null && _data.startDate != null) {
                    setState(() {
                      // 直接更新 endDate，不调用 _updateDateControllers
                      final endDate = DateTime(
                        _data.startDate!.year,
                        _data.startDate!.month + value,
                        _data.startDate!.day,
                      );
                      _data.endDate = endDate.subtract(const Duration(days: 1));
                      endDateController.text = DateTools.getDateStringByDate(
                        _data.endDate!,
                      );
                      _durationDays = _data.getDurationDays();
                    });
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          readOnly: true,
          controller: endDateController,
          decoration: const InputDecoration(labelText: '截止日期'),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _data.endDate ?? DateTime.now(),
              firstDate: _data.startDate ?? DateTime.now(),
              lastDate: DateTime(2100),
            );
            if (date != null) {
              setState(() {
                _data.endDate = date;
                _updateDateControllers(); // 更新显示
              });
            }
          },
        ),
        const SizedBox(height: 16),
        Builder(
          builder: (context) {
            _durationDays = _data.getDurationDays();
            return Text('发愿时长：$_durationDays天'); // 直接使用状态变量
          },
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _data.gkiODList.length,
          itemBuilder: (context, index) {
            final item = _data.gkiODList[index];
            return Slidable(
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) {
                      setState(() {
                        _data.gkiODList.removeAt(index);
                      });
                    },
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: '删除',
                  ),
                ],
              ),
              child: ListTile(
                title: Text(item.name),
                subtitle: Text('${item.gongketype.label} x ${item.cnt}'),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              style: AppButtonStyle.primaryButton,
              onPressed: () => _showAddGongKeDialog(),
              child: const Text('新增功课'),
            ),
            ElevatedButton(
              style: AppButtonStyle.primaryButton,
              onPressed: () => _showCopyGongKeDialog(),
              child: const Text('复制功课'),
            ),
          ],
        ),
      ],
    );
  }

  String getFaYuanWen() {
    var gongketext = "弟子每天\n";
    var cnt = 0;

    if (_data.fodiziName?.isEmpty == true || _data.yuanwang?.isEmpty == true) {
      return "未完成发愿设置，请完成发愿设置";
    }

    for (var i = 0; i < _data.gkiODList.length; i++) {
      var rec = _data.gkiODList[i];
      cnt = rec.cnt;
      gongketext +=
          "(${i + 1})${rec.gongketype.label}${rec.name}${cnt}${getDanWeiByLabel(rec.gongketype.label)}。";
      if (i < _data.gkiODList.length - 1) {
        gongketext += "\n";
      }
    }

    var fayuanwen = "今佛弟子${_data.fodiziName}发愿：\n";
    fayuanwen += "  在从${DateTools.getDateStringByDate(_data.startDate!)}";
    fayuanwen += "到${DateTools.getDateStringByDate(_data.endDate!)}";
    fayuanwen += "共${_data.getDurationDays()}天内，";
    fayuanwen += gongketext;
    fayuanwen += "\n  以此功德回向，请佛菩萨加持弟子实现愿望：\n${_data.yuanwang}\n  请佛菩萨可许则许。";

    _data.fayuanwen = fayuanwen;
    return fayuanwen;
  }

  Future<void> _showCopyGongKeDialog() async {
    final allItems = await globalDB.managers.gongKeItemsOneDay.get();
    final uniqueItems = <String>{};
    final itemMap = <String, VMGongKeItemOneDayData>{};
    final selectedItems = <String>{}; // 移到这里

    for (var item in allItems) {
      final displayText = '${item.name} x ${item.cnt}';
      uniqueItems.add(displayText);
      itemMap[displayText] = VMGongKeItemOneDayData(
        gongketype: GongKeType.values.firstWhere(
          (t) => t.name == item.gongketype,
        ),
        name: item.name,
        cnt: item.cnt,
        idx: item.idx,
      );
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        // 添加 StatefulBuilder
        builder: (context, setState) => AlertDialog(
          title: const Text('复制功课'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: uniqueItems.length,
              itemBuilder: (context, index) {
                final item = uniqueItems.elementAt(index);
                return CheckboxListTile(
                  title: Text(item),
                  value: selectedItems.contains(item),
                  onChanged: (bool? value) {
                    setState(() {
                      // 使用 StatefulBuilder 的 setState
                      if (value == true) {
                        selectedItems.add(item);
                      } else {
                        selectedItems.remove(item);
                      }
                    });
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                // 将选中的项目添加到功课列表
                for (var selected in selectedItems) {
                  if (itemMap.containsKey(selected)) {
                    final item = itemMap[selected]!;
                    setState(() {
                      _data.gkiODList.add(
                        VMGongKeItemOneDayData(
                          gongketype: item.gongketype,
                          name: item.name,
                          cnt: item.cnt,
                          idx: _data.gkiODList.length + 1,
                        ),
                      );
                    });
                  }
                }
                Navigator.pop(context);
              },
              child: const Text('确定'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddGongKeDialog() async {
    GongKeType? selectedType;
    String? selectedJingShu;
    final TextEditingController nameController = TextEditingController();
    final TextEditingController cntController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('添加功课'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 功课类型下拉框
              DropdownButtonFormField<GongKeType>(
                decoration: const InputDecoration(labelText: '功课类型'),
                value: selectedType,
                items: GongKeType.values.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type.label));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedType = value;
                    // 清除之前的选择或输入
                    selectedJingShu = null;
                    nameController.clear();
                  });
                },
              ),
              const SizedBox(height: 16),

              // 根据选择的类型显示不同的输入方式
              if (selectedType == GongKeType.songjing)
                // 经书下拉列表
                FutureBuilder<Map<String, String>>(
                  future: getJingShuFiles(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: '选择经书'),
                        value: selectedJingShu,
                        items: snapshot.data!.keys.map((name) {
                          return DropdownMenuItem(
                            value: name,
                            child: Text(name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedJingShu = value;
                          });
                        },
                      );
                    }
                    return const CircularProgressIndicator();
                  },
                )
              else if (selectedType != null)
                // 其他类型显示输入框
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: '功课名称'),
                ),

              const SizedBox(height: 16),
              // 数量输入框
              TextField(
                controller: cntController,
                decoration: InputDecoration(
                  labelText: selectedType != null
                      ? '数量（${getDanWeiByLabel(selectedType!.label)}）'
                      : '数量',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                if (selectedType == null) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('请选择功课类型')));
                  return;
                }

                final String name;
                if (selectedType == GongKeType.songjing) {
                  if (selectedJingShu == null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('请选择经书')));
                    return;
                  }
                  name = selectedJingShu!;
                } else {
                  if (nameController.text.isEmpty) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('请输入功课名称')));
                    return;
                  }
                  name = nameController.text;
                }
                if (cntController.text.isEmpty) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('请输入功课数量')));
                  return;
                }
                final cnt = int.tryParse(cntController.text);
                if (cnt == null || cnt <= 0) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('请输入有效的整数')));
                  return;
                }

                // 添加功课
                setState(() {
                  _data.gkiODList.add(
                    VMGongKeItemOneDayData(
                      gongketype: selectedType!,
                      name: name,
                      cnt: int.parse(cntController.text),
                      idx: _data.gkiODList.length + 1,
                    ),
                  );
                });

                Navigator.pop(context);
              },
              child: const Text('确定'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep4() {
    return TextFormField(
      // 使用 controller 替代 initialValue
      controller: TextEditingController(text: _data.yuanwang),
      decoration: const InputDecoration(
        labelText: '发愿',
        hintText: '请输入您的愿望...',
      ),
      maxLines: 5,
      onChanged: (value) {
        _data.yuanwang = value;
        saveStringValue('yuanwang', _data.yuanwang ?? '');
      },
    );
  }

  Widget _buildStep5() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('发愿名称：${_data.name}'),
        Text('佛弟子名称：${_data.fodiziName}'),
        Text('起始日期：${_data.startDate?.toString().split(' ')[0]}'),
        Text('截止日期：${_data.endDate?.toString().split(' ')[0]}'),
        Text('发愿时长：${_data.getDurationDays()}天'),
        const Divider(),
        const Text('每日功课：'),
        ..._data.gkiODList.map(
          (item) =>
              Text('${item.gongketype.label} - ${item.name} x ${item.cnt}'),
        ),
        const Divider(),
        Text('愿望：${_data.yuanwang}'),
      ],
    );
  }

  Future<void> _handleSave() async {
    // 将 newFaYuanId 移到事务内部声明
    await globalDB.transaction(() async {
      int currentFaYuanId;
      _data.fayuanwen = getFaYuanWen();
      if (actType == 'M' && fayuanId != null) {
        // 修改模式
        currentFaYuanId = fayuanId!;
        // 删除原有记录
        await globalDB.managers.gongKeItem
            .filter((t) => t.fayuanId(currentFaYuanId))
            .delete();
        await globalDB.managers.gongKeItemsOneDay
            .filter((t) => t.fayuanId(currentFaYuanId))
            .delete();

        // 更新现有发愿记录
        await globalDB.managers.faYuan
            .filter((f) => f.id.equals(currentFaYuanId))
            .update(
              (o) => o(
                name: Value(_data.name!),
                fodiziname: Value(_data.fodiziName!),
                startDate: Value(_data.startDate!),
                endDate: Value(_data.endDate!),
                yuanwang: Value(_data.yuanwang ?? ''),
                fayuanwen: Value(_data.fayuanwen ?? ''),
              ),
            );
      } else {
        // 新增模式
        currentFaYuanId = await globalDB.managers.faYuan.create(
          (o) => o(
            name: _data.name!,
            fodiziname: _data.fodiziName!,
            startDate: _data.startDate!,
            endDate: _data.endDate!,
            yuanwang: _data.yuanwang ?? '',
            fayuanwen: _data.fayuanwen ?? '',
            remarks: Value(''),
          ),
        );
      }

      // 插入每日功课
      for (var item in _data.gkiODList) {
        await globalDB.managers.gongKeItemsOneDay.create(
          (o) => o(
            fayuanId: currentFaYuanId, // 使用 currentFaYuanId
            gongketype: Value(item.gongketype.name),
            name: item.name,
            cnt: Value(item.cnt),
            idx: Value(_data.gkiODList.indexOf(item) + 1),
          ),
        );
      }
      String gongkedaystr = '';
      bool iscomplete = false;
      // 插入具体功课记录
      for (var day = 0; day < _data.getDurationDays(); day++) {
        for (var item in _data.gkiODList) {
          gongkedaystr = DateTools.getDateStringByDate(
            DateTools.getDateAfterDays(_data.startDate ?? DateTime.now(), day),
          );
          if (DateTools.getDateByString(
            gongkedaystr,
            'yyyy-MM-dd',
          ).isBefore(DateTime.now())) {
            if (gongkedaystr == DateTools.getDateStringByDate(DateTime.now())) {
              iscomplete = false;
            } else {
              // 如果日期早于今天，则设置为已完成
              iscomplete = true;
            }
          } else {
            iscomplete = false;
          }
          await globalDB.managers.gongKeItem.create(
            (o) => o(
              fayuanId: currentFaYuanId, // 使用 currentFaYuanId
              gongKeDay: gongkedaystr,
              gongketype: item.gongketype.name,
              name: item.name,
              cnt: Value(item.cnt),
              isComplete: Value(iscomplete),
              idx: Value(item.idx),
            ),
          );
        }
      }
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('发愿${actType == 'A' ? '新增' : '修改'}')),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 4) {
            switch (_currentStep) {
              case 0:
                if (_formKey.currentState?.validate() ?? false) {
                  _formKey.currentState?.save();
                  setState(() => _currentStep++);
                }
                break;
              case 1:
                if (_data.isDateValid()) {
                  setState(() => _currentStep++);
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('请选择起始日期和截止日期')));
                }
                break;
              case 2:
                if (_data.isGongKeValid()) {
                  setState(() => _currentStep++);
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('请至少添加一个功课')));
                }
                break;
              default:
                setState(() => _currentStep++);
            }
          } else {
            _handleSave();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          }
        },
        steps: [
          Step(title: const Text('基本信息'), content: _buildStep1()),
          Step(title: const Text('时间选择'), content: _buildStep2()),
          Step(title: const Text('功课设定'), content: _buildStep3()),
          Step(title: const Text('愿望'), content: _buildStep4()),
          Step(title: const Text('发愿确认'), content: _buildStep5()),
        ],
        controlsBuilder: (context, controls) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            children: [
              const Spacer(),
              if (_currentStep > 0) ...[
                const SizedBox(width: 8),
                ElevatedButton(
                  style: AppButtonStyle.primaryButton,
                  onPressed: controls.onStepCancel,
                  child: const Text('上一步'),
                ),
              ],
              const Spacer(),
              ElevatedButton(
                style: AppButtonStyle.primaryButton,
                onPressed: controls.onStepContinue,
                child: Text(_currentStep < 4 ? '下一步' : '保存'),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
