import 'package:flutter/material.dart';

/// 功课类型的界面展示元数据。
///
/// 数据库只保存稳定的类型代码；名称、单位和图标属于展示层配置，修改这里
/// 不会影响 Drift 表结构，也不需要执行数据库迁移。
class GongKeTypePresentation {
  const GongKeTypePresentation({
    required this.code,
    required this.label,
    required this.unit,
    required this.icon,
    this.minimumCount = 1,
    this.maximumCount,
  });

  final String code;
  final String label;
  final String unit;
  final IconData icon;
  final int minimumCount;
  final int? maximumCount;

  static const Map<String, GongKeTypePresentation> values = {
    'songjing': GongKeTypePresentation(
      code: 'songjing',
      label: '诵经',
      unit: '部',
      icon: Icons.menu_book_outlined,
    ),
    'nianzhou': GongKeTypePresentation(
      code: 'nianzhou',
      label: '念咒',
      unit: '遍',
      icon: Icons.repeat_rounded,
    ),
    'nianshenghao': GongKeTypePresentation(
      code: 'nianshenghao',
      label: '念佛菩萨圣号',
      unit: '声',
      icon: Icons.record_voice_over_outlined,
    ),
    'ketou': GongKeTypePresentation(
      code: 'ketou',
      label: '磕头',
      unit: '个',
      icon: Icons.accessibility_new_outlined,
    ),
    'baichan': GongKeTypePresentation(
      code: 'baichan',
      label: '拜忏',
      unit: '次',
      icon: Icons.volunteer_activism_outlined,
    ),
    'dazuo': GongKeTypePresentation(
      code: 'dazuo',
      label: '打坐',
      unit: '分钟',
      icon: Icons.self_improvement_outlined,
      minimumCount: 10,
      maximumCount: 600,
    ),
    'others': GongKeTypePresentation(
      code: 'others',
      label: '其他',
      unit: '遍',
      icon: Icons.check_circle_outline,
    ),
  };

  static GongKeTypePresentation of(String code) =>
      values[code] ?? values['others']!;
}
