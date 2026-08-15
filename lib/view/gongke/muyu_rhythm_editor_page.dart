/// 十念法编辑页（对应 Swift 原版 MuyuRhythmEditorView.swift）
///
/// - 名称（自定义模式可改，内置模式只读）。
/// - 2x5 共 10 声位的 A/B/C 网格，每声位独立选择音色。
/// - 快捷音序：印光 / 防昏沉。
/// - 草稿试听 20 声（两个完整循环），改动草稿或退出即停止。
/// - 保存校验：名称不空/≤20/不重名；音序必须正好 10 个 A/B/C。
/// - 内置模式支持「恢复默认」；自定义模式支持「删除（选替代模式）」。
/// - 未保存退出二次确认。

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gongke/comm/muyu_rhythm_preview_controller.dart';
import 'package:gongke/comm/muyu_rhythm_store.dart';
import 'package:gongke/model/muyu_rhythm_pattern.dart';

enum EditorMode { newCustom, builtIn, custom }

class MuyuRhythmEditorPage extends StatefulWidget {
  final EditorMode mode;
  final MuyuRhythmPattern? pattern;

  const MuyuRhythmEditorPage({super.key, required this.mode, this.pattern});

  @override
  State<MuyuRhythmEditorPage> createState() => _MuyuRhythmEditorPageState();
}

class _MuyuRhythmEditorPageState extends State<MuyuRhythmEditorPage> {
  late final TextEditingController _nameController;
  late List<MuyuSoundVariant> _draft;
  final MuyuRhythmPreviewController _preview = MuyuRhythmPreviewController();
  Timer? _uiTimer;

  late final String _initialName;
  late final List<String> _initialSeq;

  bool get _isBuiltIn => widget.mode == EditorMode.builtIn;
  bool get _isNew => widget.mode == EditorMode.newCustom;

  @override
  void initState() {
    super.initState();
    if (widget.pattern != null) {
      _nameController =
          TextEditingController(text: widget.pattern!.displayName);
      _draft = List<MuyuSoundVariant>.from(widget.pattern!.sequence);
    } else {
      _nameController = TextEditingController();
      _draft = List<MuyuSoundVariant>.from(
          MuyuRhythmTemplateCatalog.masterYinguang.sequence);
    }
    _initialName = _nameController.text;
    _initialSeq = _draft.map((v) => v.name).toList();
  }

  bool get _isDirty {
    if (_nameController.text.trim() != _initialName.trim()) return true;
    final cur = _draft.map((v) => v.name).toList();
    if (cur.length != _initialSeq.length) return true;
    for (var i = 0; i < cur.length; i++) {
      if (cur[i] != _initialSeq[i]) return true;
    }
    return false;
  }

  String get _draftDescription {
    final g1 = _draft.take(5).map((v) => v.shortName).join(' ');
    final g2 = _draft.skip(5).map((v) => v.shortName).join(' ');
    return '$g1｜$g2';
  }

  MuyuRhythmPattern get _draftPattern => MuyuRhythmPattern(
        id: 'draft',
        displayName: _nameController.text,
        sequence: List<MuyuSoundVariant>.from(_draft),
        source: MuyuRhythmPatternSource.custom,
      );

