class PrayerTime {
  final String date;
  final String fajr;     // İmsak
  final String sunrise;  // Güneş
  final String dhuhr;    // Öğle
  final String asr;      // İkindi
  final String maghrib;  // Akşam
  final String isha;     // Yatsı
  final String qibla;    // Kıble saati (varsa)

  PrayerTime({
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    this.qibla = '',
  });

  factory PrayerTime.fromJson(Map<String, dynamic> json) {
    return PrayerTime(
      date: json['date'] as String,
      fajr: json['fajr'] as String,
      sunrise: json['sunrise'] as String,
      dhuhr: json['dhuhr'] as String,
      asr: json['asr'] as String,
      maghrib: json['maghrib'] as String,
      isha: json['isha'] as String,
      qibla: json['qibla'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'fajr': fajr,
      'sunrise': sunrise,
      'dhuhr': dhuhr,
      'asr': asr,
      'maghrib': maghrib,
      'isha': isha,
      'qibla': qibla,
    };
  }

  // Bir sonraki namaz vaktini hesapla
  String getNextPrayerTime(DateTime currentTime) {
    final timeFormat = RegExp(r'(\d{2}):(\d{2})');
    
    final prayerTimes = [
      {'name': 'İmsak', 'time': fajr},
      {'name': 'Güneş', 'time': sunrise},
      {'name': 'Öğle', 'time': dhuhr},
      {'name': 'İkindi', 'time': asr},
      {'name': 'Akşam', 'time': maghrib},
      {'name': 'Yatsı', 'time': isha},
    ];
    
    final currentHour = currentTime.hour;
    final currentMinute = currentTime.minute;
    
    for (var prayer in prayerTimes) {
      final match = timeFormat.firstMatch(prayer['time']!);
      if (match != null) {
        final prayerHour = int.parse(match.group(1)!);
        final prayerMinute = int.parse(match.group(2)!);
        
        if (prayerHour > currentHour || 
            (prayerHour == currentHour && prayerMinute > currentMinute)) {
          return prayer['name']!;
        }
      }
    }
    
    // Eğer bugünün tüm vakitleri geçmişse, yarının ilk vakti
    return 'İmsak';
  }

  // Kalan süreyi hesapla
  String getRemainingTime(DateTime currentTime, String prayerName) {
    final timeFormat = RegExp(r'(\d{2}):(\d{2})');
    String prayerTime = '';
    
    switch(prayerName) {
      case 'İmsak':
        prayerTime = fajr;
        break;
      case 'Güneş':
        prayerTime = sunrise;
        break;
      case 'Öğle':
        prayerTime = dhuhr;
        break;
      case 'İkindi':
        prayerTime = asr;
        break;
      case 'Akşam':
        prayerTime = maghrib;
        break;
      case 'Yatsı':
        prayerTime = isha;
        break;
      default:
        return '00:00';
    }
    
    final match = timeFormat.firstMatch(prayerTime);
    if (match != null) {
      final prayerHour = int.parse(match.group(1)!);
      final prayerMinute = int.parse(match.group(2)!);
      
      DateTime prayerDateTime = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        prayerHour,
        prayerMinute,
      );
      
      // Eğer bir sonraki namaz imsak ise ve şu an yatsıdan sonra ise, bir sonraki günün tarihini kullan
      bool isNextDayPrayer = false;
      
      // Yatsı vaktinin saatini al
      final ishaMatch = timeFormat.firstMatch(isha);
      if (ishaMatch != null) {
        final ishaHour = int.parse(ishaMatch.group(1)!);
        final ishaMinute = int.parse(ishaMatch.group(2)!);
        
        // Eğer imsak vakti ve şu anki saat yatsı vaktinden sonra ise, bir sonraki günü kullan
        if (prayerName == 'İmsak' && (currentTime.hour > ishaHour || 
            (currentTime.hour == ishaHour && currentTime.minute >= ishaMinute))) {
          isNextDayPrayer = true;
        }
      }
      
      if (isNextDayPrayer) {
        prayerDateTime = prayerDateTime.add(const Duration(days: 1));
      }
      
      // Eğer hesaplanan vakit şu anki zamandan önce ise, bu vakit geçmiştir (bir sonraki günün vakti)
      if (prayerDateTime.isBefore(currentTime)) {
        prayerDateTime = prayerDateTime.add(const Duration(days: 1));
      }
      
      final difference = prayerDateTime.difference(currentTime);
      
      final hours = difference.inHours;
      final minutes = difference.inMinutes.remainder(60);
      
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    }
    
    return '00:00';
  }
}