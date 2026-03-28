import 'package:flutter/material.dart';
import 'package:gongke/main.dart';
import 'package:gongke/model/tables.dart';
import '../../database.dart';
import '../../comm/pub_tools.dart';
import 'package:drift/drift.dart' hide Column;

class NewBaiChanPage extends StatefulWidget {
  const NewBaiChanPage({super.key});
  @override
  _NewBaiChanPageState createState() => _NewBaiChanPageState();
}

class _NewBaiChanPageState extends State<NewBaiChanPage> {
  bool _isInitialized = false;
  late String actType; //传递过来的参数
  late int baichanId; //如果是新建，则不用传，如果是修改，则需要传递。
  late BaiChanCompanion baichan;
  late String currentImage; //当前显示的图像
  final List<String> imageList = [
    '阿弥陀佛圣像',
    '观音菩萨圣像',
    '地藏菩萨圣像',
    '大势至菩萨圣像',
    '观世音菩萨圣像',
    '释迦牟尼佛圣像',
    '西方三圣像',
  ];

  @override
  void initState() {
    super.initState();

    //这个时候还不知道是新增，还是修改，先初始化备用
    baichan = BaiChanCompanion(
      image: Value('阿弥陀佛圣像'),
      chanhuiWenStart: const Value(
        '大慈大悲愍众生，大喜大舍济含识，相好光明以自严，众等至心皈命礼。\n拿摩皈依十方尽虚空界一切诸佛\n拿摩皈依十方尽虚空界一切尊法\n拿摩皈依十方尽虚空界一切贤圣僧\n我弟子某甲，至心忏悔往昔所造诸恶业，愿自己以后诸恶莫做，诸善奉行，精进修行，早证菩提。请佛菩萨慈悲加持。',
      ),
      chanhuiWenEnd: const Value('愿以此功德，普及与一切，我等与众生，皆共成佛道。'),
      baichanTimes: const Value(108),
      baichanInterval1: const Value(7),
      baichanInterval2: const Value(5),
      flagOrderNumber: const Value(true),
      flagQiShen: const Value(true),
      name: const Value('我的拜忏'),
    );
    currentImage = baichan.image.value;
    //print('----------------初始化baichan${baichan.toString()}');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 添加标记避免重复加载
    if (_isInitialized) return;
    _isInitialized = true;
    // 如果是编辑模式，使用传入的数据；如果是新建模式，创建默认值
    try {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      actType = args['acttype'];
      baichanId = args['baichanId'] ?? 0;
      //print('----------------开始接受参数${args.toString()}');
      if (actType == 'mod' && baichanId > 0) {
        _loadBaiChanData(baichanId).then(
          (value) => {
            baichan = BaiChanCompanion(
              id: Value(value.id),
              image: Value(value.image),
              chanhuiWenStart: Value(value.chanhuiWenStart),
              chanhuiWenEnd: Value(value.chanhuiWenEnd),
              baichanTimes: Value(value.baichanTimes),
              baichanInterval1: Value(value.baichanInterval1),
              baichanInterval2: Value(value.baichanInterval2),
              flagOrderNumber: Value(value.flagOrderNumber),
              flagQiShen: Value(value.flagQiShen),
              name: Value(value.name),
            ),
          },
        );
      }
      //print('---------baichan.image.value:${baichan.image.value}');
      currentImage = baichan.image.value;
    } catch (e) {
      print('------------------didChangeDependencies error:${e}');
    }
  }

