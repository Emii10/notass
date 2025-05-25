import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../services/weather_service.dart';

class WeatherProvider with ChangeNotifier {
  Weather? _weather;
  bool _isLoading = false;
  String? _error;
  DateTime? _lastUpdated;

  Weather? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;

  final WeatherService _weatherService = WeatherService();

  // Get weather for current location
  Future<void> getCurrentLocationWeather() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _weather = await _weatherService.getCurrentLocationWeather();
      _lastUpdated = DateTime.now();
    } catch (e) {
      _error = e.toString();
      _weather = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get weather by city name
  Future<void> getWeatherByCity(String cityName) async {
    if (cityName.trim().isEmpty) {
      _error = 'Please enter a city name';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _weather = await _weatherService.getWeatherByCity(cityName.trim());
      _lastUpdated = DateTime.now();
    } catch (e) {
      _error = e.toString();
      _weather = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh current weather
  Future<void> refreshWeather() async {
    if (_weather != null) {
      await getWeatherByCity(_weather!.cityName);
    } else {
      await getCurrentLocationWeather();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Check if weather data is stale (older than 30 minutes)
  bool get isWeatherStale {
    if (_lastUpdated == null) return true;
    return DateTime.now().difference(_lastUpdated!).inMinutes > 30;
  }

  // Auto-refresh weather if stale
  Future<void> autoRefreshIfNeeded() async {
    if (isWeatherStale && !_isLoading) {
      await refreshWeather();
    }
  }
}
