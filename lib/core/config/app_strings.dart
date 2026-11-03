abstract final class AppStrings {
  static const String appName = 'Rachas';

  static const String navHabits = 'Hábitos';
  static const String navProfile = 'Perfil';
  static const String featureUnavailable = 'Función no disponible por ahora';

  static const String unexpectedError = 'Algo salió mal. Inténtalo de nuevo';
  static const String sessionExpired = 'Sesión vencida';
  static const String habitNotFound = 'No encontramos ese hábito';

  static const String emailRequired = 'Escribe tu correo';
  static const String emailInvalid = 'Correo inválido';
  static const String passwordRequired = 'Escribe tu contraseña';
  static const String passwordTooShort =
      'La contraseña debe tener al menos 6 caracteres';
  static const String confirmPasswordRequired = 'Confirma tu contraseña';
  static const String passwordsDoNotMatch = 'Las contraseñas no coinciden';

  static const String noConnection = 'Sin conexión';
  static const String invalidData =
      'Datos inválidos. Revisa e inténtalo de nuevo';
  static const String emailExists = 'Ese correo ya está registrado';
  static const String wrongCredentials =
      'Correo o contraseña incorrectos. Revisa tus datos e inténtalo de nuevo';
  static const String tooManyAttempts =
      'Demasiados intentos, espera un momento';
  static const String serverError = 'Error del servidor. Inténtalo más tarde';
  static const String cancelled = 'Solicitud cancelada';

  static const String loginTagline = 'Construye tu racha, un día a la vez';
  static const String emailLabel = 'Correo';
  static const String passwordLabel = 'Contraseña';
  static const String confirmPasswordLabel = 'Confirmar contraseña';
  static const String signIn = 'Iniciar sesión';
  static const String createAccount = 'Crear cuenta';
  static const String noAccountPrompt = '¿No tienes cuenta?';
  static const String haveAccountPrompt = '¿Ya tienes cuenta?';
  static const String forgotPassword = '¿Olvidaste tu contraseña?';
  static const String showPassword = 'Mostrar contraseña';
  static const String hidePassword = 'Ocultar contraseña';
  static const String signOut = 'Cerrar sesión';

  static const String resetPasswordTitle = 'Recuperar contraseña';
  static const String resetPasswordSection = 'Recuperación';
  static const String resetPasswordSubtitle =
      'Ingresa tu correo electrónico asociado a tu cuenta y te enviaremos un enlace seguro para restablecer tu acceso.';
  static const String resetEmailLabel = 'Correo electrónico';
  static const String resetEmailHint = 'tu@correo.com';
  static const String sendResetLink = 'Enviar enlace de recuperación';
  static const String resetEmailSentTitle = '¡Enlace enviado con éxito!';
  static const String resetEmailSent =
      'Te enviamos un correo para restablecer tu contraseña. Revisa también tu carpeta de spam si no lo ves en unos minutos.';
  static const String rememberedPasswordPrompt = '¿Recordaste tu contraseña?';
  static const String backToLogin = 'Volver al inicio de sesión';
  static const String emailNotRegistered =
      'No encontramos una cuenta con ese correo';
  static const String crashTestLabel = 'Probar Crashlytics (solo debug)';

  static const String nameLabel = 'Nombre';
  static const String nameRequired = 'Escribe tu nombre';
  static const String nameTooShort = 'El nombre debe tener al menos 2 letras';
  static const String nameTooLong = 'El nombre es demasiado largo';
  static String profileGreeting(String name) => 'Hola, $name';

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

  static const String habitDetailTitle = 'Detalle del hábito';
  static const String currentStreakLabel = 'Racha actual';
  static const String jokersLeftLabel = 'Comodines restantes';
  static const String editLabel = 'Editar hábito';
  static const String jokersHint =
      'Te protegen si no puedes cumplir un día de exámenes o entregas pesadas.';
  static const String dailyReminderLabel = 'Recordatorio diario';

  static String jokersLeftOf(int left, int max) => '$left de $max';

  static String completedCount(int days) =>
      days == 1 ? '1 logrado' : '$days logrados';

  static const List<String> monthNames = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  static const List<String> weekdayInitials = [
    'L',
    'M',
    'M',
    'J',
    'V',
    'S',
    'D',
  ];

  static String monthTitle(DateTime month) =>
      '${monthNames[month.month - 1]} ${month.year}';

  static String calendarDay(int day, {required bool completed}) =>
      completed ? 'Día $day, completado' : 'Día $day';

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
