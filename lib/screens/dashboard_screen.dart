import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sub_agent_provider.dart';
import '../providers/housemaid_provider.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../widgets/summary_card.dart';
import 'sub_agent/sub_agent_list_screen.dart';
import 'housemaid/housemaid_list_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final agents = ref.watch(subAgentProvider);
    final maids = ref.watch(housemaidProvider);
    final transactions = ref.watch(transactionProvider);

    final totalPaid =
        transactions.fold<double>(0, (sum, t) => sum + t.amount);

    double totalPending = 0;
    for (final maid in maids) {
      final paid = transactions
          .where((t) => t.maidId == maid.id)
          .fold<double>(0, (sum, t) => sum + t.amount);
      final rem = maid.totalCommission - paid;
      if (rem > 0) totalPending += rem;
    }

    // Top 5 Sub-Agents by pending balance
    final agentPendingList = agents.map((agent) {
      final agentMaids =
          maids.where((m) => m.subAgentId == agent.id).toList();
      final pending = agentMaids.fold<double>(0, (sum, maid) {
        final paid = transactions
            .where((t) => t.maidId == maid.id)
            .fold<double>(0, (s, t) => s + t.amount);
        final rem = maid.totalCommission - paid;
        return sum + (rem > 0 ? rem : 0);
      });
      return (agent: agent, pending: pending, maidCount: agentMaids.length);
    }).toList()
      ..sort((a, b) => b.pending.compareTo(a.pending));

    final top5 = agentPendingList.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.business_center, size: 22),
            const SizedBox(width: 8),
            Text(l.tr('appName')),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.tr('overview'),
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                SummaryCard(
                  label: l.tr('totalSubAgents'),
                  value: agents.length.toString(),
                  icon: Icons.people_alt_rounded,
                  color: AppColors.primary,
                  bgColor: AppColors.greenLight,
                ),
                SummaryCard(
                  label: l.tr('totalMaids'),
                  value: maids.length.toString(),
                  icon: Icons.person_rounded,
                  color: AppColors.atAgency,
                  bgColor: const Color(0xFFD6EAF8),
                ),
                SummaryCard(
                  label: l.tr('totalPaid'),
                  value: '৳${totalPaid.toStringAsFixed(0)}',
                  icon: Icons.check_circle_rounded,
                  color: AppColors.green,
                  bgColor: AppColors.greenLight,
                ),
                SummaryCard(
                  label: l.tr('totalPending'),
                  value: '৳${totalPending.toStringAsFixed(0)}',
                  icon: Icons.pending_actions_rounded,
                  color: AppColors.orange,
                  bgColor: AppColors.orangeLight,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(l.tr('quickAccess'),
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            _NavCard(
              icon: Icons.supervised_user_circle_rounded,
              title: l.tr('subAgents'),
              subtitle: '${agents.length} ${l.tr('registered')}',
              color: AppColors.primary,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => const SubAgentListScreen())),
            ),
            const SizedBox(height: 10),
            _NavCard(
              icon: Icons.person_search_rounded,
              title: l.tr('housemaids'),
              subtitle: '${maids.length} ${l.tr('registered')}',
              color: AppColors.atAgency,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => const HousemaidListScreen())),
            ),
            // ── Top 5 Pending Sub-Agents ────────────────────────────────
            if (top5.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  const Icon(Icons.bar_chart,
                      color: AppColors.orange, size: 20),
                  const SizedBox(width: 8),
                  Text(l.tr('topPendingSubs'),
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                ],
              ),
              const SizedBox(height: 10),
              Container(
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
                child: Column(
                  children: top5.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final item = entry.value;
                    final maxPending = top5.first.pending;
                    final ratio = maxPending > 0
                        ? item.pending / maxPending
                        : 0.0;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                              16, 12, 16, 8),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: idx == 0
                                      ? AppColors.orange
                                      : AppColors.orange
                                          .withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text('${idx + 1}',
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: idx == 0
                                              ? Colors.white
                                              : AppColors.orange)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(item.agent.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13)),
                                    const SizedBox(height: 4),
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: ratio,
                                        backgroundColor:
                                            AppColors.orangeLight,
                                        valueColor:
                                            const AlwaysStoppedAnimation(
                                                AppColors.orange),
                                        minHeight: 6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '৳${item.pending.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.orange,
                                    fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        if (idx < top5.length - 1)
                          const Divider(height: 1, indent: 50),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _NavCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
