import 'dart:typed_data';
import 'package:hive/hive.dart';

class HiveStorageServices<T> {
  final String boxName;
  Box<T>? _box;

  HiveStorageServices(this.boxName);

  Future<void> init(Uint8List cipherKey) async {
    _box = await Hive.openBox<T>(
      boxName,
      encryptionCipher: HiveAesCipher(cipherKey),
    );
  }

  bool get isOpen => _box != null && _box!.isOpen;

  Box<T> get _safeBox {
    if (_box == null || !_box!.isOpen) {
      throw Exception('Storage is not initialized or is closed');
    }
    return _box!;
  }

  Future<void> saveData(String key, T data) async {
    await _safeBox.put(key, data);
  }

  Future<T?> getData(String key) async {
    return _safeBox.get(key);
  }

  Future<List<T>> getAllData() async {
    return _safeBox.values.toList();
  }

  Future<void> deleteData(String key) async {
    await _safeBox.delete(key);
  }

  Future<void> clearBox() async {
    await _safeBox.clear();
  }

  Future<void> closeBox() async {
    if (isOpen) {
      await _safeBox.close();
    }
  }
}
