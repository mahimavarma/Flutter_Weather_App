import 'package:flutter/material.dart';

class WeatherIcon extends StatelessWidget {
  final String iconCode;
  final double size;

  const WeatherIcon({
    Key? key,
    required this.iconCode,
    this.size = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.network(
      'https://openweathermap.org/img/wn/$iconCode@2x.png',
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) {
        return _getIconFallback();
      },
    );
  }

  Widget _getIconFallback() {
    IconData iconData;
    
    // Map OpenWeather icon codes to Material icons
    switch (iconCode) {
      case '01d': // clear sky day
        iconData = Icons.wb_sunny;
        break;
      case '01n': // clear sky night
        iconData = Icons.nightlight_round;
        break;
      case '02d': // few clouds day
      case '03d': // scattered clouds day
        iconData = Icons.wb_cloudy; // Changed from partly_cloudy_day
        break;
      case '02n': // few clouds night
      case '03n': // scattered clouds night
        iconData = Icons.cloud; // Changed from nights_stay
        break;
      case '04d': // broken clouds day
      case '04n': // broken clouds night
        iconData = Icons.cloud;
        break;
      case '09d': // shower rain day
      case '09n': // shower rain night
        iconData = Icons.grain;
        break;
      case '10d': // rain day
      case '10n': // rain night
        iconData = Icons.water_drop;
        break;
      case '11d': // thunderstorm day
      case '11n': // thunderstorm night
        iconData = Icons.flash_on;
        break;
      case '13d': // snow day
      case '13n': // snow night
        iconData = Icons.ac_unit;
        break;
      case '50d': // mist day
      case '50n': // mist night
        iconData = Icons.foggy;
        break;
      default:
        iconData = Icons.help_outline;
    }

    return Icon(
      iconData,
      size: size,
      color: _getIconColor(iconCode),
    );
  }

  Color _getIconColor(String iconCode) {
    if (iconCode.startsWith('01')) {
      return Colors.amber;
    } else if (iconCode.startsWith('02') || iconCode.startsWith('03')) {
      return Colors.lightBlue;
    } else if (iconCode.startsWith('04')) {
      return Colors.blueGrey;
    } else if (iconCode.startsWith('09') || iconCode.startsWith('10')) {
      return Colors.blue;
    } else if (iconCode.startsWith('11')) {
      return Colors.deepPurple;
    } else if (iconCode.startsWith('13')) {
      return Colors.lightBlue;
    } else if (iconCode.startsWith('50')) {
      return Colors.grey;
    }
    return Colors.grey;
  }
}