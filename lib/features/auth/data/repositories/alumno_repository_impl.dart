import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/alumno_model.dart';
import '../../domain/entities/alumno_entity.dart';

class AlumnoRepositoryImpl {
  static SupabaseClient get _client => Supabase.instance.client;

  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<AlumnoEntity?> login(String boleta, String password) async {
    try {
      final hash = _hashPassword(password);
      final response = await _client
          .from('alumnos')
          .select()
          .eq('boleta', boleta)
          .eq('password_hash', hash)
          .maybeSingle();

      if (response == null) return null;

      final alumno = AlumnoModel.fromSupabase(response);

      // Guardar token FCM
      await _guardarTokenFcm(alumno.id);

      return alumno;
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  Future<void> _guardarTokenFcm(String alumnoId) async {
    try {
      final messaging = FirebaseMessaging.instance;

      // Solicitar permisos
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      final token = await messaging.getToken();
      debugPrint('FCM TOKEN: $token');

      if (token != null) {
        await _client
            .from('alumnos')
            .update({'fcm_token': token}).eq('id', alumnoId);
      }
    } catch (e) {
      debugPrint('Error guardando token FCM: $e');
    }
  }
}