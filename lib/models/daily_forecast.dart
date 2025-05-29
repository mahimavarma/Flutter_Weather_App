class DailyForecast {
  final DateTime date;
  final double tempDay;
  final double tempNight;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;

  DailyForecast({
    required this.date,
    required this.tempDay,
    required this.tempNight,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    try {
      // For 5-day forecast API
      return DailyForecast(
        date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
        tempDay: json['main']['temp'].toDouble(),
        tempNight: json['main']['temp_min'].toDouble(),
        description: json['weather'][0]['description'],
        icon: json['weather'][0]['icon'],
        humidity: json['main']['humidity'],
        windSpeed: json['wind']['speed'].toDouble(),
      );
    } catch (e) {
      print('Error parsing forecast data: $e');
      print('JSON data: $json');
      rethrow;
    }
  }
}