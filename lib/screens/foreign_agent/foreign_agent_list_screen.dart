import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/foreign_agent_provider.dart';
import '../../providers/housemaid_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import 'add_foreign_agent_screen.dart';

class ForeignAgentListScreen extends ConsumerWidget {
  const ForeignAgentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agents = ref.watch(foreignAgentProvider);
    final maids = ref.watch(housemaidProvider);
    final transactions = ref.watch(transactionProvider);
    final symbol = ref.watch(currencySymbolProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Foreign Agents')),
      body: agents.isEmpty
          ? _emptyState(Icons.public_outlined, 'No Foreign Agents registered')
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: agents.length,
              itemBuilder: (ctx, i) {
                final agent = agents[i];
                final agentMaids = maids.where((m) => m.foreignAgentId == agent.id).toList();
                
                double totalReceived = 0;
                for (final maid in agentMaids) {
                  totalReceived += transactions
                      .where((t) => t.maidId == maid.id)
                      .fold<double>(0, (sum, t) => sum + t.amount);
                }

                return _ForeignAgentCard(
                  agent: agent,
                  maidCount: agentMaids.length,
                  totalReceived: totalReceived,
                  symbol: symbol,
                  onEdit: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => AddForeignAgentScreen(existing: agent))),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddForeignAgentScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Add Foreign Agent'),
      ),
    );
  }

  Widget _emptyState(IconData icon, String msg) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 72, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text(msg, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500], fontSize: 15)),
      ]),
    );
  }
}

class _ForeignAgentCard extends StatelessWidget {
  final agent;
  final int maidCount;
  final double totalReceived;
  final String symbol;
  final VoidCallback onEdit;

  const _ForeignAgentCard({
    required this.agent,
    required this.maidCount,
    required this.totalReceived,
    required this.symbol,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.15),
                child: const Icon(Icons.public, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(agent.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(agent.country, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: onEdit),
            ]),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(children: [
              _Stat(label: 'Maids Sent', value: '$maidCount', color: AppColors.atAgency),
              const SizedBox(width: 24),
              _Stat(label: 'Total Received', value: '$symbol${totalReceived.toStringAsFixed(0)}', color: AppColors.green),
            ]),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Stat({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
    ]);
  }
}
