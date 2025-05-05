import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:namaz_vakti/models/city.dart';
import 'package:namaz_vakti/models/prayer_time.dart';
import 'package:namaz_vakti/services/prayer_time_service.dart';
import 'package:namaz_vakti/utils/constants.dart';

class PrayerTimeProvider extends ChangeNotifier {
  final PrayerTimeService _service = PrayerTimeService();
  
  // Şehir ve ilçe listeleri
  List<City> _cities = [];
  List<City> _districts = [];
  
  // Seçilen şehir ve ilçe
  City? _selectedCity;
  City? _selectedDistrict;
  
  // Namaz vakitleri
  PrayerTime? _currentPrayerTime;
  List<PrayerTime> _monthlyPrayerTimes = [];
  
  // Yükleme durumları
  bool _isLoading = false;
  String _errorMessage = '';
  
  // Getters
  List<City> get cities => _cities;
  List<City> get districts => _districts;
  City? get selectedCity => _selectedCity;
  City? get selectedDistrict => _selectedDistrict;
  PrayerTime? get currentPrayerTime => _currentPrayerTime;
  List<PrayerTime> get monthlyPrayerTimes => _monthlyPrayerTimes;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  
  // Provider başlatıldığında çağrılacak
  Future<void> initialize() async {
    await _loadSavedLocation();
    await fetchCities();
    
    if (_selectedCity != null) {
      await fetchDistricts(_selectedCity!.id);
      
      if (_selectedDistrict != null) {
        await fetchDailyPrayerTimes();
        await fetchMonthlyPrayerTimes();
      }
    }
  }
  
  // Kaydedilmiş konum bilgilerini yükle
  Future<void> _loadSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    
    final cityIdString = prefs.getString(AppConstants.prefSelectedCity);
    final districtIdString = prefs.getString(AppConstants.prefSelectedDistrict);
    
    if (cityIdString != null && districtIdString != null) {
      try {
        final cityData = cityIdString.split('|');
        final districtData = districtIdString.split('|');
        
        if (cityData.length >= 2 && districtData.length >= 2) {
          _selectedCity = City(
            id: int.parse(cityData[0]),
            name: cityData[1],
          );
          
          _selectedDistrict = City(
            id: int.parse(districtData[0]),
            name: districtData[1],
            parentId: int.parse(cityData[0]),
          );
        }
      } catch (e) {
        debugPrint('Konum bilgisi yüklenirken hata: $e');
      }
    }
  }
  
  // Konum bilgilerini kaydet
  Future<void> _saveLocation() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (_selectedCity != null) {
      await prefs.setString(
        AppConstants.prefSelectedCity, 
        '${_selectedCity!.id}|${_selectedCity!.name}'
      );
    }
    
    if (_selectedDistrict != null) {
      await prefs.setString(
        AppConstants.prefSelectedDistrict,
        '${_selectedDistrict!.id}|${_selectedDistrict!.name}'
      );
    }
  }
  
  // İlleri getir
  Future<void> fetchCities() async {
    _setLoading(true);
    
    try {
      _cities = await _service.getCities();
      notifyListeners();
    } catch (e) {
      _setError('Şehir listesi alınamadı: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // İlçeleri getir
  Future<void> fetchDistricts(int cityId) async {
    _setLoading(true);
    
    try {
      _districts = await _service.getDistricts(cityId);
      notifyListeners();
    } catch (e) {
      _setError('İlçe listesi alınamadı: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Şehir seç
  Future<void> selectCity(City city) async {
    _selectedCity = city;
    _selectedDistrict = null;
    notifyListeners();
    
    await fetchDistricts(city.id);
    await _saveLocation();
  }
  
  // İlçe seç
  Future<void> selectDistrict(City district) async {
    _selectedDistrict = district;
    notifyListeners();
    
    await _saveLocation();
    await fetchDailyPrayerTimes();
    await fetchMonthlyPrayerTimes();
  }
  
  // Günlük namaz vakitlerini getir
  Future<void> fetchDailyPrayerTimes() async {
    if (_selectedCity == null || _selectedDistrict == null) {
      return;
    }
    
    _setLoading(true);
    
    try {
      _currentPrayerTime = await _service.getDailyPrayerTimes(
        _selectedCity!.id,
        _selectedDistrict!.id,
      );
      notifyListeners();
    } catch (e) {
      _setError('Namaz vakitleri alınamadı: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Aylık namaz vakitlerini getir
  Future<void> fetchMonthlyPrayerTimes() async {
    if (_selectedCity == null || _selectedDistrict == null) {
      return;
    }
    
    _setLoading(true);
    
    try {
      final now = DateTime.now();
      _monthlyPrayerTimes = await _service.getMonthlyPrayerTimes(
        _selectedCity!.id,
        _selectedDistrict!.id,
        now.year,
        now.month,
      );
      notifyListeners();
    } catch (e) {
      _setError('Aylık namaz vakitleri alınamadı: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Loading durumunu güncelle
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _errorMessage = '';
    }
    notifyListeners();
  }
  
  // Hata mesajını güncelle
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }
}