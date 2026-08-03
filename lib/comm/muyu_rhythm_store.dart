/// 十念法模式仓库 + 持久化（shared_preferences 单键 JSON 快照）
///
/// 对应 Swift 原版 `MuyuRhythmPatternStore.swift`。
/// 单例风格，与全局 `globalDB` 一致：应用启动时调用一次 [load]，之后全 App 直接引用。

import 'dart:convert';
import 'dart:math';

import 'package:gongke/comm/shared_preferences.dart';
import 'package:gongke/model/muyu_rhythm_pattern.dart';

const String _kSnapshotKey = 'gongke.muyuRhythmPreferences';

class MuyuRhythmPatternStore {
  MuyuRhythmPatternStore()
      : _selectable = List.unmodifiable(MuyuRhythmTemplateCatalog.builtIns);

  /// 当前可选模式列表（普通 → 印光 → 防昏沉 → 自定义）。
  List<MuyuRhythmPattern> get selectablePatterns => _selectable;
  List<MuyuRhythmPattern> _selectable;

  /// 每次数据变更自增，供试听/选择页感知音序变化并刷新/停止。
  int revision = 0;

  // 内部可变状态
  final List<StoredMuyuRhythmDefinition> _overrides = [];
  final List<StoredMuyuRhythmDefinition> _customs = [];
  final List<MuyuRhythmSelection> _selections = [];

  // -------------------------------------------------------------------------
  // 加载
  // -------------------------------------------------------------------------

  /// 应用启动时调用一次。
  Future<void> load() async {
    final raw = await getStringValue(_kSnapshotKey);
    if (raw == null || raw.isEmpty) {
      _overrides.clear();
      _customs.clear();
      _selections.clear();
      _rebuild();
      return;
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final snapshot = MuyuRhythmPreferencesSnapshot.fromJson(json);
      // 版本高于当前支持版本：只读回退内置，不覆盖原数据。
      if (snapshot.schemaVersion > MuyuRhythmPreferencesSnapshot.currentSchemaVersion) {
        _overrides.clear();
        _customs.clear();
        _selections.clear();
        _rebuild();
        return;
      }
      _overrides
        ..clear()
        ..addAll(_filterValidOverrides(snapshot.builtInOverrides));
      _customs
        ..clear()
        ..addAll(_filterValidCustoms(snapshot.customPatterns));
      _selections
        ..clear()
        ..addAll(snapshot.selections);
    } catch (_) {
      // 整体损坏：保留原始字符串不覆盖，回退内置模式。
      _overrides.clear();
      _customs.clear();
      _selections.clear();
    }
    _rebuild();
  }

  /// 单条自定义/覆盖定义非法的忽略，其他继续可用。
  List<StoredMuyuRhythmDefinition> _filterValidOverrides(
      List<StoredMuyuRhythmDefinition> list) {
    return list.where((d) => _isValidSequence(d.sequence)).toList();
  }

  List<StoredMuyuRhythmDefinition> _filterValidCustoms(
      List<StoredMuyuRhythmDefinition> list) {
    return list
        .where((d) =>
            d.id.startsWith('user.') && _isValidSequence(d.sequence))
        .toList();
  }

  // -------------------------------------------------------------------------
  // 查询
  // -------------------------------------------------------------------------

  /// 按 ID 取模式；未知/非法回退 regular。
  MuyuRhythmPattern patternFor(String? id) {
    if (id == null) return MuyuRhythmTemplateCatalog.regular;
    for (final p in _selectable) {
      if (p.id == id) return p;
    }
    return MuyuRhythmTemplateCatalog.regular;
  }

  /// 取某个功课当前选择的模式；无选择/失效回退 regular。
  MuyuRhythmPattern selectedPattern({
    required String gongKeType,
    required String gongKeName,
  }) {
    for (final sel in _selections) {
      if (sel.gongKeType == gongKeType && sel.gongKeName == gongKeName) {
        return patternFor(sel.patternID);
      }
    }
    return MuyuRhythmTemplateCatalog.regular;
  }

