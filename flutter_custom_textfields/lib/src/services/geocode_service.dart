import 'package:geocoding/geocoding.dart';

class GeocodeService {
  static Future<String?> getAddressFromLatLng(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) {
        return null;
      }
      final place = placemarks.first;
      return "Lat: $latitude, \n Long: $longitude, \n ${place.street}, \n ${place.locality}, \n ${place.country}";
    } catch (_) {
      return null;
    }
  }
}
