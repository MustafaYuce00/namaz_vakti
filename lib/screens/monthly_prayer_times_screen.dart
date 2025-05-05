import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:namaz_vakti/models/prayer_time.dart';
import 'package:namaz_vakti/providers/prayer_time_provider.dart';
import 'package:namaz_vakti/theme/app_theme.dart';

class MonthlyPrayerTimesScreen extends StatefulWidget {
  const MonthlyPrayerTimesScreen({Key? key}) : super(key: key);

  @override
  State<MonthlyPrayerTimesScreen> createState() => _MonthlyPrayerTimesScreenState();
}

class _MonthlyPrayerTimesScreenState extends State<MonthlyPrayerTimesScreen> {
  @override
  void initState() {
    super.initState();
    // Sayfaya girildiğinde aylık verileri yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PrayerTimeProvider>(context, listen: false).fetchMonthlyPrayerTimes();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${DateFormat('MMMM yyyy', 'tr_TR').format(DateTime.now())} Namaz Vakitleri',
        ),
      ),
      body: Consumer<PrayerTimeProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (provider.errorMessage.isNotEmpty) {
            return Center(
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
                      provider.fetchMonthlyPrayerTimes();
                    },
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }
          
          if (provider.selectedCity == null || provider.selectedDistrict == null) {
            return const Center(
              child: Text('Önce konum seçmelisiniz'),
            );
          }
          
          if (provider.monthlyPrayerTimes.isEmpty) {
            return const Center(
              child: Text('Bu ay için namaz vakti bulunamadı!'),
            );
          }
          
          return _buildMonthlyTimesList(context, provider.monthlyPrayerTimes);
        },
      ),
    );
  }
  
  Widget _buildMonthlyTimesList(BuildContext context, List<PrayerTime> prayerTimes) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: prayerTimes.length,
      itemBuilder: (context, index) {
        final prayerTime = prayerTimes[index];
        
        // Tarih formatını ayarla
        String formattedDate;
        try {
          final date = DateFormat('yyyy-MM-dd').parse(prayerTime.date);
          formattedDate = DateFormat('d MMMM yyyy, EEEE', 'tr_TR').format(date);
        } catch (e) {
          formattedDate = prayerTime.date;
        }
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            title: Text(
              formattedDate,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    _buildPrayerTimeRow('İmsak', prayerTime.fajr, AppTheme.fajrColor),
                    _buildPrayerTimeRow('Güneş', prayerTime.sunrise, AppTheme.sunriseColor),
                    _buildPrayerTimeRow('Öğle', prayerTime.dhuhr, AppTheme.dhuhrColor),
                    _buildPrayerTimeRow('İkindi', prayerTime.asr, AppTheme.asrColor),
                    _buildPrayerTimeRow('Akşam', prayerTime.maghrib, AppTheme.maghribColor),
                    _buildPrayerTimeRow('Yatsı', prayerTime.isha, AppTheme.ishaColor),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildPrayerTimeRow(String prayerName, String time, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                prayerName,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}