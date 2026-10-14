import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rachas/core/errors/app_exception.dart';
import 'package:rachas/core/network/api_client.dart';
import 'package:rachas/features/habits/api_habit_repository.dart';
import 'package:rachas/features/habits/habit.dart';

typedef _Reply = ({int status, Object? body});

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this._respond);

  final _Reply Function(RequestOptions options) _respond;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final reply = _respond(options);
    return ResponseBody.fromString(
      jsonEncode(reply.body),
      reply.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

ApiHabitRepository _repository(_FakeAdapter adapter, {String? uid = 'u1'}) {
  final dio = Dio()..httpClientAdapter = adapter;
  return ApiHabitRepository(
    apiClient: ApiClient(dio: dio),
    uidProvider: () async => uid,
  );
}

Map<String, Object?> _habitJson({
  String name = 'Leer',
  String createdAt = '2026-10-01T09:30:00.000',
}) => {
  'name': name,
  'iconKey': 'menu_book',
  'colorValue': 0xFF2F4058,
  'streak': 5,
  'jokersLeft': 2,
  'completedDates': ['2026-10-12'],
  'createdAt': createdAt,
};

void main() {
  test('getAll devuelve lista vacía cuando Firebase responde null', () async {
    final adapter = _FakeAdapter((_) => (status: 200, body: null));

    expect(await _repository(adapter).getAll(), isEmpty);
    expect(adapter.requests.single.method, 'GET');
    expect(adapter.requests.single.path, '/users/u1/habits.json');
  });

  test('getAll convierte el mapa de Firebase y usa la llave como id', () async {
    final adapter = _FakeAdapter(
      (_) => (
        status: 200,
        body: {
          '-Obbb': {
            ..._habitJson(
              name: 'Caminar',
              createdAt: '2026-10-02T09:30:00.000',
            ),
            'completedDates': null,
          },
          '-Oaaa': _habitJson(name: 'Leer'),
        },
      ),
    );

    final habits = await _repository(adapter).getAll();

    expect(habits.map((h) => h.id), ['-Oaaa', '-Obbb']);
    expect(habits.first.completedDates, [DateTime(2026, 10, 12)]);
    expect(habits.last.completedDates, isEmpty);
  });

  test('getById devuelve null si el hábito no existe', () async {
    final adapter = _FakeAdapter((_) => (status: 200, body: null));

    expect(await _repository(adapter).getById('-Oaaa'), isNull);
    expect(adapter.requests.single.path, '/users/u1/habits/-Oaaa.json');
  });

  test('create hace POST y devuelve el hábito con id de Firebase', () async {
    final adapter = _FakeAdapter((_) => (status: 200, body: {'name': '-Onew'}));
    final repository = _repository(adapter);

    final created = await repository.create(Habit.draft(name: 'Nuevo'));

    expect(created.id, '-Onew');
    expect(adapter.requests.single.method, 'POST');
    expect(adapter.requests.single.path, '/users/u1/habits.json');
    expect((adapter.requests.single.data as Map)['name'], 'Nuevo');
  });

  test('update hace PUT con el hábito completo', () async {
    final adapter = _FakeAdapter((_) => (status: 200, body: _habitJson()));
    final habit = Habit.fromJson(_habitJson(), id: '-Oaaa');

    final updated = await _repository(adapter).update(habit);

    expect(updated, habit);
    expect(adapter.requests.single.method, 'PUT');
    expect(adapter.requests.single.path, '/users/u1/habits/-Oaaa.json');
  });

  test('delete hace DELETE sobre el hábito', () async {
    final adapter = _FakeAdapter((_) => (status: 200, body: null));

    await _repository(adapter).delete('-Oaaa');

    expect(adapter.requests.single.method, 'DELETE');
    expect(adapter.requests.single.path, '/users/u1/habits/-Oaaa.json');
  });

  test('toggleComplete envía PATCH con racha y fechas', () async {
    final adapter = _FakeAdapter(
      (options) =>
          (status: 200, body: options.method == 'GET' ? _habitJson() : null),
    );

    await _repository(adapter).toggleComplete('-Oaaa', DateTime(2026, 10, 13));

    final patch = adapter.requests.last;
    expect(patch.method, 'PATCH');
    expect(patch.path, '/users/u1/habits/-Oaaa.json');
    expect(
      (patch.data as Map).keys,
      unorderedEquals(['streak', 'completedDates']),
    );
  });

  test('useJoker envía PATCH con comodines, racha y fechas', () async {
    final adapter = _FakeAdapter(
      (options) =>
          (status: 200, body: options.method == 'GET' ? _habitJson() : null),
    );

    await _repository(adapter).useJoker('-Oaaa', DateTime(2026, 10, 13));

    final patch = adapter.requests.last;
    expect(patch.method, 'PATCH');
    expect(
      (patch.data as Map).keys,
      unorderedEquals(['jokersLeft', 'streak', 'completedDates']),
    );
  });

  test('toggleComplete sobre un hábito inexistente lanza notFound', () async {
    final adapter = _FakeAdapter((_) => (status: 200, body: null));

    await expectLater(
      _repository(adapter).toggleComplete('-Oaaa', DateTime(2026, 10, 13)),
      throwsA(
        isA<AppException>().having(
          (e) => e.type,
          'type',
          AppErrorType.notFound,
        ),
      ),
    );
  });

  test('un error HTTP se convierte en AppException con el código', () async {
    final adapter = _FakeAdapter(
      (_) => (status: 401, body: {'error': 'Auth token is expired'}),
    );

    await expectLater(
      _repository(adapter).getAll(),
      throwsA(
        isA<AppException>().having((e) => e.statusCode, 'statusCode', 401),
      ),
    );
  });

  test('sin uid lanza sessionExpired y no hace ninguna petición', () async {
    final adapter = _FakeAdapter((_) => (status: 200, body: null));

    await expectLater(
      _repository(adapter, uid: null).getAll(),
      throwsA(
        isA<AppException>().having(
          (e) => e.type,
          'type',
          AppErrorType.sessionExpired,
        ),
      ),
    );
    expect(adapter.requests, isEmpty);
  });

  test('update con un hábito sin id lanza ArgumentError', () async {
    final adapter = _FakeAdapter((_) => (status: 200, body: null));

    await expectLater(
      _repository(adapter).update(Habit.draft(name: 'Sin id')),
      throwsArgumentError,
    );
  });
}
