class ApiConstants {
  // Diyanet API endpoint
  static const String baseUrl = 'https://api.diyanet.gov.tr/';
  
  // Endpoint'ler
  static const String citiesEndpoint = 'cities';
  static const String districtsEndpoint = 'districts';
  static const String prayerTimesEndpoint = 'prayer-times/daily';
  static const String monthlyPrayerTimesEndpoint = 'prayer-times/monthly';
  
  // API Key parametreleri
  static const String apiKey = 'YOUR_API_KEY';
}

class AppConstants {
  // Uygulama sabitleri
  static const String appName = 'Namaz Vakti';
  static const String appVersion = '1.0.0';
  
  // Shared Preferences key'leri
  static const String prefSelectedCity = 'selected_city';
  static const String prefSelectedDistrict = 'selected_district';
  static const String prefNotifications = 'prayer_notifications';
  
  // Namaz vakitleri
  static const List<String> prayerNames = [
    'İmsak',
    'Güneş',
    'Öğle',
    'İkindi',
    'Akşam',
    'Yatsı',
  ];
}