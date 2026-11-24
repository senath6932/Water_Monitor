import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/user_settings.dart';
import '../services/firebase_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _monthlyTargetController =
      TextEditingController();

  static const List<int> _sleepHourOptions = <int>[22, 23, 0, 1, 2, 3, 4, 5, 6];

  bool _initialized = false;
  int _householdSize = 1;
  int _sleepStart = 22;
  int _sleepEnd = 5;

  @override
  void dispose() {
    _monthlyTargetController.dispose();
    super.dispose();
  }

  void _syncControllers(UserSettings settings) {
    if (_initialized) return;

    _householdSize = settings.householdSize;
    _monthlyTargetController.text = settings.monthlyTarget.toStringAsFixed(0);
    _sleepStart = _normalizeSleepHour(settings.sleepStart);
    _sleepEnd = _normalizeSleepHour(settings.sleepEnd);
    _initialized = true;
  }

  int _normalizeSleepHour(int value) {
    if (_sleepHourOptions.contains(value)) {
      return value;
    }

    final normalized = value % 24;
    if (_sleepHourOptions.contains(normalized)) {
      return normalized;
    }

    return _sleepHourOptions.first;
  }

  String formatHour(int hour) {
    final normalizedHour = hour % 24;
    final period = normalizedHour < 12 ? 'AM' : 'PM';
    final displayHour = normalizedHour % 12 == 0 ? 12 : normalizedHour % 12;
    return '$displayHour:00 $period';
  }

  List<DropdownMenuItem<int>> _hourItems() {
    return _sleepHourOptions
        .map(
          (hour) => DropdownMenuItem<int>(
            value: hour,
            child: Text(formatHour(hour)),
          ),
        )
        .toList();
  }

  Future<void> _saveSettings(UserSettings current) async {
    if (!_formKey.currentState!.validate()) return;

    final updated = UserSettings(
      householdSize: _householdSize,
      monthlyTarget:
          double.tryParse(_monthlyTargetController.text.trim()) ??
          current.monthlyTarget,
      sleepStart: _sleepStart,
      sleepEnd: _sleepEnd,
      notificationsEnabled: current.notificationsEnabled,
    );

    await _firebaseService.updateSettings(updated);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Stack(
        children: [
          const _SettingsBackdrop(),
          SafeArea(
            child: StreamBuilder<UserSettings>(
              stream: _firebaseService.watchSettings(),
              builder: (context, snapshot) {
                final settings = snapshot.data ?? UserSettings();
                _syncControllers(settings);

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _GlassShell(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                DropdownButtonFormField<int>(
                                  value: _householdSize,
                                  dropdownColor: const Color(0xFF0A2F4D),
                                  decoration: _fieldDecoration(
                                    context,
                                    'Household size',
                                  ),
                                  items: List.generate(10, (index) {
                                    final value = index + 1;
                                    return DropdownMenuItem<int>(
                                      value: value,
                                      child: Text(
                                        '$value',
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  }),
                                  onChanged: (value) {
                                    if (value == null) return;
                                    setState(() => _householdSize = value);
                                  },
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _monthlyTargetController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _fieldDecoration(
                                    context,
                                    'Monthly target (L)',
                                  ),
                                  validator: (value) {
                                    final parsed = double.tryParse(
                                      value?.trim() ?? '',
                                    );
                                    if (parsed == null || parsed <= 0) {
                                      return 'Enter a valid monthly target';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 12),
                                _buildSleepSchedule(context),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _GlassButton(
                          icon: Icons.save_rounded,
                          label: 'Save Settings',
                          accent: const Color(0xFF38BDF8),
                          onTap: () => _saveSettings(settings),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepSchedule(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sleep Schedule',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<int>(
          value: _sleepStart,
          isExpanded: true,
          dropdownColor: const Color(0xFF0A2F4D),
          decoration: _fieldDecoration(context, 'Sleep starts'),
          items: _hourItems(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _sleepStart = value);
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          value: _sleepEnd,
          isExpanded: true,
          dropdownColor: const Color(0xFF0A2F4D),
          decoration: _fieldDecoration(context, 'Wake up'),
          items: _hourItems(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _sleepEnd = value);
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Water usage detected during this period will trigger Night-time Usage alerts.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
        ),
      ],
    );
  }

  InputDecoration _fieldDecoration(BuildContext context, String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.72)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.08),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.14)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.14)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        borderSide: BorderSide(color: Color(0xFF38BDF8)),
      ),
    );
  }
}

class _SettingsBackdrop extends StatelessWidget {
  const _SettingsBackdrop();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF04111D),
              const Color(0xFF0A2F4D),
              const Color(0xFF0E7490).withOpacity(0.82),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.icon,
    required this.label,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: accent.withOpacity(0.16),
            border: Border.all(color: accent.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassShell extends StatelessWidget {
  const _GlassShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.white.withOpacity(0.11),
            border: Border.all(color: Colors.white.withOpacity(0.16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
