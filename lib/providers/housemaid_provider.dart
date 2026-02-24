import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/housemaid.dart';

class HousemaidNotifier extends StateNotifier<List<Housemaid>> {
  HousemaidNotifier() : super([]) {
    _listenToFirestore();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _listenToFirestore() {
    _firestore.collection('housemaids').snapshots().listen((snapshot) {
      state = snapshot.docs.map((doc) => Housemaid.fromMap(doc.data())).toList();
    });
  }

  Future<void> addHousemaid(Housemaid maid) async {
    await _firestore.collection('housemaids').doc(maid.id).set(maid.toMap());
  }

  Future<void> updateHousemaid(Housemaid maid) async {
    await _firestore.collection('housemaids').doc(maid.id).update(maid.toMap());
  }

  Future<void> deleteHousemaid(String id) async {
    await _firestore.collection('housemaids').doc(id).delete();
  }

  List<Housemaid> getBySubAgent(String subAgentId) =>
      state.where((m) => m.subAgentId == subAgentId).toList();

  Housemaid? getById(String id) =>
      state.firstWhere((m) => m.id == id, orElse: () => Housemaid(id: '', name: '', passportId: '', subAgentId: '', totalCommission: 0));
}

final housemaidProvider =
    StateNotifierProvider<HousemaidNotifier, List<Housemaid>>(
  (ref) => HousemaidNotifier(),
);
