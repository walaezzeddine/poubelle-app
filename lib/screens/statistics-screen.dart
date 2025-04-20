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
  String? errorMessage;
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
      print(userCount);
      print(roleData);
      print(totalPoubelles);
      print(poubelleData);
      setState(() {
        totalUtilisateurs = userCount;
        roleCounts = roleData;
        totalPoubelles = totalPoubellesCount;
        poubellesPleines = poubelleData['plein'] ?? 0;
        poubellesVides = poubelleData['vide'] ?? 0;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      print('Erreur lors de la récupération des statistiques : $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Échec de chargement des statistiques. Veuillez réessayer.';
      });
    }
  }

  Widget _buildChartsLayout(double width) {
    const double breakpoint = 600.0;
    const double chartHeight = 200.0;

    if (width >= breakpoint) {
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
          : errorMessage != null
              ? Center(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                )
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
                          StatCard(
                            icon: Icons.people,
                            title: 'Utilisateurs',
                            value: '$totalUtilisateurs',
                            color: Colors.blue,
                          ),
                          StatCard(
                            icon: Icons.delete,
                            title: 'Poubelles',
                            value: '$totalPoubelles',
                            color: Colors.orange,
                          ),
                          StatCard(
                            icon: Icons.warning,
                            title: 'Poubelles pleines',
                            value: '$poubellesPleines',
                            color: Colors.red,
                          ),
                          StatCard(
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

class StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const StatCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                Tooltip(
                  message: title,
                  child: Icon(icon, size: 25, color: color),
                ),
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
}
