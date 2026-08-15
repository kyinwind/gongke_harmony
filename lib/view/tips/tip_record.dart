import 'dart:io';
import 'dart:ui' as ui;

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../comm/harmony_share_service.dart';
import '../../comm/tts_tools.dart';
import '../../comm/widget_snapshot_service.dart';
import '../../database.dart';
import '../../main.dart';

class TipRecordPage extends StatefulWidget {
  const TipRecordPage({super.key});

  @override
  State<TipRecordPage> createState() => _TipRecordPageState();
}

class _TipRecordPageState extends State<TipRecordPage> {
  final TtsTools _tts = TtsTools();
  final HarmonyShareService _share = const HarmonyShareService();
  List<TipRecordData> _records = const [];
  int _bookId = 0;
  String _bookName = '开示记录';
  int? _speakingRecordId;
  bool _loadedArguments = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadedArguments) return;
    _loadedArguments = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic> && args['bookId'] is int) {
      _bookId = args['bookId'] as int;
      _load();
    }
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _load() async {
    final book = await (globalDB.select(globalDB.tipBook)
          ..where((table) => table.id.equals(_bookId)))
        .getSingleOrNull();
    final records = await (globalDB.select(globalDB.tipRecord)
          ..where((table) => table.bookId.equals(_bookId))
          ..orderBy([
            (table) => OrderingTerm.asc(table.sortOrder),
            (table) => OrderingTerm.asc(table.id),
          ]))
        .get();
    if (!mounted) return;
    setState(() {
      _bookName = book?.name ?? '开示记录';
      _records = records;
    });
  }

  Future<void> _syncWidget() async {
    try {
      await WidgetSnapshotService(globalDB).syncAll();
    } catch (error) {
      debugPrint('同步开示卡片失败：$error');
    }
  }

  Future<void> _toggleFavorite(TipRecordData record) async {
    await globalDB.managers.tipRecord.filter((f) => f.id(record.id)).update(
          (o) => o(
            favoriteDateTime: Value(
              record.favoriteDateTime == null ? DateTime.now() : null,
            ),
          ),
        );
    await _load();
    await _syncWidget();
  }

  Future<void> _toggleCompleted(TipRecordData record) async {
    await globalDB.managers.tipRecord.filter((f) => f.id(record.id)).update(
          (o) => o(
            completedDateTime: Value(
              record.completedDateTime == null ? DateTime.now() : null,
            ),
          ),
        );
    await _load();
    await _syncWidget();
  }

  Future<void> _edit(TipRecordData record) async {
    final changed = await Navigator.pushNamed(
      context,
      '/AddTipRecord',
      arguments: {
        'acttype': 'mod',
        'bookId': _bookId,
        'recordId': record.id,
      },
    );
    if (changed == true) {
      await _load();
      await _syncWidget();
    }
  }

  Future<void> _delete(TipRecordData record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除开示'),
        content: const Text('确定删除这条开示吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await globalDB.managers.tipRecord.filter((f) => f.id(record.id)).delete();
    await _load();
    await _syncWidget();
  }

  Future<void> _reorder(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) newIndex -= 1;
    if (oldIndex == newIndex) return;

    final reordered = List<TipRecordData>.from(_records);
    final moved = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, moved);
    setState(() => _records = reordered);

    try {
      await globalDB.transaction(() async {
        for (var index = 0; index < reordered.length; index++) {
          await (globalDB.update(globalDB.tipRecord)
                ..where((table) => table.id.equals(reordered[index].id)))
              .write(TipRecordCompanion(sortOrder: Value(index)));
        }
      });
      await _load();
      await _syncWidget();
    } catch (error) {
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('调整顺序失败：$error')),
      );
    }
  }

  Future<void> _toggleSpeak(TipRecordData record) async {
    if (_speakingRecordId == record.id) {
      await _tts.stop();
      if (mounted) setState(() => _speakingRecordId = null);
      return;
    }
    setState(() => _speakingRecordId = record.id);
    try {
      await _tts.speak(record.content, () {
        if (mounted) setState(() => _speakingRecordId = null);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _speakingRecordId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('朗读失败：$error')),
      );
    }
  }

  Future<void> _shareRecord(TipRecordData record) async {
    try {
      await _share.shareText(
        title: _bookName,
        text: '${record.content}\n\n《$_bookName》',
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('分享失败：$error')),
      );
    }
  }

  Future<void> _shareRecordImage(TipRecordData record) async {
    final boundaryKey = GlobalKey();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('分享开示图片'),
        content: RepaintBoundary(
          key: boundaryKey,
          child: Container(
            width: 480,
            padding: const EdgeInsets.all(32),
            color: const Color(0xFFFFFDF8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.content,
                    style: const TextStyle(fontSize: 24, height: 1.6)),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('《$_bookName》',
                      style: const TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('取消')),
          FilledButton(
            onPressed: () async {
              try {
                final boundary = boundaryKey.currentContext?.findRenderObject()
                    as RenderRepaintBoundary?;
                if (boundary == null) throw StateError('分享卡片尚未渲染完成');
                final image = await boundary.toImage(pixelRatio: 2);
                final data =
                    await image.toByteData(format: ui.ImageByteFormat.png);
                image.dispose();
                if (data == null) throw StateError('PNG 生成失败');
                final directory = await getTemporaryDirectory();
                final file = File(
                    path.join(directory.path, 'tip_share_${record.id}.png'));
                await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
                try {
                  await _share.shareFile(
                      title: _bookName, path: file.path, utd: 'general.png');
                } finally {
                  if (await file.exists()) await file.delete();
                }
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              } catch (error) {
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext)
                      .showSnackBar(SnackBar(content: Text('图片分享失败：$error')));
                }
              }
            },
            child: const Text('分享图片'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_bookName),
        actions: [
          IconButton(
            tooltip: '新增开示',
            icon: const Icon(Icons.add_circle, color: Colors.blue, size: 32),
            onPressed: () async {
              final changed = await Navigator.pushNamed(
                context,
                '/AddTipRecord',
                arguments: {'acttype': 'new', 'bookId': _bookId},
              );
              if (changed == true) {
                await _load();
                await _syncWidget();
              }
            },
          ),
        ],
      ),
      body: _records.isEmpty
          ? const Center(child: Text('暂无开示记录'))
          : ReorderableListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _records.length,
              onReorder: _reorder,
              buildDefaultDragHandles: false,
              itemBuilder: (context, index) {
                final record = _records[index];
                return Card(
                  key: ValueKey(record.id),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    trailing: ReorderableDragStartListener(
                      index: index,
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.drag_handle),
                      ),
                    ),
                    title: Text(record.content),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (record.comments.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text('评论：${record.comments}'),
                        ],
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 4,
                          children: [
                            IconButton(
                              tooltip: record.favoriteDateTime == null
                                  ? '收藏'
                                  : '取消收藏',
                              onPressed: () => _toggleFavorite(record),
                              icon: Icon(
                                record.favoriteDateTime == null
                                    ? Icons.favorite_border
                                    : Icons.favorite,
                                color: Colors.amber,
                              ),
                            ),
                            IconButton(
                              tooltip: record.completedDateTime == null
                                  ? '标记完成'
                                  : '取消完成',
                              onPressed: () => _toggleCompleted(record),
                              icon: Icon(
                                record.completedDateTime == null
                                    ? Icons.check_circle_outline
                                    : Icons.check_circle,
                                color: Colors.green,
                              ),
                            ),
                            IconButton(
                              tooltip: _speakingRecordId == record.id
                                  ? '停止朗读'
                                  : '朗读',
                              onPressed: () => _toggleSpeak(record),
                              icon: Icon(
                                _speakingRecordId == record.id
                                    ? Icons.stop_circle_outlined
                                    : Icons.volume_up_outlined,
                              ),
                            ),
                            IconButton(
                              tooltip: '分享',
                              onPressed: () => _shareRecord(record),
                              icon: const Icon(Icons.share_outlined),
                            ),
                            IconButton(
                              tooltip: '分享图片',
                              onPressed: () => _shareRecordImage(record),
                              icon: const Icon(Icons.image_outlined),
                            ),
                            IconButton(
                              tooltip: '修改',
                              onPressed: () => _edit(record),
                              icon: const Icon(Icons.edit_outlined),
                            ),
                            IconButton(
                              tooltip: '删除',
                              onPressed: () => _delete(record),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
