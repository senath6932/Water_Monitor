import 'dart:async';
import 'dart:ui';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../models/water_data.dart';
import '../models/user_settings.dart';
import '../services/context_engine.dart';
import '../services/firebase_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final ContextEngine _contextEngine = ContextEngine();
  final DatabaseReference _waterRef = FirebaseDatabase.instance.ref('water');

  StreamSubscription<DatabaseEvent>? _subscription;
  StreamSubscription<UserSettings>? _settingsSubscription;

  double flowRate = 0;
  double totalUsage = 0;
  double dailyUsage = 0;
  bool leakDetected = false;
  UserSettings userSettings = UserSettings(
    householdSize: 1,
    monthlyTarget: 4000,
    sleepStart: 0,
    sleepEnd: 5,
  );
  int lastUpdated = 0;

  @override
  void initState() {
    super.initState();

    _subscription = _waterRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data == null || !mounted) return;

      final water = WaterData.fromMap(Map<String, dynamic>.from(data as Map));

      setState(() {
        flowRate = water.flowRate;
        totalUsage = water.totalUsage;
        dailyUsage = water.dailyUsage;
        leakDetected = water.leakDetected;
        lastUpdated = water.lastUpdated;
      });
      _evaluateContext();
    });

    _settingsSubscription = _firebaseService.watchSettings().listen((settings) {
      if (!mounted) return;

      setState(() {
        userSettings = settings;
      });

      _evaluateContext();
    });
  }

  void _evaluateContext() {
    unawaited(
      _contextEngine
          .evaluateContext(
            water: WaterData(
              flowRate: flowRate,
              totalUsage: totalUsage,
              dailyUsage: dailyUsage,
              leakDetected: leakDetected,
              lastUpdated: lastUpdated,
            ),
            settings: userSettings,
          )
          .catchError((_) {}),
    );
  }

  double get monthlyProgress {
    if (monthlyTarget <= 0) return 0;

    return (totalUsage / monthlyTarget).clamp(0.0, 1.0);
  }

  double get monthlyTarget => userSettings.monthlyTarget;

  String _getInsight(WaterData data) {
    if (data.leakDetected) {
      return '🚨 Possible leak detected.';
    }

    final dateTime = _toDateTime(data.lastUpdated);
    if (ContextEngine.isWithinSleepHours(
          dateTime.hour,
          userSettings.sleepStart,
          userSettings.sleepEnd,
        ) &&
        data.flowRate > 1.0) {
      return '🌙 Unexpected water usage during sleeping hours.';
    }

    if (data.totalUsage > monthlyTarget) {
      return '⚠️ Monthly water target exceeded.';
    }

    return '✅ System healthy and stable.';
  }

  DateTime _toDateTime(int timestamp) {
    if (timestamp <= 0) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    final milliseconds = timestamp < 1000000000000
        ? timestamp * 1000
        : timestamp;
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _settingsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final flowProgress = (flowRate / 20).clamp(0.0, 1.0);
    final bottomPadding = MediaQuery.of(context).padding.bottom + 120;
    final currentData = WaterData(
      flowRate: flowRate,
      totalUsage: totalUsage,
      dailyUsage: dailyUsage,
      leakDetected: leakDetected,
      lastUpdated: lastUpdated,
    );
    final insight = _getInsight(currentData);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          'Water Monitor',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.2),
        ),
      ),
      body: Stack(
        children: [
          const _WaterBackdrop(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeroGlassCard(
                    flowRate: flowRate,
                    flowProgress: flowProgress,
                    leakDetected: leakDetected,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _GlassMetricCard(
                          title: 'Total Usage',
                          value: '${totalUsage.toStringAsFixed(1)} L',
                          subtitle: 'All-time consumption',
                          icon: Icons.opacity_rounded,
                          accent: const Color(0xFF38BDF8),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _GlassMetricCard(
                          title: 'Daily Usage',
                          value: '${dailyUsage.toStringAsFixed(1)} L',
                          subtitle: 'Today so far',
                          icon: Icons.today_rounded,
                          accent: const Color(0xFF22C55E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _MonthlyGoalCard(
                    currentUsage: totalUsage,
                    monthlyTarget: monthlyTarget,
                    progress: monthlyProgress,
                  ),
                  const SizedBox(height: 12),
                  _GlassMetricCard(
                    title: 'Leak Status',
                    value: leakDetected ? 'Leak Detected' : 'System Normal',
                    subtitle: leakDetected
                        ? 'Please check your lines and valves immediately.'
                        : 'No leak indicators are active right now.',
                    icon: leakDetected
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle_rounded,
                    accent: leakDetected
                        ? const Color(0xFFF97316)
                        : const Color(0xFF06B6D4),
                    wide: true,
                  ),
                  const SizedBox(height: 16),
                  _SectionHeader(
                    title: 'Water Pulse',
                    subtitle: 'A quick view of the current system rhythm',
                    accent: scheme.primary,
                  ),
                  const SizedBox(height: 12),
                  _PulseGraph(
                    flowRate: flowRate,
                    accent: leakDetected
                        ? const Color(0xFFF97316)
                        : const Color(0xFF38BDF8),
                  ),
                  const SizedBox(height: 16),
                  _SectionHeader(
                    title: 'Live Notes',
                    subtitle: 'Context around the latest sensor reading',
                    accent: scheme.primary,
                  ),
                  const SizedBox(height: 12),
                  _GlassInfoTile(
                    icon: Icons.water_drop_rounded,
                    title: 'Flow rate',
                    value: '${flowRate.toStringAsFixed(2)} L/min',
                    trailing: 'Live',
                  ),
                  const SizedBox(height: 10),
                  _GlassInfoTile(
                    icon: Icons.bubble_chart_rounded,
                    title: 'System state',
                    value: insight,
                    trailing: leakDetected ? 'Alert' : 'Normal',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterBackdrop extends StatelessWidget {
  const _WaterBackdrop();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF061C2E),
              const Color(0xFF0A3D62),
              const Color(0xFF0E7490).withOpacity(0.88),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            const _GlowCircle(
              alignment: Alignment.topRight,
              size: 240,
              color: Color(0xFF38BDF8),
            ),
            const _GlowCircle(
              alignment: Alignment.bottomLeft,
              size: 220,
              color: Color(0xFF22C55E),
            ),
            Positioned(
              left: -90,
              top: 120,
              child: _WaveBlob(
                size: 220,
                color: const Color(0xFF7DD3FC).withOpacity(0.18),
              ),
            ),
            Positioned(
              right: -50,
              bottom: 140,
              child: _WaveBlob(
                size: 180,
                color: const Color(0xFF06B6D4).withOpacity(0.16),
              ),
            ),
            const _WaterRidge(),
          ],
        ),
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({
    required this.alignment,
    required this.size,
    required this.color,
  });

  final Alignment alignment;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withOpacity(0.35), Colors.transparent],
          ),
        ),
      ),
    );
  }
}

