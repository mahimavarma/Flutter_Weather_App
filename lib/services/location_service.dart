import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  
  /// Determine the current position of the device.
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable location services.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied. Please grant location permission.');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied. Please enable location permission in settings.');
    } 

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10), // Add timeout
    );
  }

  /// Get city name from coordinates with better null handling
  Future<String> getCityFromCoordinates(double latitude, double longitude) async {
    try {
      print('Getting city name for coordinates: $latitude, $longitude');
      
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude, 
        longitude,
        localeIdentifier: 'en', // Specify locale for better results
      );
      
      print('Placemarks found: ${placemarks.length}');
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        
        // Print all available placemark data for debugging
        print('Placemark data:');
        print('  name: ${place.name}');
        print('  locality: ${place.locality}');
        print('  subLocality: ${place.subLocality}');
        print('  administrativeArea: ${place.administrativeArea}');
        print('  subAdministrativeArea: ${place.subAdministrativeArea}');
        print('  country: ${place.country}');
        print('  isoCountryCode: ${place.isoCountryCode}');
        print('  postalCode: ${place.postalCode}');
        print('  thoroughfare: ${place.thoroughfare}');
        print('  subThoroughfare: ${place.subThoroughfare}');
        
        // Try different combinations to get a city name
        String? cityName;
        
        // First try locality (most common for city names)
        if (place.locality != null && place.locality!.isNotEmpty) {
          cityName = place.locality;
        }
        // Then try subAdministrativeArea
        else if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty) {
          cityName = place.subAdministrativeArea;
        }
        // Then try administrativeArea (state/province)
        else if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          cityName = place.administrativeArea;
        }
        // Then try subLocality
        else if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          cityName = place.subLocality;
        }
        // Finally try name
        else if (place.name != null && place.name!.isNotEmpty) {
          cityName = place.name;
        }
        
        if (cityName != null && cityName.isNotEmpty) {
          print('Found city name: $cityName');
          return cityName;
        } else {
          // If no city name found, return coordinates as fallback
          print('No city name found, using coordinates');
          return '${latitude.toStringAsFixed(2)}, ${longitude.toStringAsFixed(2)}';
        }
      } else {
        throw Exception('No location information found for coordinates');
      }
    } catch (e) {
      print('Error getting city from coordinates: $e');
      
      // If geocoding fails, we can still use coordinates to get weather
      // Return a formatted coordinate string as fallback
      return '${latitude.toStringAsFixed(2)}, ${longitude.toStringAsFixed(2)}';
    }
  }

  /// Alternative method: Get city name using a simpler approach
  Future<String> getCityFromCoordinatesSimple(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        
        // Create a list of possible city names in order of preference
        List<String?> possibleNames = [
          place.locality,
          place.subAdministrativeArea,
          place.administrativeArea,
          place.subLocality,
          place.name,
        ];
        
        // Return the first non-null, non-empty name
        for (String? name in possibleNames) {
          if (name != null && name.trim().isNotEmpty) {
            return name.trim();
          }
        }
        
        // If nothing found, return coordinates
        return 'Location ${latitude.toStringAsFixed(2)}, ${longitude.toStringAsFixed(2)}';
      } else {
        return 'Location ${latitude.toStringAsFixed(2)}, ${longitude.toStringAsFixed(2)}';
      }
    } catch (e) {
      print('Geocoding failed: $e');
      return 'Location ${latitude.toStringAsFixed(2)}, ${longitude.toStringAsFixed(2)}';
    }
  }

  /// Check if location permission is granted
  Future<bool> isLocationPermissionGranted() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
}