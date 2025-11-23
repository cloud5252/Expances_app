import 'package:expances_tracker/bar_graph/individual_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarGraph extends StatefulWidget {
  final List<double> monthlySummary;
  final int startMonth;

  const BarGraph({
    super.key,
    required this.monthlySummary,
    required this.startMonth,
  });

  @override
  State<BarGraph> createState() => _BarGraphState();
}

class _BarGraphState extends State<BarGraph> {
  List<IndividualBar> barData = [];

  void initializeBarData() {
    barData = List.generate(
      widget.monthlySummary.length,
      (index) =>
          IndividualBar(x: index, y: widget.monthlySummary[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    initializeBarData();

    double maxValue = widget.monthlySummary.isNotEmpty
        ? widget.monthlySummary.reduce((a, b) => a > b ? a : b)
        : 0;

    double maxY = maxValue <= 10 ? 20 : maxValue * 1.5;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          minY: 0,
          maxY: maxY,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: getTitlesWidget,
                reservedSize: 40,
              ),
            ),
          ),
          barGroups: barData
              .map(
                (data) => BarChartGroupData(
                  x: data.x,
                  barRods: [
                    BarChartRodData(
                      toY: data.y,
                      color: Colors.green,
                      width: 20,
                      borderRadius: BorderRadius.circular(4),
                      backDrawRodData: BackgroundBarChartRodData(
                        color: Colors.white70,
                        show: true,
                        toY: maxY,
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget getTitlesWidget(double value, TitleMeta meta) {
    final monthLabels = [
      'J',
      'F',
      'M',
      'A',
      'M',
      'J',
      'J',
      'A',
      'S',
      'O',
      'N',
      'D',
    ];
    int index = value.toInt();

    if (index < 0 || index >= monthLabels.length) {
      return const SizedBox.shrink();
    }

    String text = monthLabels[index];

    return SideTitleWidget(
      space: 6,
      meta: meta,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20,
          color:
              Theme.of(context).textTheme.bodyMedium?.color ??
              Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
