// Platform-specific implementation for desktop/mobile
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';

Future<void> initializePlatformDatabase() async {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}

Future<String> getDatabasePath() async {
  final documentsDirectory = await getApplicationDocumentsDirectory();
  return documentsDirectory.path;
}

