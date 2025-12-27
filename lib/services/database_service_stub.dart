// Stub file - these functions are overridden by platform-specific implementations

Future<void> initializePlatformDatabase() async {
  // Not used - overridden by platform implementation
}

Future<String> getDatabasePath() async {
  return '';
}

Future<void> initializeWebDatabase() async {
  // Not used - overridden by web implementation
}
