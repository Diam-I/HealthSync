import 'package:hive_flutter/hive_flutter.dart';
import 'dart:typed_data';

class HiveStorageServices<T> {
  final String boxName;
  late Box<T> _box;
  HiveStorageServices(this.boxName);

  Future<void> init(Uint8List encryptionKey) async {
    // Initialize the Hive box with encryption //
    _box = await Hive.openBox<T>(
      boxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  }

  Future<void> saveData(String key, T value) async {
    // Save data to the Hive box //
    await _box.put(key, value);
  }

  T? getData(dynamic key) {
    // Retrieve data from the Hive box //
    return _box.get(key);
  }
  Future<void> deleteData(dynamic key) async {
    // Delete data from the Hive box //
    await _box.delete(key);
  }

  Future<void> clearBox() async {
    // Clear all data from the Hive box //
    await _box.clear();
  }

  Future<void> closeBox() async {
    // Close the Hive box //
    await _box.close();
  }

}
