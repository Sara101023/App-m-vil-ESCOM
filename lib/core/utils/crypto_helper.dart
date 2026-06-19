// Encripta contraseñas con SHA-256.
// NUNCA guardamos contraseñas en texto plano.
import 'dart:convert';
import 'package:crypto/crypto.dart';

class CryptoHelper {
  CryptoHelper._();

  /// Convierte un string a su hash SHA-256 en hexadecimal.
  /// Ejemplo: "admin123" → "240be518..."
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verifica si una contraseña coincide con su hash guardado.
  static bool verifyPassword(String password, String hash) {
    return hashPassword(password) == hash;
  }
}