import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/housemaid_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../models/housemaid.dart';
import '../../widgets/maid_list_tile.dart';
import '../../l10n/app_localizations.dart';
import 'add_housemaid_screen.dart';
import 'maid_detail_screen.dart';

class HousemaidListScreen extends ConsumerWidget {
  final String? subAgentId;
  final String? subAgentName;

  const HousemaidListScreen({
    super.key,
    this.subAgentId,
    this.subAgentName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final allMaids = ref.watch(housemaidProvider);
    final transactions = ref.watch(transactionProvider);

    final maids = subAgentId != null
        ? allMaids.where((m) => m.subAgentId == subAgentId).toList()
        : allMaids;

    double remaining(Housemaid m) {
      final paid = transactions
          .where((t) => t.maidId == m.id)
          .fold<double>(0, (s, t) => s + t.amount);
      return (m.totalCommission - paid).clamp(0.0, double.infinity).toDouble();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(subAgentName != null
            ? '$subAgentName\'s ${l.tr('maids')}'
            : l.tr('housemaids')),
      ),
      body: maids.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_search_outlined,
                      size: 72, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(l.tr('noHousemaids'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 15,
                          height: 1.6)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: maids.length,
              itemBuilder: (ctx, idx) {
                final maid = maids[idx];
                return MaidListTile(
                  maid: maid,
                  remaining: remaining(maid),
                  onTap: () => Navigator.push(ctx,
                      MaterialPageRoute(
                          builder: (_) =>
                              MaidDetailScreen(maidId: maid.id))),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(
                builder: (_) => AddHousemaidScreen(
                    preselectedSubAgentId: subAgentId))),
        icon: const Icon(Icons.add),
        label: Text(l.tr('addMaid')),
      ),
    );
  }
}
