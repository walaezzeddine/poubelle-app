import 'package:flutter/material.dart';
import '../../services/poubelles_service.dart';
import 'pages/container_creation_page.dart';
import 'pages/poubelles_map_page.dart';
import 'pages/alerte_icon.dart';
import '../../services/alertes_service.dart'; 
import '../../screens/admin-menu-drawer.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../screens/auth/login_screen.dart';

class ManagePoubellesScreen extends StatefulWidget {
  const ManagePoubellesScreen({super.key});

  @override
  State<ManagePoubellesScreen> createState() => _ManagePoubellesScreenState();
}

class _ManagePoubellesScreenState extends State<ManagePoubellesScreen> {
  final PoubellesService _poubelleService = PoubellesService();
  List<Map<String, dynamic>> _poubelles = [];
  String _searchSite = '';
  String _filtrePleine = 'Tous'; // Ajout du filtre
  final AlertesService _alertesService = AlertesService();

  @override
  void initState() {
    super.initState();
    _loadPoubelles();
  }

  Future<void> _loadPoubelles() async {
    final data = await _poubelleService.getPoubelles();
    setState(() {
      _poubelles = data;
    });
  }

  List<Map<String, dynamic>> _filterPoubelles() {
    return _poubelles.where((poubelle) {
      final siteMatch = poubelle['site'].toLowerCase().contains(_searchSite.toLowerCase());
      final estPleine = poubelle['pleine'] == true;

      if (_filtrePleine == 'Pleine' && !estPleine) return false;
      if (_filtrePleine == 'Non pleine' && estPleine) return false;

      return siteMatch;
    }).toList();
  }

  void _deletePoubelle(String id) async {
    await _poubelleService.deletePoubelle(id);
    _loadPoubelles();
  }

  void _editPoubelle(Map<String, dynamic> poubelle) async {
    final adresse = poubelle['adresse'];

    if (adresse == null || adresse.toString().trim().isEmpty || adresse == "Adresse introuvable") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible de modifier : adresse invalide ou introuvable.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContainerCreationPage(poubelle: poubelle),
      ),
    );
    _loadPoubelles();
  }


  @override
  Widget build(BuildContext context) {
    final filtered = _filterPoubelles();
    final authService = Provider.of<AuthService>(context);
    final role = authService.role;

    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des poubelles'),
        actions: [
          IconButton(
            icon: Icon(Icons.add_box_outlined,color: const Color.fromARGB(255, 2, 113, 46)),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ContainerCreationPage()),
              );
              _loadPoubelles();
            },
          ),
          IconButton(
            icon: Icon(Icons.map_outlined,color: const Color.fromARGB(255, 67, 1, 39)),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PoubellesMapPage()),
              );
            },
          ),
          AlerteIcon(),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthService>(context, listen: false).signOut();
                Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false, // Supprime toutes les routes précédentes
              );
            },
          ),
        ],
      ),
      drawer: role == 'admin' ? const AdminMenuDrawer() : null, // Affiche AdminMenuDrawer uniquement si admin, sinon null
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                Text("Filtrer : "),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: _filtrePleine,
                  items: ['Tous', 'Pleine', 'Non pleine']
                      .map((value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _filtrePleine = value!;
                    });
                  },
                ),
              ],
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
                        Text('Pleine: ${poubelle['pleine'] == true ? 'Oui' : 'Non'}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: const Color.fromARGB(255, 2, 58, 122)),
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



