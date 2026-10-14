import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rachas/app/app.dart';
import 'package:rachas/core/config/app_strings.dart';
import 'package:rachas/core/network/api_client.dart';
import 'package:rachas/features/habits/in_memory_habit_repository.dart';
import 'package:rachas/features/notifications/notification_service.dart';

void main() {
  testWidgets('login lleva al inicio y la barra cambia a Perfil', (
    tester,
  ) async {
    await tester.pumpWidget(
      RachasApp(
        apiClient: ApiClient(),
        habitRepository: InMemoryHabitRepository(latency: Duration.zero),
        notifications: NotificationService(),
      ),
    );

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(AppStrings.navProfile),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.featureUnavailable), findsOneWidget);
  });
}
