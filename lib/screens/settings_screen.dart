import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../services/backup_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l.tr('settings'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Appearance ─────────────────────────────────────────────
          _SectionHeader(title: l.tr('appearance')),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              SwitchListTile(
                value: settings.darkMode,
                onChanged: (v) => notifier.setDarkMode(v),
                secondary: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: settings.darkMode
                        ? Colors.deepPurple.withValues(alpha: 0.15)
                        : Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    settings.darkMode
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    color: settings.darkMode
                        ? Colors.deepPurple
                        : Colors.amber[700],
                  ),
                ),
                title: Text(l.tr('darkMode'),
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                subtitle: Text(
                  settings.darkMode ? 'On' : 'Off',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey[500]),
                ),
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Language ────────────────────────────────────────────────
          _SectionHeader(title: l.tr('language')),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _LangOption(
                label: l.tr('english'),
                code: 'en',
                flag: '🇬🇧',
                selected: settings.languageCode == 'en',
                onTap: () async {
                  await notifier.setLanguage('en');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(l.tr('preferencesSaved')),
                          backgroundColor: AppColors.green),
                    );
                  }
                },
              ),
              const Divider(height: 1, indent: 16),
              _LangOption(
                label: l.tr('sinhala'),
                code: 'si',
                flag: '🇱🇰',
                selected: settings.languageCode == 'si',
                onTap: () async {
                  await notifier.setLanguage('si');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(l.tr('preferencesSaved')),
                          backgroundColor: AppColors.green),
                    );
                  }
                },
              ),
              const Divider(height: 1, indent: 16),
              _LangOption(
                label: l.tr('tamil'),
                code: 'ta',
                flag: '🇮🇳',
                selected: settings.languageCode == 'ta',
                onTap: () async {
                  await notifier.setLanguage('ta');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(l.tr('preferencesSaved')),
                          backgroundColor: AppColors.green),
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Backup ──────────────────────────────────────────────────
          _SectionHeader(title: l.tr('backup')),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.backup_rounded, color: AppColors.primary),
                ),
                title: Text(l.tr('backupData'),
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                subtitle: Text(l.tr('backupDataSubtitle'),
                    style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                onTap: () async {
                  try {
                    await BackupService.performBackup();
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Backup failed: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'Agentry v1.0.0',
              style: TextStyle(
                  color: Colors.grey[400], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _LangOption extends StatelessWidget {
  final String label;
  final String code;
  final String flag;
  final bool selected;
  final VoidCallback onTap;

  const _LangOption({
    required this.label,
    required this.code,
    required this.flag,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Text(flag, style: const TextStyle(fontSize: 28)),
      title: Text(label,
          style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: Text(code.toUpperCase(),
          style: TextStyle(fontSize: 11, color: Colors.grey[500])),
      trailing: selected
          ? const Icon(Icons.check_circle_rounded,
              color: AppColors.primary)
          : Icon(Icons.circle_outlined, color: Colors.grey[300]),
    );
  }
}
