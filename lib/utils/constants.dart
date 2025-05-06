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

class StringHelper {
  /// API'den gelen il ve ilçe isimlerindeki karakter hatalarını düzeltir
  static String fixTurkishChars(String text) {
    if (text.isEmpty) {
      return text;
    }
    
    // Karakter kodlama sorunu düzeltmeleri
    Map<String, String> encodingFixes = {
      'Ã°': 'İ',
      'Ã°Å': 'İS',
      'Ã': 'İ',
      'Ã\u0087': 'Ç',
      'Ã\u0096': 'Ö',
      'Ã\u009c': 'Ü',
      'Ã\u0098': 'Ş',
      'Ã\u009e': 'Ğ',
      'Ã\u0084': 'Ä', // Bazen "A" olabilir
      'Ã\u0082': 'Â',
      'Â°': 'İ',
      'Å': 'Ş',
      'ÅŸ': 'ş',
      'Ãœ': 'Ü',
      'Ã‡': 'Ç',
      'Ã–': 'Ö',
      'Ä°': 'İ',
      'Ã¼': 'ü',
      'Ã¶': 'ö',
      'Ã§': 'ç',
      'Äž': 'Ğ',
      'ÄŸ': 'ğ',
      'Ä±': 'ı',
    };
    
    // Tam şehir adı düzeltmeleri
    Map<String, String> cityNameFixes = {
      'ISTANBUL': 'İSTANBUL',
      'İSTANBÜL': 'İSTANBUL',
      'KOCAELI': 'KOCAELİ',
      'IZMIR': 'İZMİR',
      'KUTAHYA': 'KÜTAHYA',
      'KONYA': 'KONYA',
      'KÖNYA': 'KONYA',
      'ADIYAMAN': 'ADIYAMAN',
      'AGRI': 'AĞRI',
      'CORUM': 'ÇORUM',
      'ISPARTA': 'ISPARTA',
      'SANLIURFA': 'ŞANLIURFA',
      'SIRNAK': 'ŞIRNAK',
      'USAK': 'UŞAK',
      'CIN': 'ÇİN',
      'TURKIYE': 'TÜRKİYE',
    };
    
    // Önce belli başlı hatalı karakterleri düzelt
    String result = text;
    encodingFixes.forEach((wrong, correct) {
      result = result.replaceAll(wrong, correct);
    });
    
    // Sonra tam şehir adı eşleşmesi varsa düzelt
    String upperCaseResult = result.toUpperCase();
    for (final entry in cityNameFixes.entries) {
      if (upperCaseResult == entry.key || upperCaseResult.contains(entry.key)) {
        return entry.value;
      }
    }
    
    // Geriye kalan sorunlu karakterleri tek tek incele
    Map<String, String> charFixes = {
      'I': 'İ',
      'i': 'ı',
      'G': 'G', // Eğer gerçekten Ğ olması gerekiyorsa 'Ğ' yapın
      'g': 'g', // Eğer gerçekten ğ olması gerekiyorsa 'ğ' yapın
      'U': 'U', // Eğer gerçekten Ü olması gerekiyorsa 'Ü' yapın
      'u': 'u', // Eğer gerçekten ü olması gerekiyorsa 'ü' yapın
      'O': 'O', // Eğer gerçekten Ö olması gerekiyorsa 'Ö' yapın
      'o': 'o', // Eğer gerçekten ö olması gerekiyorsa 'ö' yapın
      'C': 'C', // Eğer gerçekten Ç olması gerekiyorsa 'Ç' yapın
      'c': 'c', // Eğer gerçekten ç olması gerekiyorsa 'ç' yapın
      'S': 'S', // Eğer gerçekten Ş olması gerekiyorsa 'Ş' yapın
      's': 's', // Eğer gerçekten ş olması gerekiyorsa 'ş' yapın
    };
    
    // Kodla alakalı karşılaştırma yap ve debug için logla
    print("Fixing city name: '$text' -> '$result'");
    
    return result;
  }
  
  /// API yanıtlarındaki kodlama sorunlarını tespit et ve kaydet
  static void debugEncodingIssue(String originalText) {
    print("Character encoding debug for: $originalText");
    for (int i = 0; i < originalText.length; i++) {
      int codePoint = originalText.codeUnitAt(i);
      String char = originalText[i];
      print("Character at position $i: '$char', codePoint: $codePoint, hex: ${codePoint.toRadixString(16)}");
    }
  }
}