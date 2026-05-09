import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/team_colors.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/team_theme_extension.dart';
import '../../data/models/constructor_standing_model.dart';
import '../../data/models/driver_standing_model.dart';
import '../../providers/standings_provider.dart';

import '../../shared/widgets/shimmer_card.dart';
import '../../shared/widgets/staggered_list.dart';

class StandingsScreen extends ConsumerStatefulWidget {
  const StandingsScreen({super.key});

  @override
  ConsumerState<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends ConsumerState<StandingsScreen>
    with SingleTickerProviderStateMixin {
  bool _showDrivers = true;
  late AnimationController _toggleController;

  @override
  void initState() {
    super.initState();
    _toggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _toggleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teamTheme =
        Theme.of(context).extension<TeamTheme>() ?? TeamTheme.defaultTheme;
    final accentColor = teamTheme.accentColor;

    final driversAsync = ref.watch(driverStandingsProvider);
    final constructorsAsync = ref.watch(constructorStandingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: accentColor,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          if (_showDrivers) {
            ref.invalidate(driverStandingsProvider);
            await ref.read(driverStandingsProvider.future);
          } else {
            ref.invalidate(constructorStandingsProvider);
            await ref.read(constructorStandingsProvider.future);
          }
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
          // AppBar
          SliverAppBar(
            pinned: true,
            expandedHeight: 64,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              title: Text(
                'STANDINGS',
                style: AppTextStyles.headlineMedium.copyWith(fontSize: 22),
              ),
            ),
          ),

          // Toggle
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: _StandingsToggle(
                showDrivers: _showDrivers,
                accentColor: accentColor,
                onToggle: (drivers) {
                  setState(() => _showDrivers = drivers);
                },
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: child,
              ),
              child: _showDrivers
                  ? KeyedSubtree(
                      key: const ValueKey('drivers'),
                      child: driversAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: ShimmerList(itemCount: 10, itemHeight: 64),
                        ),
                        error: (e, _) => _ErrorWidget(
                          message: 'Failed to load driver standings',
                          onRetry: () => ref.invalidate(driverStandingsProvider),
                        ),
                        data: (drivers) => _DriversContent(drivers: drivers),
                      ),
                    )
                  : KeyedSubtree(
                      key: const ValueKey('constructors'),
                      child: constructorsAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: ShimmerList(itemCount: 10, itemHeight: 64),
                        ),
                        error: (e, _) => _ErrorWidget(
                          message: 'Failed to load constructor standings',
                          onRetry: () => ref.invalidate(constructorStandingsProvider),
                        ),
                        data: (constructors) =>
                            _ConstructorsContent(constructors: constructors),
                      ),
                    ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _StandingsToggle extends StatelessWidget {
  const _StandingsToggle({
    required this.showDrivers,
    required this.accentColor,
    required this.onToggle,
  });

  final bool showDrivers;
  final Color accentColor;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.glassBorder, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
              child: _ToggleOption(
            label: 'DRIVERS',
            isActive: showDrivers,
            accentColor: accentColor,
            onTap: () => onToggle(true),
          )),
          Expanded(
              child: _ToggleOption(
            label: 'CONSTRUCTORS',
            isActive: !showDrivers,
            accentColor: accentColor,
            onTap: () => onToggle(false),
          )),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  const _ToggleOption({
    required this.label,
    required this.isActive,
    required this.accentColor,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.labelBold.copyWith(
            color: isActive ? Colors.white : AppColors.tertiaryContainer,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

// ---- DRIVERS CONTENT ----

class _DriversContent extends StatelessWidget {
  const _DriversContent({required this.drivers});

  final List<DriverStandingModel> drivers;

  @override
  Widget build(BuildContext context) {
    if (drivers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: Text('No standings data available')),
      );
    }

    final top3 = drivers.take(3).toList();
    final rest = drivers.length > 3 ? drivers.sublist(3) : <DriverStandingModel>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Podium
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: _DriverPodium(top3: top3),
        ),

        // Rest of standings with staggered animation
        if (rest.isNotEmpty) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: StaggeredList(
              delayMs: 40,
              children: rest.map((d) => _DriverRow(driver: d)).toList(),
            ),
          ),
        ],

        const SizedBox(height: 100),
      ],
    );
  }
}

class _DriverPodium extends StatelessWidget {
  const _DriverPodium({required this.top3});

  final List<DriverStandingModel> top3;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // P1 full width
        if (top3.isNotEmpty) _DriverPodiumCard(driver: top3[0], isFirst: true),
        const SizedBox(height: 10),

