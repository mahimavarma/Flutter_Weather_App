import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/models/current_weather.dart';
import 'package:weather_app/utils/weather_icons.dart';

class CurrentWeatherWidget extends StatelessWidget {
  final CurrentWeather weather;

  const CurrentWeatherWidget({Key? key, required this.weather}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDaytime = DateTime.now().isAfter(weather.sunrise) && 
                      DateTime.now().isBefore(weather.sunset);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDaytime 
              ? [Colors.blue.shade300, Colors.blue.shade600]
              : [Colors.indigo.shade400, Colors.indigo.shade900],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weather.cityName}, ${weather.country}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    DateFormat('EEEE, d MMMM y').format(DateTime.now()),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    'Last updated: ${DateFormat('h:mm a').format(weather.lastUpdated)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              WeatherIcon(iconCode: weather.icon, size: 60),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weather.temp.toStringAsFixed(1)}°C',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Feels like: ${weather.feelsLike.toStringAsFixed(1)}°C',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    weather.description.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.water_drop, color: Colors.white70, size: 16),
                      const SizedBox(width: 5),
                      Text(
                        '${weather.humidity}%',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.air, color: Colors.white70, size: 16),
                      const SizedBox(width: 5),
                      Text(
                        '${weather.windSpeed} m/s',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(
                Icons.visibility,
                '${(weather.visibility / 1000).toStringAsFixed(1)} km',
                'Visibility',
              ),
              _buildInfoItem(
                Icons.compress,
                '${weather.pressure} hPa',
                'Pressure',
              ),
              _buildInfoItem(
                Icons.wb_sunny,
                DateFormat('h:mm a').format(weather.sunrise),
                'Sunrise',
              ),
              _buildInfoItem(
                Icons.nightlight_round,
                DateFormat('h:mm a').format(weather.sunset),
                'Sunset',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}