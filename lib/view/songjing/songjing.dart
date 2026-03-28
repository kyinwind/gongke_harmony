import 'package:flutter/material.dart';
import 'package:gongke/database.dart';
import 'package:styled_widget/styled_widget.dart';
import '../../comm/pdf_view.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gongke/main.dart';
import 'package:drift/drift.dart' hide Column;
import '../../comm/pub_tools.dart';

class SongJingPage extends StatefulWidget {
  const SongJingPage({super.key});

  @override
  _SongJingPageState createState() => _SongJingPageState();
}

class _SongJingPageState extends State<SongJingPage> {
  final TextEditingController _searchController = TextEditingController();
  Stream<List<JingShuData>> jingshudatalist =
      Stream.value(<JingShuData>[]).asBroadcastStream();
  //String? imagePath = 'assets/images/jingshu.png';
  bool _appBuildFlag = false;

  @override
  void initState() {
    super.initState();
    // 初始化配置
    _appBuildFlag = appBuildFlag;

    fetchAll();
    if (_appBuildFlag) {
      // 如果是完整版，就增加内置文件
      initJingShuData().then((_) {
        fetchAll();
      });
    }
  }

  Future<void> initJingShuData() async {
    // 初始化经书数据
    // 检查 jingshudatalist ,如果为空则插入经书数据
    bool exists = false;
    final dataList = await jingshudatalist.first;
    // 等待 Future 完成，获取 List<JingShuData>
    for (final item in jingShuList) {
      exists = dataList.any((o) => o.name == item.name.value);
      if (exists) {
        continue; // 如果已经存在，则跳过插入
      }
      await globalDB.into(globalDB.jingShu).insert(item);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  // 查询所有记录
  Future<void> fetchAll() async {
    try {
      final list = await (globalDB.select(globalDB.jingShu)
            ..where((tbl) => tbl.type.like('%jingshu%'))
            ..orderBy([
              (tbl) => OrderingTerm.desc(tbl.favoriteDateTime),
              (tbl) => OrderingTerm.asc(tbl.name),
            ]))
          .get();
      setState(() {
        jingshudatalist = Stream.value(list).asBroadcastStream();
      });
    } catch (e) {
      print('查询所有记录时出错: $e');
      // 可以在这里设置一个空的 Stream 或者错误提示的 Stream
      setState(() {
        jingshudatalist = Stream.error(e);
      });
    }
  }

  // 查询所有记录
  Future<void> fetchByWords(String str) async {
    try {
      final keyword = str.trim();
      final list = await (globalDB.select(globalDB.jingShu)
            ..where(
              (tbl) =>
                  tbl.name.like('%$keyword%') & tbl.type.like('%jingshu%'),
            )
            ..orderBy([
              (tbl) => OrderingTerm.desc(tbl.favoriteDateTime),
              (tbl) => OrderingTerm.asc(tbl.name),
            ]))
          .get();
      setState(() {
        jingshudatalist = Stream.value(list).asBroadcastStream();
      });
    } catch (e) {
      // print('根据关键字查询记录时出错: $e');
      // 可以在这里设置一个空的 Stream 或者错误提示的 Stream
      setState(() {
        jingshudatalist = Stream.error(e);
      });
    }
  }

  // 设置为最爱
  void _setFavorite(JingShuData jingshu) {
    setState(() {
      var favoriteDateTime = jingshu.favoriteDateTime;
      if (jingshu.favoriteDateTime != null) {
        favoriteDateTime = null; // 如果已经是最爱，则取消
      } else {
        favoriteDateTime = DateTime.now();
      }
      // 添加数据库更新逻辑
      globalDB.managers.jingShu
          .filter((f) => f.id(jingshu.id))
          .update((o) => o(favoriteDateTime: Value(favoriteDateTime)));
    });
  }

  // 跳转到PDF页面
  void _navigateToPdfView(JingShuData jingshu) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PdfViewerPage(jingshu: jingshu)),
    );
  }

  Future<void> _openImportPage() async {
    final imported = await Navigator.pushNamed(
      context,
      '/ImportFiles',
      arguments: {'jingshutype': 'jingshu'},
    );
    if (!mounted || imported != true) {
      return;
    }
    if (_searchController.text.isNotEmpty) {
      await fetchByWords(_searchController.text);
    } else {
      await fetchAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 这两个控件不能正常显示可能是因为在 AppBar 的 title 中直接使用 Row，
        // 没有给子控件设置合适的约束，导致 TextField 宽度无限大报错。
        // 以下解决方案通过 Expanded 限制 TextField 宽度，并添加样式提升显示效果。
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '输入关键字搜索经书',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  fetchByWords(value);
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.arrow_circle_down),
              color: Colors.blue,
              iconSize: 35,
              onPressed: () async {
                await _openImportPage();
              },
            ),
          ],
        ),
      ),
      body: SlidableAutoCloseBehavior(
        child: StreamBuilder<List<JingShuData>>(
          stream: jingshudatalist,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('数据加载出错: ${snapshot.error}'));
            }
            final list = snapshot.data ?? [];
            if (list.length == 0) {
              return Center(
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(children: [Text('当前暂无数据，需要导入经书文件。')]),
                ),
              );
            }
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                return Slidable(
                  startActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          _setFavorite(list[index]);
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                list[index].favoriteDateTime == null
                                    ? '已设为最爱'
                                    : '已取消最爱',
                              ),
                            ),
                          );
                        },
                        backgroundColor: Colors.white,
                        foregroundColor: Color.fromARGB(255, 226, 203, 50),
                        icon: Icons.favorite,
                        label: list[index].favoriteDateTime != null
                            ? '取消'
                            : '最爱',
                      ),
                    ],
                  ),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) async {
                          // 在这里处理删除操作
                          await globalDB.managers.jingShu
                              .filter((f) => f.id(list[index].id))
                              .delete();
                          // 重新获取数据
                          if (_searchController.text.isNotEmpty) {
                            await fetchByWords(_searchController.text);
                          } else {
                            await fetchAll();
                          }
                        },
                        backgroundColor: Color(0xFFFE4A49),
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: '删除',
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Image.asset(list[index].image),
                    title: Row(
                      children: [Expanded(child: Text(list[index].name))],
                    ),
                    subtitle: Row(
                      children: [
                        if (list[index].favoriteDateTime != null)
                          const Icon(Icons.favorite, color: Colors.yellow)
                        else
                          const SizedBox.shrink(),
                        //Spacer(),
                      ],
                    ),
                    onTap: () {
                      _navigateToPdfView(list[index]);
                    },
                  ).padding(all: 10),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
