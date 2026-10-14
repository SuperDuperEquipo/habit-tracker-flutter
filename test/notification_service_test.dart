import 'package:flutter_test/flutter_test.dart';
import 'package:rachas/features/notifications/notification_service.dart';

void main() {
  test('idFor es estable y cabe en un entero de 32 bits con signo', () {
    const habitId = '-OgXyZ123abcDEF';
    final id = NotificationService.idFor(habitId);

    expect(NotificationService.idFor(habitId), id);
    expect(id, inInclusiveRange(0, 0x7fffffff));
    expect(
      NotificationService.idFor('a'),
      isNot(NotificationService.idFor('b')),
    );
  });
}
