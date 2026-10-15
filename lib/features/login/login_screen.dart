import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rachas/app/app_routes.dart';
import 'package:rachas/core/config/app_strings.dart';
import 'package:rachas/core/errors/app_exception.dart';
import 'package:rachas/core/validators.dart';
import 'package:rachas/features/login/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // La llave del formulario vive en el State, nunca dentro de build().
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  bool get _hasCredentialsError => _errorMessage == AppStrings.wrongCredentials;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_errorMessage != null) setState(() => _errorMessage = null);
  }

  void _toggleMode() {
    setState(() {
      _isSignUp = !_isSignUp;
      _errorMessage = null;
      _confirmController.clear();
    });
  }

  void _showUnavailable() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.featureUnavailable)),
    );
  }

  Future<void> _submit() async {
    if (_isLoading) return; // evita enviar dos veces
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final auth = context.read<AuthService>();
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      if (_isSignUp) {
        await auth.signUp(email, password);
      } else {
        await auth.signIn(email, password);
      }
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = AppStrings.unexpectedError;
        _isLoading = false;
      });
    }
  }

  InputDecoration _decoration(String label, {Widget? suffixIcon}) {
    final errorColor = Theme.of(context).colorScheme.error;
    final errorBorder = OutlineInputBorder(
      borderSide: BorderSide(color: errorColor, width: 2),
    );
    return InputDecoration(
      labelText: label,
      suffixIcon: suffixIcon,
      border: const OutlineInputBorder(),
      // Borde de error cuando las credenciales son incorrectas.
      enabledBorder: _hasCredentialsError ? errorBorder : null,
      focusedBorder: _hasCredentialsError ? errorBorder : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _LogoHeader(),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                      onChanged: (_) => _clearError(),
                      validator: Validators.email,
                      decoration: _decoration(AppStrings.emailLabel),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      obscureText: _obscurePassword,
                      textInputAction: _isSignUp
                          ? TextInputAction.next
                          : TextInputAction.done,
                      onFieldSubmitted: (_) =>
                          _isSignUp ? _confirmFocus.requestFocus() : _submit(),
                      onChanged: (_) => _clearError(),
                      validator: Validators.password,
                      decoration: _decoration(
                        AppStrings.passwordLabel,
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword
                              ? AppStrings.showPassword
                              : AppStrings.hidePassword,
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                    ),
                    if (_isSignUp) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmController,
                        focusNode: _confirmFocus,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        onChanged: (_) => _clearError(),
                        // Validación cruzada: compara con la contraseña.
                        validator: (value) => Validators.confirmPassword(
                          value,
                          _passwordController.text,
                        ),
                        decoration: _decoration(
                          AppStrings.confirmPasswordLabel,
                        ),
                      ),
                    ],
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                    if (!_isSignUp)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _showUnavailable,
                          child: const Text(AppStrings.forgotPassword),
                        ),
                      ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _submit,
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.onPrimary,
                              ),
                            )
                          : Text(
                              _isSignUp
                                  ? AppStrings.createAccount
                                  : AppStrings.signIn,
                            ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          _isSignUp
                              ? AppStrings.haveAccountPrompt
                              : AppStrings.noAccountPrompt,
                        ),
                        TextButton(
                          onPressed: _isLoading ? null : _toggleMode,
                          child: Text(
                            _isSignUp
                                ? AppStrings.signIn
                                : AppStrings.createAccount,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Logo temporal: se reemplaza por el de Stitch cuando lo tengamos.
class _LogoHeader extends StatelessWidget {
  const _LogoHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.local_fire_department_rounded,
            size: 40,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 16),
        Text(AppStrings.appName, style: theme.textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          AppStrings.loginTagline,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }
}
