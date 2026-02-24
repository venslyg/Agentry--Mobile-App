import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/foreign_agent.dart';

class ForeignAgentNotifier extends StateNotifier<List<ForeignAgent>> {
  ForeignAgentNotifier() : super([]) {
    _listenToFirestore();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _listenToFirestore() {
    _firestore.collection('foreign_agents').snapshots().listen((snapshot) {
      state = snapshot.docs.map((doc) => ForeignAgent.fromMap(doc.data())).toList();
    });
  }

  Future<void> addForeignAgent(ForeignAgent agent) async {
    await _firestore.collection('foreign_agents').doc(agent.id).set(agent.toMap());
  }

  Future<void> updateForeignAgent(ForeignAgent agent) async {
    await _firestore.collection('foreign_agents').doc(agent.id).update(agent.toMap());
  }

  Future<void> deleteForeignAgent(String id) async {
    await _firestore.collection('foreign_agents').doc(id).delete();
  }
}

final foreignAgentProvider = StateNotifierProvider<ForeignAgentNotifier, List<ForeignAgent>>((ref) {
  return ForeignAgentNotifier();
});
