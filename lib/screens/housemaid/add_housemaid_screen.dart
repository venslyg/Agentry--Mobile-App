import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/housemaid.dart';
import '../../models/maid_status.dart';
import '../../providers/housemaid_provider.dart';
import '../../providers/sub_agent_provider.dart';
import '../../providers/notification_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';

class AddHousemaidScreen extends ConsumerStatefulWidget {
  final Housemaid? existing;
  final String? preselectedSubAgentId;

  const AddHousemaidScreen({
    super.key,
    this.existing,
    this.preselectedSubAgentId,
  });

  @override
  ConsumerState<AddHousemaidScreen> createState() =>
      _AddHousemaidScreenState();
}

class _AddHousemaidScreenState extends ConsumerState<AddHousemaidScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _passportCtrl;
  late final TextEditingController _commissionCtrl;
  String? _selectedSubAgentId;
  MaidStatus _status = MaidStatus.atAgency;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _passportCtrl = TextEditingController(text: e?.passportId ?? '');
    _commissionCtrl = TextEditingController(
        text: e != null ? e.totalCommission.toStringAsFixed(0) : '');
    _selectedSubAgentId = e?.subAgentId ?? widget.preselectedSubAgentId;
    _status = e?.status ?? MaidStatus.atAgency;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _passportCtrl.dispose();
    _commissionCtrl.dispose();
    super.dispose();
  }

  bool get _commissionLocked =>
      widget.existing?.status == MaidStatus.sentAbroad;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(housemaidProvider.notifier);
    final commission =
        double.tryParse(_commissionCtrl.text.trim()) ?? 0;
    final wasCompleted = widget.existing?.status == MaidStatus.completed;

    if (widget.existing != null) {
      widget.existing!.name = _nameCtrl.text.trim();
      widget.existing!.passportId = _passportCtrl.text.trim();
      widget.existing!.subAgentId = _selectedSubAgentId!;
      if (!_commissionLocked) {
        widget.existing!.totalCommission = commission;
      }
      widget.existing!.status = _status;
      await notifier.updateHousemaid(widget.existing!);

      // Notify if newly set to Completed
      if (!wasCompleted && _status == MaidStatus.completed) {
        await NotificationService.showStatusNotification(
            maidName: widget.existing!.name);
      }
    } else {
      final newMaid = Housemaid(
        id: const Uuid().v4(),
        name: _nameCtrl.text.trim(),
        passportId: _passportCtrl.text.trim(),
        subAgentId: _selectedSubAgentId!,
        totalCommission: commission,
        status: _status,
      );
      await notifier.addHousemaid(newMaid);
      if (_status == MaidStatus.completed) {
        await NotificationService.showStatusNotification(
            maidName: newMaid.name);
      }
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final agents = ref.watch(subAgentProvider);
    final isEdit = widget.existing != null;

    return Scaffold(
      appBar: AppBar(
          title: Text(
              isEdit ? l.tr('editHousemaid') : l.tr('addHousemaid'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _field(
                controller: _nameCtrl,
                label: l.tr('fullName'),
                icon: Icons.person_outline,
                validator: (v) =>
                    v!.trim().isEmpty ? l.tr('nameRequired') : null,
              ),
              const SizedBox(height: 16),
              _field(
                controller: _passportCtrl,
                label: l.tr('passportId'),
                icon: Icons.badge_outlined,
                validator: (v) =>
                    v!.trim().isEmpty ? l.tr('passportRequired') : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedSubAgentId,
                decoration: InputDecoration(
                  labelText: l.tr('subAgent'),
                  prefixIcon: const Icon(Icons.people_alt_outlined,
                      color: AppColors.primary),
                ),
                items: agents
                    .map((a) => DropdownMenuItem(
                          value: a.id,
                          child: Text(a.name),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedSubAgentId = v),
                validator: (v) =>
                    v == null ? l.tr('subAgentRequired') : null,
              ),
              const SizedBox(height: 16),
              Stack(
                children: [
                  _field(
                    controller: _commissionCtrl,
                    label: l.tr('totalCommission'),
                    icon: Icons.monetization_on_outlined,
                    keyboardType: TextInputType.number,
                    enabled: !_commissionLocked,
                    validator: (v) {
                      if (v!.trim().isEmpty) {
                        return l.tr('commissionRequired');
                      }
                      if (double.tryParse(v.trim()) == null) {
                        return l.tr('validNumber');
                      }
                      return null;
                    },
                  ),
                  if (_commissionLocked)
                    Positioned(
                      right: 12,
                      top: 16,
                      child: Row(children: [
                        Icon(Icons.lock,
                            size: 15, color: Colors.orange[700]),
                        const SizedBox(width: 4),
                        Text(l.tr('locked'),
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[700],
                                fontWeight: FontWeight.w600)),
                      ]),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<MaidStatus>(
                initialValue: _status,
                decoration: InputDecoration(
                  labelText: l.tr('status'),
                  prefixIcon: const Icon(Icons.flag_outlined,
                      color: AppColors.primary),
                ),
                items: MaidStatus.values
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.label),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _status = v!),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _save,
                child: Text(isEdit
                    ? l.tr('updateHousemaid')
                    : l.tr('saveHousemaid')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      validator: validator,
      decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary)),
    );
  }
}
