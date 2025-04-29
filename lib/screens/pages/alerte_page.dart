import 'package:flutter/material.dart';
import '../../services/alertes_service.dart';

class AlertePage extends StatefulWidget {
  @override
  _AlerteState createState() => _AlerteState();
}

class _AlerteState extends State<AlertePage> {
  final AlertesService _alertesService = AlertesService();
  List<Map<String, dynamic>> _alertes = [];

    @override
    void initState() {
    super.initState();
    _init();
    }

    Future<void> _init() async {
    await _generateAlertesForPleines(); // On attend que les alertes soient générées
    await _loadAlertes(); // Puis on recharge la liste
    }

  Future<void> _generateAlertesForPleines() async {
    try {
      await _alertesService.generateAlertesForPoubelles();
    } catch (e) {
      // Gérer l'erreur ici, par exemple afficher un message
      print("Erreur lors de la génération des alertes : $e");
    }
  }

  Future<void> _loadAlertes() async {
    try {
      final alertes = await _alertesService.getAllAlertes();
      setState(() {
        _alertes = alertes;
      });
    } catch (e) {
      // Gérer l'erreur ici, par exemple afficher un message
      print("Erreur lors du chargement des alertes : $e");
    }
  }

  Future<void> _toggleTraitee(Map<String, dynamic> alerte) async {
    try {
      await _alertesService.updateAlerte(
        id: alerte['id'],
        designation: alerte['designation'],
        poubelle: alerte['poubelle'],
        titre: alerte['titre'],
        traitee: !(alerte['traitee'] ?? false),
      );

      // Mettre à jour l'état local sans recharger toutes les alertes
      setState(() {
        alerte['traitee'] = !(alerte['traitee'] ?? false);
      });
    } catch (e) {
      // Gérer l'erreur ici
      print("Erreur lors de la mise à jour de l'alerte : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alertes'),
      ),
      body: ListView.builder(
        itemCount: _alertes.length,
        itemBuilder: (context, index) {
          final alerte = _alertes[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text('${alerte['titre']}'),
              subtitle: Text('${alerte['designation']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(alerte['traitee'] ? 'Traitée' : 'Non traitée'),
                  Switch(
                    value: alerte['traitee'] ?? false,
                    onChanged: (value) => _toggleTraitee(alerte),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
