import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:gongke/database.dart';
import 'package:gongke/main.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:gongke/comm/pub_tools.dart';

class BaiChanPage extends StatefulWidget {
  const BaiChanPage({super.key});
  @override
  _BaiChanListPageState createState() => _BaiChanListPageState();
}

class _BaiChanListPageState extends State<BaiChanPage> {
  Stream<List<BaiChanData>> baiChanList =
      Stream.value(<BaiChanData>[]).asBroadcastStream();

  bool isRefresh = false;

  @override
  void initState() {
    super.initState();
    loadAllData();
  }

  // 设置为最爱
  void _setFavorite(BaiChanData baichan) {
    setState(() {
      var favoriteDateTime = baichan.favoriteDateTime;
      if (baichan.favoriteDateTime != null) {
        favoriteDateTime = null; // 如果已经是最爱，则取消
      } else {
        favoriteDateTime = DateTime.now();
      }
      // 添加数据库更新逻辑
      globalDB.managers.baiChan
          .filter((f) => f.id(baichan.id))
          .update((o) => o(favoriteDateTime: Value(favoriteDateTime)));
    });
  }

  Future<void> loadAllData() async {
    final list = await (globalDB.select(globalDB.baiChan)
          ..orderBy([
            (tbl) => OrderingTerm.desc(tbl.favoriteDateTime),
            (tbl) => OrderingTerm.desc(tbl.createDateTime),
          ]))
        .get();
    setState(() {
      baiChanList = Stream.value(list).asBroadcastStream();
    });
  }

  void deleteBaiChan(int id) {
    setState(() {
      globalDB.managers.baiChan.filter((f) => f.id.equals(id)).delete();
    });
  }

  void setFavorite(int id) {
    setState(() {
      globalDB.managers.baiChan
          .filter((f) => f.id.equals(id))
          .update((o) => o(favoriteDateTime: Value(DateTime.now())));
    });
  }

  // 跳转到PDF页面
  void _navigateToPlay(BaiChanData baichan) {
    Navigator.pushNamed(
      context,
      '/BaiChan/BaiChanPlay',
      arguments: {'baichanId': baichan.id, 'baichan': baichan},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '拜忏',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.blue, size: 35),
            onPressed: () async {
              final result = await Navigator.pushNamed(
                context,
                '/BaiChan/NewBaiChan',
                arguments: {'acttype': 'new'},
              );
              if (result == true) {
                await loadAllData();
              }
            },
          ),
        ],
      ),
      body: SlidableAutoCloseBehavior(
        child: StreamBuilder<List<BaiChanData>>(
          stream: baiChanList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('数据加载出错: ${snapshot.error}'));
            }
            final list = snapshot.data ?? [];
            if (list.isEmpty) {
              return const Center(child: Text('暂无拜忏记录，请先添加'));
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
                        foregroundColor:
                            const Color.fromARGB(255, 226, 203, 50),
                        icon: Icons.favorite,
                        label:
                            list[index].favoriteDateTime != null ? '取消' : '最爱',
                      ),
                    ],
                  ),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) async {
                          // 在这里处理删除操作
                          await globalDB.managers.baiChan
                              .filter((f) => f.id(list[index].id))
                              .delete();
                          // 重新获取数据
                          await loadAllData();
                        },
                        backgroundColor: const Color(0xFFFE4A49),
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: '删除',
                      ),
                    ],
                  ),
                  child: ListTile(
                    // leading: SizedBox(
                    //   //width: 200,
                    //   height: 360,
                    //   child: Image.asset(
                    //     getFoPuSaImagePath(list[index].image),
                    //     fit: BoxFit.fitHeight,
                    //   ),
                    // ),
                    title: Row(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          child: Image.asset(
                            getFoPuSaImagePath(list[index].image),
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(child: Text(list[index].name)),
                      ],
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
                      try {
                        _navigateToPlay(list[index]);
                      } catch (e) {
                        print('---------${e.toString()}');
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('打开新窗口失败: $e')));
                      }
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
