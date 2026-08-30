import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_localizations.dart';
import '../../core/app_theme.dart';
import '../../services/auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String _errorMessage(FirebaseAuthException e, String Function(String) translate) {
    switch (e.code) {
      case 'invalid-email':
        return translate('invalidEmail');
      case 'user-not-found':
        return translate('userNotFound');
      case 'wrong-password':
      case 'invalid-credential':
        return translate('wrongPassword');
      default:
        return translate('unknownError');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    try {
      await context.read<AuthService>().login(_email.text, _password.text);
      if (mounted) Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      if (mounted) _showError(_errorMessage(e, t));
    } catch (_) {
      if (mounted) _showError(t('unknownError'));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _loading = true);
    try {
      final result = await context.read<AuthService>().loginWithGoogle();
      if (result != null && mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
        _showError(l10n.t('unknownError'));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations)!;
    final t = l10n.t;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.tealPrimary, AppColors.tealLight],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.tealPrimary.withValues(alpha: 0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.school_rounded, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 24),
                Text(
                  t('welcomeBack'),
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.navyText),
                ),
                const SizedBox(height: 8),
                Text(
                  t('loginSubtitle'),
                  style: TextStyle(fontSize: 16, color: AppColors.grayMedium),
                ),
                const SizedBox(height: 32),
                // Form card
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: t('email'),
                            prefixIcon: const Icon(Icons.email_rounded),
                          ),
                          validator: (v) => (v == null || !v.contains('@')) ? t('invalidEmail') : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _password,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            labelText: t('password'),
                            prefixIcon: const Icon(Icons.lock_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? t('password') : null,
                          onFieldSubmitted: (_) => _submit(),
                        ),
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: TextButton(
                            onPressed: () => _showResetDialog(context, t),
                            child: Text(t('forgotPassword')),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Google login
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _loading ? null : _loginWithGoogle,
                            icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                            label: Text('${t('login')} Google'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Email login
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _loading ? null : _submit,
                            child: _loading
                                ? const SizedBox(
                                    width: 22, height: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2.5),
                                  )
                                : Text(t('login')),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(t('noAccount'), style: TextStyle(color: AppColors.grayMedium)),
                            TextButton(
                              onPressed: () => Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => const RegisterScreen()),
                              ),
                              child: Text(t('register')),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (i) {
          if (i == 0) {
            Navigator.of(context).pop();
          } else {
            _showError(t('loginFirst'));
          }
        },
        destinations: [
          NavigationDestination(icon: const Icon(Icons.public_outlined), selectedIcon: const Icon(Icons.public_rounded), label: t('site')),
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home_rounded), label: t('home')),
          NavigationDestination(icon: const Icon(Icons.collections_bookmark_outlined), selectedIcon: const Icon(Icons.collections_bookmark_rounded), label: t('myCourses')),
          NavigationDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person_rounded), label: t('profile')),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, String Function(String) t) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t('resetPassword')),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(labelText: t('email')),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text(t('cancel'))),
          FilledButton(
            onPressed: () async {
              try {
                await context.read<AuthService>().resetPassword(controller.text);
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                _showError(t('emailSent'));
              } catch (_) {
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                _showError(t('unknownError'));
              }
            },
            child: Text(t('sendResetLink')),
          ),
        ],
      ),
    );
  }
}