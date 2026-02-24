import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/foreign_agent.dart';
import '../../providers/foreign_agent_provider.dart';
import '../../theme/app_theme.dart';

class AddForeignAgentScreen extends ConsumerStatefulWidget {
  final ForeignAgent? existing;
  const AddForeignAgentScreen({super.key, this.existing});

  @override
  ConsumerState<AddForeignAgentScreen> createState() => _AddForeignAgentScreenState();
}

class _AddForeignAgentScreenState extends ConsumerState<AddForeignAgentScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _countryCtrl;
  late final TextEditingController _notesCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _countryCtrl = TextEditingController(text: widget.existing?.country ?? '');
    _notesCtrl = TextEditingController(text: widget.existing?.notes ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _countryCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(foreignAgentProvider.notifier);
    if (widget.existing != null) {
      final updated = ForeignAgent(
        id: widget.existing!.id,
        name: _nameCtrl.text.trim(),
        country: _countryCtrl.text.trim(),
        notes: _notesCtrl.text.trim(),
      );
      await notifier.updateForeignAgent(updated);
    } else {
      final newAgent = ForeignAgent(
        id: const Uuid().v4(),
        name: _nameCtrl.text.trim(),
        country: _countryCtrl.text.trim(),
        notes: _notesCtrl.text.trim(),
      );
      await notifier.addForeignAgent(newAgent);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Foreign Agent' : 'Add Foreign Agent')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _field(controller: _nameCtrl, label: 'Agent Name', icon: Icons.person_outline),
              const SizedBox(height: 16),
              _field(controller: _countryCtrl, label: 'Country', icon: Icons.public_outlined),
              const SizedBox(height: 16),
              _field(controller: _notesCtrl, label: 'Notes', icon: Icons.note_alt_outlined, maxLines: 3),
              const SizedBox(height: 32),
              ElevatedButton(onPressed: _save, child: Text(isEdit ? 'Update Agent' : 'Save Agent')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({required TextEditingController controller, required String label, required IconData icon, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: AppColors.primary)),
      validator: (v) => v!.trim().isEmpty ? 'Field is required' : null,
    );
  }
}
