import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sushi_galaxy/core/store/game_providers.dart';
import 'package:sushi_galaxy/ui/theme/app_theme.dart';

/// Settings screen
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

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

/// Profile screen
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(playerProgressProvider);

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
                        'PROFILE',
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
                    // Avatar
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.sakuraPink,
                              AppColors.neonPurple,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Center(
                          child: Text(
                            '🍣',
                            style: TextStyle(fontSize: 50),
                          ),
                        ),
                      ),
                    ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'Sushi Master',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Stats
                    _ProfileStatCard(
                      stats: [
                        {'icon': '🏆', 'label': 'Current Level', 'value': '${progress.currentLevel}'},
                        {'icon': '⭐', 'label': 'Total Stars', 'value': '${progress.totalStars}'},
                        {'icon': '🔥', 'label': 'Best Streak', 'value': '${progress.currentStreak}'},
                        {'icon': '🎯', 'label': 'High Score', 'value': '${progress.highScore}'},
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Achievements placeholder
                    _SectionTitle(title: 'Achievements'),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.glassWhite,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Coming soon! 🎉',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                          ),
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

class _ProfileStatCard extends StatelessWidget {
  final List<Map<String, String>> stats;

  const _ProfileStatCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.glassWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: stats[0]['icon']!,
                  label: stats[0]['label']!,
                  value: stats[0]['value']!,
                ),
              ),
              Expanded(
                child: _StatItem(
                  icon: stats[1]['icon']!,
                  label: stats[1]['label']!,
                  value: stats[1]['value']!,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: stats[2]['icon']!,
                  label: stats[2]['label']!,
                  value: stats[2]['value']!,
                ),
              ),
              Expanded(
                child: _StatItem(
                  icon: stats[3]['icon']!,
                  label: stats[3]['label']!,
                  value: stats[3]['value']!,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.goldenRice,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}