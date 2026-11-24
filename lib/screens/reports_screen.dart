import 'dart:math' as math;
import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/water_data.dart';
import '../models/user_settings.dart';
import '../services/firebase_service.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          'Reports & Analytics',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.2),
        ),
      ),
      body: Stack(
        children: [
          const _ReportsBackdrop(),
          SafeArea(
            child: StreamBuilder<UserSettings>(
              stream: FirebaseService().watchSettings(),
              builder: (context, settingsSnapshot) {
                final userSettings = settingsSnapshot.data ?? UserSettings();
                return StreamBuilder<List<WaterData>>(
                  stream: FirebaseService().watchHistory(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Failed to load reports',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                      );
                    }

                    final history = snapshot.data ?? <WaterData>[];

                    if (history.isEmpty) {
                      return Center(
                        child: _GlassShell(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'No history data available yet.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ),
                      );
                    }

                    final values =
                        history.map((item) => item.dailyUsage).toList();
                    final averageDailyUsage = _average(values);
                    final weeklyAverageUsage = _average(
                      values.length > 7
                          ? values.sublist(values.length - 7)
                          : values,
                    );
                    final monthlyAverageUsage = _average(
                      values.length > 30
                          ? values.sublist(values.length - 30)
                          : values,
                    );
                    final maxDailyUsage = values.reduce(math.max);
                    final minDailyUsage = values.reduce(math.min);
                    final latestDailyUsage = history.last.dailyUsage;
                    final householdSize = math.max(1, userSettings.householdSize);
                    final perPersonDailyUsage =
                        latestDailyUsage / householdSize;

                    return ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      children: [
                        _ReportsHero(totalEntries: history.length),
                        const SizedBox(height: 16),
                        _TrendChartCard(history: history),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final cardWidth = constraints.maxWidth > 420
                                ? (constraints.maxWidth - 12) / 2
                                : constraints.maxWidth;

                            return Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                SizedBox(
                                  width: cardWidth,
                                  child: _MetricCard(
                                    title: 'Average daily usage',
                                    value:
                                        '${averageDailyUsage.toStringAsFixed(1)} L',
                                    subtitle: 'Across all available records',
                                    accent: const Color(0xFF38BDF8),
                                    icon: Icons.timeline_rounded,
                                  ),
                                ),
                                SizedBox(
                                  width: cardWidth,
                                  child: _MetricCard(
                                    title: 'Average weekly usage',
                                    value:
                                        '${weeklyAverageUsage.toStringAsFixed(1)} L',
                                    subtitle: 'Latest 7 readings',
                                    accent: const Color(0xFF22C55E),
                                    icon: Icons.date_range_rounded,
                                  ),
                                ),
                                SizedBox(
                                  width: cardWidth,
                                  child: _MetricCard(
                                    title: 'Monthly average',
                                    value:
                                        '${monthlyAverageUsage.toStringAsFixed(1)} L',
                                    subtitle: 'Latest 30 readings',
                                    accent: const Color(0xFF06B6D4),
                                    icon: Icons.calendar_month_rounded,
                                  ),
                                ),
                                SizedBox(
                                  width: cardWidth,
                                  child: _MetricCard(
                                    title: 'Per-person daily usage',
                                    value:
                                        '${perPersonDailyUsage.toStringAsFixed(1)} L',
                                    subtitle:
                                        'Based on ${userSettings.householdSize} people',
                                    accent: const Color(0xFF7DD3FC),
                                    icon: Icons.groups_rounded,
                                  ),
                                ),
                                SizedBox(
                                  width: cardWidth,
                                  child: _MetricCard(
                                    title: 'Highest daily usage',
                                    value:
                                        '${maxDailyUsage.toStringAsFixed(1)} L',
                                    subtitle: 'Peak recorded day',
                                    accent: const Color(0xFFF97316),
                                    icon: Icons.trending_up_rounded,
                                  ),
                                ),
                                SizedBox(
                                  width: cardWidth,
                                  child: _MetricCard(
                                    title: 'Lowest daily usage',
                                    value:
                                        '${minDailyUsage.toStringAsFixed(1)} L',
                                    subtitle: 'Most efficient day',
                                    accent: const Color(0xFFA78BFA),
                                    icon: Icons.trending_down_rounded,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportsBackdrop extends StatelessWidget {
  const _ReportsBackdrop();

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
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -60,
              child: _GlowBlob(
                size: 220,
                color: const Color(0xFF38BDF8).withOpacity(0.18),
              ),
            ),
            Positioned(
              bottom: 110,
              left: -70,
              child: _GlowBlob(
                size: 200,
                color: const Color(0xFF22C55E).withOpacity(0.14),
              ),
            ),
            Positioned(
              bottom: -30,
              right: -30,
              child: _WaveBlob(
                size: 180,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
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

class _ReportsHero extends StatelessWidget {
  const _ReportsHero({required this.totalEntries});

  final int totalEntries;

  @override
  Widget build(BuildContext context) {
    return _GlassShell(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Historical usage overview',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white.withOpacity(0.72),
                    letterSpacing: 1.0,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              '$totalEntries saved readings',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              'Review daily trends, compare averages, and spot unusually high water usage patterns.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.76),
                    height: 1.35,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendChartCard extends StatelessWidget {
  const _TrendChartCard({required this.history});

  final List<WaterData> history;

  @override
  Widget build(BuildContext context) {
    final spots = history.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.dailyUsage,
      );
    }).toList();

    final values = history.map((item) => item.dailyUsage).toList();
    final maxValue = values.reduce(math.max);
    final minValue = values.reduce(math.min);
    final rangePadding = math.max(1.0, (maxValue - minValue) * 0.2);
    final minY = math.max(0.0, minValue - rangePadding);
    final maxY = maxValue + rangePadding;
    final yInterval = _safeInterval(maxY - minY, 4);
    final xInterval = history.length > 6 ? math.max(1, history.length ~/ 4).toDouble() : 1.0;

    return _GlassShell(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily water usage trend',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Oldest readings on the left and newest readings on the right.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.72),
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withOpacity(0.14)),
                  ),
                  child: Text(
                    'Daily usage',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white.withOpacity(0.85),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.7,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: spots.length > 1 ? (spots.length - 1).toDouble() : 1,
                  minY: minY,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: yInterval,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.white.withOpacity(0.08),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                        interval: yInterval,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1),
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.white.withOpacity(0.68),
                                  ),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: xInterval,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= history.length) {
                            return const SizedBox.shrink();
                          }

                          final shouldShowLabel = history.length <= 6 ||
                              index == 0 ||
                              index == history.length - 1 ||
                              index % xInterval.round() == 0;

                          if (!shouldShowLabel) {
                            return const SizedBox.shrink();
                          }

                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              _formatShortDate(history[index].lastUpdated),
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.white.withOpacity(0.68),
                                  ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(enabled: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.35,
                      barWidth: 3,
                      color: const Color(0xFF38BDF8),
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF38BDF8).withOpacity(0.14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.accent,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _GlassShell(
      child: Padding(
        padding: const EdgeInsets.all(16),
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

double _average(List<double> values) {
  if (values.isEmpty) return 0.0;
  return values.reduce((a, b) => a + b) / values.length;
}

double _safeInterval(double range, int segments) {
  if (range <= 0) return 1.0;
  return math.max(0.5, range / segments);
}

String _formatShortDate(int timestamp) {
  if (timestamp <= 0) {
    return '--/--';
  }

  final milliseconds = timestamp < 1000000000000 ? timestamp * 1000 : timestamp;
  final dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);

  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${twoDigits(dateTime.day)}/${twoDigits(dateTime.month)}';
}
