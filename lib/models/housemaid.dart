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

  @HiveField(4)
  double totalCommission;

  @HiveField(5)
  MaidStatus status;

  Housemaid({
    required this.id,
    required this.name,
    required this.passportId,
    required this.subAgentId,
    required this.totalCommission,
    this.status = MaidStatus.atAgency,
  });
}
