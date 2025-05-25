import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/weather_provider.dart';
import '../widgets/weather_widget.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        return RefreshIndicator(
          onRefresh: () => weatherProvider.refreshWeather(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // City search
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Search Weather',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _cityController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter city name...',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.location_city),
                                ),
                                textInputAction: TextInputAction.search,
                                onSubmitted: (value) => _searchWeather(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: weatherProvider.isLoading ? null : _searchWeather,
                              child: const Icon(Icons.search),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: weatherProvider.isLoading
                                    ? null
                                    : () => weatherProvider.getCurrentLocationWeather(),
                                icon: const Icon(Icons.my_location),
                                label: const Text('Current Location'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: weatherProvider.isLoading
                                  ? null
                                  : () => weatherProvider.refreshWeather(),
                              icon: const Icon(Icons.refresh),
                              tooltip: 'Refresh',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Weather display
                if (weatherProvider.isLoading)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading weather data...'),
                        ],
                      ),
                    ),
                  )
                else if (weatherProvider.error != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Weather Error',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            weatherProvider.error!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              weatherProvider.clearError();
                              weatherProvider.getCurrentLocationWeather();
                            },
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (weatherProvider.weather != null)
                  Column(
                    children: [
                      WeatherWidget(weather: weatherProvider.weather!),
                      const SizedBox(height: 16),
                      _buildWeatherDetails(weatherProvider),
                    ],
                  )
                else
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.wb_sunny,
                            size: 64,
                            color: Colors.orange[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Weather Data',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Search for a city or use your current location to get weather information.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeatherDetails(WeatherProvider weatherProvider) {
    final weather = weatherProvider.weather!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weather Details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            
            _buildDetailRow(Icons.thermostat, 'Feels like', weather.feelsLikeString),
            _buildDetailRow(Icons.water_drop, 'Humidity', '${weather.humidity}%'),
            _buildDetailRow(Icons.air, 'Wind Speed', '${weather.windSpeed} m/s'),
            
            if (weatherProvider.lastUpdated != null) ...[
              const Divider(),
              Row(
                children: [
                  const Icon(Icons.update, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Last updated: ${DateFormat('MMM dd, HH:mm').format(weatherProvider.lastUpdated!)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _searchWeather() {
    final city = _cityController.text.trim();
    if (city.isNotEmpty) {
      context.read<WeatherProvider>().getWeatherByCity(city);
    }
  }
}
