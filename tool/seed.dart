// Crea en Firebase las cuentas de prueba y sus hábitos.
//
//     dart run tool/seed.dart
//
// Se puede correr varias veces: si la cuenta ya existe inicia sesión y
// reemplaza sus hábitos por los del seed. Los perfiles están en
// seed_profiles.dart y se describen en el README.
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:rachas/core/config/api_endpoints.dart';
import 'package:rachas/core/config/firebase_config.dart';

import 'seed_profiles.dart';

final Dio _dio = Dio(BaseOptions(baseUrl: FirebaseConfig.dbUrl));
const Map<String, String> _key = {'key': FirebaseConfig.apiKey};

Future<void> main() async {
  try {
    for (final profile in seedProfiles(DateTime.now())) {
      final session = await _signUpOrIn(profile.email);
      await _setName(session.idToken, profile.name);
      final saved = await _replaceHabits(session, profile);
      stdout.writeln('${profile.email}: $saved hábitos');
    }
    stdout.writeln('Listo. Contraseña de todas las cuentas: $seedPassword');
  } on DioException catch (e) {
    stderr.writeln('Falló ${e.requestOptions.uri.path}: ${_firebaseError(e)}');
    exitCode = 1;
  } on StateError catch (e) {
    stderr.writeln(e.message);
    exitCode = 1;
  }
}

Future<({String uid, String idToken})> _signUpOrIn(String email) async {
  final body = {
    'email': email,
    'password': seedPassword,
    'returnSecureToken': true,
  };
  Response<dynamic> response;
  try {
    response = await _dio.post(
      ApiEndpoints.signUp,
      queryParameters: _key,
      data: body,
    );
  } on DioException catch (e) {
    if (_firebaseError(e) != 'EMAIL_EXISTS') rethrow;
    try {
      response = await _dio.post(
        ApiEndpoints.signIn,
        queryParameters: _key,
        data: body,
      );
    } on DioException catch (e) {
      const wrongPassword = {'INVALID_LOGIN_CREDENTIALS', 'INVALID_PASSWORD'};
      if (!wrongPassword.contains(_firebaseError(e))) rethrow;
      throw StateError(
        '$email ya existe con otra contraseña. Bórrala en Firebase Console '
        '> Authentication y vuelve a correr el seed.',
      );
    }
  }
  final data = response.data as Map<String, dynamic>;
  return (uid: data['localId'] as String, idToken: data['idToken'] as String);
}

Future<void> _setName(String idToken, String? name) {
  return _dio.post<dynamic>(
    ApiEndpoints.updateProfile,
    queryParameters: _key,
    data: {
      'idToken': idToken,
      if (name != null)
        'displayName': name
      else
        'deleteAttribute': ['DISPLAY_NAME'],
    },
  );
}

/// Reemplaza todo users/{uid}/habits y devuelve cuántos hábitos quedaron.
Future<int> _replaceHabits(
  ({String uid, String idToken}) session,
  SeedProfile profile,
) async {
  final path = ApiEndpoints.habits(session.uid);
  final auth = {'auth': session.idToken};
  if (profile.habits.isEmpty) {
    await _dio.delete<dynamic>(path, queryParameters: auth);
    return 0;
  }
  final response = await _dio.put<dynamic>(
    path,
    queryParameters: auth,
    data: {for (final habit in profile.habits) habit.id: habit.toJson()},
  );
  return (response.data as Map).length;
}

// Firebase responde {"error": {"message": "EMAIL_EXISTS"}}.
String _firebaseError(DioException e) {
  final data = e.response?.data;
  final error = data is Map ? data['error'] : null;
  final message = error is Map ? error['message'] : error;
  return message?.toString() ?? e.message ?? e.type.name;
}
