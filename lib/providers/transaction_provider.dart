import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction_model.dart';
import '../models/housemaid.dart';
import 'notification_service.dart';

class TransactionNotifier extends StateNotifier<List<TransactionModel>> {
  TransactionNotifier() : super([]) {
    _listenToFirestore();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _listenToFirestore() {
    _firestore.collection('transactions').snapshots().listen((snapshot) {
      state = snapshot.docs.map((doc) => TransactionModel.fromMap(doc.data())).toList();
    });
  }

  Future<bool> addTransaction({
    required TransactionModel transaction,
    required Housemaid maid,
  }) async {
    final maidTxs = getByMaid(transaction.maidId);
    final totalPaid = maidTxs.fold<double>(0, (s, t) => s + t.amount);
    final remaining = maid.totalCommission - totalPaid;

    if (transaction.amount > remaining + 0.001) return false;

    await _firestore.collection('transactions').doc(transaction.id).set(transaction.toMap());

    final newTotalPaid = totalPaid + transaction.amount;
    final isFullyPaid = (maid.totalCommission - newTotalPaid).abs() < 0.001;

    if (isFullyPaid) {
      await NotificationService.showNotification(
        id: maid.id.hashCode,
        title: 'Fully Paid',
        body: "${maid.name}'s commission is fully paid off!",
      );
    }

    return true;
  }

  Future<void> deleteTransaction(String id) async {
    await _firestore.collection('transactions').doc(id).delete();
  }

  List<TransactionModel> getByMaid(String maidId) {
    return state
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
