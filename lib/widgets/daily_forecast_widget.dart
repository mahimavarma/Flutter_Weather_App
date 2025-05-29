import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/models/daily_forecast.dart';

class DailyForecastWidget extends StatelessWidget {
  final DailyForecast forecast;

  const DailyForecastWidget({Key? key, required this.forecast}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Day of week
            SizedBox(
              width: 100,
              child: Text(
                _isToday(forecast.date) 
                    ? 'Today' 
                    : DateFormat('EEEE').format(forecast.date),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            
            // Weather icon and description
            Row(
              children: [
                Image.network(
                  'https://openweathermap.org/img/wn/${forecast.icon}@2x.png',
                  width: 40,
                  height: 40,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.cloud, size: 40);
                  },
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: Text(
                    forecast.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            
            // Temperature
            Row(
              children: [
                Text(
                  '${forecast.tempDay.toStringAsFixed(0)}°',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${forecast.tempNight.toStringAsFixed(0)}°',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}