import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:rachas/features/habits/in_memory_habit_repository.dart';
import 'package:rachas/features/habit_form/create_habit_screen.dart';
import 'package:rachas/features/habits/habit_repository.dart';

void main() {
  testWidgets('Crear hábito guarda el nombre que escribió el usuario', (
    tester,
  ) async {
    // 1. Inicializamos el repositorio en memoria como dependencia falsa (fake)
    final repository = InMemoryHabitRepository(latency: Duration.zero);

    // 2. Construimos la pantalla envolviéndola con el Provider del repositorio para que funcione
    await tester.pumpWidget(
      MaterialApp(
        home: Provider<HabitRepository>.value(
          value: repository,
          child: CreateHabitScreen(habitRepository: repository),
        ),
      ),
    );

    // 3. Verificamos que al inicio no hay hábitos con ese nombre específico
    final initialHabits = await repository.getAll();
    expect(initialHabits.any((h) => h.name == 'Estudiar Flutter'), isFalse);

    // 4. Buscamos el campo de texto (TextField o AppTextField) y escribimos el nombre del hábito
    final textFieldFinder = find.byType(TextField);
    expect(textFieldFinder, findsOneWidget);
    await tester.enterText(textFieldFinder, 'Estudiar Flutter');
    await tester.pump();

    // 5. Buscamos y presionamos el botón de guardar/crear
    // Buscamos el botón de submit o el icono de check de creación
    final saveButtonFinder = find.byType(FilledButton).first;
    await tester.ensureVisible(saveButtonFinder);
    await tester.tap(saveButtonFinder);

    // Esperamos a que terminen las animaciones y la navegación posterior
    await tester.pumpAndSettle();

    // 6. Comprobamos que el repositorio guardó el hábito con el nombre escrito
    final updatedHabits = await repository.getAll();
    expect(
      updatedHabits.any((h) => h.name == 'Estudiar Flutter'),
      isTrue,
      reason:
          'El hábito creado debe encontrarse en el repositorio con el nombre ingresado',
    );
  });
}
