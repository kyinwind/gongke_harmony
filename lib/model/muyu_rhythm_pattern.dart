/// 十念法领域模型
///
/// 纯值类型，可直接单元测试。对应 Swift 原版
/// `MuyuRhythmPattern.swift` / `MuyuRhythmPreferencesSnapshot.swift`。

/// 木鱼音色变体。
enum MuyuSoundVariant {
  regular, // 普通木鱼（muyu.wav）
  a, // 低音木鱼
  b, // 中音木鱼
  c; // 高音木鱼

  /// 可被用户编辑选择的音色（普通不参与十声循环）。
  static const List<MuyuSoundVariant> editableCases = [a, b, c];

  /// 对应的音频资源（assets 下的相对路径）。
  String get asset {
    switch (this) {
      case MuyuSoundVariant.regular:
        return 'mp3/muyu.wav';
      case MuyuSoundVariant.a:
        return 'mp3/muyu_a.mp3';
      case MuyuSoundVariant.b:
        return 'mp3/muyu_b.mp3';
      case MuyuSoundVariant.c:
        return 'mp3/muyu_c.mp3';
    }
  }

  /// 简短显示名：REGULAR / A / B / C。
  String get shortName => name.toUpperCase();

  /// 从存储字符串解析（未知值回退 regular）。
  static MuyuSoundVariant fromShort(String s) {
    switch (s.toLowerCase()) {
      case 'a':
        return a;
      case 'b':
        return b;
      case 'c':
        return c;
      default:
        return regular;
    }
  }
}

/// 模式来源。
enum MuyuRhythmPatternSource {
  regular,
  builtIn, // 内置，可被用户覆盖
  custom,
}

/// 运行时十念法模式（值类型）。
class MuyuRhythmPattern {
  final String id;
  final String displayName;
  final List<MuyuSoundVariant> sequence;
  final MuyuRhythmPatternSource source;
  final bool isOverridden; // 内置被用户改过

  const MuyuRhythmPattern({
    required this.id,
    required this.displayName,
    required this.sequence,
    required this.source,
    this.isOverridden = false,
  });

  /// 取第 index 声（0 基）的音色，按序列长度循环；空序列/负索引回退 regular。
  MuyuSoundVariant variantForZeroBasedStrikeIndex(int index) {
    if (sequence.isEmpty || index < 0) return MuyuSoundVariant.regular;
    return sequence[index % sequence.length];
  }

  /// 音序说明，如 "B B B  C C C A A A A"。
  String get groupedDescription {
    if (source == MuyuRhythmPatternSource.regular) return '使用普通木鱼声';
    if (sequence.isEmpty) return '';
    return sequence.map((v) => v.shortName).join();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'sequence': sequence.map((v) => v.name).toList(),
        'source': source.name,
        'isOverridden': isOverridden,
      };

  factory MuyuRhythmPattern.fromJson(Map<String, dynamic> json) {
    final seqRaw =
        (json['sequence'] as List?)?.map((e) => e as String).toList() ?? [];
    return MuyuRhythmPattern(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      sequence: seqRaw
          .map((s) => MuyuSoundVariant.values.firstWhere(
                (v) => v.name == s,
                orElse: () => MuyuSoundVariant.regular,
              ))
          .toList(),
      source: MuyuRhythmPatternSource.values.firstWhere(
        (s) => s.name == (json['source'] as String? ?? 'custom'),
        orElse: () => MuyuRhythmPatternSource.custom,
      ),
      isOverridden: json['isOverridden'] as bool? ?? false,
    );
  }
}

/// 内置模板目录（稳定 ID，不依赖中文显示名）。
class MuyuRhythmTemplateCatalog {
  static const MuyuRhythmPattern regular = MuyuRhythmPattern(
    id: 'regular',
    displayName: '普通模式',
    sequence: [MuyuSoundVariant.regular],
    source: MuyuRhythmPatternSource.regular,
  );

  static const MuyuRhythmPattern masterYinguang = MuyuRhythmPattern(
    id: 'masterYinguangTenRecitation',
    displayName: '印光大师推荐十念法',
    sequence: [
      MuyuSoundVariant.b,
      MuyuSoundVariant.b,
      MuyuSoundVariant.b,
      MuyuSoundVariant.c,
      MuyuSoundVariant.c,
      MuyuSoundVariant.c,
      MuyuSoundVariant.a,
      MuyuSoundVariant.a,
      MuyuSoundVariant.a,
      MuyuSoundVariant.a,
    ],
    source: MuyuRhythmPatternSource.builtIn,
  );

  static const MuyuRhythmPattern antiDrowsiness = MuyuRhythmPattern(
    id: 'alternatingTenRecitation',
    displayName: '防昏沉十念法',
    sequence: [
      MuyuSoundVariant.b,
      MuyuSoundVariant.c,
      MuyuSoundVariant.b,
      MuyuSoundVariant.c,
      MuyuSoundVariant.b,
      MuyuSoundVariant.c,
      MuyuSoundVariant.a,
      MuyuSoundVariant.a,
      MuyuSoundVariant.a,
      MuyuSoundVariant.a,
    ],
    source: MuyuRhythmPatternSource.builtIn,
  );

