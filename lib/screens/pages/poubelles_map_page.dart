import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import '../../services/poubelles_service.dart'; // adapte selon ton arborescence


class PoubellesMapPage extends StatefulWidget {
  @override
  _PoubellesMapPageState createState() => _PoubellesMapPageState();
}


class _PoubellesMapPageState extends State<PoubellesMapPage> {
  final PoubellesService _poubellesService = PoubellesService();
  final MapController _mapController = MapController();


  List<Marker> _markers = [];
  String _searchText = '';


  @override
  void initState() {
    super.initState();
    _loadPoubelles();
  }


  Future<void> _loadPoubelles() async {
    final poubelles = await _poubellesService.getPoubelles();
    setState(() {
      _markers = poubelles.where((poubelle) {
        return poubelle['latitude'] != null && poubelle['longitude'] != null;
      }).map((poubelle) {
        final isPleine = poubelle['pleine'];
        return Marker(
          width: 30,
          height: 30,
          point: LatLng(poubelle['latitude'], poubelle['longitude']),
          child: Icon(
            Icons.location_pin,
            color: isPleine ? Colors.red : Colors.green,
            size: 40,
          ),
        );
      }).toList();
    });
  }


  Future<LatLng?> _getCoordinatesFromAddress(String address) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$address&format=json&limit=1');
    final response = await http.get(url, headers: {
      'User-Agent': 'flutter-map-app' // Obligatoire pour Nominatim
    });


    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);
        return LatLng(lat, lon);
      }
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Carte des poubelles")),
      body: Column(
        children: [
          // Zone de recherche
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Rechercher une adresse...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _searchText = value;
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () async {
                    final position =
                        await _getCoordinatesFromAddress(_searchText);
                    if (position != null) {
                      _mapController.move(position, 15.0);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Adresse introuvable'),backgroundColor: Colors.red,),
                      );
                    }
                  },
                ),
              ],
            ),
          ),


          // Carte
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: LatLng(36.8, 10.2),
                zoom: 12,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(markers: _markers),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



