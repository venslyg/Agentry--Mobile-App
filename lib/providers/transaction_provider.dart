import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';
import '../models/housemaid.dart';
import 'notification_service.dart';

class TransactionNotifier extends StateNotifier<List<TransactionModel>> {
  TransactionNotifier() : super([]) {
    _loadFromHive();
  }

  static const String _boxName = 'transactions';

  Box<TransactionModel> get _box => Hive.box<TransactionModel>(_boxName);

  void _loadFromHive() {
    state = _box.values.toList();
  }

  Future<bool> addTransaction({
    required TransactionModel transaction,
    required Housemaid maid,
  }) async {
    final maidTxs = getByMaid(transaction.maidId);
    final totalPaid = maidTxs.fold<double>(0, (s, t) => s + t.amount);
    final remaining = maid.totalCommission - totalPaid;

    if (transaction.amount > remaining + 0.001) return false;

    await _box.put(transaction.id, transaction);
    _loadFromHive();

    final newTotalPaid = totalPaid + transaction.amount;
    final isFullyPaid = (maid.totalCommission - newTotalPaid).abs() < 0.001;

    if (isFullyPaid) {
      await NotificationService.showNotification(
        id: maid.id.hashCode,
        title: 'Fully Paid',
        body: "'s commission is fully paid off!",
      );
    }

    return true;
  }

  Future<void> deleteTransaction(String id) async {
    await _box.delete(id);
    _loadFromHive();
  }

  List<TransactionModel> getByMaid(String maidId) {
    return _box.values
        .where((t) => t.maidId == maidId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  double getTotalPaidForMaid(String maidId) =>
      getByMaid(maidId).fold<double>(0, (s, t) => s + t.amount);
}

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, List<TransactionModel>>(
  (ref) => TransactionNotifier(),
);
