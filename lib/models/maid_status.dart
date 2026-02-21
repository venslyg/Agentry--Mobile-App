import 'package:hive/hive.dart';

part 'maid_status.g.dart';

@HiveType(typeId: 3)
enum MaidStatus {
  @HiveField(0)
  atAgency,

  @HiveField(1)
  sentAbroad,

  @HiveField(2)
  completed,
}

extension MaidStatusExtension on MaidStatus {
  String get label {
    switch (this) {
      case MaidStatus.atAgency:
        return 'At Agency';
      case MaidStatus.sentAbroad:
        return 'Sent Abroad';
      case MaidStatus.completed:
        return 'Completed';
    }
  }
}
