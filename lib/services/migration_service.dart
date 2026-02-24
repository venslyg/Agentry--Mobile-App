import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/sub_agent.dart';
import '../models/housemaid.dart';
import '../models/transaction_model.dart';

class MigrationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> migrateData() async {
    await _migrateSubAgents();
    await _migrateHousemaids();
    await _migrateTransactions();
  }

  Future<void> _migrateSubAgents() async {
    final box = Hive.box<SubAgent>('sub_agents');
    final batch = _firestore.batch();
    
    for (var agent in box.values) {
      final docRef = _firestore.collection('sub_agents').doc(agent.id);
      batch.set(docRef, {
        'id': agent.id,
        'name': agent.name,
        'contact': agent.contact,
        'notes': agent.notes,
      });
    }
    await batch.commit();
  }

  Future<void> _migrateHousemaids() async {
    final box = Hive.box<Housemaid>('housemaids');
    final batch = _firestore.batch();
    
    for (var maid in box.values) {
      final docRef = _firestore.collection('housemaids').doc(maid.id);
      batch.set(docRef, {
        'id': maid.id,
        'name': maid.name,
        'passportId': maid.passportId,
        'subAgentId': maid.subAgentId,
        'totalCommission': maid.totalCommission,
        'status': maid.status.index, // Storing index for enum
        'country': maid.country,
      });
    }
    await batch.commit();
  }

  Future<void> _migrateTransactions() async {
    final box = Hive.box<TransactionModel>('transactions');
    final batch = _firestore.batch();
    
    for (var tx in box.values) {
      final docRef = _firestore.collection('transactions').doc(tx.id);
      batch.set(docRef, {
        'id': tx.id,
        'maidId': tx.maidId,
        'amount': tx.amount,
        'date': Timestamp.fromDate(tx.date),
        'note': tx.note,
      });
    }
    await batch.commit();
  }
}
