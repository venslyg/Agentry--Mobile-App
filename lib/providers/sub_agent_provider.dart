import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/sub_agent.dart';

class SubAgentNotifier extends StateNotifier<List<SubAgent>> {
  SubAgentNotifier() : super([]) {
    _loadFromHive();
  }

  static const String _boxName = 'sub_agents';

  Box<SubAgent> get _box => Hive.box<SubAgent>(_boxName);

  void _loadFromHive() {
    state = _box.values.toList();
  }

  Future<void> addSubAgent(SubAgent agent) async {
    await _box.put(agent.id, agent);
    _loadFromHive();
  }

  Future<void> updateSubAgent(SubAgent agent) async {
    await _box.put(agent.id, agent);
    _loadFromHive();
  }

  Future<void> deleteSubAgent(String id) async {
    await _box.delete(id);
    _loadFromHive();
  }

  SubAgent? getById(String id) => _box.get(id);
}

final subAgentProvider =
    StateNotifierProvider<SubAgentNotifier, List<SubAgent>>(
  (ref) => SubAgentNotifier(),
);