  @override
  void dispose() {
    _preview.dispose();
    _uiTimer?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  void _setSlot(int index, MuyuSoundVariant v) {
    _preview.stop();
    _uiTimer?.cancel();
    setState(() {
      _draft[index] = v;
    });
  }

  void _applyPreset(MuyuRhythmPattern preset) {
    _preview.stop();
    _uiTimer?.cancel();
    setState(() {
      _draft = List<MuyuSoundVariant>.from(preset.sequence);
    });
  }

  void _togglePreview() {
    if (_preview.isPlaying) {
      _preview.stop();
      _uiTimer?.cancel();
      setState(() {});
      return;
    }
    _preview.start(pattern: _draftPattern, interval: 1.0);
    _uiTimer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      if (!_preview.isPlaying) {
        _uiTimer?.cancel();
        _uiTimer = null;
      }
      if (mounted) setState(() {});
    });
    setState(() {});
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    String? err;
    if (_isBuiltIn) {
      err = await muyuRhythmStore.updateBuiltIn(
        id: widget.pattern!.id,
        sequence: _draft,
      );
    } else if (_isNew) {
      err = await muyuRhythmStore.createCustom(name: name, sequence: _draft);
    } else {
      err = await muyuRhythmStore.updateCustom(
        id: widget.pattern!.id,
        name: name,
        sequence: _draft,
      );
    }
    if (err != null) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(err)));
      }
      return;
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _resetBuiltIn() async {
    await muyuRhythmStore.resetBuiltIn(widget.pattern!.id);
    final catalog = MuyuRhythmTemplateCatalog.builtIns.firstWhere(
      (p) => p.id == widget.pattern!.id,
      orElse: () => MuyuRhythmTemplateCatalog.regular,
    );
    _preview.stop();
    _uiTimer?.cancel();
    setState(() {
      _draft = List<MuyuSoundVariant>.from(catalog.sequence);
      _initialSeq = _draft.map((v) => v.name).toList();
    });
  }

  Future<void> _deleteCustom() async {
    final id = widget.pattern!.id;
    final candidates =
        muyuRhythmStore.selectablePatterns.where((c) => c.id != id).toList();
    String? replacement = candidates.isNotEmpty ? candidates.first.id : null;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('删除「${widget.pattern!.displayName}」'),
        content: StatefulBuilder(
          builder: (ctx2, setSt) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('正在被 ${muyuRhythmStore.usageCount(id)} 项功课使用。'
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
    if (confirmed != true || replacement == null) return;
    final err =
        await muyuRhythmStore.deleteCustom(id: id, replacementID: replacement!);
    if (err != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    if (mounted) Navigator.pop(context);
  }

  Future<bool> _onWillPop() async {
    if (!_isDirty) return true;
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('放弃修改？'),
        content: const Text('当前十念法尚未保存，退出将丢失修改。'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('继续编辑')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('放弃', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    return discard == true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDirty,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final scaffoldContext = context;
        final ok = await _onWillPop();
        if (ok && scaffoldContext.mounted) {
          Navigator.pop(scaffoldContext);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isNew ? '新建十念法' : '编辑十念法'),
          actions: [
            TextButton(
              onPressed: _save,
              child: const Text('保存'),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('名称', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              enabled: !_isBuiltIn,
              maxLength: 20,
              decoration: InputDecoration(
                hintText: _isBuiltIn ? '内置模式名称不可修改' : '给这个十念法起个名字',
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('音序（每 10 声一组，A/B/C 三音色）',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton(
                  onPressed: () =>
                      _applyPreset(MuyuRhythmTemplateCatalog.masterYinguang),
                  child: const Text('印光大师推荐'),
                ),
                TextButton(
                  onPressed: () =>
                      _applyPreset(MuyuRhythmTemplateCatalog.antiDrowsiness),
                  child: const Text('防昏沉'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildGrid(),
            const SizedBox(height: 8),
            Text('音序预览：$_draftDescription',
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _togglePreview,
              icon: Icon(_preview.isPlaying ? Icons.stop : Icons.play_arrow),
              label: Text(_preview.isPlaying ? '停止试听' : '试听（20 声）'),
            ),
            const SizedBox(height: 16),
            if (_isBuiltIn)
              OutlinedButton(
                onPressed: _resetBuiltIn,
                child: const Text('恢复默认音序'),
              ),
            if (!_isNew && !_isBuiltIn)
              OutlinedButton(
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                onPressed: _deleteCustom,
                child: const Text('删除此十念法'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return Column(
      children: [
        _buildRow(0),
        const SizedBox(height: 8),
        _buildRow(5),
      ],
    );
  }

  Widget _buildRow(int start) {
    return Row(
      children: List.generate(5, (i) {
        final index = start + i;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: _buildSlot(index),
          ),
        );
      }),
    );
  }

  Widget _buildSlot(int index) {
    final current = _draft[index];
    return Column(
      children: [
        Text('第${index + 1}声',
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
        DropdownButton<MuyuSoundVariant>(
          isExpanded: true,
          value: current,
          underline: Container(height: 1, color: Colors.grey[300]),
          items: MuyuSoundVariant.editableCases
              .map((v) => DropdownMenuItem(value: v, child: Text(v.shortName)))
              .toList(),
          onChanged: (v) {
            if (v != null) _setSlot(index, v);
          },
        ),
      ],
    );
  }
}
