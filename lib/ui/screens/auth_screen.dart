import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sushi_galaxy/core/store/auth_providers.dart';
import 'package:sushi_galaxy/ui/components/effects/cosmic_background.dart';
import 'package:sushi_galaxy/ui/screens/home_screen.dart';
import 'package:sushi_galaxy/ui/theme/app_theme.dart';

class AuthGateScreen extends ConsumerWidget {
  const AuthGateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authSessionProvider);

    if (auth.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.terracotta),
        ),
      );
    }

    if (auth.session == null) {
      return const AuthScreen();
    }

    return const HomeScreen();
  }
}

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  bool _isBusy = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _runAuthAction(Future<void> Function() action) async {
    setState(() {
      _isBusy = true;
    });

    try {
      await action();
    } on AuthFailure catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CosmicBackground(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.deepSpaceBlue, AppColors.cosmosDark],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 460),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.glassWhite.withOpacity(0.18),
                        AppColors.glassWhite.withOpacity(0.06),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: AppColors.terracotta.withOpacity(0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 22,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        '🍣',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 56),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Connexion joueur',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Mode local dev/test : chaque compte garde sa propre progression sur cet appareil.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _AuthProviderButton(
                        label: 'Continuer avec Google',
                        emoji: 'G',
                        color: const Color(0xFFEA4335),
                        onPressed: _isBusy
                            ? null
                            : () => _runAuthAction(
                                  () => ref
                                      .read(authSessionProvider.notifier)
                                      .signInWithGoogle(),
                                ),
                      ),
                      const SizedBox(height: 12),
                      _AuthProviderButton(
                        label: 'Continuer avec Apple',
                        emoji: '',
                        color: const Color(0xFF111111),
                        onPressed: _isBusy
                            ? null
                            : () => _runAuthAction(
                                  () => ref
                                      .read(authSessionProvider.notifier)
                                      .signInWithApple(),
                                ),
                      ),
                      const SizedBox(height: 12),
                      _AuthProviderButton(
                        label: 'Continuer avec Facebook',
                        emoji: 'f',
                        color: const Color(0xFF1877F2),
                        onPressed: _isBusy
                            ? null
                            : () => _runAuthAction(
                                  () => ref
                                      .read(authSessionProvider.notifier)
                                      .signInWithFacebook(),
                                ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.nebulaPurple.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.goldenRice.withOpacity(0.25),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Connexion email',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _displayNameController,
                              decoration: _inputDecoration('Pseudo (optionnel)'),
                              style: const TextStyle(color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: _inputDecoration('Email'),
                              style: const TextStyle(color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: _inputDecoration('Mot de passe'),
                              style: const TextStyle(color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _isBusy
                                  ? null
                                  : () => _runAuthAction(
                                        () => ref
                                            .read(authSessionProvider.notifier)
                                            .signInWithEmail(
                                              email: _emailController.text,
                                              password: _passwordController.text,
                                              displayName:
                                                  _displayNameController.text,
                                            ),
                                      ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.terracotta,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Se connecter avec email',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextButton(
                        onPressed: _isBusy
                            ? null
                            : () => _runAuthAction(
                                  () => ref
                                      .read(authSessionProvider.notifier)
                                      .signInAnonymously(),
                                ),
                        child: const Text(
                          'Continuer en mode anonyme',
                          style: TextStyle(
                            color: AppColors.goldenRice,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (_isBusy) ...[
                        const SizedBox(height: 16),
                        const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.terracotta,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.glassWhite.withOpacity(0.08),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.terracotta, width: 1.5),
      ),
    );
  }
}

class _AuthProviderButton extends StatelessWidget {
  final String label;
  final String emoji;
  final Color color;
  final VoidCallback? onPressed;

  const _AuthProviderButton({
    required this.label,
    required this.emoji,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        disabledBackgroundColor: color.withOpacity(0.4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}