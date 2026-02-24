import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sub_agent.dart';

class SubAgentNotifier extends StateNotifier<List<SubAgent>> {
  SubAgentNotifier() : super([]) {
    _listenToFirestore();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _listenToFirestore() {
    _firestore.collection('sub_agents').snapshots().listen((snapshot) {
      state = snapshot.docs.map((doc) => SubAgent.fromMap(doc.data())).toList();
    });
  }

  Future<void> addSubAgent(SubAgent agent) async {
    await _firestore.collection('sub_agents').doc(agent.id).set(agent.toMap());
  }

  Future<void> updateSubAgent(SubAgent agent) async {
    await _firestore.collection('sub_agents').doc(agent.id).update(agent.toMap());
  }

  Future<void> deleteSubAgent(String id) async {
    await _firestore.collection('sub_agents').doc(id).delete();
  }

  SubAgent? getById(String id) =>
      state.firstWhere((a) => a.id == id, orElse: () => SubAgent(id: '', name: '', contact: ''));
}

final subAgentProvider =
    StateNotifierProvider<SubAgentNotifier, List<SubAgent>>(
  (ref) => SubAgentNotifier(),
);
