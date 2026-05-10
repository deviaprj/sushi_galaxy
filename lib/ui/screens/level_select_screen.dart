import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sushi_galaxy/core/store/game_providers.dart';
import 'package:sushi_galaxy/ui/theme/app_theme.dart';
import 'package:sushi_galaxy/ui/screens/game_screen.dart';

/// Level selection screen with warm terracotta theme
class LevelSelectScreen extends ConsumerWidget {
  const LevelSelectScreen({super.key});

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
                        'SELECT LEVEL',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Stats bar with warm glass effect
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.glassWhite.withOpacity(0.2),
                        AppColors.glassWhite.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.terracotta.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatChip(icon: '🏆', value: '${progress.currentLevel}'),
                      _StatChip(icon: '⭐', value: '${progress.totalStars}'),
                      _StatChip(icon: '🔥', value: '${progress.currentStreak}'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Level grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemCount: 50,
                  itemBuilder: (context, index) {
                    final levelNum = index + 1;
                    final isUnlocked = levelNum <= progress.currentLevel;
                    final isCompleted = progress.completedLevels.contains(levelNum);

                    return _LevelTile(
                      level: levelNum,
                      isUnlocked: isUnlocked,
                      isCompleted: isCompleted,
                      onTap: isUnlocked
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const GameScreen(),
                                ),
                              );
                            }
                          : null,
                    ).animate().fadeIn(
                          delay: Duration(milliseconds: 30 * index),
                        );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String icon;
  final String value;

  const _StatChip({
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _LevelTile extends StatelessWidget {
  final int level;
  final bool isUnlocked;
  final bool isCompleted;
  final VoidCallback? onTap;

  const _LevelTile({
    required this.level,
    required this.isUnlocked,
    required this.isCompleted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: isUnlocked
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isCompleted
                      ? [
                          AppColors.goldenRice.withOpacity(0.5),
                          AppColors.goldenRice.withOpacity(0.25),
                        ]
                      : [
                          AppColors.terracotta.withOpacity(0.5),
                          AppColors.terracotta.withOpacity(0.25),
                        ],
                )
              : null,
          color: isUnlocked ? null : AppColors.textSecondary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUnlocked
                ? (isCompleted
                    ? AppColors.goldenRice
                    : AppColors.terracotta)
                : AppColors.textSecondary.withOpacity(0.25),
            width: 2,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: (isCompleted
                            ? AppColors.goldenRice
                            : AppColors.terracotta)
                        .withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isUnlocked
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$level',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (isCompleted)
                      const Icon(
                        Icons.star,
                        size: 14,
                        color: AppColors.goldenRice,
                      ),
                  ],
                )
              : Icon(
                  Icons.lock,
                  size: 20,
                  color: AppColors.textSecondary.withOpacity(0.4),
                ),
        ),
      ),
    );
  }
}

/// World map with themed worlds
class WorldMapScreen extends StatelessWidget {
  const WorldMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final worlds = [
      {'name': 'Sushi Garden', 'icon': '🍣', 'unlocked': true, 'levels': 50},
      {'name': 'Space Kitchen', 'icon': '🚀', 'unlocked': false, 'levels': 50},
      {'name': 'Galaxy Chef', 'icon': '🌌', 'unlocked': false, 'levels': 50},
    ];

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
                        'WORLDS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: worlds.length,
                  itemBuilder: (context, index) {
                    final world = worlds[index];
                    final isUnlocked = world['unlocked'] as bool;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _WorldCard(
                        name: world['name'] as String,
                        icon: world['icon'] as String,
                        levels: world['levels'] as int,
                        isUnlocked: isUnlocked,
                        onTap: isUnlocked
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LevelSelectScreen(),
                                  ),
                                );
                              }
                            : null,
                      ),
                    ).animate().fadeIn(
                          delay: Duration(milliseconds: 200 * index),
                        );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorldCard extends StatelessWidget {
  final String name;
  final String icon;
  final int levels;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const _WorldCard({
    required this.name,
    required this.icon,
    required this.levels,
    required this.isUnlocked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: isUnlocked
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.terracotta.withOpacity(0.35),
                    AppColors.cosmosDark.withOpacity(0.8),
                  ],
                )
              : null,
          color: isUnlocked ? null : AppColors.textSecondary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isUnlocked
                ? AppColors.terracotta
                : AppColors.textSecondary.withOpacity(0.2),
            width: 2,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: AppColors.terracotta.withOpacity(0.15),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Icon with warm glow
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: isUnlocked
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.terracotta.withOpacity(0.4),
                          AppColors.nebulaPurple.withOpacity(0.3),
                        ],
                      )
                    : null,
                color: isUnlocked ? null : AppColors.textSecondary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(18),
                boxShadow: isUnlocked
                    ? [
                        BoxShadow(
                          color: AppColors.terracotta.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 38),
                ),
              ),
            ),
            const SizedBox(width: 18),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isUnlocked ? '$levels levels' : 'Locked',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow
            Icon(
              isUnlocked ? Icons.arrow_forward_ios : Icons.lock,
              color: isUnlocked
                  ? AppColors.terracotta
                  : AppColors.textSecondary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}