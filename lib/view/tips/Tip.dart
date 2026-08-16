import 'package:flutter/material.dart';
import 'package:gongke/main.dart';
import 'package:styled_widget/styled_widget.dart';
import '../../database.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter_slidable/flutter_slidable.dart'; // 导入 Slidable 库
import 'dart:convert'; // 导入 dart:convert 库，确保已导入
import 'package:flutter/services.dart';
import 'package:gongke/comm/harmony_share_service.dart';
import 'package:gongke/comm/import_service.dart';
import 'package:gongke/comm/tip_export_service.dart';
import 'package:gongke/comm/today_tip_service.dart';
import 'package:gongke/comm/widget_snapshot_service.dart';
import 'package:gongke/viewmodel/current_record.dart';
import 'package:gongke/comm/pub_tools.dart';
import 'package:gongke/comm/tts_tools.dart';

// 为了让页面能够上下滑动，将 Scaffold 的 body 用 SingleChildScrollView 包裹
class TipPage extends StatefulWidget {
  const TipPage({super.key});

  @override
  State<TipPage> createState() => _TipPageState();
}

// 在 _TipPageState 类中添加数据库实例和记录列表
class _TipPageState extends State<TipPage> {
  static const _importService = ImportService();
  static const _exportService = TipExportService();
  static const _shareService = HarmonyShareService();
  final TtsTools _tts = TtsTools();
  List<TipBookData> records = <TipBookData>[];
  bool _isLoading = true;
  CurrentRecord curRec = CurrentRecord();
  TodayTipMode _todayTipMode = TodayTipMode.sequential;
  bool _isSpeaking = false;
  int _previewRefreshSequence = 0;
  bool _isImportingSample = false;
  _TipPageState(); // 添加构造函数

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    _todayTipMode = await TodayTipSettings.loadMode();
    await fetchTip();
    if (records.isEmpty) {
      if (appBuildFlag) {
        //如果是完整版本，则导入内置开示文件
        await importTip();
      }
      await fetchTip();
    }
    await _loadCurrentRecord();
    if (!mounted) {
      return;
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _setTodayTipMode(TodayTipMode mode) async {
    if (mode == _todayTipMode) return;
    await TodayTipSettings.saveMode(mode);
    if (mounted) setState(() => _todayTipMode = mode);
    await _loadCurrentRecord();
    await WidgetSnapshotService(globalDB).syncAll();
  }

  // 新增方法处理异步加载
  Future<void> _loadCurrentRecord() async {
    final record = await getCurrentRecord();
    setState(() {
      curRec = record;
      //print(curRec.id);
      //print(curRec.content);
    });
  }

  Future<void> importTip() async {
    // 假设文件名为 广钦老和尚开示.json, 第二个文件.json, 第三个文件.json, 第四个文件.json
    final fileNames = ['1.json', '2.json', '3.json', '4.json'];

    for (final fileName in fileNames) {
      final data = await rootBundle.load('assets/tips/$fileName');
      await _importService.importTipBytes(data.buffer.asUint8List());
    }
  }

  Future<void> _exportBook(TipBookData book) async {
    try {
      final saved = await _exportService.saveBook(globalDB, book.id);
      if (mounted && saved) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('开示文件已保存')));
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导出失败：$error')),
      );
    }
  }

  Future<void> _shareBookFile(TipBookData book) async {
    final file = await _exportService.createTemporaryJson(globalDB, book.id);
    try {
      await _shareService.shareFile(
        title: '${book.name}.json',
        path: file.path,
        utd: 'general.json',
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('分享失败：$error')));
      }
    } finally {
      if (await file.exists()) await file.delete();
    }
  }

  Future<bool> _confirmDeleteBook(TipBookData book) async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('删除开示录'),
            content: Text(
              '确定删除“${book.name}”吗？\n\n该开示录下的全部开示记录也会被删除，此操作无法撤销。',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('删除'),
              ),
            ],
          ),
        ) ??
        false;
  }

  // 查询所有记录
  Future<void> fetchTip() async {
    // Only read the columns needed by this list. Databases migrated from old
    // Harmony versions can contain legacy defaults in newer metadata columns
    // (for example updated_date_time=0). Mapping the complete Drift model can
    // therefore fail even though the book and all of its records are valid.
    final rows = await globalDB.customSelect(
      '''
      SELECT id, create_date_time, favorite_date_time, remarks, bk1, bk2, name, image
      FROM tip_book
      ORDER BY
        CASE WHEN favorite_date_time IS NULL THEN 0 ELSE 1 END DESC,
        favorite_date_time DESC,
        create_date_time DESC,
        id DESC
      ''',
    ).get();
    final books = rows.map(_mapTipBookListRow).toList();
    if (!mounted) {
      records = books;
      return;
    }
    setState(() {
      records = books;
    });
  }

  TipBookData _mapTipBookListRow(QueryRow row) {
    final createdAt = _readLegacyDateTime(row.data['create_date_time']) ??
        DateTime.fromMillisecondsSinceEpoch(0);
    return TipBookData(
      id: row.read<int>('id'),
      createDateTime: createdAt,
      favoriteDateTime: _readLegacyDateTime(row.data['favorite_date_time']),
      remarks: row.readNullable<String>('remarks'),
      bk1: row.readNullable<String>('bk1'),
      bk2: row.readNullable<String>('bk2'),
      name: row.read<String>('name'),
      image: row.read<String>('image'),
      sourceType: 'userCreated',
      updatedDateTime: createdAt,
    );
  }

  DateTime? _readLegacyDateTime(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is num) {
      final raw = value.toInt();
      // Drift stores DateTime as Unix seconds, while some historical plugin
      // versions returned milliseconds. Accept both representations.
      return DateTime.fromMillisecondsSinceEpoch(
        raw.abs() < 100000000000 ? raw * 1000 : raw,
      );
    }
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
      final numeric = num.tryParse(value);
      if (numeric != null) return _readLegacyDateTime(numeric);
    }
    return null;
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  bool get _hasCurrentRecord => curRec.id > 0;

  Future<void> _togglePreviewFavorite() async {
    if (!_hasCurrentRecord) return;
    await globalDB.managers.tipRecord.filter((f) => f.id(curRec.id)).update(
          (o) => o(
            favoriteDateTime: Value(
              curRec.favoriteDateTime == null ? DateTime.now() : null,
            ),
          ),
        );
    await _loadCurrentRecord();
    await WidgetSnapshotService(globalDB).syncAll();
  }

  Future<void> _togglePreviewCompleted() async {
    if (!_hasCurrentRecord) return;
    await globalDB.managers.tipRecord.filter((f) => f.id(curRec.id)).update(
          (o) => o(
            completedDateTime: Value(
              curRec.completedDateTime == null ? DateTime.now() : null,
            ),
          ),
        );
    await _loadCurrentRecord();
    await WidgetSnapshotService(globalDB).syncAll();
  }

  Future<void> _copyPreview() async {
    if (!_hasCurrentRecord) return;
    await Clipboard.setData(
      ClipboardData(text: '${curRec.content}\n\n《${curRec.bookName}》'),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('开示已复制')));
  }

  Future<void> _editPreviewComments() async {
    if (!_hasCurrentRecord) return;
    final controller = TextEditingController(text: curRec.comments);
    final comments = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('开示评论'),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 3,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: '记录心得或备注',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (comments == null) return;
    await globalDB.managers.tipRecord.filter((f) => f.id(curRec.id)).update(
          (o) => o(comments: Value(comments)),
        );
    await _loadCurrentRecord();
    await WidgetSnapshotService(globalDB).syncAll();
  }

  Future<void> _togglePreviewSpeak() async {
    if (!_hasCurrentRecord) return;
    if (_isSpeaking) {
      await _tts.stop();
      if (mounted) setState(() => _isSpeaking = false);
      return;
    }
    setState(() => _isSpeaking = true);
    try {
      await _tts.speak(curRec.content, () {
        if (mounted) setState(() => _isSpeaking = false);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSpeaking = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('朗读失败：$error')));
    }
  }

  Future<void> _sharePreview() async {
    if (!_hasCurrentRecord) return;
    try {
      await _shareService.shareText(
        title: curRec.bookName,
        text: '${curRec.content}\n\n《${curRec.bookName}》',
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('分享失败：$error')));
    }
  }

  Future<void> _refreshPreview() async {
    if (_todayTipMode != TodayTipMode.random || !_hasCurrentRecord) return;
    final now = DateTime.now();
    final startDate = await TodayTipSettings.loadStartDate(
      fallback: DateTime.tryParse(firstDate ?? ''),
    );
    final service = TodayTipService(globalDB);
    final candidates = await service.loadCandidates();
    if (candidates.length < 2) return;

    TodayTipSelection? selected;
    // A deterministic increment keeps the click reproducible while skipping
    // the record currently shown whenever another candidate exists.
    for (var attempt = 0; attempt < candidates.length; attempt++) {
      _previewRefreshSequence += 1;
      selected = await service.select(
        now: now,
        startDate: startDate,
        mode: TodayTipMode.random,
        seedScope: 'app|manual:$_previewRefreshSequence',
      );
      if (selected != null && selected.record.id != curRec.id) break;
    }
    if (selected == null || selected.record.id == curRec.id) return;
    if (!mounted) return;
    setState(() {
      curRec = CurrentRecord(
        id: selected!.record.id,
        bookId: selected.book.id,
        content: selected.record.content,
        comments: selected.record.comments,
        bookName: selected.book.name,
        bookImage: selected.book.image,
        favoriteDateTime: selected.record.favoriteDateTime,
        completedDateTime: selected.record.completedDateTime,
      );
    });
  }

  Future<void> _importSampleTips() async {
    if (_isImportingSample) return;
    setState(() => _isImportingSample = true);
    try {
      final data = await rootBundle.load('assets/tips/fojiaogeyan.json');
      await _importService.importTipBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        conflictStrategy: TipImportConflictStrategy.overwrite,
      );
      await fetchTip();
      await _loadCurrentRecord();
      await WidgetSnapshotService(globalDB).syncAll();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已导入 7 条佛教格言示例数据')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导入示例数据失败：$error')),
      );
    } finally {
      if (mounted) setState(() => _isImportingSample = false);
    }
  }

  String? imagePath = 'assets/images/shanshu.png';
  // 设置为最爱
  Future<void> _setFavorite(TipBookData book) async {
    var favoriteDateTime = book.favoriteDateTime;
    if (book.favoriteDateTime != null) {
      favoriteDateTime = null; // 如果已经是最爱，则取消
    } else {
      favoriteDateTime = DateTime.now();
    }
    // 添加数据库更新逻辑
    await globalDB.managers.tipBook
        .filter((f) => f.id(book.id))
        .update((o) => o(favoriteDateTime: Value(favoriteDateTime)));

    await _loadCurrentRecord();
    await WidgetSnapshotService(globalDB).syncAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '开示录',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        //backgroundColor: Colors.blue,
        //toolbarHeight: 40,
        actions: [
          //Spacer(),
          IconButton(
            icon: const Icon(Icons.arrow_circle_down),
            color: Colors.blue,
            iconSize: 35,
            onPressed: () async {
              final imported = await Navigator.pushNamed(
                context,
                '/ImportFiles',
                arguments: {'jingshutype': 'kaishi'},
              );
              if (!mounted || imported != true) {
                return;
              }
              await fetchTip();
              await _loadCurrentRecord();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.blue, size: 35),
            onPressed: () async {
              // 跳转到新增页面
              final changed = await Navigator.pushNamed(
                context,
                '/AddTip',
                arguments: {'acttype': 'new'},
              );
              if (!mounted || changed != true) {
                return;
              }
              await fetchTip();
              await _loadCurrentRecord();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SlidableAutoCloseBehavior(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ListView.builder(
                  shrinkWrap: true, // 保持这个属性确保正确嵌套
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return Slidable(
                      startActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) async {
                              // 跳转到修改页面
                              final changed = await Navigator.pushNamed(
                                context,
                                '/AddTip',
                                arguments: {
                                  'acttype': 'mod',
                                  'id': record.id,
                                },
                              );
                              if (!mounted || changed != true) {
                                return;
                              }
                              await fetchTip();
                              await _loadCurrentRecord();
                            },
                            backgroundColor: Color(0xFF2196F3),
                            foregroundColor: Colors.white,
                            icon: Icons.edit,
                            label: '修改',
                          ),
                          SlidableAction(
                            onPressed: (context) {
                              _setFavorite(records[index]);
                            },
                            backgroundColor: Color.fromARGB(
                              5,
                              201,
                              223,
                              36,
                            ), // 使用不同颜色区分
                            foregroundColor: const Color.fromARGB(
                              255,
                              226,
                              203,
                              50,
                            ),
                            icon: Icons.favorite,
                            label:
                                record.favoriteDateTime == null ? '最爱' : '取消',
                          ),
                        ],
                      ),
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) async {
                              if (!await _confirmDeleteBook(record)) return;
                              await globalDB.transaction(() async {
                                await (globalDB.delete(globalDB.tipRecord)
                                      ..where(
                                        (table) =>
                                            table.bookId.equals(record.id),
                                      ))
                                    .go();
                                await globalDB.managers.tipBook
                                    .filter((f) => f.id(record.id))
                                    .delete();
                              });
                              // 重新获取数据
                              await fetchTip();
                              await _loadCurrentRecord();
                              await WidgetSnapshotService(globalDB).syncAll();
                            },
                            backgroundColor: Color(0xFFFE4A49),
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: '删除',
                          ),
                        ],
                      ),
                      child: ListTile(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/TipRecord',
                            arguments: {'bookId': record.id},
                          );
                        },
                        leading: (record.image != '')
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.memory(
                                  const Base64Codec().decode(record.image),
                                  //height: 200,
                                  width: 60,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Image.asset(
                                'assets/images/jingshu.png',
                                height: 100,
                              ),
                        title: Text(record.name),
                        subtitle: Row(
                          children: [
                            if (record.favoriteDateTime != null)
                              const Icon(Icons.favorite, color: Colors.yellow)
                            else
                              const SizedBox.shrink(),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          tooltip: '导出/分享 JSON',
                          onSelected: (value) => value == 'save'
                              ? _exportBook(record)
                              : _shareBookFile(record),
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                                value: 'save', child: Text('保存 JSON 文件')),
                            PopupMenuItem(
                                value: 'share', child: Text('分享 JSON 文件')),
                          ],
                          icon: const Icon(Icons.ios_share_outlined),
                        ),
                      ).padding(all: 10),
                    );
                  },
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 12, 8, 4),
                child: Row(
                  children: [
                    const Text(
                      '预览',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    PopupMenuButton<TodayTipMode>(
                      tooltip: '今日开示显示方式',
                      initialValue: _todayTipMode,
                      onSelected: _setTodayTipMode,
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: TodayTipMode.sequential,
                          child: Text('顺序模式（每日一条）'),
                        ),
                        PopupMenuItem(
                          value: TodayTipMode.random,
                          child: Text('随机模式（当天固定）'),
                        ),
                      ],
                      child: _PreviewAction(
                        icon: _todayTipMode == TodayTipMode.sequential
                            ? Icons.format_list_numbered
                            : Icons.shuffle,
                        label: _todayTipMode == TodayTipMode.sequential
                            ? '顺序'
                            : '随机',
                      ),
                    ),
                    _PreviewAction(
                      icon: _isSpeaking ? Icons.stop_circle : Icons.volume_up,
                      label: _isSpeaking ? '停止' : '朗读',
                      onTap: _hasCurrentRecord ? _togglePreviewSpeak : null,
                    ),
                    _PreviewAction(
                      icon: Icons.share_outlined,
                      label: '分享',
                      onTap: _hasCurrentRecord ? _sharePreview : null,
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center, // 添加水平居中
                crossAxisAlignment: CrossAxisAlignment.center, //
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, // 添加水平居中
                    crossAxisAlignment: CrossAxisAlignment.center, //
                    children: [
                      (curRec.bookImage != '')
                          ? ClipOval(
                              // 改用 ClipOval
                              child: Image.memory(
                                const Base64Codec().decode(curRec.bookImage),
                                height: 100,
                                width: 100, // 添加宽度确保是圆形
                                fit: BoxFit.cover, // 确保图片填充整个圆形
                              ),
                            )
                          : ClipOval(
                              // 默认图片也使用圆形
                              child: Image.asset(
                                'assets/images/jingshu.png',
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                            ).padding(all: 10),
                      const SizedBox(width: 30),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '${DateTime.now().day}',
                                style: const TextStyle(fontSize: 60),
                              ),
                              Divider(),
                              buildVerticalText(
                                '${DateTime.now().month}月',
                                20,
                              ).padding(all: 10),
                              Divider(),
                              //const VerticalDivider(width: 20, thickness: 1, color: Colors.grey),
                              // 在 Column 中添加显示星期几的 Text 组件
                              buildVerticalText(getWeekday(), 20),
                            ],
                          ),
                          Text(
                            '更新:${DateTime.now().toString().split(' ')[0]}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ).padding(all: 10),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        curRec.content,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!_hasCurrentRecord)
                        Padding(
                          padding: const EdgeInsets.only(top: 18, bottom: 8),
                          child: FilledButton.icon(
                            onPressed:
                                _isImportingSample ? null : _importSampleTips,
                            icon: _isImportingSample
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.download_outlined),
                            label: Text(
                              _isImportingSample ? '正在导入…' : '导入示例数据',
                            ),
                          ),
                        ),
                      Row(
                        children: [
                          Spacer(),
                          Text(
                            '《${curRec.bookName}》',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (curRec.comments.isNotEmpty)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              '评论：${curRec.comments}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (_todayTipMode == TodayTipMode.random)
                            IconButton(
                              tooltip: '换一条随机开示',
                              onPressed:
                                  _hasCurrentRecord ? _refreshPreview : null,
                              icon: const Icon(
                                Icons.refresh,
                                color: Colors.blue,
                              ),
                            ),
                          IconButton(
                            tooltip: curRec.favoriteDateTime == null
                                ? '收藏开示'
                                : '取消收藏',
                            onPressed: _hasCurrentRecord
                                ? _togglePreviewFavorite
                                : null,
                            icon: Icon(
                              curRec.favoriteDateTime == null
                                  ? Icons.favorite_border
                                  : Icons.favorite,
                              color: curRec.favoriteDateTime == null
                                  ? null
                                  : Colors.red,
                            ),
                          ),
                          IconButton(
                            tooltip: curRec.completedDateTime == null
                                ? '标记已完成'
                                : '标记未完成',
                            onPressed: _hasCurrentRecord
                                ? _togglePreviewCompleted
                                : null,
                            icon: Icon(
                              curRec.completedDateTime == null
                                  ? Icons.check_box_outline_blank
                                  : Icons.check_box,
                              color: curRec.completedDateTime == null
                                  ? null
                                  : Colors.green,
                            ),
                          ),
                          IconButton(
                            tooltip: '复制开示',
                            onPressed: _hasCurrentRecord ? _copyPreview : null,
                            icon: const Icon(Icons.copy_outlined),
                          ),
                          IconButton(
                            tooltip: curRec.comments.isEmpty ? '添加评论' : '修改评论',
                            onPressed:
                                _hasCurrentRecord ? _editPreviewComments : null,
                            icon: Icon(
                              curRec.comments.isEmpty
                                  ? Icons.comment_outlined
                                  : Icons.comment,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ).padding(all: 15),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewAction extends StatelessWidget {
  const _PreviewAction({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: Colors.blue),
            const SizedBox(width: 3),
            Text(label, style: const TextStyle(color: Colors.blue)),
          ],
        ),
      ),
    );
  }
}

// 构建垂直显示的文本
Widget buildVerticalText(String text, double fontsize) {
  if (text.isEmpty) return const SizedBox();

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: text
        .split('')
        .map((char) => Text(char, style: TextStyle(fontSize: fontsize)))
        .toList(),
  );
}

// 获取当前日期是星期几
String getWeekday() {
  final weekday = DateTime.now().weekday;
  switch (weekday) {
    case 1:
      return '周一';
    case 2:
      return '周二';
    case 3:
      return '周三';
    case 4:
      return '周四';
    case 5:
      return '周五';
    case 6:
      return '周六';
    case 7:
      return '周日';
    default:
      return '';
  }
}
