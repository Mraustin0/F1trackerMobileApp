import 'package:flutter/material.dart';
import 'app_colors.dart';

@immutable
class TeamTheme extends ThemeExtension<TeamTheme> {
  const TeamTheme({
    required this.accentColor,
    required this.accentColorDark,
    required this.teamName,
  });

  final Color accentColor;
  final Color accentColorDark;
  final String teamName;

  static const defaultTheme = TeamTheme(
    accentColor: AppColors.primaryContainer,
    accentColorDark: AppColors.appRed,
    teamName: '',
  );

  @override
  TeamTheme copyWith({
    Color? accentColor,
    Color? accentColorDark,
    String? teamName,
  }) {
    return TeamTheme(
      accentColor: accentColor ?? this.accentColor,
      accentColorDark: accentColorDark ?? this.accentColorDark,
      teamName: teamName ?? this.teamName,
    );
  }

  @override
  TeamTheme lerp(TeamTheme? other, double t) {
    if (other is! TeamTheme) return this;
    return TeamTheme(
      accentColor: Color.lerp(accentColor, other.accentColor, t)!,
      accentColorDark: Color.lerp(accentColorDark, other.accentColorDark, t)!,
      teamName: t < 0.5 ? teamName : other.teamName,
    );
  }
}
