import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../models/housemaid.dart';
import '../../models/maid_status.dart';
import '../../models/transaction_model.dart';
import '../../providers/housemaid_provider.dart';
import '../../providers/sub_agent_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/pdf_report_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/transaction_tile.dart';
import 'add_housemaid_screen.dart';

class MaidDetailScreen extends ConsumerWidget {
  final String maidId;
  const MaidDetailScreen({super.key, required this.maidId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final maids = ref.watch(housemaidProvider);
    final agents = ref.watch(subAgentProvider);
    final transactions = ref.watch(transactionProvider);
    final symbol = ref.watch(currencySymbolProvider);

    final maid = maids.firstWhere(
      (m) => m.id == maidId,
      orElse: () => Housemaid(
          id: '', name: 'Unknown', passportId: '', subAgentId: '',
          totalCommission: 0),
    );
    if (maid.id.isEmpty) return const Scaffold(body: Center(child: Text('Not found')));

    final agent = agents.firstWhere(
      (a) => a.id == maid.subAgentId,
      orElse: () => throw Exception('Agent not found'),
    );

    final maidTransactions = transactions
        .where((t) => t.maidId == maidId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final totalPaid =
        maidTransactions.fold<double>(0, (s, t) => s + t.amount);
    final remaining =
        (maid.totalCommission - totalPaid).clamp(0.0, double.infinity).toDouble();
    final isFullyPaid = remaining <= 0.001;
    final isSentAbroad = maid.status == MaidStatus.sentAbroad;
    final isDisabled = maid.status == MaidStatus.completed || isFullyPaid;

    Color statusColor;
    switch (maid.status) {
      case MaidStatus.atAgency:
        statusColor = AppColors.atAgency;
        break;
      case MaidStatus.sentAbroad:
        statusColor = AppColors.sentAbroad;
        break;
      case MaidStatus.completed:
        statusColor = AppColors.completed;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(maid.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => AddHousemaidScreen(existing: maid)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: l.tr('exportReport'),
            onPressed: () async {
              await PdfReportService.generateMaidReport(
                maid: maid,
                agent: agent,
                transactions: maidTransactions,
                symbol: symbol,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────────────
            Container(
              width: double.infinity,
              color: AppColors.primary,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor:
                            Colors.white.withValues(alpha: 0.2),
                        child: Text(
                          maid.name.isNotEmpty
                              ? maid.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(maid.name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            Text('Passport: ${maid.passportId}',
                                style: TextStyle(
                                    color: Colors.white
                                        .withValues(alpha: 0.8),
                                    fontSize: 13)),
                            Text('Agent: ${agent.name}',
                                style: TextStyle(
                                    color: Colors.white
                                        .withValues(alpha: 0.8),
                                    fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: statusColor.withValues(alpha: 0.5)),
                      ),
                      child: Text(maid.status.label,
                          style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ),
                    if (isFullyPaid) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.green.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.green
                                  .withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle,
                                color: AppColors.greenLight, size: 13),
                            const SizedBox(width: 4),
                            Text(l.tr('fullyPaid'),
                                style: const TextStyle(
                                    color: AppColors.greenLight,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ]),
                ],
              ),
            ),

            // ── Financial Summary ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _FinCard(
                      label: l.tr('commission'),
                      value: '$symbol${maid.totalCommission.toStringAsFixed(0)}',
                      color: AppColors.primary),
                  const SizedBox(width: 10),
                  _FinCard(
                      label: l.tr('totalPaid'),
                      value: '$symbol${totalPaid.toStringAsFixed(0)}',
                      color: AppColors.green),
                  const SizedBox(width: 10),
                  _FinCard(
                      label: l.tr('remaining'),
                      value: '$symbol${remaining.toStringAsFixed(0)}',
                      color: isFullyPaid ? AppColors.green : AppColors.orange),
                ],
              ),
            ),

            // ── Log Payment Button ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: (isSentAbroad || isDisabled)
                    ? null
                    : () => _showPaymentDialog(
                        context, ref, l, maid, remaining),
                icon: const Icon(Icons.add_card),
                label: Text(isFullyPaid
                    ? l.tr('fullyPaid')
                    : l.tr('logPayment')),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor:
                      isFullyPaid ? AppColors.green : AppColors.primary,
                  disabledBackgroundColor: Colors.grey[200],
                ),
              ),
            ),
            if (isSentAbroad && !isFullyPaid)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.orange[600], size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Payments disabled when status is "Sent Abroad"',
                      style: TextStyle(
                          color: Colors.orange[600], fontSize: 12),
                    ),
                  ],
                ),
              ),

            // ── Transaction History ─────────────────────────────────────
            const SizedBox(height: 16),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(l.tr('transactions'),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
            ),
            if (maidTransactions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 24),
                child: Center(
                  child: Text(l.tr('noTransactions'),
                      style: TextStyle(
                          color: Colors.grey[400], fontSize: 14)),
                ),
              )
            else
              ...maidTransactions.map((t) => TransactionTile(
                    transaction: t,
                    onDelete: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: Text(l.tr('deleteTransaction')),
                          content: Text(
                              'Remove $symbol${t.amount.toStringAsFixed(0)} payment?'),
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
                            .read(transactionProvider.notifier)
                            .deleteTransaction(t.id);
                      }
                    },
                  )),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, WidgetRef ref,
      AppLocalizations l, Housemaid maid, double remaining) {
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          const Icon(Icons.add_card, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(l.tr('logPayment')),
        ]),
        content: Consumer(builder: (context, ref, _) {
          final symbol = ref.watch(currencySymbolProvider);
          return Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Remaining balance hint
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.orangeLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${l.tr('remaining')}: $symbol${remaining.toStringAsFixed(0)}',
                    style: const TextStyle(
                        color: AppColors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: amountCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: l.tr('amount'),
                    prefixText: symbol,
                    prefixStyle: const TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return l.tr('amountRequired');
                    }
                    final amt = double.tryParse(v.trim());
                    if (amt == null || amt <= 0) {
                      return l.tr('validAmount');
                    }
                    // Hard validation: block if exceeds remaining
                    if (amt > remaining + 0.001) {
                      return '${l.tr('exceedsBalance')} (max $symbol${remaining.toStringAsFixed(0)})';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: noteCtrl,
                  decoration: InputDecoration(
                    labelText: l.tr('note'),
                    prefixIcon: const Icon(Icons.note_outlined,
                        color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 12),
                StatefulBuilder(builder: (context, setDialogState) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today_outlined, color: AppColors.primary),
                    title: Text(DateFormat('dd MMMM yyyy').format(selectedDate)),
                    subtitle: const Text('Transaction Date', style: TextStyle(fontSize: 11)),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setDialogState(() => selectedDate = picked);
                      }
                    },
                  );
                }),
              ],
            ),
          );
        }),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final amt =
                  double.tryParse(amountCtrl.text.trim()) ?? 0;
              final tx = TransactionModel(
                id: const Uuid().v4(),
                maidId: maid.id,
                amount: amt,
                date: selectedDate,
                note: noteCtrl.text.trim(),
              );
              final ok = await ref
                  .read(transactionProvider.notifier)
                  .addTransaction(
                    transaction: tx,
                    maid: maid,
                  );
              if (!ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l.tr('exceedsBalance')),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              if (ctx.mounted) {
                await showDialog(
                  context: ctx,
                  builder: (c) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    title: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 10),
                        Text(l.tr('appName')),
                      ],
                    ),
                    content: const Text('Payment recorded successfully!'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(c),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: Text(l.tr('save')),
          ),
        ],
      ),
    );
  }
}

class _FinCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _FinCard(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: color),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
