import 'package:flutter/material.dart';
import '../../services/sites_services.dart'; 
import '../../screens/admin-menu-drawer.dart'; 

class ManageSitesScreen extends StatefulWidget {
  const ManageSitesScreen({super.key});

  @override
  State<ManageSitesScreen> createState() => _ManageSitesScreenState();
}

class _ManageSitesScreenState extends State<ManageSitesScreen> {
  final SitesService _sitesService = SitesService();
  List<Map<String, dynamic>> _sites = [];
  String _searchCodeP = '';
  String _searchNom = '';

  @override
  void initState() {
    super.initState();
    _loadSites();
  }

  // Fonction de recherche partielle par codeP et nom
  Future<void> _loadSites() async {
    final sites = await _sitesService.getSites();
    setState(() {
      _sites = sites;
    });
  }

  // Afficher le dialogue pour ajouter/éditer un site
  Future<void> _showSiteDialog({Map<String, dynamic>? site}) async {
    final codePController = TextEditingController(text: site?['codeP']);
    final nbPoubellesController = TextEditingController(text: site?['nbPoubelles']);
    final nomController = TextEditingController(text: site?['nom']);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(site == null ? 'Ajouter un site' : 'Modifier site'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codePController,
                decoration: const InputDecoration(labelText: 'Code P'),
              ),
              TextField(
                controller: nbPoubellesController,
                decoration: const InputDecoration(labelText: 'Nombre de Poubelles'),
              ),
              TextField(
                controller: nomController,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                final codeP = codePController.text.trim();
                final nbPoubelles = nbPoubellesController.text.trim();
                final nom = nomController.text.trim();

                if (codeP.isEmpty || nbPoubelles.isEmpty || nom.isEmpty) return;

                if (site == null) {
                  // Ajouter
                  await _sitesService.addSite(codeP, nbPoubelles, nom);
                } else {
                  // Modifier
                  await _sitesService.updateSite(site['id'], codeP, nbPoubelles, nom);
                }

                Navigator.pop(context);
                setState(() {
                  _loadSites(); // Recharger la liste après modification
                });
              },
              child: Text(site == null ? 'Ajouter' : 'Modifier'),
            ),
          ],
        );
      },
    );
  }

  // Confirmer la suppression d'un site
  Future<void> _confirmDelete(String siteId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer ce site ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _sitesService.deleteSite(siteId);
      setState(() {
        _loadSites(); // Recharger la liste après suppression
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gérer les sites'),
      ),
      drawer: const AdminMenuDrawer(), // ← menu réutilisé
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Liste des sites',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Zone de recherche
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Recherche par code P',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchCodeP = value;
                        _loadSites(); // Rechercher à chaque modification du code P
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Recherche par nom',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchNom = value;
                        _loadSites(); // Rechercher à chaque modification du nom
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _sites.length,
                itemBuilder: (context, index) {
                  final site = _sites[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(site['nom']),
                      subtitle: Text('Code P: ${site['codeP']}, Poubelles: ${site['nbPoubelles']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showSiteDialog(site: site),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _confirmDelete(site['id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showSiteDialog(),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Ajouter un site'),
            ),
          ],
        ),
      ),
    );
  }
}
