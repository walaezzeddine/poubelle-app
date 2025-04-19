import 'package:flutter/material.dart';
import '../../services/poubelles_service.dart';
import './container_creation_page.dart'; // importe ton ajout ici

class ManagePoubellesScreen extends StatefulWidget {
  const ManagePoubellesScreen({super.key});

  @override
  State<ManagePoubellesScreen> createState() => _ManagePoubellesScreenState();
}

class _ManagePoubellesScreenState extends State<ManagePoubellesScreen> {
  final PoubellesService _poubelleService = PoubellesService();
  List<Map<String, dynamic>> _poubelles = [];
  String _searchSite = '';

  @override
  void initState() {
    super.initState();
    _loadPoubelles();
  }

  Future<void> _loadPoubelles() async {
    final data = await _poubelleService.getPoubelles(); // méthode à créer côté service
    setState(() {
      _poubelles = data;
    });
  }

  List<Map<String, dynamic>> _filterPoubelles() {
    return _poubelles.where((poubelle) {
      final siteMatch = poubelle['site'].toLowerCase().contains(_searchSite.toLowerCase());
      return siteMatch;
    }).toList();
  }

  void _deletePoubelle(String id) async {
    await _poubelleService.deletePoubelle(id); // méthode delete dans ton service
    _loadPoubelles(); // rafraîchir la liste
  }

  void _editPoubelle(Map<String, dynamic> poubelle) {
    // à implémenter plus tard
    print('Édition de : $poubelle');
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filterPoubelles();

    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des poubelles'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ContainerCreationPage()),
              );
              _loadPoubelles(); // recharger après ajout
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Recherche par site',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchSite = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final poubelle = filtered[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text('Site: ${poubelle['site']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Adresse: ${poubelle['adresse']}'),
                        Text('Latitude: ${poubelle['latitude']}'),
                        Text('Longitude: ${poubelle['longitude']}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => _editPoubelle(poubelle),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deletePoubelle(poubelle['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
