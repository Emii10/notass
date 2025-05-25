import 'package:flutter/material.dart';
import '../models/weather.dart';

class WeatherWidget extends StatelessWidget {
  final Weather weather;

  const WeatherWidget({
    super.key,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: _getWeatherGradient(weather.main),
        ),
        child: Column(
          children: [
            // City name
            Text(
              weather.cityName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Weather description
            Text(
              weather.description.split(' ').map((word) => 
                word[0].toUpperCase() + word.substring(1)
              ).join(' '),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Temperature and icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Weather icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _getWeatherIcon(weather.main),
                ),
                
                const SizedBox(width: 24),
                
                // Temperature
                Text(
                  weather.temperatureString,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient _getWeatherGradient(String weatherMain) {
    switch (weatherMain.toLowerCase()) {
      case 'clear':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2196F3), Color(0xFF21CBF3)],
        );
      case 'clouds':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF607D8B), Color(0xFF90A4AE)],
        );
      case 'rain':
      case 'drizzle':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0)],
        );
      case 'thunderstorm':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF424242), Color(0xFF616161)],
        );
      case 'snow':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF546E7A), Color(0xFF78909C)],
        );
      case 'mist':
      case 'haze':
      case 'fog':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF78909C), Color(0xFF90A4AE)],
        );
      default:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2196F3), Color(0xFF21CBF3)],
        );
    }
  }

  Widget _getWeatherIcon(String weatherMain) {
    IconData iconData;
    
    switch (weatherMain.toLowerCase()) {
      case 'clear':
        iconData = Icons.wb_sunny;
        break;
      case 'clouds':
        iconData = Icons.cloud;
        break;
      case 'rain':
        iconData = Icons.grain;
        break;
      case 'drizzle':
        iconData = Icons.grain;
        break;
      case 'thunderstorm':
        iconData = Icons.flash_on;
        break;
      case 'snow':
        iconData = Icons.ac_unit;
        break;
      case 'mist':
      case 'haze':
      case 'fog':
        iconData = Icons.blur_on;
        break;
      default:
        iconData = Icons.wb_sunny;
    }

    return Icon(
      iconData,
      size: 48,
      color: Colors.white,
    );
  }
}
