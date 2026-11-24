import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/water_data.dart';
import '../services/firebase_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          'History',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Stack(
        children: [
          const _HistoryBackdrop(),
          SafeArea(
            child: StreamBuilder<List<WaterData>>(
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
                      'Failed to load history',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                          'No history data available',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ),
                  );
                }

                final newestFirst = history.reversed.toList();

                return ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    _HistoryHero(totalEntries: history.length),
                    const SizedBox(height: 16),
                    ...newestFirst.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _HistoryCard(item: item),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryBackdrop extends StatelessWidget {
  const _HistoryBackdrop();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF04111D),
              const Color(0xFF0A2F4D),
              const Color(0xFF0E7490).withOpacity(0.80),
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
                color: const Color(0xFF38BDF8).withOpacity(0.20),
              ),
            ),
            Positioned(
              bottom: 100,
              left: -80,
              child: _GlowBlob(
                size: 200,
                color: const Color(0xFF22C55E).withOpacity(0.14),
              ),
            ),
            Positioned(
              bottom: -40,
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

class _HistoryHero extends StatelessWidget {
  const _HistoryHero({required this.totalEntries});

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
              'Flow history timeline',
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
              'Track your latest water sensor readings from Firebase Realtime Database.',
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

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.item});

  final WaterData item;

  @override
  Widget build(BuildContext context) {
    final isAlert = item.leakDetected || item.flowRate > 15;
    final accent = isAlert ? const Color(0xFFF97316) : const Color(0xFF38BDF8);

    return _GlassShell(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [accent.withOpacity(0.55), accent.withOpacity(0.12)],
                ),
              ),
              child: Icon(
                isAlert
                    ? Icons.warning_amber_rounded
                    : Icons.water_drop_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _formatTimestamp(item.lastUpdated),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                      _Pill(
                        text: isAlert ? 'Leak' : 'Normal',
                        color: accent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Daily usage: ${item.dailyUsage.toStringAsFixed(1)} L',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.78),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Flow rate: ${item.flowRate.toStringAsFixed(2)} L/min',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.78),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Leak status: ${item.leakDetected ? 'Detected' : 'Normal'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.64),
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

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

String _formatTimestamp(int timestamp) {
  if (timestamp <= 0) {
    return 'Unknown date';
  }

  final milliseconds = timestamp < 1000000000000 ? timestamp * 1000 : timestamp;
  final dateTime = DateTime.fromMillisecondsSinceEpoch(
    milliseconds,
    isUtc: false,
  );

  String twoDigits(int value) => value.toString().padLeft(2, '0');

  return '${twoDigits(dateTime.day)}/${twoDigits(dateTime.month)}/${dateTime.year} '
      '${twoDigits(dateTime.hour)}:${twoDigits(dateTime.minute)}';
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

