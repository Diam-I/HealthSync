import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class EncryptionService {
  static const String _keyName = 'aes_key';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final LocalAuthentication _auth = LocalAuthentication();

  Future<Uint8List> generateAESKey() async {
    // Check if the key already exists in secure storage //
    String? key64 = await _storage.read(key: _keyName);

    if (key64 != null) {
      try {
        final keyBytes = base64Decode(key64);
        if (keyBytes.length == 32) {
          return Uint8List.fromList(keyBytes);
        }
      } catch (_) {}
    }

    final newKey = encrypt.Key.fromSecureRandom(32);
    await _storage.write(key: _keyName, value: newKey.base64);
    return newKey.bytes;
  }

  Future<encrypt.Key> _getKey() async {
    // Retrieve the AES key from secure storage or generate a new one if it doesn't exist //
    final keyBytes = await generateAESKey();
    return encrypt.Key(keyBytes);
  }

  Future<bool> authenticate() async {
    // Check if the device supports biometric authentication and if the user has enrolled biometrics //
    try {
      final canAuthenticate =
          await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
      if (!canAuthenticate) return false;

      return await _auth.authenticate(
        localizedReason: 'Accès sécurisé aux données médicales',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  Future<String> encryptData(String plainText) async {
    // Check if the input text is empty //
    if (plainText.trim().isEmpty) {
      throw Exception('Le texte à chiffrer est vide.');
    }

    try {
      final key = await _getKey();
      final iv = encrypt.IV.fromSecureRandom(16);
      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc),
      );

      final encrypted = encrypter.encrypt(plainText, iv: iv);
      return '${iv.base64}:${encrypted.base64}';
    } catch (e) {
      throw Exception('Impossible de chiffrer les données : $e');
    }
  }

  Future<String> decryptData(String encryptedText) async {
    // added check for empty encrypted text //
    if (encryptedText.trim().isEmpty) {
      throw Exception('Le texte chiffré est vide.');
    }

    try {
      final parts = encryptedText.split(':');
      if (parts.length != 2) throw Exception('Format invalide.');

      final iv = encrypt.IV.fromBase64(parts[0]);
      final encrypted = encrypt.Encrypted.fromBase64(parts[1]);
      final key = await _getKey();
      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc),
      );

      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      throw Exception('Impossible de déchiffrer les données : $e');
    }
  }
}
