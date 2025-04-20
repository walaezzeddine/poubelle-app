import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  Future<void> _loadSites() async {
    try {
      final sites = await _sitesService.getSites();
      setState(() {
        _sites = sites;
      });
    } catch (e) {
      _showError('Erreur de chargement des sites : $e');
    }
  }

  List<Map<String, dynamic>> _filterSites() {
    return _sites.where((site) {
      final codePMatch = site['codeP'].toString().toLowerCase().contains(_searchCodeP.toLowerCase());
      final nomMatch = site['nom'].toString().toLowerCase().contains(_searchNom.toLowerCase());
      return codePMatch && nomMatch;
    }).toList();
  }

  Future<void> _showSiteDialog({Map<String, dynamic>? site}) async {
    final codePController = TextEditingController(text: site?['codeP']?.toString() ?? '');
    final nbPoubellesController = TextEditingController(text: site?['nbPoubelles']?.toString() ?? '');
    final nomController = TextEditingController(text: site?['nom'] ?? '');

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(site == null ? 'Ajouter un site' : 'Modifier un site'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codePController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'Code P'),
              ),
              TextField(
                controller: nbPoubellesController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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

                if (codeP.isEmpty || nbPoubelles.isEmpty || nom.isEmpty) {
                  _showError('Tous les champs doivent être remplis.');
                  return;
                }

                final codePInt = int.tryParse(codeP);
                final nbPoubellesInt = int.tryParse(nbPoubelles);

                if (codePInt == null || nbPoubellesInt == null) {
                  _showError('Valeurs invalides pour Code P ou Nombre de Poubelles.');
                  return;
                }
                try {
                  if (site == null) {
                    await _sitesService.addSite(codePInt, nbPoubellesInt, nom);
                  } else {
                    await _sitesService.updateSite(site['id'], codePInt, nbPoubellesInt, nom);
                  }

                  Navigator.pop(context); // Fermer la popup
                  _loadSites(); // Recharger les données
                } catch (e) {
                  _showError('Erreur : $e');
                }
              },
              child: Text(site == null ? 'Ajouter' : 'Modifier'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
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
      try {
        await _sitesService.deleteSite(id);
        _loadSites();
      } catch (e) {
        _showError('Erreur lors de la suppression : $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message),backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gérer les sites')),
      drawer: const AdminMenuDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Liste des sites',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 9, 106, 9),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Recherche par code P',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) => setState(() => _searchCodeP = value),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Recherche par nom',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) => setState(() => _searchNom = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _sites.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _filterSites().length,
                      itemBuilder: (context, index) {
                        final site = _filterSites()[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(site['nom']?? ""),
                            subtitle: Text('Code P: ${site['codeP']}, Poubelles: ${site['nbPoubelles']}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Color.fromARGB(255, 229, 131, 31)),
                                  onPressed: () => _showSiteDialog(site: site),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _confirmDelete(site['id']),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => _showSiteDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un site'),
            ),
          ],
        ),
      ),
    );
  }
}
