import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../services/poubelles_service.dart';
import '../services/open_route_service.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../screens/auth/login_screen.dart';
import '../services/sites_services.dart';

class CollectorDashboardScreen extends StatefulWidget {
  const CollectorDashboardScreen({Key? key}) : super(key: key);

  @override
  State<CollectorDashboardScreen> createState() => _CollectorDashboardScreenState();
}

class _CollectorDashboardScreenState extends State<CollectorDashboardScreen> {
  List<LatLng> routePoints = [];
  List<Marker> poubelleMarkers = [];
  bool _isLoading = false;
  bool _hasError = false;
  final PoubellesService _poubellesService = PoubellesService();
  final OpenRouteService _openRouteService = OpenRouteService();
  final SitesService _sitesService = SitesService();
  List<String> secteurs = [];

  @override
  void initState() {
    super.initState();
    _loadSecteursEtPoubelles();
  }

  Future<void> _loadSecteursEtPoubelles() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.userId;

      if (userId != null) {
        final List<String> data = await _sitesService.getSecteurByChauffeurID(userId);
        print(data);
        setState(() {
          secteurs = data;
        });
      } else {
        print("Aucun ID de chauffeur disponible.");
      }
    } catch (e) {
      print("Erreur de chargement : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement des données')),
      );
    }
  }

  Future<void> fetchOptimalRoute() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final double currentLat = position.latitude;
      final double currentLng = position.longitude;

      Marker startMarker = Marker(
        point: LatLng(currentLat, currentLng),
        width: 70,
        height: 70,
        child: const Icon(Icons.fire_truck, color: Color.fromARGB(255, 239, 123, 7)),
      );

      if (secteurs.isEmpty) {
        print("Aucun secteur défini !");
        setState(() => _isLoading = false);
        return;
      }

      final secteursCSV = secteurs.join(',');
      final uri = Uri.parse(
        'http://localhost:3000/api/itineraire/itineraire-optimal?latitude=$currentLat&longitude=$currentLng&secteurs=${Uri.encodeComponent(secteursCSV)}',
      );
      final response = await http.get(uri);


      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<LatLng> optimalPoints = [
          LatLng(currentLat, currentLng),
          ...data.map((point) => LatLng(point['latitude'] as double, point['longitude'] as double))
        ];

        final routeData = await _openRouteService.getRouteBetweenMultiplePoints(optimalPoints);

        setState(() {
          routePoints = routeData;
          poubelleMarkers.insert(0, startMarker);
        });

        try {
          final poubelles = await _poubellesService.getPoubellesPleine(secteurs);

          setState(() {
            poubelleMarkers.addAll(poubelles.map<Marker>((poubelle) {
              final double lat = double.parse(poubelle['latitude'].toString());
              final double lng = double.parse(poubelle['longitude'].toString());
              return Marker(
                point: LatLng(lat, lng),
                width: 40,
                height: 40,
                child: const Icon(Icons.location_on, color: Colors.red),
              );
            }).toList());
          });

        } catch (e) {
          _hasError = true;
          print('Erreur lors de la récupération des poubelles pleines: $e');
        }
      } else {
        _hasError = true;
        print('Erreur Backend : ${response.body}');
      }
    } catch (e) {
      _hasError = true;
      print('Erreur générale : $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Itinéraire de collecte'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthService>(context, listen: false).signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? const Center(child: Text('Erreur lors de la récupération des données'))
              : FlutterMap(
                  options: MapOptions(
                    center: routePoints.isNotEmpty ? routePoints.first : LatLng(36.8065, 10.1815),
                    zoom: 14,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.app',
                    ),
                    if (routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: routePoints,
                            strokeWidth: 4.0,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: poubelleMarkers,
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchOptimalRoute,
        child: const Icon(Icons.directions),
      ),
    );
  }
}
