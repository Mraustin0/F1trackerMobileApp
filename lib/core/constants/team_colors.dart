import 'package:flutter/material.dart';
import '../theme/team_theme_extension.dart';

class TeamColors {
  TeamColors._();

  static const Map<String, TeamTheme> themes = {
    '': TeamTheme(
      accentColor: Color(0xFFFF553D),
      accentColorDark: Color(0xFFBE0E00),
      teamName: '',
    ),
    'red_bull': TeamTheme(
      accentColor: Color(0xFF3671C6),
      accentColorDark: Color(0xFFCC1E4A),
      teamName: 'Red Bull Racing',
    ),
    'ferrari': TeamTheme(
      accentColor: Color(0xFFE8002D),
      accentColorDark: Color(0xFFB30024),
      teamName: 'Ferrari',
    ),
    'mercedes': TeamTheme(
      accentColor: Color(0xFF27F4D2),
      accentColorDark: Color(0xFF00A19C),
      teamName: 'Mercedes',
    ),
    'mclaren': TeamTheme(
      accentColor: Color(0xFFFF8000),
      accentColorDark: Color(0xFFCC6600),
      teamName: 'McLaren',
    ),
    'aston_martin': TeamTheme(
      accentColor: Color(0xFF358C75),
      accentColorDark: Color(0xFF236B57),
      teamName: 'Aston Martin',
    ),
    'alpine': TeamTheme(
      accentColor: Color(0xFF0093CC),
      accentColorDark: Color(0xFF006FA3),
      teamName: 'Alpine',
    ),
    'williams': TeamTheme(
      accentColor: Color(0xFF64C4FF),
      accentColorDark: Color(0xFF0057A0),
      teamName: 'Williams',
    ),
    'haas': TeamTheme(
      accentColor: Color(0xFFB6BABD),
      accentColorDark: Color(0xFF767676),
      teamName: 'Haas F1 Team',
    ),
    'rb': TeamTheme(
      accentColor: Color(0xFF6692FF),
      accentColorDark: Color(0xFF3355CC),
      teamName: 'RB',
    ),
    'sauber': TeamTheme(
      accentColor: Color(0xFF52E252),
      accentColorDark: Color(0xFF1B9E1B),
      teamName: 'Stake F1 / Sauber',
    ),
  };

  // Map constructor ID (from API) to theme key
  static const Map<String, String> constructorIdToKey = {
    'red_bull': 'red_bull',
    'ferrari': 'ferrari',
    'mercedes': 'mercedes',
    'mclaren': 'mclaren',
    'aston_martin': 'aston_martin',
    'alpine': 'alpine',
    'williams': 'williams',
    'haas': 'haas',
    'rb': 'rb',
    'sauber': 'sauber',
    'kick_sauber': 'sauber',
    'alphatauri': 'rb',
  };

  static TeamTheme forConstructorId(String id) {
    final key = constructorIdToKey[id.toLowerCase()] ?? '';
    return themes[key] ?? themes['']!;
  }
}
