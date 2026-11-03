abstract final class AppStrings {
  static const String appName = 'Rachas';

  static const String navHabits = 'Hábitos';
  static const String navProfile = 'Perfil';
  static const String featureUnavailable = 'Función no disponible por ahora';

  static const String unexpectedError = 'Algo salió mal. Inténtalo de nuevo';
  static const String sessionExpired = 'Sesión vencida';
  static const String habitNotFound = 'No encontramos ese hábito';

  static const String reminderChannelName = 'Recordatorios de hábitos';
  static const String reminderChannelDescription =
      'Avisos diarios para completar tus hábitos';
  static const String reminderBody = 'Es hora de tu hábito. ¡Cuida tu racha!';

  static const String summaryNoProgress =
      'Un paso pequeño es suficiente para empezar';
  static const String summaryInProgress =
      'Mantienes un ritmo relajado y constante';
  static const String summaryAllDone = '¡Lo lograste! Hoy cumpliste todo';

  // Mis hábitos
  static String greeting([String? name]) {
    final clean = name?.trim() ?? '';
    return clean.isEmpty ? '¡Buen día!' : '¡Buen día, $clean!';
  }

  static const String habitsCalmSubtitle = 'Organiza tu día con calma';

  static String habitsScheduled(int count) => count == 1
      ? '1 hábito programado para hoy'
      : '$count hábitos programados para hoy';

  static String completedOf(int done, int total) =>
      '$done de $total completados';

  static String streakDays(int days) => days == 1 ? '1 día' : '$days días';

  static const String jokersLabel = 'Comodines:';
  static const String useJoker = 'Usar comodín';
  static const String jokerDialogTitle = '¿Conservar tu racha?';
  static const String jokerDialogBody =
      '¿Usar un comodín para conservar tu racha de hoy?';
  static const String cancel = 'Cancelar';
  static const String use = 'Usar';

  static const String newHabit = 'Nuevo Hábito';
  static const String emptyTitle = 'Aún no tienes hábitos registrados';
  static const String emptyBody =
      'Comienza con una pequeña meta diaria. Un paso a la vez para construir una racha que dure.';
  static const String createFirstHabit = 'Crear mi primer hábito';

  static const String offlineTitle = 'Sin conexión';
  static const String offlineBody =
      'No pudimos cargar tus hábitos. Revisa tu conexión e inténtalo de nuevo.';
  static const String loadErrorTitle = 'No pudimos cargar tus hábitos';
  static const String retry = 'Reintentar';

  static String markHabit(String name) => 'Marcar hábito $name';
  static String unmarkHabit(String name) => 'Desmarcar hábito $name';

  // Editar y eliminar hábito
  static const String editHabitTitle = 'Editar hábito';
  static const String editStreakNotice = 'Tu racha se conserva al editar';
  static const String saveChanges = 'Guardar cambios';
  static const String savingChanges = 'Guardando cambios...';
  static const String deleteHabit = 'Eliminar hábito';
  static const String delete = 'Eliminar';
  static const String deleteDialogTitle = '¿Eliminar este hábito?';
  static String deleteDialogBody(String name) =>
      'Se borrará "$name" con su racha e historial. Esta acción no se puede deshacer.';

  // Estadisticas 
  static const String navStats = 'Estadísticas';
  static const String statsTitle = 'Estadísticas';
  static const String statsWeekRate = 'Cumplimiento de la semana';
  static const String statsBestStreak = 'Mejor racha';
  static const String statsMostConsistent = 'Hábito más constante';
  static const String statsNoData = 'Sin datos todavía';
  static const String statsEmpty =
      'Cuando tengas hábitos, aquí verás cómo vas en la semana.';

  static String statsDays(int n) => n == 1 ? '1 día' : '$n días';
  static String statsDaysOf(int done, int total) =>
      '$done de $total días completados';
  static String statsConsistentDetail(int percent) =>
      '$percent% de cumplimiento';

}
