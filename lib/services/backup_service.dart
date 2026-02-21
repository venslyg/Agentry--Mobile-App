import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class BackupService {
  static Future<void> performBackup() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final files = docsDir.listSync();
    
    final List<XFile> backupFiles = [];
    
    for (var file in files) {
      if (file is File && (file.path.endsWith('.hive') || file.path.endsWith('.lock'))) {
        backupFiles.add(XFile(file.path));
      }
    }

    if (backupFiles.isEmpty) {
      throw Exception('No data files found to backup.');
    }

    await Share.shareXFiles(
      backupFiles,
      text: 'Agentry App Data Backup - ${DateTime.now().toLocal()}',
      subject: 'Agentry Backup',
    );
  }
}
