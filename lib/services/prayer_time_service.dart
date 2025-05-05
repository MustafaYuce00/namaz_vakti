import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:namaz_vakti/models/city.dart';
import 'package:namaz_vakti/models/prayer_time.dart';
import 'package:namaz_vakti/utils/constants.dart';

class PrayerTimeService {
  final String baseUrl = ApiConstants.baseUrl;
  
  // İlleri getir
  Future<List<City>> getCities() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiConstants.citiesEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiConstants.apiKey}',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> citiesJson = json.decode(response.body);
        return citiesJson.map((city) => City.fromJson(city)).toList();
      } else {
        throw Exception('Failed to load cities: ${response.statusCode}');
      }
    } catch (e) {
      // Gerçek API'ye bağlanmak yerine sahte veri gösterelim
      // Bu kısmı gerçek API'ye bağlandığınızda kaldırabilirsiniz
      return _getMockCities();
    }
  }
  
  // İlçeleri getir
  Future<List<City>> getDistricts(int cityId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiConstants.districtsEndpoint}/$cityId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiConstants.apiKey}',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> districtsJson = json.decode(response.body);
        return districtsJson.map((district) => City.fromJson(district)).toList();
      } else {
        throw Exception('Failed to load districts: ${response.statusCode}');
      }
    } catch (e) {
      // Gerçek API'ye bağlanmak yerine sahte veri gösterelim
      return _getMockDistricts(cityId);
    }
  }
  
  // Günlük namaz vakitlerini getir
  Future<PrayerTime> getDailyPrayerTimes(int cityId, int districtId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiConstants.prayerTimesEndpoint}/$cityId/$districtId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiConstants.apiKey}',
        },
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> prayerTimeJson = json.decode(response.body);
        return PrayerTime.fromJson(prayerTimeJson);
      } else {
        throw Exception('Failed to load prayer times: ${response.statusCode}');
      }
    } catch (e) {
      // Gerçek API'ye bağlanmak yerine sahte veri gösterelim
      return _getMockDailyPrayerTime();
    }
  }
  
  // Aylık namaz vakitlerini getir
  Future<List<PrayerTime>> getMonthlyPrayerTimes(
    int cityId,
    int districtId,
    int year,
    int month,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiConstants.monthlyPrayerTimesEndpoint}/$cityId/$districtId/$year/$month'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiConstants.apiKey}',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> prayerTimesJson = json.decode(response.body);
        return prayerTimesJson.map((prayerTime) => PrayerTime.fromJson(prayerTime)).toList();
      } else {
        throw Exception('Failed to load monthly prayer times: ${response.statusCode}');
      }
    } catch (e) {
      // Gerçek API'ye bağlanmak yerine sahte veri gösterelim
      return _getMockMonthlyPrayerTimes();
    }
  }
  
  // Sahte il verileri
  List<City> _getMockCities() {
    return [
      City(id: 1, name: 'Adana'),
      City(id: 2, name: 'Adıyaman'),
      City(id: 3, name: 'Afyonkarahisar'),
      City(id: 4, name: 'Ağrı'),
      City(id: 5, name: 'Amasya'),
      City(id: 6, name: 'Ankara'),
      City(id: 7, name: 'Antalya'),
      City(id: 8, name: 'Artvin'),
      City(id: 9, name: 'Aydın'),
      City(id: 10, name: 'Balıkesir'),
      City(id: 11, name: 'Bilecik'),
      City(id: 12, name: 'Bingöl'),
      City(id: 13, name: 'Bitlis'),
      City(id: 14, name: 'Bolu'),
      City(id: 15, name: 'Burdur'),
      City(id: 16, name: 'Bursa'),
      City(id: 17, name: 'Çanakkale'),
      City(id: 18, name: 'Çankırı'),
      City(id: 19, name: 'Çorum'),
      City(id: 20, name: 'Denizli'),
      City(id: 21, name: 'Diyarbakır'),
      City(id: 22, name: 'Edirne'),
      City(id: 23, name: 'Elazığ'),
      City(id: 24, name: 'Erzincan'),
      City(id: 25, name: 'Erzurum'),
      City(id: 26, name: 'Eskişehir'),
      City(id: 27, name: 'Gaziantep'),
      City(id: 28, name: 'Giresun'),
      City(id: 29, name: 'Gümüşhane'),
      City(id: 30, name: 'Hakkari'),
      City(id: 31, name: 'Hatay'),
      City(id: 32, name: 'Isparta'),
      City(id: 33, name: 'Mersin'),
      City(id: 34, name: 'İstanbul'),
      City(id: 35, name: 'İzmir'),
      City(id: 36, name: 'Kars'),
      City(id: 37, name: 'Kastamonu'),
      City(id: 38, name: 'Kayseri'),
      City(id: 39, name: 'Kırklareli'),
      City(id: 40, name: 'Kırşehir'),
      City(id: 41, name: 'Kocaeli'),
      City(id: 42, name: 'Konya'),
      City(id: 43, name: 'Kütahya'),
      City(id: 44, name: 'Malatya'),
      City(id: 45, name: 'Manisa'),
      City(id: 46, name: 'Kahramanmaraş'),
      City(id: 47, name: 'Mardin'),
      City(id: 48, name: 'Muğla'),
      City(id: 49, name: 'Muş'),
      City(id: 50, name: 'Nevşehir'),
      City(id: 51, name: 'Niğde'),
      City(id: 52, name: 'Ordu'),
      City(id: 53, name: 'Rize'),
      City(id: 54, name: 'Sakarya'),
      City(id: 55, name: 'Samsun'),
      City(id: 56, name: 'Siirt'),
      City(id: 57, name: 'Sinop'),
      City(id: 58, name: 'Sivas'),
      City(id: 59, name: 'Tekirdağ'),
      City(id: 60, name: 'Tokat'),
      City(id: 61, name: 'Trabzon'),
      City(id: 62, name: 'Tunceli'),
      City(id: 63, name: 'Şanlıurfa'),
      City(id: 64, name: 'Uşak'),
      City(id: 65, name: 'Van'),
      City(id: 66, name: 'Yozgat'),
      City(id: 67, name: 'Zonguldak'),
      City(id: 68, name: 'Aksaray'),
      City(id: 69, name: 'Bayburt'),
      City(id: 70, name: 'Karaman'),
      City(id: 71, name: 'Kırıkkale'),
      City(id: 72, name: 'Batman'),
      City(id: 73, name: 'Şırnak'),
      City(id: 74, name: 'Bartın'),
      City(id: 75, name: 'Ardahan'),
      City(id: 76, name: 'Iğdır'),
      City(id: 77, name: 'Yalova'),
      City(id: 78, name: 'Karabük'),
      City(id: 79, name: 'Kilis'),
      City(id: 80, name: 'Osmaniye'),
      City(id: 81, name: 'Düzce'),
    ];
  }
  
  // Sahte ilçe verileri
  List<City> _getMockDistricts(int cityId) {
    if (cityId == 34) { // İstanbul için örnek ilçeler
      return [
        City(id: 3401, name: 'Adalar', parentId: 34),
        City(id: 3402, name: 'Arnavutköy', parentId: 34),
        City(id: 3403, name: 'Ataşehir', parentId: 34),
        City(id: 3404, name: 'Avcılar', parentId: 34),
        City(id: 3405, name: 'Bağcılar', parentId: 34),
        City(id: 3406, name: 'Bahçelievler', parentId: 34),
        City(id: 3407, name: 'Bakırköy', parentId: 34),
        City(id: 3408, name: 'Başakşehir', parentId: 34),
        City(id: 3409, name: 'Bayrampaşa', parentId: 34),
        City(id: 3410, name: 'Beşiktaş', parentId: 34),
        City(id: 3411, name: 'Beykoz', parentId: 34),
        City(id: 3412, name: 'Beylikdüzü', parentId: 34),
        City(id: 3413, name: 'Beyoğlu', parentId: 34),
        City(id: 3414, name: 'Büyükçekmece', parentId: 34),
        City(id: 3415, name: 'Çatalca', parentId: 34),
        City(id: 3416, name: 'Çekmeköy', parentId: 34),
        City(id: 3417, name: 'Esenler', parentId: 34),
        City(id: 3418, name: 'Esenyurt', parentId: 34),
        City(id: 3419, name: 'Eyüpsultan', parentId: 34),
        City(id: 3420, name: 'Fatih', parentId: 34),
        City(id: 3421, name: 'Gaziosmanpaşa', parentId: 34),
        City(id: 3422, name: 'Güngören', parentId: 34),
        City(id: 3423, name: 'Kadıköy', parentId: 34),
        City(id: 3424, name: 'Kağıthane', parentId: 34),
        City(id: 3425, name: 'Kartal', parentId: 34),
        City(id: 3426, name: 'Küçükçekmece', parentId: 34),
        City(id: 3427, name: 'Maltepe', parentId: 34),
        City(id: 3428, name: 'Pendik', parentId: 34),
        City(id: 3429, name: 'Sancaktepe', parentId: 34),
        City(id: 3430, name: 'Sarıyer', parentId: 34),
        City(id: 3431, name: 'Silivri', parentId: 34),
        City(id: 3432, name: 'Sultanbeyli', parentId: 34),
        City(id: 3433, name: 'Sultangazi', parentId: 34),
        City(id: 3434, name: 'Şile', parentId: 34),
        City(id: 3435, name: 'Şişli', parentId: 34),
        City(id: 3436, name: 'Tuzla', parentId: 34),
        City(id: 3437, name: 'Ümraniye', parentId: 34),
        City(id: 3438, name: 'Üsküdar', parentId: 34),
        City(id: 3439, name: 'Zeytinburnu', parentId: 34),
      ];
    } else if (cityId == 6) { // Ankara için örnek ilçeler
      return [
        City(id: 601, name: 'Akyurt', parentId: 6),
        City(id: 602, name: 'Altındağ', parentId: 6),
        City(id: 603, name: 'Ayaş', parentId: 6),
        City(id: 604, name: 'Bala', parentId: 6),
        City(id: 605, name: 'Beypazarı', parentId: 6),
        City(id: 606, name: 'Çamlıdere', parentId: 6),
        City(id: 607, name: 'Çankaya', parentId: 6),
        City(id: 608, name: 'Çubuk', parentId: 6),
        City(id: 609, name: 'Elmadağ', parentId: 6),
        City(id: 610, name: 'Etimesgut', parentId: 6),
        City(id: 611, name: 'Evren', parentId: 6),
        City(id: 612, name: 'Gölbaşı', parentId: 6),
        City(id: 613, name: 'Güdül', parentId: 6),
        City(id: 614, name: 'Haymana', parentId: 6),
        City(id: 615, name: 'Kalecik', parentId: 6),
        City(id: 616, name: 'Kazan', parentId: 6),
        City(id: 617, name: 'Keçiören', parentId: 6),
        City(id: 618, name: 'Kızılcahamam', parentId: 6),
        City(id: 619, name: 'Mamak', parentId: 6),
        City(id: 620, name: 'Nallıhan', parentId: 6),
        City(id: 621, name: 'Polatlı', parentId: 6),
        City(id: 622, name: 'Pursaklar', parentId: 6),
        City(id: 623, name: 'Sincan', parentId: 6),
        City(id: 624, name: 'Şereflikoçhisar', parentId: 6),
        City(id: 625, name: 'Yenimahalle', parentId: 6),
      ];
    } else { // Diğer şehirler için örnek ilçeler
      return [
        City(id: cityId * 100 + 1, name: 'Merkez', parentId: cityId),
        City(id: cityId * 100 + 2, name: 'İlçe 1', parentId: cityId),
        City(id: cityId * 100 + 3, name: 'İlçe 2', parentId: cityId),
        City(id: cityId * 100 + 4, name: 'İlçe 3', parentId: cityId),
        City(id: cityId * 100 + 5, name: 'İlçe 4', parentId: cityId),
      ];
    }
  }
  
  // Sahte günlük namaz vakti verisi
  PrayerTime _getMockDailyPrayerTime() {
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    
    return PrayerTime(
      date: dateStr,
      fajr: '04:12',
      sunrise: '05:47',
      dhuhr: '12:55',
      asr: '16:42',
      maghrib: '19:54',
      isha: '21:23',
    );
  }
  
  // Sahte aylık namaz vakti verileri
  List<PrayerTime> _getMockMonthlyPrayerTimes() {
    final now = DateTime.now();
    final List<PrayerTime> monthlyPrayerTimes = [];
    
    // Ayın kaç gün olduğunu hesapla
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    
    for (int day = 1; day <= daysInMonth; day++) {
      final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
      
      // Her gün için rastgele değişiklikler içeren veri oluştur
      final prayerTime = PrayerTime(
        date: dateStr,
        fajr: '04:${(10 + day % 10).toString().padLeft(2, '0')}',
        sunrise: '05:${(45 + day % 15).toString().padLeft(2, '0')}',
        dhuhr: '12:${(50 + day % 10).toString().padLeft(2, '0')}',
        asr: '16:${(40 + day % 10).toString().padLeft(2, '0')}',
        maghrib: '19:${(50 + day % 10).toString().padLeft(2, '0')}',
        isha: '21:${(20 + day % 10).toString().padLeft(2, '0')}',
      );
      
      monthlyPrayerTimes.add(prayerTime);
    }
    
    return monthlyPrayerTimes;
  }
}