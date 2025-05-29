class CurrentWeather {
  final String cityName;
  final String country;
  final double temp;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String description;
  final String icon;
  final double lat;
  final double lon;
  final int pressure;
  final int visibility;
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime lastUpdated;

  CurrentWeather({
    required this.cityName,
    required this.country,
    required this.temp,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.icon,
    required this.lat,
    required this.lon,
    required this.pressure,
    required this.visibility,
    required this.sunrise,
    required this.sunset,
    required this.lastUpdated,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    try {
      return CurrentWeather(
        cityName: json['name'],
        country: json['sys']['country'],
        temp: json['main']['temp'].toDouble(),
        feelsLike: json['main']['feels_like'].toDouble(),
        humidity: json['main']['humidity'],
        windSpeed: json['wind']['speed'].toDouble(),
        description: json['weather'][0]['description'],
        icon: json['weather'][0]['icon'],
        lat: json['coord']['lat'].toDouble(),
        lon: json['coord']['lon'].toDouble(),
        pressure: json['main']['pressure'],
        visibility: json['visibility'],
        sunrise: DateTime.fromMillisecondsSinceEpoch(json['sys']['sunrise'] * 1000),
        sunset: DateTime.fromMillisecondsSinceEpoch(json['sys']['sunset'] * 1000),
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      print('Error parsing weather data: $e');
      print('JSON data: $json');
      rethrow;
    }
  }
}