  /// 代码内置（普通 + 两个内置十念法），固定顺序。
  static const List<MuyuRhythmPattern> builtIns = [
    regular,
    masterYinguang,
    antiDrowsiness,
  ];

  /// 两个内置十念法的稳定 ID。
  static const List<String> builtInIds = [
    'masterYinguangTenRecitation',
    'alternatingTenRecitation',
  ];
}

// ---------------------------------------------------------------------------
// 持久化结构（shared_preferences 单键 JSON 快照）
// ---------------------------------------------------------------------------

/// 持久化的十念法定义（内置覆盖或自定义）。
class StoredMuyuRhythmDefinition {
  final String id;
  final String name;
  final List<String> sequence; // ['a','b','c',...] 仅 a/b/c
  final int sortOrder;
  final int createdAt; // epoch ms
  final int updatedAt;

  StoredMuyuRhythmDefinition({
    required this.id,
    required this.name,
    required this.sequence,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  List<MuyuSoundVariant> get variants =>
      sequence.map(MuyuSoundVariant.fromShort).toList();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sequence': sequence,
        'sortOrder': sortOrder,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  factory StoredMuyuRhythmDefinition.fromJson(Map<String, dynamic> json) {
    final seq = (json['sequence'] as List?)?.map((e) => e as String).toList() ??
        <String>[];
    return StoredMuyuRhythmDefinition(
      id: json['id'] as String,
      name: json['name'] as String,
      sequence: seq,
      sortOrder: json['sortOrder'] as int? ?? 0,
      createdAt: json['createdAt'] as int? ?? 0,
      updatedAt: json['updatedAt'] as int? ?? 0,
    );
  }
}

/// 某个功课（gongketype + name）选择的模式。
class MuyuRhythmSelection {
  final String gongKeType;
  final String gongKeName;
  final String patternID;

  MuyuRhythmSelection({
    required this.gongKeType,
    required this.gongKeName,
    required this.patternID,
  });

  Map<String, dynamic> toJson() => {
        'gongKeType': gongKeType,
        'gongKeName': gongKeName,
        'patternID': patternID,
      };

  factory MuyuRhythmSelection.fromJson(Map<String, dynamic> json) {
    return MuyuRhythmSelection(
      gongKeType: json['gongKeType'] as String? ?? '',
      gongKeName: json['gongKeName'] as String? ?? '',
      patternID: json['patternID'] as String? ?? 'regular',
    );
  }
}

/// 版本化偏好快照。
class MuyuRhythmPreferencesSnapshot {
  static const int currentSchemaVersion = 1;

  final int schemaVersion;
  final List<StoredMuyuRhythmDefinition> builtInOverrides;
  final List<StoredMuyuRhythmDefinition> customPatterns;
  final List<MuyuRhythmSelection> selections;

  MuyuRhythmPreferencesSnapshot({
    this.schemaVersion = currentSchemaVersion,
    this.builtInOverrides = const [],
    this.customPatterns = const [],
    this.selections = const [],
  });

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'builtInOverrides':
            builtInOverrides.map((e) => e.toJson()).toList(),
        'customPatterns': customPatterns.map((e) => e.toJson()).toList(),
        'selections': selections.map((e) => e.toJson()).toList(),
      };

  /// 从 JSON 解析；任何非法字段都安全回退到空快照，不抛异常。
  factory MuyuRhythmPreferencesSnapshot.fromJson(Map<String, dynamic>? json) {
    if (json == null) return MuyuRhythmPreferencesSnapshot();
    try {
      final version = json['schemaVersion'] as int? ?? currentSchemaVersion;
      final overrides = (json['builtInOverrides'] as List?)
              ?.map((e) =>
                  StoredMuyuRhythmDefinition.fromJson(e as Map<String, dynamic>))
              .toList() ??
          <StoredMuyuRhythmDefinition>[];
      final customs = (json['customPatterns'] as List?)
              ?.map((e) =>
                  StoredMuyuRhythmDefinition.fromJson(e as Map<String, dynamic>))
              .toList() ??
          <StoredMuyuRhythmDefinition>[];
      final sels = (json['selections'] as List?)
              ?.map((e) => MuyuRhythmSelection.fromJson(e as Map<String, dynamic>))
              .toList() ??
          <MuyuRhythmSelection>[];
      return MuyuRhythmPreferencesSnapshot(
        schemaVersion: version,
        builtInOverrides: overrides,
        customPatterns: customs,
        selections: sels,
      );
    } catch (_) {
      return MuyuRhythmPreferencesSnapshot();
    }
  }
}
