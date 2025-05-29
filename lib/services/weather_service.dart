import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_app/models/current_weather.dart';
import 'package:weather_app/models/daily_forecast.dart';

class WeatherService {
  static const String _apiKey = 'API_KEY';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  Future<CurrentWeather?> getCurrentWeather(String city) async {
    try {
      final url = '$_baseUrl/weather?q=$city&units=metric&appid=$_apiKey';
      print('Current weather API URL: $url');
      
      final response = await http.get(Uri.parse(url));
      
      print('Current weather response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return CurrentWeather.fromJson(data);
      } else if (response.statusCode == 404) {
        print('City not found: $city');
        return null;
      } else {
        print('API error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in getCurrentWeather: $e');
      throw Exception('Failed to load weather data');
    }
  }

  // New method: Get weather by coordinates
  Future<CurrentWeather?> getCurrentWeatherByCoordinates(double lat, double lon) async {
    try {
      final url = '$_baseUrl/weather?lat=$lat&lon=$lon&units=metric&appid=$_apiKey';
      print('Current weather by coordinates API URL: $url');
      
      final response = await http.get(Uri.parse(url));
      
      print('Current weather by coordinates response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return CurrentWeather.fromJson(data);
      } else {
        print('API error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in getCurrentWeatherByCoordinates: $e');
      throw Exception('Failed to load weather data');
    }
  }

  Future<List<DailyForecast>> getForecast(String city) async {
    try {
      final url = '$_baseUrl/forecast?q=$city&units=metric&appid=$_apiKey';
      print('Forecast API URL: $url');
      
      final response = await http.get(Uri.parse(url));
      
      print('Forecast response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['list'] == null) {
          print('No forecast list found in response');
          return [];
        }
        
        final List<dynamic> forecastList = data['list'];
        print('Forecast list length: ${forecastList.length}');
        
        // Group forecasts by day (take one per day, preferably around noon)
        Map<String, Map<String, dynamic>> dailyForecasts = {};
        
        for (var item in forecastList) {
          DateTime date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
          String dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          
          // Prefer forecasts around noon (12:00) for daily temperature
          if (!dailyForecasts.containsKey(dateKey) || 
              (date.hour >= 12 && date.hour <= 14)) {
            dailyForecasts[dateKey] = item;
          }
        }
        
        print('Daily forecasts grouped: ${dailyForecasts.length}');
        
        // Sort by date
        List<MapEntry<String, Map<String, dynamic>>> sortedEntries = 
            dailyForecasts.entries.toList()
            ..sort((a, b) => a.key.compareTo(b.key));
        
        return sortedEntries
            .map((entry) => DailyForecast.fromJson(entry.value))
            .toList();
            
      } else {
        print('Forecast API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load forecast data: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in getForecast: $e');
      throw Exception('Failed to load forecast data');
    }
  }

  // New method: Get forecast by coordinates
  Future<List<DailyForecast>> getForecastByCoordinates(double lat, double lon) async {
    try {
      final url = '$_baseUrl/forecast?lat=$lat&lon=$lon&units=metric&appid=$_apiKey';
      print('Forecast by coordinates API URL: $url');
      
      final response = await http.get(Uri.parse(url));
      
      print('Forecast by coordinates response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['list'] == null) {
          print('No forecast list found in response');
          return [];
        }
        
        final List<dynamic> forecastList = data['list'];
        print('Forecast list length: ${forecastList.length}');
        
        // Group forecasts by day (take one per day, preferably around noon)
        Map<String, Map<String, dynamic>> dailyForecasts = {};
        
        for (var item in forecastList) {
          DateTime date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
          String dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          
          // Prefer forecasts around noon (12:00) for daily temperature
          if (!dailyForecasts.containsKey(dateKey) || 
              (date.hour >= 12 && date.hour <= 14)) {
            dailyForecasts[dateKey] = item;
          }
        }
        
        print('Daily forecasts grouped: ${dailyForecasts.length}');
        
        // Sort by date
        List<MapEntry<String, Map<String, dynamic>>> sortedEntries = 
            dailyForecasts.entries.toList()
            ..sort((a, b) => a.key.compareTo(b.key));
        
        return sortedEntries
            .map((entry) => DailyForecast.fromJson(entry.value))
            .toList();
            
      } else {
        print('Forecast API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load forecast data: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in getForecastByCoordinates: $e');
      throw Exception('Failed to load forecast data');
    }
  }
}