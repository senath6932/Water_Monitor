import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/water_data.dart';

class UsageChart extends StatelessWidget {
  const UsageChart({
    super.key,
    required this.history,
  });

  final List<WaterData> history;

  @override
  Widget build(BuildContext context) {
    final reversed = history.reversed.toList();
    final points = reversed
        .asMap()
        .entries
        .map((entry) => FlSpot(
              entry.key.toDouble(),
              entry.value.flowRate,
            ))
        .toList();

    return AspectRatio(
      aspectRatio: 1.8,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: points.length < 2
            ? Center(
                child: Text(
                  'Not enough history yet to draw the chart.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              )
            : LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                  ),
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: points,
                      isCurved: true,
                      barWidth: 3,
                      color: Theme.of(context).colorScheme.primary,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color:
                            Theme.of(context).colorScheme.primary.withOpacity(0.12),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(enabled: true),
                ),
              ),
      ),
    );
  }
}
