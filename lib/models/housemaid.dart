import 'package:hive/hive.dart';
import 'maid_status.dart';

part 'housemaid.g.dart';

@HiveType(typeId: 1)
class Housemaid extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String passportId;

  @HiveField(3)
  String subAgentId;

  @HiveField(7)
  String? foreignAgentId;

  @HiveField(4)
  double totalCommission;

  @HiveField(5)
  MaidStatus status;

  @HiveField(6)
  String? country;

  Housemaid({
    required this.id,
    required this.name,
    required this.passportId,
    required this.subAgentId,
    required this.totalCommission,
    this.status = MaidStatus.atAgency,
    this.country,
    this.foreignAgentId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'passportId': passportId,
      'subAgentId': subAgentId,
      'foreignAgentId': foreignAgentId,
      'totalCommission': totalCommission,
      'status': status.index,
      'country': country,
    };
  }

  factory Housemaid.fromMap(Map<String, dynamic> map) {
    return Housemaid(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      passportId: map['passportId'] ?? '',
      subAgentId: map['subAgentId'] ?? '',
      foreignAgentId: map['foreignAgentId'],
      totalCommission: (map['totalCommission'] ?? 0).toDouble(),
      status: MaidStatus.values[(map['status'] ?? 0)],
      country: map['country'],
    );
  }
}