        // P2 and P3 side by side
        if (top3.length >= 2)
          Row(
            children: [
              Expanded(
                  child: _DriverPodiumCard(
                      driver: top3[1], isFirst: false)),
              const SizedBox(width: 10),
              if (top3.length >= 3)
                Expanded(
                    child: _DriverPodiumCard(
                        driver: top3[2], isFirst: false)),
            ],
          ),
      ],
    );
  }
}

class _DriverPodiumCard extends StatelessWidget {
  const _DriverPodiumCard({
    required this.driver,
    required this.isFirst,
  });

  final DriverStandingModel driver;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final teamTheme = TeamColors.forConstructorId(driver.constructorId);
    final accentColor = teamTheme.accentColor;

    return GestureDetector(
      onTap: () => context.push('/driver/${driver.driverId}', extra: {
        'driverNumber': driver.permanentNumber,
        'driverName': driver.fullName,
        'constructorId': driver.constructorId,
      }),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border.fromBorderSide(
                BorderSide(color: AppColors.glassBorder)),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 3, color: accentColor),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned(
                        right: -8,
                        top: -8,
                        child: Text(
                          driver.position.toString(),
                          style: AppTextStyles.rankXL.copyWith(
                            fontSize: isFirst ? 80 : 60,
                            color: AppColors.surfaceHigh,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _PositionBadge(
                                    position: driver.position,
                                    accentColor: accentColor),
                                if (driver.wins > 0) ...[
                                  const SizedBox(width: 8),
                                  _Badge(
                                      label: '${driver.wins} WIN${driver.wins > 1 ? 'S' : ''}',
                                      color: const Color(0xFFFFD700)),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              driver.familyName.toUpperCase(),
                              style: AppTextStyles.headlineLarge.copyWith(
                                fontSize: isFirst ? 26 : 18,
                              ),
                            ),
                            Text(
                              driver.givenName,
                              style: AppTextStyles.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              driver.constructorName,
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: accentColor),
                            ),
                            const SizedBox(height: 12),
                            if (isFirst) ...[
                              Text(
                                'CHAMPIONSHIP POINTS',
                                style:
                                    AppTextStyles.labelSmall.copyWith(fontSize: 8),
                              ),
                              const SizedBox(height: 2),
                            ],
                            Text(
                              driver.points
                                  .toStringAsFixed(driver.points % 1 == 0 ? 0 : 1),
                              style: AppTextStyles.rankXL.copyWith(
                                fontSize: isFirst ? 48 : 32,
                                color: accentColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PositionBadge extends StatelessWidget {
  const _PositionBadge({required this.position, required this.accentColor});

  final int position;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: accentColor.withValues(alpha: 0.4), width: 1),
      ),
      child: Center(
        child: Text(
          'P$position',
          style: AppTextStyles.labelBold.copyWith(
            color: accentColor,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontSize: 7,
        ),
      ),
    );
  }
}

class _DriverRow extends StatelessWidget {
  const _DriverRow({required this.driver});

  final DriverStandingModel driver;

  @override
  Widget build(BuildContext context) {
    final teamTheme = TeamColors.forConstructorId(driver.constructorId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        onTap: () => context.push('/driver/${driver.driverId}', extra: {
          'driverNumber': driver.permanentNumber,
          'driverName': driver.fullName,
          'constructorId': driver.constructorId,
        }),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border.fromBorderSide(
                  BorderSide(color: AppColors.glassBorder)),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 3, color: teamTheme.accentColor),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 28,
                            child: Text(
                              driver.position.toString(),
                              style: AppTextStyles.rankLarge.copyWith(
                                fontSize: 18,
                                color: AppColors.tertiaryContainer,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  driver.fullName,
                                  style: AppTextStyles.headlineSmall
                                      .copyWith(fontSize: 13),
                                ),
                                Text(
                                  driver.constructorName,
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          if (driver.wins > 0) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${driver.wins}W',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: const Color(0xFFFFD700),
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ],
                          Text(
                            driver.points.toStringAsFixed(
                                driver.points % 1 == 0 ? 0 : 1),
                            style: AppTextStyles.rankLarge.copyWith(
                              fontSize: 20,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text('PTS',
                              style: AppTextStyles.labelSmall
                                  .copyWith(fontSize: 8)),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.tertiaryContainer,
                            size: 18,
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
      ),
    );
  }
}

// ---- CONSTRUCTORS CONTENT ----

class _ConstructorsContent extends StatelessWidget {
  const _ConstructorsContent({required this.constructors});

  final List<ConstructorStandingModel> constructors;

  @override
  Widget build(BuildContext context) {
    if (constructors.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: Text('No standings data available')),
      );
    }

    final top3 = constructors.take(3).toList();
    final rest = constructors.length > 3
        ? constructors.sublist(3)
        : <ConstructorStandingModel>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: _ConstructorPodium(top3: top3),
        ),
        if (rest.isNotEmpty) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: StaggeredList(
              delayMs: 40,
              children: rest.map((c) => _ConstructorRow(constructor: c)).toList(),
            ),
          ),
        ],
        const SizedBox(height: 100),
      ],
    );
  }
}

