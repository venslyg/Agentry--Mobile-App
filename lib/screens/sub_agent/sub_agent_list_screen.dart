import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/sub_agent_provider.dart';
import '../../providers/housemaid_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/sub_agent.dart';
import '../../services/pdf_report_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import 'add_sub_agent_screen.dart';
import '../housemaid/housemaid_list_screen.dart';

class SubAgentListScreen extends ConsumerWidget {
  const SubAgentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final agents = ref.watch(subAgentProvider);
    final maids = ref.watch(housemaidProvider);
    final transactions = ref.watch(transactionProvider);
    final symbol = ref.watch(currencySymbolProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.tr('subAgents'))),
      body: agents.isEmpty
          ? _emptyState(Icons.people_alt_outlined, l.tr('noSubAgents'))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: agents.length,
              itemBuilder: (ctx, i) {
                final agent = agents[i];
                final agentMaids =
                    maids.where((m) => m.subAgentId == agent.id).toList();
                final agentPaid =
                    agentMaids.fold<double>(0, (sum, maid) {
                  return sum +
                      transactions
                          .where((t) => t.maidId == maid.id)
                          .fold<double>(0, (s, t) => s + t.amount);
                });
                final agentPending =
                    agentMaids.fold<double>(0, (sum, maid) {
                  final paid = transactions
                      .where((t) => t.maidId == maid.id)
                      .fold<double>(0, (s, t) => s + t.amount);
                  final rem = maid.totalCommission - paid;
                  return sum + (rem > 0 ? rem : 0);
                });

                return _AgentCard(
                  agent: agent,
                  maidCount: agentMaids.length,
                  totalPaid: agentPaid,
                  totalPending: agentPending,
                  symbol: symbol,
                  onTap: () => Navigator.push(ctx,
                      MaterialPageRoute(
                          builder: (_) => HousemaidListScreen(
                              subAgentId: agent.id,
                              subAgentName: agent.name))),
                  onEdit: () => Navigator.push(ctx,
                      MaterialPageRoute(
                          builder: (_) =>
                              AddSubAgentScreen(existing: agent))),
                  onExport: () async {
                    final agentTxs = transactions
                        .where((t) => agentMaids
                            .any((m) => m.id == t.maidId))
                        .toList();
                    await PdfReportService.generateAgentReport(
                      agent: agent,
                      maids: agentMaids,
                      allTransactions: agentTxs,
                      symbol: symbol,
                    );
                  },
                  onDelete: () async {
                    final ok = await showDialog<bool>(
                      context: ctx,
                      builder: (c) => AlertDialog(
                        title: Text(l.tr('deleteSubAgent')),
                        content: Text(
                            '${agent.name}? ${l.tr('deleteSubAgentMsg')}'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(c, false),
                              child: Text(l.tr('cancel'))),
                          TextButton(
                              onPressed: () => Navigator.pop(c, true),
                              child: Text(l.tr('delete'),
                                  style: const TextStyle(
                                      color: Colors.red))),
                        ],
                      ),
                    );
                    if (ok == true) {
                      await ref
                          .read(subAgentProvider.notifier)
                          .deleteSubAgent(agent.id);
                    }
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(
                builder: (_) => const AddSubAgentScreen())),
        icon: const Icon(Icons.add),
        label: Text(l.tr('addSubAgent')),
      ),
    );
  }

  Widget _emptyState(IconData icon, String msg) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 72, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text(msg,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.grey[500], fontSize: 15, height: 1.6)),
      ]),
    );
  }
}

class _AgentCard extends StatelessWidget {
  final SubAgent agent;
  final int maidCount;
  final double totalPaid;
  final double totalPending;
  final String symbol;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onExport;

  const _AgentCard({
    required this.agent,
    required this.maidCount,
    required this.totalPaid,
    required this.totalPending,
    required this.symbol,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                CircleAvatar(
                  backgroundColor:
                      AppColors.primary.withValues(alpha: 0.15),
                  child: Text(
                    agent.name.isNotEmpty
                        ? agent.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(agent.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      if (agent.contact.isNotEmpty)
                        Text(agent.contact,
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13)),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                    if (v == 'delete') onDelete();
                    if (v == 'export') onExport();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'export',
                      child: Row(children: [
                        Icon(Icons.picture_as_pdf,
                            size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Export PDF'),
                      ]),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        Icon(Icons.edit, size: 18, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ]),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ]),
                    ),
                  ],
                ),
              ]),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(children: [
                _Stat(
                    label: 'Maids',
                    value: '$maidCount',
                    color: AppColors.atAgency),
                const SizedBox(width: 16),
                _Stat(
                    label: 'Paid',
                    value: '$symbol${totalPaid.toStringAsFixed(0)}',
                    color: AppColors.green),
                const SizedBox(width: 16),
                _Stat(
                    label: 'Pending',
                    value: '$symbol${totalPending.toStringAsFixed(0)}',
                    color: AppColors.orange),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _Stat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary)),
        Text(value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color)),
      ],
    );
  }
}
