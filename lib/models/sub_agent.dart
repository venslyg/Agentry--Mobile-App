import 'package:hive/hive.dart';

part 'sub_agent.g.dart';

@HiveType(typeId: 0)
class SubAgent extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String contact;

  @HiveField(3)
  String notes;

  SubAgent({
    required this.id,
    required this.name,
    required this.contact,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'notes': notes,
    };
  }

  factory SubAgent.fromMap(Map<String, dynamic> map) {
    return SubAgent(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      contact: map['contact'] ?? '',
      notes: map['notes'] ?? '',
    );
  }
}
