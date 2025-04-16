import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class UsersBarChart extends StatelessWidget {
  final Map<String, int> roleCounts;

  const UsersBarChart({required this.roleCounts, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final roles = roleCounts.keys.toList();
    final counts = roleCounts.values.toList();

    return BarChart(
      BarChartData(
        barGroups: List.generate(roles.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: counts[index].toDouble(),
                color: Colors.green,
                width: 20,
                borderRadius: BorderRadius.zero,
              ),
            ],
          );
        }),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < roles.length) {
                  return Text(roles[index]);
                } else {
                  return const Text('');
                }
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        gridData: FlGridData(show: true),
        barTouchData: BarTouchData(
          enabled: false, // désactive les interactions et donc les tooltips
        ),
      ),
    );
  }
}
