import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/providers/weather_provider.dart';
import 'package:weather_app/models/current_weather.dart';
import 'package:weather_app/widgets/daily_forecast_widget.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // Location button in app bar
          Consumer<WeatherProvider>(
            builder: (context, weatherProvider, child) {
              return IconButton(
                icon: weatherProvider.isLocationLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.my_location),
                onPressed: weatherProvider.isLocationLoading 
                    ? null 
                    : () {
                        weatherProvider.getCurrentLocationWeather();
                      },
                tooltip: 'Get weather for current location',
              );
            },
          ),
        ],
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProvider, child) {
          final currentWeather = weatherProvider.currentWeather;
          final forecast = weatherProvider.forecast;
          final isLoading = weatherProvider.isLoading;
          final isLocationLoading = weatherProvider.isLocationLoading;
          final error = weatherProvider.error;
          
          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for a city',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      print('Searching for: $value');
                      weatherProvider.fetchWeatherData(value);
                    }
                  },
                ),
              ),
              
              // Location loading indicator
              if (isLocationLoading)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Getting your current location...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Debug info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                // child: Text(
                //   'Debug: Loading: $isLoading, Location Loading: $isLocationLoading, Error: ${error.isEmpty ? 'None' : error}, Forecast days: ${forecast.length}',
                //   style: const TextStyle(fontSize: 12, color: Colors.grey),
                // ),
              ),
              
              // Content
              Expanded(
                child: _buildContent(isLoading, error, currentWeather, forecast, weatherProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(
    bool isLoading,
    String error,
    CurrentWeather? currentWeather,
    List<dynamic> forecast,
    WeatherProvider weatherProvider,
  ) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading weather data...'),
          ],
        ),
      );
    }
    
    if (error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    weatherProvider.clearError();
                    if (weatherProvider.lastSearchedCity.isNotEmpty) {
                      weatherProvider.fetchWeatherData(weatherProvider.lastSearchedCity);
                    }
                  },
                  child: const Text('Try Again'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    weatherProvider.clearError();
                    weatherProvider.getCurrentLocationWeather();
                  },
                  icon: const Icon(Icons.my_location),
                  label: const Text('Use Location'),
                ),
              ],
            ),
          ],
        ),
      );
    }
    
    if (currentWeather == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Welcome to Weather App!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Search for a city or use your current location to get started',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    weatherProvider.getCurrentLocationWeather();
                  },
                  icon: const Icon(Icons.my_location),
                  label: const Text('Use Current Location'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'or',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Search for a city in the search bar above',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      );
    }
    
    // Display current weather and forecast
    return RefreshIndicator(
      onRefresh: () async {
        await weatherProvider.fetchWeatherData(currentWeather.cityName);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // City and date with location indicator
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${currentWeather.cityName}, ${currentWeather.country}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('EEEE, d MMMM y').format(DateTime.now()),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Show if this is the last searched city
                if (weatherProvider.lastSearchedCity == currentWeather.cityName)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history,
                          size: 16,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Recent',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Main weather card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Temperature and icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${currentWeather.temp.toStringAsFixed(1)}°C',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Feels like: ${currentWeather.feelsLike.toStringAsFixed(1)}°C',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Image.network(
                              'https://openweathermap.org/img/wn/${currentWeather.icon}@2x.png',
                              width: 80,
                              height: 80,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.cloud, size: 80);
                              },
                            ),
                            Text(
                              currentWeather.description.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Weather details
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildWeatherDetail(
                          Icons.water_drop, 
                          '${currentWeather.humidity}%', 
                          'Humidity'
                        ),
                        _buildWeatherDetail(
                          Icons.air, 
                          '${currentWeather.windSpeed} m/s', 
                          'Wind'
                        ),
                        _buildWeatherDetail(
                          Icons.visibility, 
                          '${(currentWeather.visibility / 1000).toStringAsFixed(1)} km', 
                          'Visibility'
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildWeatherDetail(
                          Icons.wb_sunny, 
                          DateFormat('h:mm a').format(currentWeather.sunrise), 
                          'Sunrise'
                        ),
                        _buildWeatherDetail(
                          Icons.nightlight_round, 
                          DateFormat('h:mm a').format(currentWeather.sunset), 
                          'Sunset'
                        ),
                        _buildWeatherDetail(
                          Icons.compress, 
                          '${currentWeather.pressure} hPa', 
                          'Pressure'
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Weekly forecast
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Weekly Forecast',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Quick location button in forecast section
                TextButton.icon(
                  onPressed: weatherProvider.isLocationLoading 
                      ? null 
                      : () {
                          weatherProvider.getCurrentLocationWeather();
                        },
                  icon: weatherProvider.isLocationLoading 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location, size: 16),
                  label: Text(
                    weatherProvider.isLocationLoading 
                        ? 'Getting location...' 
                        : 'Current Location',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            if (forecast.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'No forecast data available',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              )
            else
              ...forecast.map((day) => DailyForecastWidget(forecast: day)),
            
            const SizedBox(height: 20),
            Text(
              'Last updated: ${DateFormat('h:mm a').format(currentWeather.lastUpdated)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.blue),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}