  /// 取某个功课当前选择的模式 ID（无则 'regular'）。
  String selectedPatternId({
    required String gongKeType,
    required String gongKeName,
  }) {
    for (final sel in _selections) {
      if (sel.gongKeType == gongKeType && sel.gongKeName == gongKeName) {
        return patternFor(sel.patternID).id;
      }
    }
    return 'regular';
  }

  /// 某模式被多少「功课类型 + 名称」引用。
  int usageCount(String id) {
    return _selections.where((s) => s.patternID == id).length;
  }

  // -------------------------------------------------------------------------
  // 选择
  // -------------------------------------------------------------------------

  Future<void> select({
    required String patternID,
    required String gongKeType,
    required String gongKeName,
  }) async {
    final effectiveId = patternFor(patternID).id; // 失效回退
    final idx = _selections.indexWhere(
        (s) => s.gongKeType == gongKeType && s.gongKeName == gongKeName);
    if (idx >= 0) {
      _selections[idx] = MuyuRhythmSelection(
        gongKeType: gongKeType,
        gongKeName: gongKeName,
        patternID: effectiveId,
      );
    } else {
      _selections.add(MuyuRhythmSelection(
        gongKeType: gongKeType,
        gongKeName: gongKeName,
        patternID: effectiveId,
      ));
    }
    await _persist();
  }

  // -------------------------------------------------------------------------
  // 自定义模式 CRUD
  // -------------------------------------------------------------------------

  /// 返回 null 表示成功；否则返回错误描述。
  Future<String?> createCustom({
    required String name,
    required List<MuyuSoundVariant> sequence,
  }) async {
    final seq = sequence.map((v) => v.name).toList();
    final err = _validateName(name, ignoreId: null) ??
        _validateSequence(seq);
    if (err != null) return err;

    final id = 'user.${DateTime.now().microsecondsSinceEpoch}'
        '_${Random().nextInt(999999)}';
    final now = DateTime.now().millisecondsSinceEpoch;
    final maxOrder = _customs.isEmpty
        ? 0
        : _customs.map((c) => c.sortOrder).reduce(max);
    _customs.add(StoredMuyuRhythmDefinition(
      id: id,
      name: name.trim(),
      sequence: seq,
      sortOrder: maxOrder + 1,
      createdAt: now,
      updatedAt: now,
    ));
    await _persist();
    return null;
  }

  Future<String?> updateCustom({
    required String id,
    required String name,
    required List<MuyuSoundVariant> sequence,
  }) async {
    final idx = _customs.indexWhere((c) => c.id == id);
    if (idx < 0) return '未找到该十念法';
    final seq = sequence.map((v) => v.name).toList();
    final err = _validateName(name, ignoreId: id) ?? _validateSequence(seq);
    if (err != null) return err;

    final now = DateTime.now().millisecondsSinceEpoch;
    final old = _customs[idx];
    _customs[idx] = StoredMuyuRhythmDefinition(
      id: id,
      name: name.trim(),
      sequence: seq,
      sortOrder: old.sortOrder,
      createdAt: old.createdAt,
      updatedAt: now,
    );
    await _persist();
    return null;
  }

  /// 更新内置模式音序（写入覆盖）。内置名称固定，不可改。
  Future<String?> updateBuiltIn({
    required String id,
    required List<MuyuSoundVariant> sequence,
  }) async {
    if (!MuyuRhythmTemplateCatalog.builtInIds.contains(id)) {
      return '不是内置模式';
    }
    final seq = sequence.map((v) => v.name).toList();
    final err = _validateSequence(seq);
    if (err != null) return err;

    final catalog = MuyuRhythmTemplateCatalog.builtIns.firstWhere(
      (p) => p.id == id,
      orElse: () => MuyuRhythmTemplateCatalog.regular,
    );
    final now = DateTime.now().millisecondsSinceEpoch;
    final idx = _overrides.indexWhere((o) => o.id == id);
    if (idx >= 0) {
      final old = _overrides[idx];
      _overrides[idx] = StoredMuyuRhythmDefinition(
        id: id,
        name: catalog.displayName,
        sequence: seq,
        sortOrder: 0,
        createdAt: old.createdAt,
        updatedAt: now,
      );
    } else {
      _overrides.add(StoredMuyuRhythmDefinition(
        id: id,
        name: catalog.displayName,
        sequence: seq,
        sortOrder: 0,
        createdAt: now,
        updatedAt: now,
      ));
    }
    await _persist();
    return null;
  }

