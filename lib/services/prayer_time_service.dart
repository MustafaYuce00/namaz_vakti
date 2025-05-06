import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:namaz_vakti/models/city.dart';
import 'package:namaz_vakti/models/prayer_time.dart';
import 'package:namaz_vakti/utils/constants.dart';

class PrayerTimeService {
  final String baseUrl = 'https://ezanvakti.emushaf.net';
  
  // Get cities - exclusively from API
  Future<List<City>> getCities() async {
    try {
      debugPrint('Fetching cities from API: $baseUrl/sehirler/2');
      final response = await http.get(
        Uri.parse('$baseUrl/sehirler/2'),
        headers: {'Accept-Charset': 'utf-8'},
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('City API request timed out');
          throw Exception('Şehirler yüklenirken zaman aşımı oluştu');
        },
      );
      
      if (response.statusCode == 200) {
        // Debug için karakter kodlama bilgisini yazdır
        debugPrint('Response encoding: ${response.headers['content-type']}');
        
        // Doğru kodlama ile decode etmeye çalış
        final String responseBody = utf8.decode(response.bodyBytes);
        
        // Debug için ilk birkaç şehir adını yazdır
        try {
          final List<dynamic> citiesJson = json.decode(responseBody);
          debugPrint('Cities fetched: ${citiesJson.length}');
          
          if (citiesJson.isNotEmpty) {
            for (int i = 0; i < min(5, citiesJson.length); i++) {
              String cityName = citiesJson[i]['SehirAdi'] ?? 'Unknown';
              StringHelper.debugEncodingIssue(cityName);
            }
          }
          
          return citiesJson.map((city) => City.fromJson(city)).toList();
        } catch (e) {
          debugPrint('Error parsing cities JSON: $e');
          throw Exception('Şehirler verisi işlenirken hata oluştu: $e');
        }
      } else {
        debugPrint('Failed to fetch cities: ${response.statusCode}');
        throw Exception('Şehirler yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching cities: $e');
      throw Exception('Şehirler yüklenemedi: $e');
    }
  }
  
  // Get districts by cityId - exclusively from API
  Future<List<City>> getDistricts(String cityId) async {
    try {
      debugPrint('Fetching districts from API: $baseUrl/ilceler/$cityId');
      final response = await http.get(
        Uri.parse('$baseUrl/ilceler/$cityId'),
        headers: {'Accept-Charset': 'utf-8'},
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('District API request timed out');
          throw Exception('İlçeler yüklenirken zaman aşımı oluştu');
        },
      );
      
      if (response.statusCode == 200) {
        // Debug için karakter kodlama bilgisini yazdır
        debugPrint('Response encoding: ${response.headers['content-type']}');
        
        // Doğru kodlama ile decode etmeye çalış
        final String responseBody = utf8.decode(response.bodyBytes);
        
        try {
          final List<dynamic> districtsJson = json.decode(responseBody);
          debugPrint('Districts fetched: ${districtsJson.length}');
          
          if (districtsJson.isNotEmpty) {
            for (int i = 0; i < min(5, districtsJson.length); i++) {
              String districtName = districtsJson[i]['IlceAdi'] ?? 'Unknown';
              StringHelper.debugEncodingIssue(districtName);
            }
          }
          
          return districtsJson.map((district) => City.districtFromJson(district)).toList();
        } catch (e) {
          debugPrint('Error parsing districts JSON: $e');
          throw Exception('İlçeler verisi işlenirken hata oluştu: $e');
        }
      } else {
        debugPrint('Failed to fetch districts: ${response.statusCode}');
        throw Exception('İlçeler yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching districts: $e');
      throw Exception('İlçeler yüklenemedi: $e');
    }
  }
  
  // Get prayer times by districtId - exclusively from API
  Future<List<PrayerTime>> getMonthlyPrayerTimes(String districtId) async {
    try {
      debugPrint('Fetching prayer times from API: $baseUrl/vakitler/$districtId');
      // Use a timeout to prevent hanging
      final response = await http.get(
        Uri.parse('$baseUrl/vakitler/$districtId'),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('Prayer time API request timed out');
          throw Exception('Namaz vakitleri yüklenirken zaman aşımı oluştu');
        },
      );
      
      debugPrint('Prayer time API response code: ${response.statusCode}');
      debugPrint('Prayer time API response body: ${response.body.substring(0, min(100, response.body.length))}...');
      
      if (response.statusCode == 200) {
        final List<dynamic> prayerTimesJson = json.decode(response.body);
        debugPrint('Prayer times fetched: ${prayerTimesJson.length}');
        
        if (prayerTimesJson.isEmpty) {
          debugPrint('Warning: Prayer times JSON is empty');
          throw Exception('Namaz vakitleri yüklenemedi: Veri bulunamadı');
        }
        
        try {
          return prayerTimesJson.map((pt) => PrayerTime.fromJson(pt)).toList();
        } catch (e) {
          debugPrint('Error parsing prayer times: $e');
          throw Exception('Namaz vakitleri işlenirken hata oluştu: $e');
        }
      } else {
        debugPrint('Failed to fetch prayer times: ${response.statusCode}');
        throw Exception('Namaz vakitleri yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching prayer times: $e');
      throw Exception('Namaz vakitleri yüklenemedi: $e');
    }
  }
  
  // Get today's prayer time - exclusively from API
  Future<PrayerTime> getDailyPrayerTime(String districtId) async {
    final monthlyTimes = await getMonthlyPrayerTimes(districtId);
    if (monthlyTimes.isEmpty) {
      throw Exception('Günlük namaz vakitleri bulunamadı');
    }
    
    // Get today's date in DD.MM.YYYY format
    final now = DateTime.now();
    final today = '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}';
    debugPrint('Today: $today');
    
    // Find today's prayer time
    for (var prayerTime in monthlyTimes) {
      debugPrint('Checking date: ${prayerTime.gregorianDateShort} or ${prayerTime.date}');
      if (prayerTime.gregorianDateShort == today || prayerTime.date == today) {
        debugPrint('Found today\'s prayer time');
        return prayerTime;
      }
    }
    
    // If today's time is not found, use the first available time
    debugPrint('Today\'s prayer time not found, using first available time');
    return monthlyTimes.first;
  }
  
  int min(int a, int b) {
    return a < b ? a : b;
  }
}