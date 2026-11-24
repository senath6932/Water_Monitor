import 'package:flutter/material.dart';

enum ThemePreset {
  ocean,
  emerald,
  sunset,
  midnight,
}

class ThemeOption {
  const ThemeOption({
    required this.preset,
    required this.name,
    required this.subtitle,
    required this.seedColor,
    required this.accentColor,
  });

  final ThemePreset preset;
  final String name;
  final String subtitle;
  final Color seedColor;
  final Color accentColor;
}

class ThemeService extends ChangeNotifier {
  ThemeService._();

  static final ThemeService instance = ThemeService._();

  final List<ThemeOption> options = const [
    ThemeOption(
      preset: ThemePreset.ocean,
      name: 'Ocean Teal',
      subtitle: 'Cool blue-green clarity',
      seedColor: Color(0xFF0EA5E9),
      accentColor: Color(0xFF38BDF8),
    ),
    ThemeOption(
      preset: ThemePreset.emerald,
      name: 'Emerald Tide',
      subtitle: 'Fresh green energy',
      seedColor: Color(0xFF10B981),
      accentColor: Color(0xFF22C55E),
    ),
    ThemeOption(
      preset: ThemePreset.sunset,
      name: 'Sunset Coral',
      subtitle: 'Warm amber-coral glow',
      seedColor: Color(0xFFF97316),
      accentColor: Color(0xFFF59E0B),
    ),
    ThemeOption(
      preset: ThemePreset.midnight,
      name: 'Midnight Lagoon',
      subtitle: 'Deep indigo calm',
      seedColor: Color(0xFF6366F1),
      accentColor: Color(0xFFA78BFA),
    ),
  ];

  ThemePreset _selectedPreset = ThemePreset.ocean;

  ThemePreset get selectedPreset => _selectedPreset;

  ThemeOption get selectedOption =>
      options.firstWhere((option) => option.preset == _selectedPreset);

  ThemeData get lightTheme => _buildTheme(Brightness.light);
  ThemeData get darkTheme => _buildTheme(Brightness.dark);
  ThemeMode get themeMode => ThemeMode.dark;

  void selectTheme(ThemePreset preset) {
    if (_selectedPreset == preset) return;
    _selectedPreset = preset;
    notifyListeners();
  }

  ThemeOption optionFor(ThemePreset preset) {
    return options.firstWhere((option) => option.preset == preset);
  }

  ThemeData _buildTheme(Brightness brightness) {
    final option = selectedOption;
    final scheme = ColorScheme.fromSeed(
      seedColor: option.seedColor,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          brightness == Brightness.dark ? Colors.transparent : scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: brightness == Brightness.dark ? Colors.white : scheme.onSurface,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor:
            brightness == Brightness.dark ? const Color(0xFF0A2F4D) : scheme.surface,
        contentTextStyle: TextStyle(
          color: brightness == Brightness.dark ? Colors.white : scheme.onSurface,
        ),
      ),
    );
  }
}
