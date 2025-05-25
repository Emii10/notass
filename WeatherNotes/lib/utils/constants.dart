class AppConstants {
  // API Configuration
  static const String openWeatherMapBaseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  static const String weatherIconBaseUrl = 'https://openweathermap.org/img/wn/';
  
  // Database Configuration
  static const String databaseName = 'notes_database.db';
  static const int databaseVersion = 1;
  static const String notesTableName = 'notes';
  
  // App Configuration
  static const String appName = 'Notes & Weather';
  static const int weatherUpdateIntervalMinutes = 30;
  static const int maxNotesSearchResults = 100;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double cardElevation = 2.0;
  static const double borderRadius = 12.0;
  
  // Error Messages
  static const String noInternetError = 'No internet connection. Please check your network and try again.';
  static const String locationPermissionError = 'Location permission is required to get current weather.';
  static const String apiKeyError = 'Invalid API key. Please check your OpenWeatherMap API key.';
  static const String cityNotFoundError = 'City not found. Please check the spelling and try again.';
  static const String timeoutError = 'Request timed out. Please check your connection and try again.';
  static const String databaseError = 'Database error occurred. Please try again.';
  
  // Success Messages
  static const String noteSavedSuccess = 'Note saved successfully';
  static const String noteDeletedSuccess = 'Note deleted';
  static const String weatherUpdatedSuccess = 'Weather updated';
  
  // Preferences Keys
  static const String lastWeatherUpdateKey = 'last_weather_update';
  static const String lastSelectedCityKey = 'last_selected_city';
  static const String themePreferenceKey = 'theme_preference';
}
