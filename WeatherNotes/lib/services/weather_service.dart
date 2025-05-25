import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/weather.dart';
import '../utils/constants.dart';

class WeatherService {
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  
  // Get API key from environment variables with fallback
  static String get apiKey => const String.fromEnvironment('OPENWEATHER_API_KEY', defaultValue: '6d834949e6247ad48ea249f818b9a0cc');

  // Get current location
  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      throw Exception('Failed to get location: $e');
    }
  }

  // Get weather by coordinates
  Future<Weather> getWeatherByCoordinates(double lat, double lon) async {
    try {
      final url = Uri.parse(
        '$baseUrl?lat=$lat&lon=$lon&appid=$apiKey&units=metric'
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Weather.fromJson(data, data['name']);
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key. Please check your OpenWeatherMap API key.');
      } else if (response.statusCode == 404) {
        throw Exception('Location not found');
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network and try again.');
    } on http.ClientException {
      throw Exception('Network error occurred. Please try again.');
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timed out. Please check your connection and try again.');
      }
      rethrow;
    }
  }

  // Get weather by city name
  Future<Weather> getWeatherByCity(String cityName) async {
    try {
      final url = Uri.parse(
        '$baseUrl?q=$cityName&appid=$apiKey&units=metric'
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Weather.fromJson(data, data['name']);
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key. Please check your OpenWeatherMap API key.');
      } else if (response.statusCode == 404) {
        throw Exception('City not found. Please check the spelling and try again.');
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network and try again.');
    } on http.ClientException {
      throw Exception('Network error occurred. Please try again.');
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timed out. Please check your connection and try again.');
      }
      rethrow;
    }
  }

  // Get weather for current location
  Future<Weather> getCurrentLocationWeather() async {
    try {
      final position = await getCurrentLocation();
      if (position == null) {
        throw Exception('Unable to get current location');
      }
      return await getWeatherByCoordinates(position.latitude, position.longitude);
    } catch (e) {
      rethrow;
    }
  }
}