  /// 恢复内置默认音序（删除覆盖）。
  Future<void> resetBuiltIn(String id) async {
    _overrides.removeWhere((o) => o.id == id);
    await _persist();
  }

  /// 删除自定义模式，并把所有引用原子替换为 replacementID。
  /// 返回 null 成功，否则错误描述。
  Future<String?> deleteCustom({
    required String id,
    required String replacementID,
  }) async {
    final idx = _customs.indexWhere((c) => c.id == id);
    if (idx < 0) return '未找到该十念法';
    // 替代模式必须有效
    if (patternFor(replacementID).id != replacementID) {
      return '替代模式无效';
    }
    if (replacementID == id) return '替代模式不能是自身';
    // 原子替换引用
    for (var i = 0; i < _selections.length; i++) {
      if (_selections[i].patternID == id) {
        _selections[i] = MuyuRhythmSelection(
          gongKeType: _selections[i].gongKeType,
          gongKeName: _selections[i].gongKeName,
          patternID: replacementID,
        );
      }
    }
    _customs.removeAt(idx);
    await _persist();
    return null;
  }

  // -------------------------------------------------------------------------
  // 校验
  // -------------------------------------------------------------------------

  static bool _isValidSequence(List<String> seq) {
    if (seq.length != 10) return false;
    for (final s in seq) {
      if (s != 'a' && s != 'b' && s != 'c') return false;
    }
    return true;
  }

  /// 返回 null 表示合法，否则为错误描述。
  String? _validateName(String name, {String? ignoreId}) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '名称不能为空';
    if (trimmed.length > 20) return '名称最多 20 个字符';
    final lower = trimmed.toLowerCase();
    // 与所有已有名称（内置显示名 + 自定义名）不区分大小写重复
    for (final p in _selectable) {
      if (p.id == ignoreId) continue;
      if (p.displayName.toLowerCase() == lower) return '名称已存在';
    }
    return null;
  }

  String? _validateSequence(List<String> seq) {
    if (!_isValidSequence(seq)) return '十念法必须为 10 个 A/B/C 声位';
    return null;
  }

  // -------------------------------------------------------------------------
  // 持久化
  // -------------------------------------------------------------------------

  void _rebuild() {
    final List<MuyuRhythmPattern> result = [];
    for (final built in MuyuRhythmTemplateCatalog.builtIns) {
      if (built.source == MuyuRhythmPatternSource.regular) {
        result.add(built);
        continue;
      }
      final override = _overrides.where((o) => o.id == built.id).isEmpty
          ? null
          : _overrides.firstWhere((o) => o.id == built.id);
      if (override != null) {
        result.add(MuyuRhythmPattern(
          id: built.id,
          displayName: built.displayName,
          sequence: override.variants,
          source: MuyuRhythmPatternSource.builtIn,
          isOverridden: true,
        ));
      } else {
        result.add(built);
      }
    }
    final customs = List<StoredMuyuRhythmDefinition>.from(_customs)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    for (final c in customs) {
      result.add(MuyuRhythmPattern(
        id: c.id,
        displayName: c.name,
        sequence: c.variants,
        source: MuyuRhythmPatternSource.custom,
      ));
    }
    _selectable = List.unmodifiable(result);
    revision++;
  }

  Future<void> _persist() async {
    final snapshot = MuyuRhythmPreferencesSnapshot(
      schemaVersion: MuyuRhythmPreferencesSnapshot.currentSchemaVersion,
      builtInOverrides: _overrides,
      customPatterns: _customs,
      selections: _selections,
    );
    // 编码成功后才写入；写入失败不破坏内存状态。
    try {
      final raw = jsonEncode(snapshot.toJson());
      await saveStringValue(_kSnapshotKey, raw);
      _rebuild();
    } catch (_) {
      // 编码异常：保持内存状态，不影响本次运行。
    }
  }
}

/// 全局单例。
final MuyuRhythmPatternStore muyuRhythmStore = MuyuRhythmPatternStore();
