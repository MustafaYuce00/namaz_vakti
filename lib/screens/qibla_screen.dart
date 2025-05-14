import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:namaz_vakti/theme/app_theme.dart';
import 'dart:async';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({Key? key}) : super(key: key);

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  bool _hasPermission = false;
  bool _compassAvailable = false;
  double _direction = 0;
  double _qiblaDirection = 0;
  Position? _currentPosition;
  Timer? _locationUpdateTimer;
  
  // Kabe'nin koordinatları (Enlem, Boylam)
  final double kaabaLatitude = 21.422487;
  final double kaabaLongitude = 39.826206;
  
  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _checkCompassAvailability();
    _startLocationUpdates();
  }
  
  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    super.dispose();
  }
  
  void _startLocationUpdates() {
    // Konum bilgisini periyodik olarak güncelle (1 dakikada bir)
    _getCurrentLocation();
    _locationUpdateTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _getCurrentLocation();
    });
  }
    Future<void> _checkLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final result = await Geolocator.requestPermission();
        setState(() {
          _hasPermission = result != LocationPermission.denied && 
                         result != LocationPermission.deniedForever;
        });
      } else {
        setState(() {
          _hasPermission = permission != LocationPermission.denied && 
                         permission != LocationPermission.deniedForever;
        });
      }
      
      if (_hasPermission) {
        _getCurrentLocation();
      }
    } catch (e) {
      debugPrint('Konum izni alınamadı: $e');
      setState(() {
        _hasPermission = false;
      });
    }
  }
  
  Future<void> _checkCompassAvailability() async {
    bool? available = await FlutterCompass.events?.first.then((_) => true).catchError((error) {
      debugPrint('Compass error: $error');
      return false;
    });
    
    setState(() {
      _compassAvailable = available ?? false;
    });
    
    if (_compassAvailable) {
      FlutterCompass.events?.listen((CompassEvent event) {
        // Pusula yönünü ve kıble açısını güncelle
        if (mounted && event.heading != null) {
          setState(() {
            _direction = event.heading!;
            // _qiblaDirection zaten hesaplandı, bunu güncelleme
          });
        }
      });
    }
  }
  
  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      
      setState(() {
        _currentPosition = position;
      });
      
      _calculateQiblaDirection();
    } catch (e) {
      debugPrint('Konum alınamadı: $e');
    }
  }
  
  void _calculateQiblaDirection() {
    if (_currentPosition == null) return;
    
    // Koordinatları radyana çevirme
    final latRad = _currentPosition!.latitude * (math.pi / 180);
    final longRad = _currentPosition!.longitude * (math.pi / 180);
    final kaabaLatRad = kaabaLatitude * (math.pi / 180);
    final kaabaLongRad = kaabaLongitude * (math.pi / 180);
    
    // Kıble yönünü hesaplama formülü 
    final y = math.sin(kaabaLongRad - longRad);
    final x = math.cos(latRad) * math.tan(kaabaLatRad) - 
              math.sin(latRad) * math.cos(kaabaLongRad - longRad);
    
    // Açıyı derece cinsinden hesaplama
    double qiblaAngle = math.atan2(y, x) * (180 / math.pi);
    // Açıyı 0-360 derece arasına normalize etme
    qiblaAngle = (qiblaAngle + 360) % 360;
    
    setState(() {
      _qiblaDirection = qiblaAngle;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kıble Yönü'),
      ),
      body: _buildQiblaContent(),
    );
  }
  
  Widget _buildQiblaContent() {
    if (!_hasPermission) {
      return _buildPermissionRequest();
    }
    
    if (!_compassAvailable) {
      return _buildCompassNotAvailable();
    }
    
    if (_currentPosition == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Konum bilgisi alınıyor...'),
          ],
        ),
      );
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Kıble Yönü',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
              Transform.rotate(
                angle: (((_direction - _qiblaDirection) % 360) * (math.pi / 180) * -1),
                child: Column(
                  children: [
                    const Icon(Icons.arrow_upward, size: 50, color: AppTheme.dhuhrColor),
                    const SizedBox(height: 90),
                    Image.asset(
                      'assets/images/kaaba.png',
                      width: 60,
                      height: 60,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.green,
                        child: const Icon(Icons.mosque, color: Colors.white, size: 40),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Text(
            'Kıble açısı: ${_qiblaDirection.toStringAsFixed(1)}°',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pusula: ${_direction.toStringAsFixed(1)}°',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Telefonunuzu düz tutun ve ekrandaki ok Kabe yönünü gösterene kadar döndürün',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
    Widget _buildPermissionRequest() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Kıble yönünü bulmak için konum izni gerekiyor',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'Konum izni vermezseniz kıble yönünü hesaplayamayız. Lütfen ayarlardan uygulamaya konum izni verin.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                // Geolocator.openAppSettings() kullanarak doğrudan uygulama ayarlarına yönlendir
                await Geolocator.openAppSettings();
              },
              child: const Text('Uygulama Ayarlarını Aç'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _checkLocationPermission,
              child: const Text('İzinleri Tekrar Kontrol Et'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCompassNotAvailable() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.compass_calibration, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Pusula sensörü bulunamadı',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Cihazınızda pusula sensörü bulunmuyor veya sensöre erişim sağlanamıyor. Kıble yönü bulunamıyor.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
