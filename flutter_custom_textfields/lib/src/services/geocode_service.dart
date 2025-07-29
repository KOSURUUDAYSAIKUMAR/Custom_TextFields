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

      // Build address parts without extra spaces and line breaks
      List<String> addressParts = [];

      if (place.street != null && place.street!.isNotEmpty) {
        addressParts.add(place.street!);
      }

      if (place.subLocality != null && place.subLocality!.isNotEmpty) {
        addressParts.add(place.subLocality!);
      }

      if (place.locality != null && place.locality!.isNotEmpty) {
        addressParts.add(place.locality!);
      }

      if (place.administrativeArea != null &&
          place.administrativeArea!.isNotEmpty) {
        addressParts.add(place.administrativeArea!);
      }

      if (place.country != null && place.country!.isNotEmpty) {
        addressParts.add(place.country!);
      }

      // Join with commas and clean up
      return addressParts.join(', ');
    } catch (e) {
      print('Geocoding error: $e');
      return null;
    }
  }
}
