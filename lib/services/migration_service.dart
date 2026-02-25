import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/sub_agent.dart';
import '../models/housemaid.dart';
import '../models/transaction_model.dart';

class MigrationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> migrateFiles(List<String> filePaths) async {
    for (final path in filePaths) {
      await _migrateSingleFile(path);
    }
  }

  Future<void> _migrateSingleFile(String filePath) async {
    final file = File(filePath);
    final fileName = p.basename(filePath).toLowerCase();
    final tempDir = await getTemporaryDirectory();
    
    // Copy file to temp with .hive extension so Hive recognizes it
    final migrationBoxName = 'migration_${DateTime.now().millisecondsSinceEpoch}';
    final targetPath = p.join(tempDir.path, '$migrationBoxName.hive');
    await file.copy(targetPath);

    try {
      if (fileName.contains('sub_agent')) {
        final box = await Hive.openBox<SubAgent>(migrationBoxName, path: tempDir.path);
        await _migrateSubAgents(box);
        await box.close();
      } else if (fileName.contains('housemaid')) {
        final box = await Hive.openBox<Housemaid>(migrationBoxName, path: tempDir.path);
        await _migrateHousemaids(box);
        await box.close();
      } else if (fileName.contains('transaction')) {
        final box = await Hive.openBox<TransactionModel>(migrationBoxName, path: tempDir.path);
        await _migrateTransactions(box);
        await box.close();
      }
    } finally {
      // Cleanup temp files
      if (await File(targetPath).exists()) await File(targetPath).delete();
      final lockFile = File(p.join(tempDir.path, '$migrationBoxName.lock'));
      if (await lockFile.exists()) await lockFile.delete();
    }
  }

  Future<void> _migrateSubAgents(Box<SubAgent> box) async {
    final batch = _firestore.batch();
    for (var agent in box.values) {
      final docRef = _firestore.collection('sub_agents').doc(agent.id);
      batch.set(docRef, agent.toMap());
    }
    await batch.commit();
  }

  Future<void> _migrateHousemaids(Box<Housemaid> box) async {
    final batch = _firestore.batch();
    for (var maid in box.values) {
      final docRef = _firestore.collection('housemaids').doc(maid.id);
      batch.set(docRef, maid.toMap());
    }
    await batch.commit();
  }

  Future<void> _migrateTransactions(Box<TransactionModel> box) async {
    final batch = _firestore.batch();
    for (var tx in box.values) {
      final docRef = _firestore.collection('transactions').doc(tx.id);
      batch.set(docRef, tx.toMap());
    }
    await batch.commit();
  }
}
