import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/team_colors.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/driver_detail_model.dart';
import '../../providers/driver_detail_provider.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/section_header.dart';

class DriverDetailScreen extends StatelessWidget {
  const DriverDetailScreen({
    super.key,
    required this.driverId,
    required this.driverNumber,
    required this.driverName,
    required this.constructorId,
  });

  final String driverId;
  final int driverNumber;
  final String driverName;
  final String constructorId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _DriverDetailBody(
        driverId: driverId,
        driverNumber: driverNumber,
        driverName: driverName,
        constructorId: constructorId,
      ),
    );
  }
}

class _DriverDetailBody extends ConsumerWidget {
  const _DriverDetailBody({
    required this.driverId,
    required this.driverNumber,
    required this.driverName,
    required this.constructorId,
  });

  final String driverId;
  final int driverNumber;
  final String driverName;
  final String constructorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = '$driverId:$driverNumber';
    final detailAsync = ref.watch(driverDetailProvider(key));
    final teamTheme = TeamColors.forConstructorId(constructorId);
    final accent = teamTheme.accentColor;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header with driver photo
        SliverAppBar(
          pinned: true,
          expandedHeight: 280,
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: _DriverHeroBanner(
              driverName: driverName,
              driverNumber: driverNumber,
              accent: accent,
              detailAsync: detailAsync,
            ),
          ),
        ),

        // Content
        detailAsync.when(
          loading: () => const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryContainer,
                strokeWidth: 2,
              ),
            ),
          ),
          error: (e, _) => SliverFillRemaining(
            child: Center(
              child: Text('Error: $e', style: AppTextStyles.bodySmall),
            ),
          ),
          data: (detail) => SliverList(
            delegate: SliverChildListDelegate([
              // Driver info bar
              _DriverInfoBar(detail: detail, accent: accent),

              const SizedBox(height: 20),

              // Career Stats grid
              const SectionHeader(
                label: 'Career Stats',
                padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
              ),
              _CareerStatsGrid(detail: detail, accent: accent),

              const SizedBox(height: 24),

              // Career details row
              _CareerDetailsCard(detail: detail),

              const SizedBox(height: 24),

              // Championship history
              const SectionHeader(
                label: 'Championship History',
                padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
              ),
              _ChampionshipHistory(
                  standings: detail.seasonStandings, accent: accent),

              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }
}

// ─── Hero Banner ──────────────────────────────────────────────────────────────

class _DriverHeroBanner extends StatelessWidget {
  const _DriverHeroBanner({
    required this.driverName,
    required this.driverNumber,
    required this.accent,
    required this.detailAsync,
  });

  final String driverName;
  final int driverNumber;
  final Color accent;
  final AsyncValue<DriverDetailModel> detailAsync;

  @override
  Widget build(BuildContext context) {
    final headshotUrl = detailAsync.valueOrNull?.headshotUrl;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            accent.withValues(alpha: 0.3),
            AppColors.background,
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Ghost number background
          Positioned(
            right: -20,
            bottom: -30,
            child: Text(
              '$driverNumber',
              style: TextStyle(
                fontSize: 200,
                fontWeight: FontWeight.w900,
                color: accent.withValues(alpha: 0.08),
                height: 1,
              ),
            ),
          ),
          // Headshot
          if (headshotUrl != null)
            Positioned(
              right: 0,
              bottom: 0,
              child: CachedNetworkImage(
                imageUrl: headshotUrl,
                height: 240,
                fit: BoxFit.contain,
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          // Bottom gradient for text legibility
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 100,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.background.withValues(alpha: 0.9),
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ),
          // Name overlay
          Positioned(
            left: 20,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#$driverNumber',
                  style: AppTextStyles.labelBold.copyWith(
                    color: accent,
                    fontSize: 14,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  driverName.toUpperCase(),
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontSize: 24,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Info Bar ─────────────────────────────────────────────────────────────────

class _DriverInfoBar extends StatelessWidget {
  const _DriverInfoBar({required this.detail, required this.accent});

  final DriverDetailModel detail;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            detail.seasonStandings.isNotEmpty
                ? detail.seasonStandings.first.constructorName
                : '',
            style: AppTextStyles.bodyMedium.copyWith(
              color: accent,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (detail.nationality.isNotEmpty)
            Text(
              detail.nationality,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.tertiaryContainer,
              ),
            ),
          if (detail.age != null) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surfaceHigh,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${detail.age} yrs',
                style: AppTextStyles.labelBold.copyWith(
                  fontSize: 11,
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Career Stats Grid ────────────────────────────────────────────────────────

class _CareerStatsGrid extends StatelessWidget {
  const _CareerStatsGrid({required this.detail, required this.accent});

  final DriverDetailModel detail;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _StatCard(
            value: '${detail.championships}',
            label: 'WDC',
            accent: detail.championships > 0 ? const Color(0xFFFFD700) : null,
          ),
          const SizedBox(width: 10),
          _StatCard(
            value: '${detail.careerWins}',
            label: 'WINS',
          ),
          const SizedBox(width: 10),
          _StatCard(
            value: '${detail.totalSeasons}',
            label: 'SEASONS',
          ),
          const SizedBox(width: 10),
          _StatCard(
            value: detail.careerPoints.toStringAsFixed(0),
            label: 'POINTS',
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    this.accent,
  });

  final String value;
  final String label;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.headlineMedium.copyWith(
                fontSize: 24,
                color: accent ?? Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 9,
                color: AppColors.tertiaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Career Details Card ──────────────────────────────────────────────────────

class _CareerDetailsCard extends StatelessWidget {
  const _CareerDetailsCard({required this.detail});

  final DriverDetailModel detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (detail.debutYear != null)
              _DetailRow(
                label: 'F1 DEBUT',
                value: detail.debutYear!,
              ),
            if (detail.debutTeam != null) ...[
              const SizedBox(height: 10),
              _DetailRow(
                label: 'DEBUT TEAM',
                value: detail.debutTeam!,
              ),
            ],
            if (detail.dateOfBirth != null) ...[
              const SizedBox(height: 10),
              _DetailRow(
                label: 'DATE OF BIRTH',
                value:
                    '${detail.dateOfBirth!.day}/${detail.dateOfBirth!.month}/${detail.dateOfBirth!.year}',
              ),
            ],
            const SizedBox(height: 10),
            _DetailRow(
              label: 'CAREER POINTS',
              value: detail.careerPoints.toStringAsFixed(0),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(fontSize: 9),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

// ─── Championship History ─────────────────────────────────────────────────────

class _ChampionshipHistory extends StatelessWidget {
  const _ChampionshipHistory({
    required this.standings,
    required this.accent,
  });

  final List<SeasonStanding> standings;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: standings.map((s) {
          final isChampion = s.position == 1;
          final teamTheme = TeamColors.forConstructorId(s.constructorId);

          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 3,
                      color: teamTheme.accentColor,
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isChampion
                              ? const Color(0xFFFFD700).withValues(alpha: 0.06)
                              : AppColors.surface,
                          border: Border.all(
                            color: isChampion
                                ? const Color(0xFFFFD700).withValues(alpha: 0.2)
                                : AppColors.glassBorder,
                            width: 1,
                          ),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Season year
                            SizedBox(
                              width: 42,
                              child: Text(
                                s.season,
                                style: AppTextStyles.labelBold.copyWith(
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            // Position badge
                            Container(
                              width: 28,
                              height: 24,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isChampion
                                    ? const Color(0xFFFFD700)
                                    : AppColors.surfaceHigh,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                'P${s.position}',
                                style: AppTextStyles.labelBold.copyWith(
                                  fontSize: 10,
                                  color: isChampion
                                      ? Colors.black
                                      : AppColors.tertiaryContainer,
                                ),
                              ),
                            ),
                            if (isChampion) ...[
                              const SizedBox(width: 4),
                              const Text('★',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFFFD700))),
                            ],
                            const SizedBox(width: 10),
                            // Constructor
                            Expanded(
                              child: Text(
                                s.constructorName,
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontSize: 11,
                                  color: AppColors.tertiaryContainer,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Wins
                            if (s.wins > 0) ...[
                              Text(
                                '${s.wins}W',
                                style: AppTextStyles.labelBold.copyWith(
                                  fontSize: 10,
                                  color: Colors.white54,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            // Points
                            Text(
                              '${s.points.toStringAsFixed(0)} pts',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
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
        }).toList(),
      ),
    );
  }
}
