import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rachas/app/app_routes.dart';
import 'package:rachas/core/config/app_strings.dart';
import 'package:rachas/core/errors/app_exception.dart';
import 'package:rachas/core/theme/app_theme.dart';
import 'package:rachas/core/validators.dart';
import 'package:rachas/core/widgets/app_logo.dart';
import 'package:rachas/features/login/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  bool get _hasCredentialsError => _errorMessage == AppStrings.wrongCredentials;

  String get _submitLabel {
    if (_isLoading) {
      return _isSignUp ? AppStrings.creatingAccount : AppStrings.signingIn;
    }
    if (_hasCredentialsError) return AppStrings.tryAgain;
    return _isSignUp ? AppStrings.createAccount : AppStrings.signIn;
  }

  IconData get _submitIcon {
    if (_hasCredentialsError) return Icons.lock_open;
    return _isSignUp ? Icons.arrow_forward : Icons.login;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _emailFocus.dispose();
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
      _nameController.clear();
      _confirmController.clear();
    });
  }

  Future<void> _submit() async {
    if (_isLoading) return;
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
        await auth.signUp(email, password, name: _nameController.text);
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

  // Con credenciales incorrectas, correo y contraseña se marcan en Rosa Oscuro.
  InputDecoration _decoration(String? hint, {Widget? suffixIcon}) {
    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppTheme.darkPink, width: 2),
    );
    return InputDecoration(
      hintText: hint,
      suffixIcon: suffixIcon,
      enabledBorder: _hasCredentialsError ? errorBorder : null,
      focusedBorder: _hasCredentialsError ? errorBorder : null,
    );
  }

  Widget _passwordToggle() {
    return IconButton(
      tooltip: _obscurePassword
          ? AppStrings.showPassword
          : AppStrings.hidePassword,
      icon: Icon(
        _obscurePassword
            ? Icons.visibility_outlined
            : Icons.visibility_off_outlined,
      ),
      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
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
                    _LogoHeader(isSignUp: _isSignUp),
                    const SizedBox(height: 32),
                    if (_isSignUp) ...[
                      const _FieldLabel(
                        icon: Icons.person_outline,
                        text: AppStrings.nameLabel,
                      ),
                      // Las keys mantienen cada error en su campo cuando el
                      // campo Nombre aparece o desaparece al cambiar de modo.
                      TextFormField(
                        key: const ValueKey('name-field'),
                        enabled: !_isLoading,
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                        onChanged: (_) => _clearError(),
                        validator: Validators.personName,
                        decoration: _decoration(AppStrings.nameHint),
                      ),
                      const SizedBox(height: 16),
                    ],
                    const _FieldLabel(
                      icon: Icons.school_outlined,
                      text: AppStrings.emailLabel,
                    ),
                    TextFormField(
                      key: const ValueKey('email-field'),
                      enabled: !_isLoading,
                      controller: _emailController,
                      focusNode: _emailFocus,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                      onChanged: (_) => _clearError(),
                      validator: Validators.email,
                      decoration: _decoration(AppStrings.emailHint),
                    ),
                    const SizedBox(height: 16),
                    _FieldLabel(
                      icon: Icons.lock_outline,
                      text: AppStrings.passwordLabel,
                      trailing: _isSignUp
                          ? null
                          : TextButton(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                AppRoutes.forgotPassword,
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                              child: const Text(AppStrings.forgotPassword),
                            ),
                    ),
                    TextFormField(
                      key: const ValueKey('password-field'),
                      enabled: !_isLoading,
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
                        _isSignUp ? AppStrings.newPasswordHint : null,
                        suffixIcon: _passwordToggle(),
                      ),
                    ),
                    if (_isSignUp) ...[
                      const SizedBox(height: 16),
                      const _FieldLabel(
                        icon: Icons.verified_user_outlined,
                        text: AppStrings.confirmPasswordLabel,
                      ),
                      TextFormField(
                        key: const ValueKey('confirm-field'),
                        enabled: !_isLoading,
                        controller: _confirmController,
                        focusNode: _confirmFocus,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        onChanged: (_) => _clearError(),
                        validator: (value) => Validators.confirmPassword(
                          value,
                          _passwordController.text,
                        ),
                        decoration: _decoration(
                          AppStrings.confirmPasswordHint,
                          suffixIcon: _passwordToggle(),
                        ),
                      ),
                    ],
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      _ErrorBanner(message: _errorMessage!),
                    ],
                    const SizedBox(height: 24),
                    // Estados del botón según Stitch: normal, cargando
                    // (spinner Sky Blue y texto) y credenciales incorrectas.
                    FilledButton(
                      onPressed: _submit,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isLoading)
                            const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.skyBlue,
                              ),
                            )
                          else
                            Icon(_submitIcon, size: 20),
                          const SizedBox(width: 8),
                          Flexible(child: Text(_submitLabel)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          _isSignUp
                              ? AppStrings.haveAccountPrompt
                              : AppStrings.noAccountPrompt,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.slateBlue,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _isLoading ? null : _toggleMode,
                          iconAlignment: IconAlignment.end,
                          icon: const Icon(Icons.arrow_forward, size: 18),
                          label: Text(
                            _isSignUp
                                ? AppStrings.signIn
                                : AppStrings.createAccount,
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: _isSignUp
                                ? AppTheme.darkPink
                                : AppTheme.navy,
                          ),
                        ),
                      ],
                    ),
                    if (!_isSignUp) ...[
                      const SizedBox(height: 16),
                      const _TipCard(),
                    ],
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

class _LogoHeader extends StatelessWidget {
  const _LogoHeader({required this.isSignUp});

  final bool isSignUp;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        if (!isSignUp) ...[
          const AppLogo(size: 96, circle: true),
          const SizedBox(height: 20),
        ],
        Text(
          isSignUp ? AppStrings.signUpTitle : AppStrings.signIn,
          textAlign: TextAlign.center,
          style: textTheme.headlineMedium?.copyWith(
            color: AppTheme.navy,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isSignUp ? AppStrings.signUpTagline : AppStrings.loginTagline,
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(color: AppTheme.slateBlue),
        ),
      ],
    );
  }
}

/// Etiqueta arriba del campo, con ícono y un botón opcional a la derecha.
class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.icon, required this.text, this.trailing});

  final IconData icon;
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.navy),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppTheme.slateBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.palePink,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.darkPink.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 18, color: AppTheme.darkPink),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.darkPink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.skyBlue.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.skyBlue),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppTheme.skyBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_outlined,
              size: 20,
              color: AppTheme.navy,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppStrings.loginTip,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.navy),
            ),
          ),
        ],
      ),
    );
  }
}
