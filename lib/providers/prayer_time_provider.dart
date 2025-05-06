import 'package:flutter/material.dart';
import 'package:namaz_vakti/models/city.dart';
import 'package:namaz_vakti/models/prayer_time.dart';
import 'package:namaz_vakti/services/prayer_time_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrayerTimeProvider with ChangeNotifier {
  final PrayerTimeService _prayerTimeService = PrayerTimeService();
  
  // Cities data
  List<City> _cities = [];
  List<City> get cities => _cities;
  bool _isLoadingCities = false;
  bool get isLoadingCities => _isLoadingCities;
  String _cityError = '';
  String get cityError => _cityError;
  
  // Districts data
  List<City> _districts = [];
  List<City> get districts => _districts;
  bool _isLoadingDistricts = false;
  bool get isLoadingDistricts => _isLoadingDistricts;
  String _districtError = '';
  String get districtError => _districtError;
  
  // Selected location
  City? _selectedCity;
  City? get selectedCity => _selectedCity;
  City? _selectedDistrict;
  City? get selectedDistrict => _selectedDistrict;
  
  // Prayer times data
  List<PrayerTime> _monthlyPrayerTimes = [];
  List<PrayerTime> get monthlyPrayerTimes => _monthlyPrayerTimes;
  PrayerTime? _dailyPrayerTime;
  PrayerTime? get dailyPrayerTime => _dailyPrayerTime;
  bool _isLoadingPrayerTimes = false;
  bool get isLoadingPrayerTimes => _isLoadingPrayerTimes;
  String _prayerTimeError = '';
  String get prayerTimeError => _prayerTimeError;
  
  // Initialize provider data
  Future<void> initialize() async {
    await _loadSavedLocation();
    if (_selectedCity != null && _selectedDistrict != null) {
      await fetchPrayerTimes();
    } else {
      await fetchCities();
    }
  }
  
  // Load cities from API
  Future<void> fetchCities() async {
    _isLoadingCities = true;
    _cityError = '';
    notifyListeners();
    
    try {
      _cities = await _prayerTimeService.getCities();
      _cityError = '';
    } catch (e) {
      debugPrint('Error in fetchCities: $e');
      _cityError = e.toString();
      _cities = [];
    } finally {
      _isLoadingCities = false;
      notifyListeners();
    }
  }
  
  // Load districts for a city from API
  Future<void> fetchDistricts(String cityId) async {
    _isLoadingDistricts = true;
    _districtError = '';
    notifyListeners();
    
    try {
      _districts = await _prayerTimeService.getDistricts(cityId);
      _districtError = '';
    } catch (e) {
      debugPrint('Error in fetchDistricts: $e');
      _districtError = e.toString();
      _districts = [];
    } finally {
      _isLoadingDistricts = false;
      notifyListeners();
    }
  }
  
  // Set selected city
  Future<void> setSelectedCity(City city) async {
    _selectedCity = city;
    _selectedDistrict = null;
    await fetchDistricts(city.id);
    notifyListeners();
  }
  
  // Set selected district
  Future<void> setSelectedDistrict(City district) async {
    _selectedDistrict = district;
    
    // Save selected location
    await _saveLocation();
    
    // Fetch prayer times for the selected district
    await fetchPrayerTimes();
    
    notifyListeners();
  }
  
  // Fetch prayer times from API
  Future<void> fetchPrayerTimes() async {
    if (_selectedDistrict == null) {
      debugPrint('Cannot fetch prayer times: No district selected');
      _prayerTimeError = 'Lütfen önce bir şehir ve ilçe seçin';
      notifyListeners();
      return;
    }
    
    _isLoadingPrayerTimes = true;
    _prayerTimeError = '';
    notifyListeners();
    
    try {
      _monthlyPrayerTimes = await _prayerTimeService.getMonthlyPrayerTimes(_selectedDistrict!.id);
      _dailyPrayerTime = await _prayerTimeService.getDailyPrayerTime(_selectedDistrict!.id);
      _prayerTimeError = '';
    } catch (e) {
      debugPrint('Error in fetchPrayerTimes: $e');
      _prayerTimeError = e.toString();
      _monthlyPrayerTimes = [];
      _dailyPrayerTime = null;
    } finally {
      _isLoadingPrayerTimes = false;
      notifyListeners();
    }
  }
  
  // Save selected location to SharedPreferences
  Future<void> _saveLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_selectedCity != null) {
        await prefs.setString('selectedCityId', _selectedCity!.id);
        await prefs.setString('selectedCityName', _selectedCity!.name);
        await prefs.setString('selectedCityNameEn', _selectedCity!.nameEn);
      }
      
      if (_selectedDistrict != null) {
        await prefs.setString('selectedDistrictId', _selectedDistrict!.id);
        await prefs.setString('selectedDistrictName', _selectedDistrict!.name);
        await prefs.setString('selectedDistrictNameEn', _selectedDistrict!.nameEn);
        if (_selectedDistrict!.parentId != null) {
          await prefs.setString('selectedDistrictParentId', _selectedDistrict!.parentId!);
        }
      }
      debugPrint('Location saved to preferences');
    } catch (e) {
      debugPrint('Error saving location to preferences: $e');
    }
  }
  
  // Load saved location from SharedPreferences
  Future<void> _loadSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final cityId = prefs.getString('selectedCityId');
      final cityName = prefs.getString('selectedCityName');
      final cityNameEn = prefs.getString('selectedCityNameEn');
      
      final districtId = prefs.getString('selectedDistrictId');
      final districtName = prefs.getString('selectedDistrictName');
      final districtNameEn = prefs.getString('selectedDistrictNameEn');
      final districtParentId = prefs.getString('selectedDistrictParentId');
      
      if (cityId != null && cityName != null && cityNameEn != null) {
        _selectedCity = City(
          id: cityId,
          name: cityName,
          nameEn: cityNameEn,
        );
        
        if (districtId != null && districtName != null && districtNameEn != null) {
          _selectedDistrict = City(
            id: districtId,
            name: districtName,
            nameEn: districtNameEn,
            parentId: districtParentId,
          );
        }
        
        debugPrint('Loaded saved location: ${_selectedCity?.name}, ${_selectedDistrict?.name}');
        
        // Load districts for the selected city
        if (_selectedCity != null) {
          await fetchDistricts(_selectedCity!.id);
        }
      }
    } catch (e) {
      debugPrint('Error loading saved location: $e');
    }
  }
  
  // Clear saved location
  Future<void> clearLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('selectedCityId');
      await prefs.remove('selectedCityName');
      await prefs.remove('selectedCityNameEn');
      await prefs.remove('selectedDistrictId');
      await prefs.remove('selectedDistrictName');
      await prefs.remove('selectedDistrictNameEn');
      await prefs.remove('selectedDistrictParentId');
      
      _selectedCity = null;
      _selectedDistrict = null;
      _monthlyPrayerTimes = [];
      _dailyPrayerTime = null;
      
      notifyListeners();
      
      debugPrint('Location cleared from preferences');
    } catch (e) {
      debugPrint('Error clearing location from preferences: $e');
    }
  }
  
  // Get next prayer time information
  Map<String, dynamic> getNextPrayerInfo() {
    if (_dailyPrayerTime == null) {
      return {
        'name': 'Bilinmiyor',
        'time': '--:--',
        'remaining': 'Bilinmiyor',
        'index': -1,
      };
    }
    
    final now = DateTime.now();
    final currentTimeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    final times = [
      {'name': 'İmsak', 'time': _dailyPrayerTime!.fajr},
      {'name': 'Güneş', 'time': _dailyPrayerTime!.sunrise},
      {'name': 'Öğle', 'time': _dailyPrayerTime!.dhuhr},
      {'name': 'İkindi', 'time': _dailyPrayerTime!.asr},
      {'name': 'Akşam', 'time': _dailyPrayerTime!.maghrib},
      {'name': 'Yatsı', 'time': _dailyPrayerTime!.isha},
    ];
    
    int nextIndex = -1;
    for (int i = 0; i < times.length; i++) {
      if (currentTimeStr.compareTo(times[i]['time']!) < 0) {
        nextIndex = i;
        break;
      }
    }
    
    // If no next prayer time today, first prayer time tomorrow
    if (nextIndex == -1) {
      nextIndex = 0;
    }
    
    final nextPrayerName = times[nextIndex]['name'];
    final nextPrayerTime = times[nextIndex]['time'];
    
    // Calculate remaining time
    final nextPrayerHour = int.parse(nextPrayerTime!.split(':')[0]);
    final nextPrayerMinute = int.parse(nextPrayerTime.split(':')[1]);
    
    DateTime nextPrayerDateTime = DateTime(
      now.year, 
      now.month, 
      now.day, 
      nextPrayerHour, 
      nextPrayerMinute,
    );
    
    // If next prayer is tomorrow's Fajr
    if (nextIndex == 0 && currentTimeStr.compareTo(times.last['time']!) >= 0) {
      nextPrayerDateTime = nextPrayerDateTime.add(const Duration(days: 1));
    }
    
    final difference = nextPrayerDateTime.difference(now);
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    
    String remaining = '';
    if (hours > 0) {
      remaining = '$hours saat $minutes dakika';
    } else {
      remaining = '$minutes dakika';
    }
    
    return {
      'name': nextPrayerName,
      'time': nextPrayerTime,
      'remaining': remaining,
      'index': nextIndex,
    };
  }
}