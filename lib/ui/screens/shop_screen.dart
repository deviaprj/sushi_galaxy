import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sushi_galaxy/core/store/game_providers.dart';
import 'package:sushi_galaxy/ui/theme/app_theme.dart';
import 'package:sushi_galaxy/ui/components/game_widgets.dart';

/// Shop screen for IAP and in-game purchases
class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

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
                        'SHOP',
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

              // Gems display
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GemCounter(gems: progress.gems),
              ).animate().fadeIn().slideY(begin: -0.2),

              const SizedBox(height: 24),

              // Shop tabs
              Expanded(
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: AppColors.glassWhite,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TabBar(
                          indicator: BoxDecoration(
                            color: AppColors.sakuraPink,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: AppColors.textSecondary,
                          dividerColor: Colors.transparent,
                          tabs: const [
                            Tab(text: '💎 Gems'),
                            Tab(text: '🎁 Boosters'),
                            Tab(text: '⏱️ Temps'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _GemsTab(),
                            _BoostersTab(),
                            const _TimePassTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GemsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gemPacks = [
      _GemPack(
        name: 'Starter Pack',
        gems: 80,
        price: 0.99,
        icon: '⚡',
        isPopular: false,
      ),
      _GemPack(
        name: 'Popular',
        gems: 500,
        price: 4.99,
        icon: '💎',
        isPopular: true,
      ),
      _GemPack(
        name: 'Power Pack',
        gems: 1200,
        price: 9.99,
        icon: '💰',
        isPopular: false,
      ),
      _GemPack(
        name: 'Mega Pack',
        gems: 3000,
        price: 19.99,
        icon: '👑',
        isPopular: false,
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: gemPacks.length,
      itemBuilder: (context, index) {
        final pack = gemPacks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _GemPackCard(pack: pack)
              .animate()
              .fadeIn(delay: Duration(milliseconds: 100 * index))
              .slideX(begin: 0.1),
        );
      },
    );
  }
}

class _GemPack {
  final String name;
  final int gems;
  final double price;
  final String icon;
  final bool isPopular;

  const _GemPack({
    required this.name,
    required this.gems,
    required this.price,
    required this.icon,
    required this.isPopular,
  });
}

class _GemPackCard extends ConsumerWidget {
  final _GemPack pack;

  const _GemPackCard({required this.pack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.neonPurple.withOpacity(0.3),
                AppColors.cosmosDark,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: pack.isPopular
                  ? AppColors.sakuraPink
                  : AppColors.neonPurple.withOpacity(0.5),
              width: pack.isPopular ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.neonPurple.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    pack.icon,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pack.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text('💎', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          '${pack.gems}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.goldenRice,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Price
              ElevatedButton(
                onPressed: () {
                  ref.read(playerProgressProvider.notifier).addGems(pack.gems);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Achat test : +${pack.gems} gemmes ajoutees'),
                      backgroundColor: AppColors.avocado,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sakuraPink,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '\$${pack.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Popular badge
        if (pack.isPopular)
          Positioned(
            top: 0,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.sakuraPink,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'BEST VALUE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _BoostersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const _FunctionalBoostersTab();
  }
}

class _FunctionalBoostersTab extends ConsumerWidget {
  const _FunctionalBoostersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(playerProgressProvider);
    final boosters = [
      _ShopBoosterPack(
        icon: '🔨',
        name: 'Marteau',
        desc: 'Detruit une tuile et declenche la gravite',
        price: 50,
        stock: progress.hammerBoosters,
        accent: AppColors.terracotta,
        onBuy: () => ref.read(playerProgressProvider.notifier).addHammerBoosters(1),
      ),
      _ShopBoosterPack(
        icon: '🔀',
        name: 'Melange',
        desc: 'Remix total de la grille',
        price: 75,
        stock: progress.shuffleBoosters,
        accent: AppColors.neonPurple,
        onBuy: () => ref.read(playerProgressProvider.notifier).addShuffleBoosters(1),
      ),
      _ShopBoosterPack(
        icon: '🧰',
        name: 'Pack marteaux x3',
        desc: 'Reserve rapide pour plusieurs niveaux',
        price: 135,
        stock: progress.hammerBoosters,
        accent: AppColors.goldenRice,
        onBuy: () => ref.read(playerProgressProvider.notifier).addHammerBoosters(3),
      ),
      _ShopBoosterPack(
        icon: '🎛️',
        name: 'Pack melanges x3',
        desc: 'Trois remises a zero de grille',
        price: 200,
        stock: progress.shuffleBoosters,
        accent: AppColors.sakuraPink,
        onBuy: () => ref.read(playerProgressProvider.notifier).addShuffleBoosters(3),
      ),
    ];

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.88,
      ),
      itemCount: boosters.length,
      itemBuilder: (context, index) {
        final booster = boosters[index];
        final canBuy = progress.gems >= booster.price;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                booster.accent.withOpacity(0.22),
                AppColors.glassWhite.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: booster.accent.withOpacity(0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(booster.icon, style: const TextStyle(fontSize: 30)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Stock ${booster.stock}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                booster.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                booster.desc,
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.25,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: canBuy
                      ? () {
                          ref.read(playerProgressProvider.notifier).spendGems(booster.price);
                          booster.onBuy();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${booster.name} ajoute au stock'),
                              backgroundColor: booster.accent,
                            ),
                          );
                        }
                      : null,
                  icon: const Text('💎', style: TextStyle(fontSize: 14)),
                  label: Text('${booster.price}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        canBuy ? booster.accent : AppColors.textSecondary.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 90 * index)).slideY(begin: 0.08);
      },
    );
  }
}

class _ShopBoosterPack {
  final String icon;
  final String name;
  final String desc;
  final int price;
  final int stock;
  final Color accent;
  final VoidCallback onBuy;

  const _ShopBoosterPack({
    required this.icon,
    required this.name,
    required this.desc,
    required this.price,
    required this.stock,
    required this.accent,
    required this.onBuy,
  });
}

/// Subscription screen
class _TimePassTab extends ConsumerWidget {
  const _TimePassTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(playerProgressProvider);

    final packs = [
      _TimePack(icon: '⏱️', label: '+60 secondes', seconds: 60, price: 30, color: AppColors.avocado),
      _TimePack(icon: '⏰', label: '+120 secondes', seconds: 120, price: 50, color: AppColors.terracotta, popular: true),
      _TimePack(icon: '🕐', label: '+300 secondes', seconds: 300, price: 100, color: AppColors.neonPurple),
      _TimePack(icon: '❤️', label: '+1 vie',        seconds: 0,   price: 60, color: AppColors.sakuraPink, isLife: true),
    ];

    return Column(
      children: [
        // Temps stocké actuel
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.goldenRice.withOpacity(0.15), AppColors.glassWhite.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.goldenRice.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('⏰', style: TextStyle(fontSize: 26)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${progress.storedTimeSeconds} sec stockées',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.goldenRice)),
                    const Text('Utilisables comme bonus en jeu',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: packs.length,
            itemBuilder: (context, i) {
              final pack = packs[i];
              final canBuy = progress.gems >= pack.price;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [pack.color.withOpacity(0.18), AppColors.glassWhite.withOpacity(0.06)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: pack.color.withOpacity(pack.popular ? 0.8 : 0.3), width: pack.popular ? 1.5 : 1),
                ),
                child: Row(
                  children: [
                    Text(pack.icon, style: const TextStyle(fontSize: 36)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (pack.popular)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              margin: const EdgeInsets.only(bottom: 4),
                              decoration: BoxDecoration(
                                color: AppColors.terracotta,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('⭐ POPULAIRE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
                            ),
                          Text(pack.label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          const SizedBox(height: 2),
                          Text(pack.isLife ? 'Régénération immédiate' : 'Ajout à votre réserve de temps',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Text('💎', style: TextStyle(fontSize: 14)),
                      label: Text('${pack.price}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canBuy ? pack.color : AppColors.textSecondary.withOpacity(0.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onPressed: canBuy
                          ? () {
                              ref.read(playerProgressProvider.notifier).spendGems(pack.price);
                              if (pack.isLife) {
                                ref.read(livesProvider.notifier).addLife();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('❤️ +1 vie ajoutée !'), backgroundColor: AppColors.sakuraPink),
                                );
                              } else {
                                ref.read(playerProgressProvider.notifier).addStoredTime(pack.seconds);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('⏰ +${pack.seconds}s ajoutées à votre réserve !'), backgroundColor: AppColors.terracotta),
                                );
                              }
                            }
                          : null,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: Duration(milliseconds: 80 * i)).slideX(begin: 0.15);
            },
          ),
        ),
      ],
    );
  }
}

class _TimePack {
  final String icon;
  final String label;
  final int seconds;
  final int price;
  final Color color;
  final bool popular;
  final bool isLife;
  const _TimePack({required this.icon, required this.label, required this.seconds, required this.price, required this.color, this.popular = false, this.isLife = false});
}

/// Subscription screen
class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                        'PREMIUM',
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

              const SizedBox(height: 24),

              // Premium benefits
              const Text(
                '👑',
                style: TextStyle(fontSize: 60),
              ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
              const SizedBox(height: 16),
              const Text(
                'Go Premium',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Remove ads & get daily bonuses!',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 32),

              // Benefits list
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: const [
                    _BenefitItem(
                      icon: '🚫',
                      text: 'No advertisements',
                    ),
                    _BenefitItem(
                      icon: '❤️',
                      text: '1 free life every hour',
                    ),
                    _BenefitItem(
                      icon: '💎',
                      text: '3x daily gem bonus',
                    ),
                    _BenefitItem(
                      icon: '🎁',
                      text: '10 free boosters per week',
                    ),
                    _BenefitItem(
                      icon: '🎨',
                      text: 'Exclusive themes',
                    ),
                  ],
                ),
              ),

              // Plans
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _SubscriptionPlan(
                      name: 'Weekly',
                      price: 1.99,
                      badge: null,
                    ),
                    const SizedBox(height: 12),
                    _SubscriptionPlan(
                      name: 'Monthly',
                      price: 5.99,
                      badge: 'POPULAR',
                    ),
                    const SizedBox(height: 12),
                    _SubscriptionPlan(
                      name: 'Yearly',
                      price: 39.99,
                      badge: 'BEST VALUE',
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

class _BenefitItem extends StatelessWidget {
  final String icon;
  final String text;

  const _BenefitItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 16),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionPlan extends StatelessWidget {
  final String name;
  final double price;
  final String? badge;

  const _SubscriptionPlan({
    required this.name,
    required this.price,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.glassWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: badge != null
                  ? AppColors.sakuraPink
                  : AppColors.textSecondary.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '\$$price',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.sakuraPink,
                ),
              ),
            ],
          ),
        ),
        if (badge != null)
          Positioned(
            top: 0,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.sakuraPink,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badge!,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}