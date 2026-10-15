abstract final class ApiEndpoints {
  static const String signUp =
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp';
  static const String signIn =
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword';
  static const String refreshToken =
      'https://securetoken.googleapis.com/v1/token';

  static String habits(String uid) => '/users/$uid/habits.json';

  static String habit(String uid, String habitId) =>
      '/users/$uid/habits/$habitId.json';

  static const String updateProfile =
      'https://identitytoolkit.googleapis.com/v1/accounts:update';
}
