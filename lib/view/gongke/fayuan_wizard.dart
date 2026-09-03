import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column;
import '../../database.dart';
//import 'package:gongke/database.dart';
//import '../../database.dart';
import '../../main.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../comm/date_tools.dart';
import '../../comm/shared_preferences.dart';
import '../../comm/pub_tools.dart';
import '../../comm/widget_sync_hooks.dart';
import '../../comm/gongke_type_presentation.dart';
import 'package:my_flutter_app_tools/my_flutter_app_tools.dart';

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

  // 添加 controller 作为类成员
  late TextEditingController nameController;
  late TextEditingController fodiziNameController;
  late TextEditingController yuanwangController;
  // 添加初始化标记，避免重复初始化
  bool _initialized = false; // 添加初始化标记
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // 初始化 controllers
    nameController = TextEditingController();
    fodiziNameController = TextEditingController();
    yuanwangController = TextEditingController();
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
    yuanwangController.dispose();
    // 释放 controller
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  // 在加载数据后更新控制器的值
  Future<void> _loadExistingData() async {
    //print('--------------------------------_loadExistingData----');
    final fayuan = await (globalDB.select(globalDB.faYuan)
          ..where((tbl) => tbl.id.equals(fayuanId!)))
        .getSingle();

    // 移除这个 setState，使用单个 setState
    _data.name = fayuan.name;
    nameController.text = fayuan.name;
    _data.fodiziName = fayuan.fodiziname;
    fodiziNameController.text = fayuan.fodiziname;
    _data.startDate = fayuan.startDate;
    _data.endDate = fayuan.endDate;
    _data.yuanwang = fayuan.yuanwang;
    yuanwangController.text = fayuan.yuanwang;

    final items = await (globalDB.select(globalDB.gongKeItemsOneDay)
          ..where((tbl) => tbl.fayuanId.equals(fayuanId!)))
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
      yuanwangController.text = yuanwang ?? '';
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
    return _sectionCard(
      icon: Icons.edit_note_rounded,
      title: '填写基本信息',
      subtitle: '用于生成发愿文，之后仍可修改',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: '发愿名称 *',
                hintText: '例如：求智慧疏',
                prefixIcon: Icon(Icons.auto_awesome_outlined),
              ),
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
              decoration: const InputDecoration(
                labelText: '佛弟子名称 *',
                hintText: '请输入发愿人名称',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
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
      ),
    );
  }

  // 修改 _updateDateControllers 方法
  void _updateDateControllers() {
    // print('Updating date controllers...');
    // print('1 Start Date: ${_data.startDate}');
    // print('1 End Date: ${_data.endDate}');
    startDateController.text = _data.startDate != null
        ? DateTools.getDateStringByDate(_data.startDate!)
        : '';
    endDateController.text = _data.endDate != null
        ? DateTools.getDateStringByDate(_data.endDate!)
        : '';
    // print('2 Start Date: ${_data.startDate}');
    // print('2 End Date: ${_data.endDate}');
  }

  Widget _buildStep2() {
    return _sectionCard(
      icon: Icons.date_range_rounded,
      title: '设定发愿时间',
      subtitle: '选择开始日期和持续周期',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  readOnly: true,
                  controller: startDateController,
                  decoration: const InputDecoration(
                    labelText: '起始日期',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
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
                        _data.endDate =
                            endDate.subtract(const Duration(days: 1));
                        endDateController.text = DateTools.getDateStringByDate(
                          _data.endDate!,
                        );
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
            decoration: const InputDecoration(
              labelText: '截止日期',
              prefixIcon: Icon(Icons.event_available_outlined),
            ),
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: RcmTheme.of(context).colors.accentSoft,
              borderRadius:
                  BorderRadius.circular(RcmTheme.of(context).radius.md),
            ),
            child: Row(
              children: [
                Icon(Icons.timelapse_rounded,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 10),
                Text('共 ${_data.getDurationDays()} 天',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    final design = RcmTheme.of(context);
    return _sectionCard(
      icon: Icons.checklist_rounded,
      title: '安排每日功课',
      subtitle: '每天将按照以下清单进行修持',
      child: Column(
        children: [
          if (_data.gkiODList.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: design.spacing.lg),
              child: Column(
                children: [
                  Icon(Icons.playlist_add_rounded,
                      size: 48, color: design.textSecondaryOf(context)),
                  const SizedBox(height: 8),
                  Text('暂未添加每日功课',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('请至少添加一项功课',
                      style: TextStyle(color: design.textSecondaryOf(context))),
                ],
              ),
            ),
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  leading: CircleAvatar(
                    backgroundColor: design.colors.accentSoft,
                    foregroundColor: design.colors.primary,
                    child: Icon(
                      GongKeTypePresentation.of(item.gongketype.name).icon,
                    ),
                  ),
                  title: Text(item.name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(item.gongketype.label),
                  trailing: Text(
                    '${item.cnt} ${GongKeTypePresentation.of(item.gongketype.name).unit}',
                    style: TextStyle(
                      color: design.colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showCopyGongKeDialog(),
                  icon: const Icon(Icons.copy_all_outlined),
                  label: const Text('复制功课'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _showAddGongKeDialog(),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('新增功课'),
                ),
              ),
            ],
          ),
        ],
      ),
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
          "(${i + 1})${rec.gongketype.label}${rec.name}$cnt${getDanWeiByLabel(rec.gongketype.label)}。";
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
    final allItems = await globalDB.select(globalDB.gongKeItemsOneDay).get();
    if (!mounted) return;
    final itemMap = <String, VMGongKeItemOneDayData>{};

    for (var item in allItems) {
      final displayText = '${item.name} x ${item.cnt}';
      final types = GongKeType.values.where((t) => t.name == item.gongketype);
      if (types.isNotEmpty) {
        itemMap[displayText] = VMGongKeItemOneDayData(
          gongketype: types.first,
          name: item.name,
          cnt: item.cnt,
          idx: item.idx,
        );
      }
    }

    if (itemMap.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('还没有可复制的历史功课')),
      );
      return;
    }

    final selectedItems = <String>{};
    final result = await showDialog<Set<String>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('复制功课'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 280,
              maxWidth: 420,
              maxHeight: 420,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: itemMap.length,
              itemBuilder: (context, index) {
                final item = itemMap.keys.elementAt(index);
                return CheckboxListTile(
                  title: Text(item),
                  value: selectedItems.contains(item),
                  onChanged: (bool? value) {
                    setDialogState(() {
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
              onPressed: () => Navigator.pop(context, <String>{}),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: selectedItems.isEmpty
                  ? null
                  : () => Navigator.pop(context, Set.of(selectedItems)),
              child: const Text('确定'),
            ),
          ],
        ),
      ),
    );

    if (!mounted || result == null || result.isEmpty) return;
    setState(() {
      for (final selected in result) {
        final item = itemMap[selected];
        if (item == null) continue;
        _data.gkiODList.add(
          VMGongKeItemOneDayData(
            gongketype: item.gongketype,
            name: item.name,
            cnt: item.cnt,
            idx: _data.gkiODList.length + 1,
          ),
        );
      }
    });
  }

  Future<void> _showAddGongKeDialog() async {
    GongKeType? selectedType;
    String? selectedJingShu;
    final TextEditingController nameController = TextEditingController();
    final TextEditingController cntController = TextEditingController(
      text: '1',
    );

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
                    if (value != null) {
                      cntController.text = GongKeTypePresentation.of(value.name)
                          .minimumCount
                          .toString();
                    }
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
                final countRule = GongKeTypePresentation.of(selectedType!.name);
                if (cnt < countRule.minimumCount) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${selectedType!.label}不能少于${countRule.minimumCount}${countRule.unit}',
                      ),
                    ),
                  );
                  return;
                }
                if (countRule.maximumCount != null &&
                    cnt > countRule.maximumCount!) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${selectedType!.label}不能超过${countRule.maximumCount}${countRule.unit}',
                      ),
                    ),
                  );
                  return;
                }

                // 添加功课
                setState(() {
                  _data.gkiODList.add(
                    VMGongKeItemOneDayData(
                      gongketype: selectedType!,
                      name: name,
                      cnt: cnt,
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
    return _sectionCard(
      icon: Icons.favorite_border_rounded,
      title: '写下愿望',
      subtitle: '愿望将写入最终生成的发愿文',
      child: TextFormField(
        controller: yuanwangController,
        decoration: const InputDecoration(
          labelText: '愿望内容',
          hintText: '例如：消除烦恼，增长智慧……',
          alignLabelWithHint: true,
        ),
        minLines: 7,
        maxLines: 10,
        maxLength: 500,
        onChanged: (value) {
          _data.yuanwang = value;
          saveStringValue('yuanwang', _data.yuanwang ?? '');
        },
      ),
    );
  }

  Widget _buildStep5() {
    final design = RcmTheme.of(context);
    return Column(
      children: [
        _summaryCard(
          icon: Icons.badge_outlined,
          title: '基本信息',
          children: [
            _summaryRow('发愿名称', _data.name ?? ''),
            _summaryRow('佛弟子名称', _data.fodiziName ?? ''),
          ],
        ),
        SizedBox(height: design.spacing.sm),
        _summaryCard(
          icon: Icons.date_range_rounded,
          title: '时间安排',
          children: [
            _summaryRow('开始日期', startDateController.text),
            _summaryRow('截止日期', endDateController.text),
            _summaryRow('发愿时长', '${_data.getDurationDays()} 天'),
          ],
        ),
        SizedBox(height: design.spacing.sm),
        _summaryCard(
          icon: Icons.checklist_rounded,
          title: '每日功课',
          children: _data.gkiODList.map((item) {
            final presentation =
                GongKeTypePresentation.of(item.gongketype.name);
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(presentation.icon, color: design.colors.primary),
              title: Text(item.name),
              trailing: Text('${item.cnt} ${presentation.unit}',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            );
          }).toList(),
        ),
        SizedBox(height: design.spacing.sm),
        _summaryCard(
          icon: Icons.favorite_border_rounded,
          title: '愿望',
          children: [
            Text(
              (_data.yuanwang?.trim().isNotEmpty ?? false)
                  ? _data.yuanwang!.trim()
                  : '未填写愿望',
              style: TextStyle(
                height: 1.6,
                color: (_data.yuanwang?.trim().isNotEmpty ?? false)
                    ? design.textPrimaryOf(context)
                    : design.textSecondaryOf(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    final design = RcmTheme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(design.spacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(design.radius.lg),
        border: Border.all(color: design.colors.primary.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: design.colors.accentSoft,
                foregroundColor: design.colors.primary,
                child: Icon(icon),
              ),
              SizedBox(width: design.spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            )),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style:
                            TextStyle(color: design.textSecondaryOf(context))),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: design.spacing.lg),
          child,
        ],
      ),
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    final design = RcmTheme.of(context);
    return Container(
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
          Row(children: [
            Icon(icon, color: design.colors.primary),
            const SizedBox(width: 8),
            Text(title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    )),
          ]),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(label,
                style: TextStyle(
                    color: RcmTheme.of(context).textSecondaryOf(context))),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave() async {
    if (_isSaving) return;
    setState(() {
      _isSaving = true;
    });

    int? currentFaYuanId;
    final isModify = actType == 'M' && fayuanId != null;
    try {
      _data.fayuanwen = getFaYuanWen();
      if (isModify) {
        currentFaYuanId = fayuanId!;

        await (globalDB.delete(globalDB.gongKeItem)
              ..where((tbl) => tbl.fayuanId.equals(currentFaYuanId!)))
            .go();
        await (globalDB.delete(globalDB.gongKeItemsOneDay)
              ..where((tbl) => tbl.fayuanId.equals(currentFaYuanId!)))
            .go();

        await (globalDB.update(globalDB.faYuan)
              ..where((tbl) => tbl.id.equals(currentFaYuanId!)))
            .write(
          FaYuanCompanion(
            name: Value(_data.name!),
            fodiziname: Value(_data.fodiziName!),
            startDate: Value(_data.startDate!),
            endDate: Value(_data.endDate!),
            yuanwang: Value(_data.yuanwang ?? ''),
            fayuanwen: Value(_data.fayuanwen ?? ''),
          ),
        );
      } else {
        currentFaYuanId = await globalDB.into(globalDB.faYuan).insert(
              FaYuanCompanion.insert(
                name: _data.name!,
                fodiziname: _data.fodiziName!,
                startDate: _data.startDate!,
                endDate: _data.endDate!,
                yuanwang: _data.yuanwang ?? '',
                fayuanwen: _data.fayuanwen ?? '',
                remarks: const Value(''),
              ),
            );
      }

      for (var item in _data.gkiODList) {
        await globalDB.into(globalDB.gongKeItemsOneDay).insert(
              GongKeItemsOneDayCompanion.insert(
                fayuanId: currentFaYuanId,
                gongketype: Value(item.gongketype.name),
                name: item.name,
                cnt: Value(item.cnt),
                idx: Value(_data.gkiODList.indexOf(item) + 1),
              ),
            );
      }

      String gongkedaystr = '';
      bool iscomplete = false;
      for (var day = 0; day < _data.getDurationDays(); day++) {
        for (var item in _data.gkiODList) {
          gongkedaystr = DateTools.getDateStringByDate(
            DateTools.getDateAfterDays(_data.startDate ?? DateTime.now(), day),
          );
          if (DateTools.getDateByString(
            gongkedaystr,
            'yyyy-MM-dd',
          ).isBefore(DateTime.now())) {
            iscomplete =
                gongkedaystr != DateTools.getDateStringByDate(DateTime.now());
          } else {
            iscomplete = false;
          }

          await globalDB.into(globalDB.gongKeItem).insert(
                GongKeItemCompanion.insert(
                  fayuanId: currentFaYuanId,
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

      await syncTaskAndCalendarCards();
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (currentFaYuanId != null) {
        try {
          await (globalDB.delete(globalDB.gongKeItem)
                ..where((tbl) => tbl.fayuanId.equals(currentFaYuanId!)))
              .go();
          await (globalDB.delete(globalDB.gongKeItemsOneDay)
                ..where((tbl) => tbl.fayuanId.equals(currentFaYuanId!)))
              .go();
          if (!isModify) {
            await (globalDB.delete(globalDB.faYuan)
                  ..where((tbl) => tbl.id.equals(currentFaYuanId!)))
                .go();
          }
        } catch (_) {}
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _continue() {
    if (_currentStep == 4) {
      _handleSave();
      return;
    }
    switch (_currentStep) {
      case 0:
        if (!(_formKey.currentState?.validate() ?? false)) return;
        _formKey.currentState?.save();
        break;
      case 1:
        if (!_data.isDateValid()) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('请选择有效的起始日期和截止日期')),
          );
          return;
        }
        break;
      case 2:
        if (!_data.isGongKeValid()) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('请至少添加一个功课')),
          );
          return;
        }
        break;
    }
    FocusScope.of(context).unfocus();
    setState(() => _currentStep++);
  }

  Widget _buildProgressHeader() {
    const labels = ['基本', '时间', '功课', '愿望', '确认'];
    final design = RcmTheme.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
        design.spacing.sm,
        design.spacing.sm,
        design.spacing.sm,
        design.spacing.md,
      ),
      child: RcmStepProgress(
        steps: labels,
        currentStep: _currentStep,
      ),
    );
  }

  Widget _buildBottomActions() {
    final design = RcmTheme.of(context);
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          design.spacing.md,
          design.spacing.sm,
          design.spacing.md,
          design.spacing.md,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border:
              Border(top: BorderSide(color: Theme.of(context).dividerColor)),
        ),
        child: Row(
          children: [
            if (_currentStep > 0) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isSaving
                      ? null
                      : () {
                          FocusScope.of(context).unfocus();
                          setState(() => _currentStep--);
                        },
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('上一步'),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: _currentStep > 0 ? 1 : 2,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _continue,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(_currentStep == 4
                        ? Icons.check_rounded
                        : Icons.arrow_forward_rounded),
                label: Text(_currentStep == 4
                    ? (_isSaving ? '保存中...' : '保存发愿')
                    : '下一步'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final design = RcmTheme.of(context);
    final steps = [
      _buildStep1(),
      _buildStep2(),
      _buildStep3(),
      _buildStep4(),
      _buildStep5(),
    ];
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(actType == 'A' ? '新建发愿' : '修改发愿'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildProgressHeader(),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  design.spacing.md,
                  0,
                  design.spacing.md,
                  design.spacing.lg,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: KeyedSubtree(
                    key: ValueKey(_currentStep),
                    child: steps[_currentStep],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }
}
