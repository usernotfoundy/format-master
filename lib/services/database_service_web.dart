// Web-specific implementation
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

Future<void> initializePlatformDatabase() async {
  // Not used on web
}

Future<String> getDatabasePath() async {
  return '';
}

Future<void> initializeWebDatabase() async {
  // Initialize the web database factory without web worker (simpler setup)
  databaseFactory = databaseFactoryFfiWebNoWebWorker;
}