  Future<BaiChanData> _loadBaiChanData(id) async {
    return await (globalDB.select(globalDB.baiChan)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingle();
  }

  void _updateBaichan({
    String? image,
    String? chanhuiWenStart,
    String? chanhuiWenEnd,
    int? baichanTimes,
    int? baichanInterval1,
    int? baichanInterval2,
    bool? flagOrderNumber,
    bool? flagQiShen,
    String? name,
  }) {
    setState(() {
      baichan = BaiChanCompanion(
        // 保持原有值，只更新修改的字段
        image: image != null ? Value(image) : baichan.image,
        chanhuiWenStart: chanhuiWenStart != null
            ? Value(chanhuiWenStart)
            : baichan.chanhuiWenStart,
        chanhuiWenEnd: chanhuiWenEnd != null
            ? Value(chanhuiWenEnd)
            : baichan.chanhuiWenEnd,
        baichanTimes: baichanTimes != null
            ? Value(baichanTimes)
            : baichan.baichanTimes,
        baichanInterval1: baichanInterval1 != null
            ? Value(baichanInterval1)
            : baichan.baichanInterval1,
        baichanInterval2: baichanInterval2 != null
            ? Value(baichanInterval2)
            : baichan.baichanInterval2,
        flagOrderNumber: flagOrderNumber != null
            ? Value(flagOrderNumber)
            : baichan.flagOrderNumber,
        flagQiShen: flagQiShen != null ? Value(flagQiShen) : baichan.flagQiShen,
        name: name != null ? Value(name) : baichan.name,
      );
    });
  }

  Future<void> saveData() async {
    try {
      // 确保所有必要字段都有值
      final dataToSave = BaiChanCompanion(
        id: actType == 'new'
            ? Value.absent()
            : baichan.id, // 如果是新增，这个是 Value.absent()
        image: Value(currentImage),
        chanhuiWenStart: Value(baichan.chanhuiWenStart.value),
        chanhuiWenEnd: Value(baichan.chanhuiWenEnd.value),
        baichanTimes: Value(baichan.baichanTimes.value),
        baichanInterval1: Value(baichan.baichanInterval1.value),
        baichanInterval2: Value(baichan.baichanInterval2.value),
        flagOrderNumber: Value(baichan.flagOrderNumber.value),
        flagQiShen: Value(baichan.flagQiShen.value),
        name: Value(baichan.name.value),
      );

      //print('------------开始保存-----------baichan:${dataToSave.toString()}');
      await globalDB.into(globalDB.baiChan).insertOnConflictUpdate(dataToSave);
    } catch (e) {
      if (mounted) {
        print('---------${e.toString()}');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('保存失败: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 添加空值检查
    if (baichan == null || currentImage == null) {
      return Scaffold(
        appBar: AppBar(title: Text('数据为空')),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(actType == 'new' ? '新建拜忏' : '修改拜忏')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Align(
          alignment: Alignment.centerLeft, // 添加 Align widget
          child: Column(
            children: [
              Row(children: [Text('1. 请选择拜忏背景图片'), Spacer()]),
              DropdownButton<String>(
                value: currentImage,
                onChanged: (String? newValue) {
                  try {
                    //print('-------------------newValue${newValue}');
                    if (newValue != null) {
                      // 直接存储枚举的 label，也就是汉字
                      setState(() {
                        currentImage = newValue;

                        _updateBaichan(image: newValue); // 同时更新 baichan 对象
                      });
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('切换失败: $e')));
                  }
                },
                items: imageList.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                      children: [
                        Image.asset(
                          getFoPuSaImagePath(value),
                          width: 30,
                          height: 30,
                        ),
                        const SizedBox(width: 8),
                        Text(value),
                      ],
                    ),
                  );
                }).toList(),
              ),
              Image.asset(getFoPuSaImagePath(currentImage), height: 200),
              _textField('2. 忏悔文前文', baichan.chanhuiWenStart.value, (val) {
                _updateBaichan(chanhuiWenStart: val);
              }),
              _sliderField(
                '3. 共拜多少拜',
                baichan.baichanTimes.value.toDouble(),
                '拜',
                5,
                500,
                (val) {
                  _updateBaichan(baichanTimes: val.toInt());
                },
              ),
              _sliderField(
                '4. 每一拜时长',
                baichan.baichanInterval1.value.toDouble(),
                '秒',
                7,
                50,
                (val) {
                  _updateBaichan(baichanInterval1: val.toInt());
                },
              ),
              SwitchListTile(
                title: Text('是否语音提示第几拜'),
                value: baichan.flagOrderNumber.value,
                onChanged: (val) {
                  setState(() => _updateBaichan(flagOrderNumber: val));
                },
              ),
              _sliderField(
                '5. 每拜间隔',
                baichan.baichanInterval2.value.toDouble(),
                '秒',
                5,
                10,
                (val) {
                  _updateBaichan(baichanInterval2: val.toInt());
                },
              ),
              SwitchListTile(
                title: Text('是否语音提示起身'),
                value: baichan.flagQiShen.value,
                onChanged: (val) {
                  setState(() => _updateBaichan(flagQiShen: val));
                },
              ),
              _textField('6. 忏悔文回向', baichan.chanhuiWenEnd.value, (val) {
                _updateBaichan(chanhuiWenEnd: val);
              }),
              _textField('7. 名称', baichan.name.value ?? '', (val) {
                _updateBaichan(name: val);
              }),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    style: AppButtonStyle.primaryButton,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('取消'),
                  ),
                  ElevatedButton(
                    style: AppButtonStyle.primaryButton,
                    onPressed: () async {
                      await saveData();
                      Navigator.of(context).pop(true);
                    },
                    child: Text('确认'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textField(String label, String value, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        TextFormField(
          initialValue: value,
          maxLines: null,
          onChanged: onChanged,
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _sliderField(
    String label,
    double value,
    String danwei,
    double min,
    double max,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label (${value.toInt()}${danwei})'),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          label: value.toStringAsFixed(0),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
