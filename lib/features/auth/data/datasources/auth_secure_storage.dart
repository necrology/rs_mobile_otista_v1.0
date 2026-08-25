import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/network/api_session.dart';
import '../../domain/entities/patient_identity.dart';

class AuthSecureStorage implements ApiSessionStore {
  AuthSecureStorage({
    FlutterSecureStorage secureStorage = const FlutterSecureStorage(),
  }) : _secureStorage = secureStorage;

  static const String _identityKey = 'auth_identity';
  static const String _tokenPairKey = 'auth_token_pair_v1';

  final FlutterSecureStorage _secureStorage;

  Future<PatientIdentity?> readIdentity() async {
    final String? rawIdentity;
    try {
      rawIdentity = await _secureStorage.read(key: _identityKey);
    } on MissingPluginException {
      return null;
    }

    if (rawIdentity == null || rawIdentity.isEmpty) {
      return null;
    }

    try {
      final Object? decoded = jsonDecode(rawIdentity);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return PatientIdentity.fromJson(decoded);
    } catch (_) {
      await clearIdentity();
      return null;
    }
  }

  @override
  Future<SessionTokenPair?> readTokenPair() async {
    final String? rawTokenPair;
    try {
      rawTokenPair = await _secureStorage.read(key: _tokenPairKey);
    } on MissingPluginException {
      return null;
    }

    if (rawTokenPair == null || rawTokenPair.isEmpty) {
      return null;
    }

    try {
      final Object? decoded = jsonDecode(rawTokenPair);
      if (decoded is! Map<String, dynamic>) {
        await clearSession();
        return null;
      }
      return SessionTokenPair.fromJson(decoded);
    } catch (_) {
      await clearSession();
      return null;
    }
  }

  Future<void> saveIdentity(PatientIdentity identity) async {
    try {
      await _secureStorage.write(
        key: _identityKey,
        value: jsonEncode(identity.toJson()),
      );
    } on MissingPluginException {
      rethrow;
    }
  }

  @override
  Future<void> saveTokenPair(SessionTokenPair tokenPair) async {
    try {
      await _secureStorage.write(
        key: _tokenPairKey,
        value: jsonEncode(tokenPair.toJson()),
      );
    } on MissingPluginException {
      rethrow;
    }
  }

  Future<void> clearIdentity() async {
    await clearSession();
  }

  @override
  Future<void> clearSession() async {
    try {
      await _secureStorage.delete(key: _identityKey);
      await _secureStorage.delete(key: _tokenPairKey);
    } on MissingPluginException {
      return;
    }
  }
}
