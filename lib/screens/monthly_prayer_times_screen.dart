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
    // Sayfaya girildiğinde verileri yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PrayerTimeProvider>(context, listen: false).fetchPrayerTimes();
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
          if (provider.isLoadingPrayerTimes) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (provider.prayerTimeError.isNotEmpty) {
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
                    provider.prayerTimeError,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.fetchPrayerTimes();
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
    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<PrayerTimeProvider>(context, listen: false).fetchPrayerTimes();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: prayerTimes.length,
        itemBuilder: (context, index) {
          final prayerTime = prayerTimes[index];
          
          // Tarih formatını ayarla
          String formattedDate;
          try {
            // Use the correct date format based on our API format (dd.MM.yyyy)
            final dateString = prayerTime.gregorianDateShort.isNotEmpty ? 
                                prayerTime.gregorianDateShort : prayerTime.date;
            
            final date = DateFormat('dd.MM.yyyy').parse(dateString);
            formattedDate = DateFormat('d MMMM yyyy, EEEE', 'tr_TR').format(date);
          } catch (e) {
            debugPrint('Date parsing error: $e');
            // Use the long date format from API if parsing fails
            formattedDate = prayerTime.gregorianDateLong.isNotEmpty ? 
                            prayerTime.gregorianDateLong : prayerTime.date;
          }
          
          // Check if this is today's date
          bool isToday = false;
          try {
            final dateString = prayerTime.gregorianDateShort.isNotEmpty ? 
                                prayerTime.gregorianDateShort : prayerTime.date;
            final date = DateFormat('dd.MM.yyyy').parse(dateString);
            final today = DateTime.now();
            isToday = date.year == today.year && 
                      date.month == today.month && 
                      date.day == today.day;
          } catch (e) {
            debugPrint('Today check error: $e');
          }
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            // If it's today's date, add a highlight
            color: isToday ? Colors.blue.withOpacity(0.1) : null,
            child: ExpansionTile(
              title: Row(
                children: [
                  if (isToday)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Bugün',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      formattedDate,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              // Add the Hijri date as subtitle
              subtitle: prayerTime.hijriDateLong.isNotEmpty ? 
                        Text(prayerTime.hijriDateLong) : null,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      _buildPrayerTimeRow('İmsak', prayerTime.fajr, AppTheme.fajrColor),
                      _buildPrayerTimeRow('Güneş', prayerTime.sunrise, AppTheme.sunriseColor),
                      _buildPrayerTimeRow('Öğle', prayerTime.dhuhr, AppTheme.dhuhrColor),                      _buildPrayerTimeRow('İkindi', prayerTime.asr, AppTheme.asrColor),
                      _buildPrayerTimeRow('Akşam', prayerTime.maghrib, AppTheme.maghribColor),
                      _buildPrayerTimeRow('Yatsı', prayerTime.isha, AppTheme.ishaColor),
                      // Add Qibla time if available 
                      if (prayerTime.qibla.isNotEmpty)
                        _buildPrayerTimeRow('Kıble', prayerTime.qibla, Colors.purple),
                    ],
                  ),
                ),
                // Add moon phase image if available
                if (prayerTime.moonPhaseUrl.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      children: [
                        const Text('Ayın Şekli', style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 4),
                        Image.network(
                          prayerTime.moonPhaseUrl,
                          width: 40,
                          height: 40,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const SizedBox(
                              width: 40,
                              height: 40,
                              child: Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => 
                            const Icon(Icons.image_not_supported, size: 40),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
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