
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';


class OpenRouteService {
  static const String apiKey = '5b3ce3597851110001cf62480591eaf831784651b7547d599cf25cea';
  static const String baseUrl = 'https://api.openrouteservice.org/v2/directions/driving-car';


  // ✅ Méthode existante pour un trajet entre DEUX points (start ➔ end)
  Future<Map<String, dynamic>> getOptimalRoute(double startLat, double startLng, double endLat, double endLng) async {
    final url = Uri.parse(
      '$baseUrl?api_key=$apiKey&start=$startLng,$startLat&end=$endLng,$endLat',
    );
    print(url);


    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );


    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);


      final route = data['features'][0];
      final geometry = route['geometry']['coordinates'];
      final distance = route['properties']['segments'][0]['distance'];
      final duration = route['properties']['segments'][0]['duration'];


      final coordinates = geometry.map((point) => [point[1], point[0]]).toList();


      return {
        'coordinates': coordinates,
        'distance': distance,
        'duration': duration,
      };
    } else {
      throw Exception('Erreur lors de la récupération de l\'itinéraire');
    }
  }


  // 🚀 Nouvelle méthode pour un trajet entre PLUSIEURS points
  Future<List<LatLng>> getRouteBetweenMultiplePoints(List<LatLng> points) async {
    final url = Uri.parse('$baseUrl/geojson');


    // Construire le corps de la requête
    final coordinates = points.map((point) => [point.longitude, point.latitude]).toList();


    final body = json.encode({
      "coordinates": coordinates,
      "instructions": false,
    });


    final response = await http.post(
      url,
      headers: {
        'Authorization': apiKey,
        'Content-Type': 'application/json',
      },
      body: body,
    );


    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final routeCoords = data['features'][0]['geometry']['coordinates'] as List<dynamic>;


      // Convertir en liste de LatLng
      return routeCoords.map<LatLng>((coord) {
        return LatLng(coord[1] as double, coord[0] as double);
      }).toList();
    } else {
      throw Exception('Erreur lors de la récupération de l\'itinéraire multiple');
    }
  }
}


