import 'package:flutter/material.dart';
import '../../services/statistics_services.dart';
import '../../widgets/poubelles_pie_chart.dart';
import '../../widgets/users_bar_chart.dart';
import '../screens/admin-menu-drawer.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final StatisticsService _statisticsService = StatisticsService();

  int totalUtilisateurs = 0;
  int totalPoubelles = 0;
  int poubellesPleines = 0;
  int poubellesVides = 0;
  bool isLoading = true;
  Map<String, int> roleCounts = {};

  @override
  void initState() {
    super.initState();
    _fetchStatistics();
  }

  Future<void> _fetchStatistics() async {
    try {
      final userCount = await _statisticsService.getUserCount();
      final roleData = await _statisticsService.getUserCountsByRoles();
      final totalPoubellesCount = await _statisticsService.getTotalPoubelles();
      final poubelleData = await _statisticsService.getPoubellesStatus();

      setState(() {
        totalUtilisateurs = userCount;
        roleCounts = roleData;
        totalPoubelles = totalPoubellesCount;
        poubellesPleines = poubelleData['plein'] ?? 0;
        poubellesVides = poubelleData['vide'] ?? 0;
        isLoading = false;
      });
    } catch (e) {
      print('Erreur lors de la récupération des statistiques : $e');
    }
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 25, color: color),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsLayout(double width) {
    const double breakpoint = 600.0; // Définir un seuil pour le responsive
    const double chartHeight = 200.0;

    if (width >= breakpoint) {
      // Affichage côte à côte
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                const Text(
                  'État des poubelles',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: chartHeight,
                  child: PoubellesPieChart(
                    pleines: poubellesPleines,
                    vides: poubellesVides,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                const Text(
                  'Utilisateurs par rôle',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: chartHeight,
                  child: UsersBarChart(roleCounts: roleCounts),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      // Affichage empilé verticalement
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'État des poubelles',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: chartHeight,
            child: PoubellesPieChart(
              pleines: poubellesPleines,
              vides: poubellesVides,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Utilisateurs par rôle',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: chartHeight,
            child: UsersBarChart(roleCounts: roleCounts),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistiques')),
      drawer: const AdminMenuDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Statistiques globales',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      _buildStatCard(
                        icon: Icons.people,
                        title: 'Utilisateurs',
                        value: '$totalUtilisateurs',
                        color: Colors.blue,
                      ),
                      _buildStatCard(
                        icon: Icons.delete,
                        title: 'Poubelles',
                        value: '$totalPoubelles',
                        color: Colors.orange,
                      ),
                      _buildStatCard(
                        icon: Icons.warning,
                        title: 'Poubelles pleines',
                        value: '$poubellesPleines',
                        color: Colors.red,
                      ),
                      _buildStatCard(
                        icon: Icons.check_circle,
                        title: 'Poubelles vides',
                        value: '$poubellesVides',
                        color: Colors.green,
                      ),
                      const SizedBox(height: 20),
                      _buildChartsLayout(constraints.maxWidth),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
