/// 十念法管理列表页（对应 Swift 原版 MuyuRhythmManagementView.swift）
///
/// - 内置模式：普通（只展示，不可编辑）；印光 / 防昏沉（可进编辑器改音序，显示「已调整」）。
/// - 我的十念法：自定义列表（可进编辑器；侧滑删除，删除前选替代模式）。
/// - 新建十念法入口。

import 'package:flutter/material.dart';
import 'package:gongke/comm/muyu_rhythm_store.dart';
import 'package:gongke/model/muyu_rhythm_pattern.dart';
import 'package:gongke/view/gongke/muyu_rhythm_editor_page.dart';

class MuyuRhythmManagementPage extends StatefulWidget {
  const MuyuRhythmManagementPage({super.key});

  @override
  State<MuyuRhythmManagementPage> createState() =>
      _MuyuRhythmManagementPageState();
}

class _MuyuRhythmManagementPageState extends State<MuyuRhythmManagementPage> {
  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final patterns = muyuRhythmStore.selectablePatterns;
    final builtIns = patterns
        .where((p) => p.source != MuyuRhythmPatternSource.custom)
        .toList();
    final customs = patterns
        .where((p) => p.source == MuyuRhythmPatternSource.custom)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('管理十念法')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text('内置模式',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
          ...builtIns.map((p) => _buildBuiltInTile(context, p)).toList(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text('我的十念法',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
          if (customs.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Text('还没有自定义十念法', style: TextStyle(color: Colors.grey)),
            ),
          ...customs.map((p) => _buildCustomTile(context, p)).toList(),
          ListTile(
            leading: const Icon(Icons.add_circle_outline, color: Colors.blue),
            title: const Text('新建十念法'),
            onTap: () =>
                _openEditor(context, mode: EditorMode.newCustom).then((_) => _refresh()),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildBuiltInTile(BuildContext context, MuyuRhythmPattern p) {
    final isRegular = p.source == MuyuRhythmPatternSource.regular;
    final trailing = p.isOverridden
        ? const Text('已调整', style: TextStyle(color: Colors.orange))
        : null;
    final tile = ListTile(
      title: Text(p.displayName),
      subtitle: Text(p.groupedDescription),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: isRegular
          ? null
          : () => _openEditor(context,
                  mode: EditorMode.builtIn, pattern: p)
              .then((_) => _refresh()),
    );
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: Colors.grey[100],
      child: tile,
    );
  }

  Widget _buildCustomTile(BuildContext context, MuyuRhythmPattern p) {
    return Dismissible(
      key: ValueKey(p.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        final ok = await _confirmDelete(context, p);
        if (ok) _refresh();
        return ok;
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        color: Colors.grey[100],
        child: ListTile(
          title: Text(p.displayName),
          subtitle: Text(p.groupedDescription),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _openEditor(context,
                  mode: EditorMode.custom, pattern: p)
              .then((_) => _refresh()),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, MuyuRhythmPattern p) async {
    final candidates = muyuRhythmStore.selectablePatterns
        .where((c) => c.id != p.id)
        .toList();
    String? replacement = candidates.isNotEmpty ? candidates.first.id : null;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('删除「${p.displayName}」'),
        content: StatefulBuilder(
          builder: (ctx2, setSt) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('正在被 ${muyuRhythmStore.usageCount(p.id)} 项功课使用。'
                  '删除前请选择替代模式：'),
              const SizedBox(height: 8),
              DropdownButton<String>(
                isExpanded: true,
                value: replacement,
                items: candidates
                    .map((c) => DropdownMenuItem(
                        value: c.id, child: Text(c.displayName)))
                    .toList(),
                onChanged: (v) => setSt(() => replacement = v),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('删除', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed != true || replacement == null) return false;
    final err = await muyuRhythmStore.deleteCustom(
        id: p.id, replacementID: replacement!);
    if (err != null && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err)));
      return false;
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('已删除并替换引用')));
    }
    return true;
  }

  Future<dynamic> _openEditor(BuildContext context,
      {required EditorMode mode, MuyuRhythmPattern? pattern}) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MuyuRhythmEditorPage(mode: mode, pattern: pattern),
      ),
    );
  }
}
