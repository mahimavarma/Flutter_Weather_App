import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/models/current_weather.dart';
import 'package:weather_app/models/daily_forecast.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:geolocator/geolocator.dart';

class WeatherProvider with ChangeNotifier {
  CurrentWeather? _currentWeather;
  List<DailyForecast> _forecast = [];
  bool _isLoading = false;
  String _error = '';
  String _lastSearchedCity = '';
  bool _isLocationLoading = false;
  final WeatherService _weatherService = WeatherService();

  CurrentWeather? get currentWeather => _currentWeather;
  List<DailyForecast> get forecast => _forecast;
  bool get isLoading => _isLoading;
  bool get isLocationLoading => _isLocationLoading;
  String get error => _error;
  String get lastSearchedCity => _lastSearchedCity;

  WeatherProvider() {
    _initializeApp();
  }

  /// Initialize the app - only load last searched city, no automatic location
  Future<void> _initializeApp() async {
    print('Initializing app...');
    
    // Only load the last searched city on startup
    await _loadLastSearchedCity();
  }

  /// Load and display weather for the last searched city
  Future<void> _loadLastSearchedCity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCity = prefs.getString('lastCity');
      if (lastCity != null && lastCity.isNotEmpty) {
        _lastSearchedCity = lastCity;
        print('Loading last searched city: $lastCity');
        await fetchWeatherData(lastCity);
      } else {
        print('No last searched city found');
      }
    } catch (e) {
      print('Error loading last searched city: $e');
    }
  }

  /// Manually get weather for current location (only when user clicks button)
  Future<void> getCurrentLocationWeather() async {
    try {
      _isLocationLoading = true;
      _error = '';
      notifyListeners();

      print('Getting current location weather...');

      // Check if location services are available
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled. Please enable location services in your device settings.');
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied. Please grant location permission to use this feature.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied. Please enable location permission in your device settings.');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
      
      print('Got location: ${position.latitude}, ${position.longitude}');

      // Fetch weather using coordinates
      await _fetchWeatherByCoordinates(position.latitude, position.longitude);
      
    } catch (e) {
      print('Failed to get location weather: $e');
      _error = e.toString();
      _currentWeather = null;
      _forecast = [];
    } finally {
      _isLocationLoading = false;
      notifyListeners();
    }
  }

  /// Fetch weather by coordinates
  Future<void> _fetchWeatherByCoordinates(double lat, double lon) async {
    _isLoading = true;
    notifyListeners();

    try {
      print('Fetching weather for coordinates: $lat, $lon');
      
      // Get current weather by coordinates
      final currentWeatherData = await _weatherService.getCurrentWeatherByCoordinates(lat, lon);
      
      if (currentWeatherData != null) {
        _currentWeather = currentWeatherData;
        
        // Use the city name from the weather API response
        String cityName = currentWeatherData.cityName;
        if (cityName.isNotEmpty) {
          await _saveLastSearchedCity(cityName);
        }
        
        // Try to get forecast
        try {
          _forecast = await _weatherService.getForecastByCoordinates(lat, lon);
          print('Successfully loaded ${_forecast.length} forecast days for location');
        } catch (forecastError) {
          print('Forecast failed for location: $forecastError');
          _forecast = [];
        }
        
        _error = '';
      } else {
        _error = 'Failed to get weather for current location';
        _currentWeather = null;
        _forecast = [];
      }
    } catch (e) {
      _error = 'Failed to fetch weather data: ${e.toString()}';
      _currentWeather = null;
      _forecast = [];
      print('Error fetching weather data by coordinates: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveLastSearchedCity(String city) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastCity', city);
      _lastSearchedCity = city;
      print('Saved last searched city: $city');
    } catch (e) {
      print('Error saving last searched city: $e');
    }
  }

  Future<void> fetchWeatherData(String city) async {
    if (city.isEmpty) return;
    
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      print('Fetching weather for city: $city');
      
      // First, get current weather
      final currentWeatherData = await _weatherService.getCurrentWeather(city);
      
      if (currentWeatherData != null) {
        _currentWeather = currentWeatherData;
        await _saveLastSearchedCity(city);
        
        // Try to get forecast
        try {
          _forecast = await _weatherService.getForecast(city);
          print('Successfully loaded ${_forecast.length} forecast days');
        } catch (forecastError) {
          print('Forecast failed, but current weather succeeded: $forecastError');
          _forecast = [];
        }
        
        _error = '';
      } else {
        _error = 'City not found';
        _currentWeather = null;
        _forecast = [];
      }
    } catch (e) {
      _error = 'Failed to fetch weather data: ${e.toString()}';
      _currentWeather = null;
      _forecast = [];
      print('Error fetching weather data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}