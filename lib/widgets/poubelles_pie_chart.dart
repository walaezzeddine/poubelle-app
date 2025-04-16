import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PoubellesPieChart extends StatelessWidget {
  final int pleines;
  final int vides;

  const PoubellesPieChart({required this.pleines, required this.vides, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final total = pleines + vides;
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: pleines.toDouble(),
            color: Colors.red,
            title: '${((pleines / total) * 100).toStringAsFixed(1)}%',
          ),
          PieChartSectionData(
            value: vides.toDouble(),
            color: Colors.green,
            title: '${((vides / total) * 100).toStringAsFixed(1)}%',
          ),
        ],
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }
}
