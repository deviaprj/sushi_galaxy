import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sushi_galaxy/core/store/game_providers.dart';
import 'package:sushi_galaxy/ui/theme/app_theme.dart';

/// Settings screen
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmAndResetProgress(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.nebulaPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Reinitialiser la progression ?',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Cette action remet le jeu a zero (niveau, etoiles, gems, boosters et vies).',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Reinitialiser'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref.read(playerProgressProvider.notifier).resetProgress();
    await ref.read(livesProvider.notifier).resetLives();
    ref.read(gameStatusProvider.notifier).reset();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Progression reinitialisee. Le jeu redemarre au niveau 1.'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.deepSpaceBlue,
              AppColors.cosmosDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'SETTINGS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Sound section
                    _SectionTitle(title: 'Sound'),
                    _SettingsTile(
                      icon: '🔊',
                      title: 'Sound Effects',
                      subtitle: 'Game sounds and feedback',
                      value: settings.soundEnabled,
                      onChanged: (value) {
                        ref.read(settingsProvider.notifier).toggleSound();
                      },
                    ),
                    _SettingsTile(
                      icon: '🎵',
                      title: 'Music',
                      subtitle: 'Background music',
                      value: settings.musicEnabled,
                      onChanged: (value) {
                        ref.read(settingsProvider.notifier).toggleMusic();
                      },
                    ),

                    const SizedBox(height: 24),

                    // Feedback section
                    _SectionTitle(title: 'Feedback'),
                    _SettingsTile(
                      icon: '📳',
                      title: 'Haptics',
                      subtitle: 'Vibration feedback',
                      value: settings.hapticsEnabled,
                      onChanged: (value) {
                        ref.read(settingsProvider.notifier).toggleHaptics();
                      },
                    ),

                    const SizedBox(height: 24),

                    // Notifications section
                    _SectionTitle(title: 'Notifications'),
                    _SettingsTile(
                      icon: '🔔',
                      title: 'Push Notifications',
                      subtitle: 'Daily reminders and events',
                      value: settings.notificationsEnabled,
                      onChanged: (value) {
                        ref.read(settingsProvider.notifier).toggleNotifications();
                      },
                    ),

                    const SizedBox(height: 24),

                    // About section
                    _SectionTitle(title: 'About'),
                    _SettingsTile(
                      icon: '📋',
                      title: 'Terms of Service',
                      subtitle: 'Read our terms',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: '🔒',
                      title: 'Privacy Policy',
                      subtitle: 'How we handle your data',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: '⭐',
                      title: 'Rate Us',
                      subtitle: 'Leave a review',
                      onTap: () {},
                    ),

                    const SizedBox(height: 24),

                    _SectionTitle(title: 'Progression'),
                    _SettingsTile(
                      icon: '🗑️',
                      title: 'Reinitialiser la progression',
                      subtitle: 'Remettre le jeu a zero',
                      onTap: () => _confirmAndResetProgress(context, ref),
                    ),

                    const SizedBox(height: 24),

                    // Version
                    Center(
                      child: Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.sakuraPink,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final bool? value;
  final Function(bool)? onChanged;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.value,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.glassWhite,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (value != null)
                Switch(
                  value: value!,
                  onChanged: onChanged,
                  activeColor: AppColors.sakuraPink,
                )
              else
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
