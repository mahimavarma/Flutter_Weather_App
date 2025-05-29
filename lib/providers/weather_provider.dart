import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/models/current_weather.dart';
import 'package:weather_app/models/daily_forecast.dart';
import 'package:weather_app/services/weather_service.dart';

class WeatherProvider with ChangeNotifier {
  CurrentWeather? _currentWeather;
  List<DailyForecast> _forecast = [];
  bool _isLoading = false;
  String _error = '';
  String _lastSearchedCity = '';
  final WeatherService _weatherService = WeatherService();

  CurrentWeather? get currentWeather => _currentWeather;
  List<DailyForecast> get forecast => _forecast;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get lastSearchedCity => _lastSearchedCity;

  WeatherProvider() {
    _loadLastSearchedCity();
  }

  Future<void> _loadLastSearchedCity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCity = prefs.getString('lastCity');
      if (lastCity != null && lastCity.isNotEmpty) {
        _lastSearchedCity = lastCity;
        await fetchWeatherData(lastCity);
      }
    } catch (e) {
      print('Error loading last searched city: $e');
    }
  }

  Future<void> _saveLastSearchedCity(String city) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastCity', city);
      _lastSearchedCity = city;
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
          _forecast = []; // Clear forecast but keep current weather
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