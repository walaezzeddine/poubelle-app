import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CollectorDashboardScreen extends StatefulWidget {
  const CollectorDashboardScreen({super.key});

  @override
  State<CollectorDashboardScreen> createState() => _CollectorDashboardScreenState();
}

class _CollectorDashboardScreenState extends State<CollectorDashboardScreen> {
  final List<LatLng> routePoints = [
    LatLng(36.8065, 10.1815), // Tunis
    LatLng(36.8070, 10.1800),
    LatLng(36.8080, 10.1785),
    LatLng(36.8100, 10.1765),
    LatLng(36.8120, 10.1750),
    LatLng(36.8189, 10.1658), // Le Lac
  ];

  int currentIndex = 0;
  Timer? _timer;

  LatLng? movingMarker;

  void startSimulation() {
    _timer?.cancel();
    setState(() {
      movingMarker = routePoints[0];
      currentIndex = 1;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (currentIndex < routePoints.length) {
        setState(() {
          movingMarker = routePoints[currentIndex];
          currentIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Itinéraire de collecte')),
      body: FlutterMap(
        options: MapOptions(
          center: routePoints[0],
          zoom: 14,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.app',
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: routePoints,
                strokeWidth: 4.0,
                color: Colors.blue,
              )
            ],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: routePoints.first,
                width: 40,
                height: 40,
                child: const Icon(Icons.flag, color: Colors.green),
              ),
              Marker(
                point: routePoints.last,
                width: 40,
                height: 40,
                child: const Icon(Icons.location_on, color: Colors.red),
              ),
              if (movingMarker != null)
                Marker(
                  point: movingMarker!,
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.directions_bus, color: Colors.orange, size: 36),
                ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: startSimulation,
        label: const Text("Démarrer"),
        icon: const Icon(Icons.play_arrow),
      ),
    );
  }
}
