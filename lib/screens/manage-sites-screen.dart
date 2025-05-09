import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/sites_services.dart';
import '../../services/users_service.dart'; 
import '../../screens/admin-menu-drawer.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../screens/auth/login_screen.dart';

class ManageSitesScreen extends StatefulWidget {
  const ManageSitesScreen({super.key});

  @override
  State<ManageSitesScreen> createState() => _ManageSitesScreenState();
}

class _ManageSitesScreenState extends State<ManageSitesScreen> {
  final SitesService _secteursService = SitesService();

  List<Map<String, dynamic>> _secteurs = [];
  Map<String, String> _chauffeurCins = {}; // <-- Map pour stocker ID -> Cin
  List<Map<String, dynamic>> _chauffeurs = []; // <-- Liste des chauffeurs
  String? _selectedChauffeurID; // <-- ID du chauffeur sélectionné

  String _searchCodeP = '';
  String _searchNom = '';

  @override
  void initState() {
    super.initState();
    _loadSecteurs();
    _loadChauffeurs();
  }

  // Charger la liste des chauffeurs
  Future<void> _loadChauffeurs() async {
    try {
      final chauffeurs = await _secteursService.getUsers('chauffeur');
      setState(() {
        _chauffeurs = chauffeurs;
      });
    } catch (e) {
      _showError('Erreur de chargement des chauffeurs : $e');
    }
  }

  Future<void> _loadSecteurs() async {
    try {
      final secteurs = await _secteursService.getSecteurs();
      final cins = <String, String>{};

      // Charger aussi les cins de chaque chauffeur
      for (var secteur in secteurs) {
        final chauffeurID = secteur['chauffeurID'];
        if (chauffeurID != null && chauffeurID != '') {
          final user = await _secteursService.getUserByChauffeurID(chauffeurID);
          final cin = user['cin']; // <-- récupérer le cin à partir du user
          cins[chauffeurID] = (cin as String?) ?? 'Cin non trouvé';
        }
      }

      setState(() {
        _secteurs = secteurs;
        _chauffeurCins = cins;
      });
    } catch (e) {
      _showError('Erreur de chargement des secteurs : $e');
    }
  }

  List<Map<String, dynamic>> _filterSecteurs() {
  return _secteurs.where((secteur) {
    final codePMatch = secteur['codeP'].toString().toLowerCase().contains(_searchCodeP.toLowerCase());
    final nomMatch = secteur['nom'].toString().toLowerCase().contains(_searchNom.toLowerCase());
    return codePMatch && nomMatch;
  }).toList();
  }

  Future<void> _showSecteurDialog({Map<String, dynamic>? secteur}) async {
    final codePController = TextEditingController(text: secteur?['codeP']?.toString() ?? '');
    final nbPoubellesController = TextEditingController(text: secteur?['nbPoubelles']?.toString() ?? '');
    final nomController = TextEditingController(text: secteur?['nom'] ?? '');

    // Prendre l'ID du chauffeur existant ou null si pas de secteur
    final initialChauffeurID = secteur != null ? secteur['chauffeurID'] : null;
    setState(() {
      _selectedChauffeurID=initialChauffeurID;
    });
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(secteur == null ? 'Ajouter un secteur' : 'Modifier un secteur'),
          content: SingleChildScrollView(
            child: Column(
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
                // Liste déroulante des chauffeurs
                  DropdownButtonFormField<String>(
                    value: _selectedChauffeurID ?? initialChauffeurID,
                    decoration: const InputDecoration(labelText: 'Chauffeur affecté'),
                    hint: const Text('Sélectionner un chauffeur'),
                    items: _chauffeurs
                      .where((chauffeur) => RegExp(r'^\d{8}$').hasMatch(chauffeur['cin'] ?? ''))
                      .map((chauffeur) {
                        // Afficher le nom et prénom du chauffeur
                        return DropdownMenuItem<String>(
                          value: chauffeur['id'],
                          child: Text('${chauffeur['nom']} ${chauffeur['prenom']}'),  // Affiche le nom et prénom
                        );
                      }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedChauffeurID = value;
                      });
                    },
                  ),
              ],
            ),
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

                if (codeP.isEmpty || nbPoubelles.isEmpty || nom.isEmpty || _selectedChauffeurID == null) {
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
                  if (secteur == null) {
                    // Ajouter un secteur
                    await _secteursService.addSecteur(codePInt, nbPoubellesInt, nom, _selectedChauffeurID!);
                  } else {
                    // Modifier un secteur
                    await _secteursService.updateSecteur(secteur['id'], codePInt, nbPoubellesInt, nom, _selectedChauffeurID!);
                  }

                  Navigator.pop(context);
                  _loadSecteurs();
                } catch (e) {
                  _showError('Erreur : $e');
                }
              },
              child: Text(secteur == null ? 'Ajouter' : 'Modifier'),
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
        content: const Text('Voulez-vous vraiment supprimer ce secteur ?'),
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
        await _secteursService.deleteSecteur(id);
        _loadSecteurs();
      } catch (e) {
        _showError('Erreur lors de la suppression : $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gérer les secteurs'),
        actions: [
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
      drawer: const AdminMenuDrawer() , 
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
             const Text(
              'Liste des secteurs',
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
              child: _secteurs.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _filterSecteurs().length,
                    itemBuilder: (context, index) {
                      final secteur = _filterSecteurs()[index];
                      final chauffeurCin = _chauffeurCins[secteur['chauffeurID']] ?? 'Cin non trouvé';
                      final chauffeur = _chauffeurs.firstWhere(
                        (chauffeur) => chauffeur['id'] == secteur['chauffeurID'], 
                        orElse: () => {'nom': 'Inconnu', 'prenom': 'Inconnu'} // Valeur par défaut en cas d'absence
                      );
                      final chauffeurNomPrenom = '${chauffeur['nom']} ${chauffeur['prenom']}'; // Nom et prénom

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(secteur['nom'] ?? ''),
                          subtitle: Text('Code P: ${secteur['codeP']}, Poubelles: ${secteur['nbPoubelles']}, Chauffeur: $chauffeurNomPrenom'),  // Affiche le nom et prénom du chauffeur
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Color.fromARGB(255, 2, 58, 122)),
                                onPressed: () => _showSecteurDialog(secteur: secteur),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmDelete(secteur['id']),
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
              onPressed: () => _showSecteurDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un secteur'),
            ),
          ],
        ),
      ),
    );
  }
}
