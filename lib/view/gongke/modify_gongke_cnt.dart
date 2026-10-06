import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gongke/database.dart';
import 'package:easy_design_system/easy_design_system.dart';
import '../../main.dart';
import '../../comm/widget_sync_hooks.dart';
import '../../comm/gongke_type_presentation.dart';

/// 修改当天功课数量页。
///
/// 从功课设置页右滑条目「修改数量」进入。
/// 保存规则（2026-10-06 评审确认）：
/// - 仅当新数量与原数量不同时写库；
/// - 数量变更后该功课状态重置为未完成，已完成遍数（curCnt）清零。
class ModifyGongKeCntPage extends StatefulWidget {
  const ModifyGongKeCntPage({super.key});

  @override
  State<ModifyGongKeCntPage> createState() => _ModifyGongKeCntPageState();
}

class _ModifyGongKeCntPageState extends State<ModifyGongKeCntPage> {
  late GongKeItemData gongkeitem;
  VoidCallback? onUpdated;
  bool _argsLoaded = false;

  // controller 为 State 成员，在 dispose 中释放
  // （遵守 2026-08-22 踩坑结论：避免 showDialog/页面拆解期间销毁 controller）
  final TextEditingController _controller = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsLoaded) return;
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null) {
      gongkeitem = args['gongkeitem'] as GongKeItemData;
      onUpdated = args['onUpdated'] as VoidCallback?;
      _controller.text = gongkeitem.cnt.toString();
      _argsLoaded = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int? get _parsedCnt => int.tryParse(_controller.text.trim());

  bool get _isValid {
    final cnt = _parsedCnt;
    return cnt != null && cnt >= 1;
  }

  void _adjust(int delta) {
    final current = _parsedCnt ?? 0;
    final next = (current + delta).clamp(1, 99999);
    _controller.text = next.toString();
  }

  Future<void> _save() async {
    if (!_isValid) return;
    final newCnt = _parsedCnt!;
    if (newCnt != gongkeitem.cnt) {
      await globalDB.managers.gongKeItem
          .filter((t) => t.id.equals(gongkeitem.id))
          .update(
            (o) => o(
              cnt: Value(newCnt),
              curCnt: const Value(0),
              isComplete: const Value(false),
            ),
          );
      await syncTaskAndCalendarCards();
      onUpdated?.call();
    }
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.edsTokens;
    final scheme = context.edsScheme;
    final presentation = GongKeTypePresentation.of(gongkeitem.gongketype);
    return Scaffold(
      backgroundColor: scheme.surfacePage,
      appBar: AppBar(
        title: const Text('修改功课数量'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isValid ? _save : null,
            child: const Text('保存'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(tokens.spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 功课信息卡片
              Container(
                padding: EdgeInsets.all(tokens.spacing.md),
                decoration: BoxDecoration(
                  color: scheme.surfaceRaised,
                  borderRadius: BorderRadius.circular(tokens.radius.lg),
                  border: Border.all(color: scheme.borderDefault),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: scheme.brandSurface,
                        borderRadius: BorderRadius.circular(tokens.radius.sm),
                      ),
                      child: Icon(
                        presentation.icon,
                        size: 22,
                        color: scheme.brandForeground,
                      ),
                    ),
                    SizedBox(width: tokens.spacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            gongkeitem.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: tokens.typography.body15Strong.copyWith(
                              color: scheme.foregroundPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${presentation.label} · 当前目标 ${gongkeitem.cnt} ${presentation.unit}',
                            style: tokens.typography.caption.copyWith(
                              color: scheme.foregroundSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: tokens.spacing.md),
              // 数量输入
              Text(
                '新的目标数量（${presentation.unit}）',
                style: tokens.typography.body15Strong.copyWith(
                  color: scheme.foregroundPrimary,
                ),
              ),
              SizedBox(height: tokens.spacing.sm),
              TextField(
                controller: _controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                style: tokens.typography.hero,
                decoration: InputDecoration(
                  hintText: '请输入正整数',
                  errorText: _controller.text.isEmpty || !_isValid
                      ? '请输入大于 0 的整数'
                      : null,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
              SizedBox(height: tokens.spacing.sm),
              // 快捷加减按钮
              Row(
                children: [
                  Expanded(child: _buildAdjustButton(-10, tokens)),
                  SizedBox(width: tokens.spacing.sm),
                  Expanded(child: _buildAdjustButton(-1, tokens)),
                  SizedBox(width: tokens.spacing.sm),
                  Expanded(child: _buildAdjustButton(1, tokens)),
                  SizedBox(width: tokens.spacing.sm),
                  Expanded(child: _buildAdjustButton(10, tokens)),
                ],
              ),
              SizedBox(height: tokens.spacing.md),
              // 重置提示
              Container(
                padding: EdgeInsets.all(tokens.spacing.sm),
                decoration: BoxDecoration(
                  color: scheme.warningSurface,
                  borderRadius: BorderRadius.circular(tokens.radius.md),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: scheme.warningForeground,
                    ),
                    SizedBox(width: tokens.spacing.xs),
                    Expanded(
                      child: Text(
                        '修改数量保存后，该功课的完成状态将重置为未完成，已完成遍数清零，需要重新计数。',
                        style: tokens.typography.caption.copyWith(
                          color: scheme.foregroundSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdjustButton(int delta, EdsDesignTokens tokens) {
    final label = delta > 0 ? '+$delta' : '$delta';
    return EdsButton(
      label,
      role: EdsButtonRole.secondary,
      action: () => setState(() => _adjust(delta)),
    );
  }
}
