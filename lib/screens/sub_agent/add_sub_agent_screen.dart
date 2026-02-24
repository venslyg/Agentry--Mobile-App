import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/sub_agent.dart';
import '../../providers/sub_agent_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';

class AddSubAgentScreen extends ConsumerStatefulWidget {
  final SubAgent? existing;
  const AddSubAgentScreen({super.key, this.existing});

  @override
  ConsumerState<AddSubAgentScreen> createState() =>
      _AddSubAgentScreenState();
}

class _AddSubAgentScreenState extends ConsumerState<AddSubAgentScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _contactCtrl;
  late final TextEditingController _notesCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _contactCtrl =
        TextEditingController(text: widget.existing?.contact ?? '');
    _notesCtrl =
        TextEditingController(text: widget.existing?.notes ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _contactCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(subAgentProvider.notifier);
    if (widget.existing != null) {
      widget.existing!.name = _nameCtrl.text.trim();
      widget.existing!.contact = _contactCtrl.text.trim();
      widget.existing!.notes = _notesCtrl.text.trim();
      await notifier.updateSubAgent(widget.existing!);
    } else {
      await notifier.addSubAgent(SubAgent(
        id: const Uuid().v4(),
        name: _nameCtrl.text.trim(),
        contact: _contactCtrl.text.trim(),
        notes: _notesCtrl.text.trim(),
      ));
    }

    if (mounted) {
      final l = AppLocalizations.of(context);
      await showDialog(
        context: context,
        builder: (c) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 10),
              Text(l.tr('appName')),
            ],
          ),
          content: Text(l.tr('savedSuccessfully')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isEdit = widget.existing != null;
    return Scaffold(
      appBar: AppBar(
          title: Text(isEdit ? l.tr('editSubAgent') : l.tr('addSubAgent'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildField(
                controller: _nameCtrl,
                label: l.tr('fullName'),
                icon: Icons.person_outline,
                validator: (v) =>
                    v!.trim().isEmpty ? l.tr('nameRequired') : null,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _contactCtrl,
                label: l.tr('contactNumber'),
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    v!.trim().isEmpty ? l.tr('contactRequired') : null,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _notesCtrl,
                label: l.tr('notes'),
                icon: Icons.note_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _save,
                child: Text(isEdit
                    ? l.tr('updateSubAgent')
                    : l.tr('saveSubAgent')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
      ),
    );
  }
}
