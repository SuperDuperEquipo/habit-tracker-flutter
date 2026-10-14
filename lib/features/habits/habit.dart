import 'package:rachas/core/utils/date_helpers.dart';

class Habit {
  Habit({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.colorValue,
    this.reminderTime,
    required this.streak,
    required this.jokersLeft,
    required List<DateTime> completedDates,
    required this.createdAt,
  }) : assert(jokersLeft >= 0 && jokersLeft <= maxJokers),
       completedDates = List<DateTime>.unmodifiable(
         completedDates.map(dateOnly),
       );

  factory Habit.draft({
    required String name,
    String iconKey = defaultIconKey,
    int colorValue = defaultColorValue,
    String? reminderTime,
  }) {
    return Habit(
      id: '',
      name: name,
      iconKey: iconKey,
      colorValue: colorValue,
      reminderTime: reminderTime,
      streak: 0,
      jokersLeft: maxJokers,
      completedDates: const [],
      createdAt: DateTime.now(),
    );
  }

  factory Habit.fromJson(Map<String, dynamic> json, {String? id}) {
    return Habit(
      id: id ?? _asString(json['id']) ?? '',
      name: _asString(json['name']) ?? '',
      iconKey: _asString(json['iconKey']) ?? defaultIconKey,
      colorValue: _asInt(json['colorValue']) ?? defaultColorValue,
      reminderTime: _asString(json['reminderTime']),
      streak: _asInt(json['streak']) ?? 0,
      jokersLeft: _clampJokers(_asInt(json['jokersLeft']) ?? maxJokers),
      completedDates: _asDates(json['completedDates']),
      createdAt:
          DateTime.tryParse(_asString(json['createdAt']) ?? '') ?? _epoch,
    );
  }

  static const int maxJokers = 3;
  static const String defaultIconKey = 'menu_book';
  static const int defaultColorValue = 0xFF2F4058;

  static final DateTime _epoch = DateTime.fromMillisecondsSinceEpoch(0);

  final String id;
  final String name;
  final String iconKey;
  final int colorValue;
  final String? reminderTime;
  final int streak;
  final int jokersLeft;
  final List<DateTime> completedDates;
  final DateTime createdAt;

  bool get isNew => id.isEmpty;

  Habit copyWith({
    String? id,
    String? name,
    String? iconKey,
    int? colorValue,
    String? reminderTime,
    bool clearReminderTime = false,
    int? streak,
    int? jokersLeft,
    List<DateTime>? completedDates,
    DateTime? createdAt,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      colorValue: colorValue ?? this.colorValue,
      reminderTime: clearReminderTime
          ? null
          : (reminderTime ?? this.reminderTime),
      streak: streak ?? this.streak,
      jokersLeft: jokersLeft ?? this.jokersLeft,
      completedDates: completedDates ?? this.completedDates,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'iconKey': iconKey,
    'colorValue': colorValue,
    'reminderTime': reminderTime,
    'streak': streak,
    'jokersLeft': jokersLeft,
    'completedDates': completedDates.map(dateKey).toList(),
    'createdAt': createdAt.toIso8601String(),
  };

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Habit &&
            id == other.id &&
            name == other.name &&
            iconKey == other.iconKey &&
            colorValue == other.colorValue &&
            reminderTime == other.reminderTime &&
            streak == other.streak &&
            jokersLeft == other.jokersLeft &&
            _sameDates(completedDates, other.completedDates) &&
            createdAt == other.createdAt;
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    iconKey,
    colorValue,
    reminderTime,
    streak,
    jokersLeft,
    Object.hashAll(completedDates),
    createdAt,
  );
}

String? _asString(Object? value) => value is String ? value : null;

int? _asInt(Object? value) => value is num ? value.toInt() : null;

int _clampJokers(int value) {
  if (value < 0) return 0;
  if (value > Habit.maxJokers) return Habit.maxJokers;
  return value;
}

List<DateTime> _asDates(Object? value) {
  Iterable<Object?> raw = const [];
  if (value is List) {
    raw = value;
  } else if (value is Map) {
    raw = value.values;
  }
  final dates = <DateTime>[];
  for (final item in raw) {
    if (item is! String) continue;
    final parsed = parseDateKey(item);
    if (parsed != null) dates.add(parsed);
  }
  return dates;
}

bool _sameDates(List<DateTime> a, List<DateTime> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
