import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:healthsync/core/security/encryption_service.dart';
import 'package:healthsync/core/storage/hive_storage_services.dart';
import 'package:healthsync/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Hive //
  await Hive.initFlutter();
  // Initialize encryption service  //
  final encryption = EncryptionService();
  // Generate or retrieve the AES key //
  final key = await encryption.generateAESKey();
  // Initialize Hive storage with the encryption key //
  final healthStorage = HiveStorageServices<String>('health_data');
  await healthStorage.init(key);
  runApp(const MyApp());
}