class _ConstructorPodium extends StatelessWidget {
  const _ConstructorPodium({required this.top3});

  final List<ConstructorStandingModel> top3;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (top3.isNotEmpty)
          _ConstructorPodiumCard(constructor: top3[0], isFirst: true),
        const SizedBox(height: 10),
        if (top3.length >= 2)
          Row(
            children: [
              Expanded(
                  child: _ConstructorPodiumCard(
                      constructor: top3[1], isFirst: false)),
              const SizedBox(width: 10),
              if (top3.length >= 3)
                Expanded(
                    child: _ConstructorPodiumCard(
                        constructor: top3[2], isFirst: false)),
            ],
          ),
      ],
    );
  }
}

class _ConstructorPodiumCard extends StatelessWidget {
  const _ConstructorPodiumCard({
    required this.constructor,
    required this.isFirst,
  });

  final ConstructorStandingModel constructor;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final teamTheme =
        TeamColors.forConstructorId(constructor.constructorId);
    final accentColor = teamTheme.accentColor;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border.fromBorderSide(
              BorderSide(color: AppColors.glassBorder)),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 3, color: accentColor),
              Expanded(
                child: Stack(
                  children: [
                    Positioned(
                      right: -8,
                      top: -8,
                      child: Text(
                        constructor.position.toString(),
                        style: AppTextStyles.rankXL.copyWith(
                          fontSize: isFirst ? 80 : 60,
                          color: AppColors.surfaceHigh,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _PositionBadge(
                                  position: constructor.position,
                                  accentColor: accentColor),
                              if (constructor.wins > 0) ...[
                                const SizedBox(width: 8),
                                _Badge(
                                    label: '${constructor.wins} WIN${constructor.wins > 1 ? 'S' : ''}',
                                    color: const Color(0xFFFFD700)),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            constructor.name.toUpperCase(),
                            style: AppTextStyles.headlineLarge.copyWith(
                              fontSize: isFirst ? 22 : 16,
                            ),
                          ),
                          Text(constructor.nationality,
                              style: AppTextStyles.bodySmall),
                          const SizedBox(height: 12),
                          if (isFirst)
                            Text(
                              'CONSTRUCTOR POINTS',
                              style: AppTextStyles.labelSmall
                                  .copyWith(fontSize: 8),
                            ),
                          Text(
                            constructor.points.toStringAsFixed(
                                constructor.points % 1 == 0 ? 0 : 1),
                            style: AppTextStyles.rankXL.copyWith(
                              fontSize: isFirst ? 48 : 32,
                              color: accentColor,
                            ),
                          ),
                        ],
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

class _ConstructorRow extends StatelessWidget {
  const _ConstructorRow({required this.constructor});

  final ConstructorStandingModel constructor;

  @override
  Widget build(BuildContext context) {
    final teamTheme =
        TeamColors.forConstructorId(constructor.constructorId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border.fromBorderSide(
                BorderSide(color: AppColors.glassBorder)),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 3, color: teamTheme.accentColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 28,
                          child: Text(
                            constructor.position.toString(),
                            style: AppTextStyles.rankLarge.copyWith(
                              fontSize: 18,
                              color: AppColors.tertiaryContainer,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            constructor.name,
                            style: AppTextStyles.headlineSmall
                                .copyWith(fontSize: 13),
                          ),
                        ),
                        Text(
                          constructor.points.toStringAsFixed(
                              constructor.points % 1 == 0 ? 0 : 1),
                          style: AppTextStyles.rankLarge.copyWith(
                            fontSize: 20,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text('PTS',
                            style: AppTextStyles.labelSmall
                                .copyWith(fontSize: 8)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  const _ErrorWidget({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.tertiaryContainer,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.tertiaryContainer,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
