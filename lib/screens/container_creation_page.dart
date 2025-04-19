import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:poubelle/services/poubelles_service.dart';
import 'package:poubelle/services/sites_services.dart';


/*void main() {
  runApp(MaterialApp(
    home: ContainerCreationPage(),
  ));
}*/


class ContainerCreationPage extends StatefulWidget {
  @override
  _ContainerCreationPageState createState() => _ContainerCreationPageState();
}


class _ContainerCreationPageState extends State<ContainerCreationPage> {
  @override
  void initState() {
    super.initState();
    _loadSites(); // Charger les sites au démarrage
  }


  final SitesService _siteService = SitesService();
  final PoubellesService _poubelleService = PoubellesService();


  LatLng _initialPosition = LatLng(36.4549, 10.7252);
  LatLng _selectedPosition = LatLng(36.4549, 10.7252);
  List<String> _sites = [];
  String? _selectedSite;


  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();


  Future<void> _loadSites() async {
    final sites = await _siteService.getSites();
    setState(() {
      _sites = _getDistinctSite(sites);
    });
  }


  List<String> _getDistinctSite(List<Map<String, dynamic>> sites) {
    Set<String> siteSet = {};
    for (var site in sites) {
      siteSet.add(site['nom']);
    }
    return siteSet.toList();
  }
void changeADR(position) async{
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
  void _onMapTap(LatLng position) async {
    _latController.text = position.latitude.toString();
    _lngController.text = position.longitude.toString();
    print(position);
    changeADR(position);
    _updateMarker();


 
  }


  void _onCreatePressed() async {
    final lat = double.tryParse(_latController.text);
    final lng = double.tryParse(_lngController.text);


    if (lat == null || lng == null || _selectedSite == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs (site, latitude, longitude).')),
      );
      return;
    }


    await _poubelleService.addPoubelle(
      lat,
      lng,
      _addressController.text,
      _selectedSite!, // <-- site ajouté ici
    );


    print("Site: $_selectedSite");
    print("Latitude: ${_latController.text}");
    print("Longitude: ${_lngController.text}");
    print("Adresse: ${_addressController.text}");
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nouvelle poubelle")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedSite,
              items: _sites.map((site) {
                return DropdownMenuItem<String>(
                  value: site,
                  child: Text(site),
                );
              }).toList(),
              onChanged: (newsite) {
                setState(() {
                  _selectedSite = newsite;
                });
              },
              decoration: const InputDecoration(labelText: 'Site'),
              hint: const Text('Sélectionner un site'),
            ),
           TextField(
            controller: _latController,
            decoration: InputDecoration(labelText: "Latitude"),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              double? lat = double.tryParse(_latController.text);
              double? lng = double.tryParse(_lngController.text);
              if (lat != null && lng != null) {
                LatLng position = LatLng(lat, lng);
                changeADR(position);
                _updateMarker();
              }
            },
          ),
          TextField(
            controller: _lngController,
            decoration: InputDecoration(labelText: "Longitude"),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              double? lat = double.tryParse(_latController.text);
              double? lng = double.tryParse(_lngController.text);
              if (lat != null && lng != null) {
                LatLng position = LatLng(lat, lng);
                changeADR(position);
                _updateMarker();
              }
            },
          ),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: "Adresse"),
              readOnly: true,
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 250,
              child: FlutterMap(
                options: MapOptions(
                  center: _initialPosition,
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
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _onCreatePressed,
              child: Text("Create"),
            ),
          ],
        ),
      ),
    );
  }
}