class _WaveBlob extends StatelessWidget {
  const _WaveBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _WaterRidge extends StatelessWidget {
  const _WaterRidge();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF0E7490).withOpacity(0.18),
              const Color(0xFF0A3D62).withOpacity(0.02),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }
}

class _HeroGlassCard extends StatelessWidget {
  const _HeroGlassCard({
    required this.flowRate,
    required this.flowProgress,
    required this.leakDetected,
  });

  final double flowRate;
  final double flowProgress;
  final bool leakDetected;

  @override
  Widget build(BuildContext context) {
    return _GlassShell(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hydration radar',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white.withOpacity(0.72),
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${flowRate.toStringAsFixed(2)} L/min',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        height: 0.95,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _FlowDial(
                progress: flowProgress,
                accent: leakDetected
                    ? const Color(0xFFF97316)
                    : const Color(0xFF38BDF8),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _StatusChip(
                icon: leakDetected
                    ? Icons.warning_amber_rounded
                    : Icons.water_drop_rounded,
                label: leakDetected ? 'Leak active' : 'Flow stable',
                color: leakDetected
                    ? const Color(0xFFF97316)
                    : const Color(0xFF22C55E),
              ),
              const SizedBox(width: 10),
              _StatusChip(
                icon: Icons.timelapse_rounded,
                label: 'Realtime',
                color: const Color(0xFF38BDF8),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FlowDial extends StatelessWidget {
  const _FlowDial({required this.progress, required this.accent});

  final double progress;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: progress),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return SizedBox(
          width: 104,
          height: 104,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: 10,
                  backgroundColor: Colors.white.withOpacity(0.10),
                  valueColor: AlwaysStoppedAnimation<Color>(accent),
                ),
              ),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                  border: Border.all(color: Colors.white.withOpacity(0.20)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(value * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'flow',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent,
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.5),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.72),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GlassMetricCard extends StatelessWidget {
  const _GlassMetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accent,
    this.wide = false,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return _GlassShell(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: wide ? double.infinity : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [accent.withOpacity(0.5), accent.withOpacity(0.12)],
                ),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white.withOpacity(0.72),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.68),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthlyGoalCard extends StatelessWidget {
  const _MonthlyGoalCard({
    required this.currentUsage,
    required this.monthlyTarget,
    required this.progress,
  });

  final double currentUsage;
  final double monthlyTarget;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final progressPercent = (progress * 100).round();

    return _GlassShell(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Goal',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white.withOpacity(0.72),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${currentUsage.toStringAsFixed(0)} L / ${monthlyTarget.toStringAsFixed(0)} L',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$progressPercent%',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.78),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.12),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF38BDF8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassInfoTile extends StatelessWidget {
  const _GlassInfoTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String value;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return _GlassShell(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.10),
              border: Border.all(color: Colors.white.withOpacity(0.16)),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white.withOpacity(0.72),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Text(
            trailing,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white.withOpacity(0.68),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white.withOpacity(0.82),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassShell extends StatelessWidget {
  const _GlassShell({required this.child, required this.padding});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.white.withOpacity(0.11),
            border: Border.all(color: Colors.white.withOpacity(0.16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _PulseGraph extends StatelessWidget {
  const _PulseGraph({required this.flowRate, required this.accent});

  final double flowRate;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final bars = List<double>.generate(10, (index) {
      final base = 0.25 + ((index % 3) * 0.12);
      final flowImpact = (flowRate / 20).clamp(0.0, 1.0) * 0.55;
      return (base + flowImpact).clamp(0.18, 1.0);
    });

    return _GlassShell(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current pulse',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Live',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 110,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(bars.length, (index) {
                final heightFactor = bars[index];
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 420 + (index * 40)),
                      curve: Curves.easeOutCubic,
                      height: 110 * heightFactor,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(99),
                        gradient: LinearGradient(
                          colors: [
                            accent.withOpacity(0.95),
                            accent.withOpacity(0.25),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withOpacity(0.28),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}








