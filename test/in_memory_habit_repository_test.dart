import 'package:flutter_test/flutter_test.dart';
import 'package:rachas/core/errors/app_exception.dart';
import 'package:rachas/features/habits/habit.dart';
import 'package:rachas/features/habits/in_memory_habit_repository.dart';

void main() {
  late InMemoryHabitRepository repository;

  setUp(() {
    repository = InMemoryHabitRepository(latency: Duration.zero);
  });

  test('arranca con los 4 hábitos de ejemplo', () async {
    expect(await repository.getAll(), hasLength(4));
  });

  test('create asigna id y update, getById y delete lo usan', () async {
    final created = await repository.create(Habit.draft(name: 'Nuevo'));
    expect(created.isNew, isFalse);
    expect(await repository.getById(created.id), created);

    final renamed = await repository.update(created.copyWith(name: 'Otro'));
    expect((await repository.getById(created.id))?.name, renamed.name);

    await repository.delete(created.id);
    expect(await repository.getById(created.id), isNull);
  });

  test('operar sobre un id inexistente lanza notFound', () async {
    await expectLater(
      repository.delete('no-existe'),
      throwsA(
        isA<AppException>().having(
          (e) => e.type,
          'type',
          AppErrorType.notFound,
        ),
      ),
    );
  });
}
