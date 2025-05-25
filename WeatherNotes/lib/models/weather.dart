class Weather {
  final String cityName;
  final double temperature;
  final String description;
  final String main;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String iconCode;
  final DateTime timestamp;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.main,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.iconCode,
    required this.timestamp,
  });

  factory Weather.fromJson(Map<String, dynamic> json, String cityName) {
    return Weather(
      cityName: cityName,
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'],
      main: json['weather'][0]['main'],
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      humidity: json['main']['humidity'],
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      iconCode: json['weather'][0]['icon'],
      timestamp: DateTime.now(),
    );
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$iconCode@2x.png';

  String get temperatureString => '${temperature.round()}°C';
  
  String get feelsLikeString => '${feelsLike.round()}°C';

  @override
  String toString() {
    return 'Weather{cityName: $cityName, temperature: $temperature, description: $description}';
  }
}
