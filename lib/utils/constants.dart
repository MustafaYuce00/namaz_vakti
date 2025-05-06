class ApiConstants {
  // New API endpoints
  static const String baseUrl = 'https://ezanvakti.emushaf.net';
  
  // Endpoints
  static const String citiesEndpoint = '/sehirler/2';
  static const String districtsEndpoint = '/ilceler';
  static const String prayerTimesEndpoint = '/vakitler';
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