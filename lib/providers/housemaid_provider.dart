import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/housemaid.dart';

class HousemaidNotifier extends StateNotifier<List<Housemaid>> {
  HousemaidNotifier() : super([]) {
    _loadFromHive();
  }

  static const String _boxName = 'housemaids';

  Box<Housemaid> get _box => Hive.box<Housemaid>(_boxName);

  void _loadFromHive() {
    state = _box.values.toList();
  }

  Future<void> addHousemaid(Housemaid maid) async {
    await _box.put(maid.id, maid);
    _loadFromHive();
  }

  Future<void> updateHousemaid(Housemaid maid) async {
    await _box.put(maid.id, maid);
    _loadFromHive();
  }

  Future<void> deleteHousemaid(String id) async {
    await _box.delete(id);
    _loadFromHive();
  }

  List<Housemaid> getBySubAgent(String subAgentId) =>
      _box.values.where((m) => m.subAgentId == subAgentId).toList();

  Housemaid? getById(String id) => _box.get(id);
}

final housemaidProvider =
    StateNotifierProvider<HousemaidNotifier, List<Housemaid>>(
  (ref) => HousemaidNotifier(),
);
