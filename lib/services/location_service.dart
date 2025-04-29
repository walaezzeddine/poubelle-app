// location_service.dart
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';


class LocationService {
  // Fonction pour obtenir la position actuelle de l'utilisateur
  Future<LatLng?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;


    // Vérifier si le service de localisation est activé
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Le service de localisation est désactivé.");
      return null;
    }


    // Vérifier les permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("La permission d'accès à la localisation est refusée.");
        return null;
      }
    }


    if (permission == LocationPermission.deniedForever) {
      print("La permission d'accès à la localisation est définitivement refusée.");
      return null;
    }


    // Obtenir la position actuelle de l'utilisateur
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return LatLng(position.latitude, position.longitude);  // Retourner la position sous forme de LatLng
  }
}


