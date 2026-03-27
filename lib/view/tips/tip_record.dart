import 'package:flutter/material.dart';
import 'package:drift/drift.dart';
import 'package:gongke/main.dart';
import '../../database.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; // 导入 Slidable 库

// 假设这是一个StatefulWidget页面
class TipRecordPage extends StatefulWidget {
  const TipRecordPage({super.key});

  @override
  _TipRecordPageState createState() => _TipRecordPageState();
}

class _TipRecordPageState extends State<TipRecordPage> {
  Stream<List<TipRecordData>> tipRecords = Stream.value([]);
  int bookId = 0; // 默认值，实际使用时可能需要从路由参数获取

  @override
  void initState() {
    super.initState();

    if (bookId > 0) {
      _loadTipRecords(bookId);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic> && args['bookId'] != null) {
      bookId = args['bookId'];
      _loadTipRecords(bookId);
    }
    print('Book ID: $bookId');
  }

  Future<void> _loadTipRecords(int bookId) async {
    final records = globalDB.managers.tipRecord
        .orderBy((o) => o.id.asc())
        .filter((f) => f.bookId.equals(bookId))
        .watch();
    setState(() {
      tipRecords = records;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('提示记录'),
        toolbarHeight: 40,
        actions: [
          Spacer(),
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.blue, size: 35),
            onPressed: () {
              // 跳转到新增页面
              Navigator.pushNamed(
                context,
                '/AddTipRecord',
                arguments: {'acttype': 'new', 'bookId': bookId},
              );
            },
          ),
        ],
      ),
      body: SlidableAutoCloseBehavior(
        child: StreamBuilder<List<TipRecordData>>(
          stream: tipRecords,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final records = snapshot.data ?? [];
              return ListView.builder(
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final record = records[index];
                  return Slidable(
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) {
                            // 删除操作
                            globalDB.managers.tipRecord
                                .filter((f) => f.id(record.id))
                                .delete();
                          },
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: '删除',
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(record.id.toString()),
                      subtitle: Text(record.content),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text('错误: ${snapshot.error}');
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
