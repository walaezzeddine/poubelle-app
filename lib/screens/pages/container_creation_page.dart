

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:poubelle/services/poubelles_service.dart';
import 'package:poubelle/services/sites_services.dart';
import 'package:flutter/services.dart';
import '../../services/location_service.dart';






class ContainerCreationPage extends StatefulWidget {
  final Map<String, dynamic>? poubelle;




  ContainerCreationPage({this.poubelle});




  @override
  _ContainerCreationPageState createState() => _ContainerCreationPageState();
}




class _ContainerCreationPageState extends State<ContainerCreationPage> {
  final SitesService _secteurService = SitesService();
  final PoubellesService _poubelleService = PoubellesService();




  LatLng _initialPosition = LatLng(36.4549, 10.7252);
  LatLng _selectedPosition = LatLng(36.4549, 10.7252);
  final LocationService _locationService = LocationService();  // Instance du service de localisation


  List<String> _secteurs = [];
  String? _selectedSecteur;








  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool adresseInvalide = false;




  @override
  void initState() {
    super.initState();
    _loadSecteurs();
    _getCurrentLocation();  // Appeler la méthode pour obtenir la position actuelle




    if (widget.poubelle != null) {
      _latController.text = widget.poubelle!['latitude'].toString();
      _lngController.text = widget.poubelle!['longitude'].toString();
      _addressController.text = widget.poubelle!['adresse'];
      _selectedSecteur = widget.poubelle!['secteur'];
      _selectedPosition = LatLng(
        widget.poubelle!['latitude'],
        widget.poubelle!['longitude'],
      );
    }
  }


 


  // Fonction pour obtenir la position actuelle
  Future<void> _getCurrentLocation() async {
    LatLng? currentPosition = await _locationService.getCurrentLocation(); // Utiliser le service de localisation
    if (currentPosition != null) {
      setState(() {
        _initialPosition = currentPosition;
        _selectedPosition = currentPosition;
      });
    }
  }




  Future<void> _loadSecteurs() async {
    final secteurs = await _secteurService.getSecteurs();
    setState(() {
      _secteurs = _getDistinctSecteur(secteurs);
    });
  }




  List<String> _getDistinctSecteur(List<Map<String, dynamic>> secteurs) {
    Set<String> secteurSet = {};
    for (var secteur in secteurs) {
      secteurSet.add(secteur['nom']);
    }
    return secteurSet.toList();
  }




  void changeADR(LatLng position) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&addressdetails=1',
      );




      final response = await http.get(url, headers: {
        'User-Agent': 'FlutterApp/1.0 (contact@example.com)',
      });




      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final displayName = data['display_name'];
        _addressController.text = displayName ?? "Adresse introuvable";
      } else {
        _addressController.text = "Erreur lors de la récupération de l'adresse";
      }
    } catch (e) {
      _addressController.text = "Erreur: ${e.toString()}";
    }
  }




Future<void> _geocodeAddress(String address) async {
    final query = Uri.encodeFull(address);
   final url = Uri.parse(
  'https://corsproxy.io/?https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1',
);






    try {
      final response = await http.get(url, headers: {
        'User-Agent': 'FlutterApp/1.0 (contact@example.com)',
      });




      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final lat = double.tryParse(data[0]['lat']);
          final lon = double.tryParse(data[0]['lon']);




          if (lat != null && lon != null) {
            _latController.text = lat.toString();
            _lngController.text = lon.toString();
            setState(() {
              _selectedPosition = LatLng(lat, lon);
              adresseInvalide = false;
            });
           
          }
        }
      }




  setState(() {
  adresseInvalide =true;
});












    } catch (e) {
      print("Erreur lors du géocodage: $e");
    }
  }








  void _onMapTap(LatLng position) async {
    _latController.text = position.latitude.toString();
    _lngController.text = position.longitude.toString();
    changeADR(position);
    _updateMarker();
  }




  void _updateMarker() {
    double? lat = double.tryParse(_latController.text);
    double? lng = double.tryParse(_lngController.text);
    if (lat != null && lng != null) {
      setState(() {
        _selectedPosition = LatLng(lat, lng);
      });
    }
  }




  void _updateFromInput() {
    double? lat = double.tryParse(_latController.text);
    double? lng = double.tryParse(_lngController.text);
    if (lat != null && lng != null) {
      LatLng position = LatLng(lat, lng);
      changeADR(position);
      _updateMarker();
    }
  }




  void _onSubmitPressed() async {
  final lat = double.tryParse(_latController.text);
  final lng = double.tryParse(_lngController.text);
  final adresse = _addressController.text.trim();
  setState(() {
  _addressController.text = adresseInvalide ? "Adresse introuvable" : _addressController.text;
});




  if (lat == null || lng == null || _selectedSecteur == null || adresse.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Veuillez remplir tous les champs.'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }
  if ( adresseInvalide==true|| adresse.contains("Adresse introuvable")) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("L'adresse n'est pas valide."),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }




  try {
    if (widget.poubelle != null) {
      await _poubelleService.updatePoubelle(
        id: widget.poubelle!['id'],
        latitude: lat,
        longitude: lng,
        adresse: adresse,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Poubelle modifiée avec succès.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      await _poubelleService.addPoubelle(
        lat,
        lng,
        adresse,
        _selectedSecteur!,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Poubelle ajoutée avec succès.'),
          backgroundColor: Colors.green,
        ),
      );
    }




    // Attendre un court instant pour afficher le snackbar avant de revenir
    await Future.delayed(Duration(milliseconds: 800));
    Navigator.pop(context);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Une erreur est survenue.'),
        backgroundColor: Colors.red,
      ),
    );
    print('Erreur: $e');
  }
}








  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.poubelle != null ? "Modifier la poubelle" : "Nouvelle poubelle")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedSecteur,
              items: _secteurs.map((secteur) {
                return DropdownMenuItem<String>(
                  value: secteur,
                  child: Text(secteur),
                );
              }).toList(),
              onChanged: (newsecteur) {
                setState(() {
                  _selectedSecteur = newsecteur;
                });
              },
              decoration: const InputDecoration(labelText: 'Secteur'),
              hint: const Text('Sélectionner un secteur'),
            ),
            TextField(
              controller: _latController,
              decoration: InputDecoration(labelText: "Latitude"),
              keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
              ],
              onChanged: (value) {
                _updateFromInput();
              },
            ),
            TextField(
              controller: _lngController,
              decoration: InputDecoration(labelText: "Longitude"),
              keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
              ],
              onChanged: (value) {
                _updateFromInput();
              },
            ),
            TextField(
              readOnly: true,
              controller: _addressController,
              decoration: InputDecoration(labelText: "Adresse"),
              onChanged: (value) {
                if (value.trim().isNotEmpty) {
                  _geocodeAddress(value);
                }
              },
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 250,
              child: FlutterMap(
  options: MapOptions(
    center: _selectedPosition,
    zoom: 14,
    onTap: (tapPosition, point) {
      _onMapTap(point);
    },
  ),
  children: [
    TileLayer(
      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
      subdomains: ['a', 'b', 'c'],
    ),
    MarkerLayer(
      markers: [
        Marker(
          point: _selectedPosition,
          width: 40,
          height: 40,
          child: Icon(
            Icons.location_pin,
            color: Colors.red,
            size: 40,
          ),
        ),
      ],
    ),
  ],
),


            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _onSubmitPressed,
              child: Text(widget.poubelle != null ? "Modifier" : "Créer"),
            ),
          ],
        ),
      ),
    );
  }
}
