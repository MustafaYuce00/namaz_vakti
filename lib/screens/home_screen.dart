import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:namaz_vakti/models/prayer_time.dart';
import 'package:namaz_vakti/providers/prayer_time_provider.dart';
import 'package:namaz_vakti/screens/location_selection_screen.dart';
import 'package:namaz_vakti/screens/monthly_prayer_times_screen.dart';
import 'package:namaz_vakti/theme/app_theme.dart';
import 'package:namaz_vakti/utils/constants.dart';
import 'package:namaz_vakti/widgets/prayer_time_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;
  DateTime _currentTime = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    // Her saniye saati güncelle
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PrayerTimeProvider>(context);
    final currentPrayer = provider.currentPrayerTime;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Namaz Vakitleri'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MonthlyPrayerTimesScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LocationSelectionScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Hata oluştu:',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        provider.errorMessage,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          provider.fetchDailyPrayerTimes();
                        },
                        child: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                )
              : provider.selectedCity == null || provider.selectedDistrict == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.location_off,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Konum seçilmedi',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Namaz vakitlerini görmek için lütfen konum seçin',
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LocationSelectionScreen(),
                                ),
                              );
                            },
                            child: const Text('Konum Seç'),
                          ),
                        ],
                      ),
                    )
                  : currentPrayer == null
                      ? const Center(
                          child: Text('Namaz vakti bulunamadı!'),
                        )
                      : _buildPrayerTimeScreen(context, provider, currentPrayer),
    );
  }
  
  Widget _buildPrayerTimeScreen(
    BuildContext context, 
    PrayerTimeProvider provider,
    PrayerTime currentPrayer,
  ) {
    // Bir sonraki namaz vaktini hesapla
    final nextPrayerName = currentPrayer.getNextPrayerTime(_currentTime);
    // Kalan süreyi hesapla
    final remainingTime = currentPrayer.getRemainingTime(_currentTime, nextPrayerName);
    
    return RefreshIndicator(
      onRefresh: () async {
        await provider.fetchDailyPrayerTimes();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Konum ve tarih bilgisi
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${provider.selectedCity?.name} / ${provider.selectedDistrict?.name}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('d MMMM yyyy', 'tr_TR').format(_currentTime),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        DateFormat('EEEE', 'tr_TR').format(_currentTime),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('HH:mm:ss').format(_currentTime),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Bir sonraki namaz vakti
              Card(
                color: AppTheme.getPrayerTimeColor(nextPrayerName).withOpacity(0.2),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Bir Sonraki Namaz',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.access_time,
                            color: AppTheme.getPrayerTimeColor(nextPrayerName),
                            size: 32,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            nextPrayerName,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppTheme.getPrayerTimeColor(nextPrayerName),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Kalan Süre: $remainingTime',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Günlük tüm namaz vakitleri
              const Text(
                'Günlük Namaz Vakitleri',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              // İmsak
              PrayerTimeCard(
                prayerName: 'İmsak',
                prayerTime: currentPrayer.fajr,
                color: AppTheme.fajrColor,
                isActive: nextPrayerName == 'İmsak',
              ),
              
              // Güneş
              PrayerTimeCard(
                prayerName: 'Güneş',
                prayerTime: currentPrayer.sunrise,
                color: AppTheme.sunriseColor,
                isActive: nextPrayerName == 'Güneş',
              ),
              
              // Öğle
              PrayerTimeCard(
                prayerName: 'Öğle',
                prayerTime: currentPrayer.dhuhr,
                color: AppTheme.dhuhrColor,
                isActive: nextPrayerName == 'Öğle',
              ),
              
              // İkindi
              PrayerTimeCard(
                prayerName: 'İkindi',
                prayerTime: currentPrayer.asr,
                color: AppTheme.asrColor,
                isActive: nextPrayerName == 'İkindi',
              ),
              
              // Akşam
              PrayerTimeCard(
                prayerName: 'Akşam',
                prayerTime: currentPrayer.maghrib,
                color: AppTheme.maghribColor,
                isActive: nextPrayerName == 'Akşam',
              ),
              
              // Yatsı
              PrayerTimeCard(
                prayerName: 'Yatsı',
                prayerTime: currentPrayer.isha,
                color: AppTheme.ishaColor,
                isActive: nextPrayerName == 'Yatsı',
              ),
            ],
          ),
        ),
      ),
    );
  }
}