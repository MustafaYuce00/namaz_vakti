import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:namaz_vakti/models/city.dart';
import 'package:namaz_vakti/providers/prayer_time_provider.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({Key? key}) : super(key: key);

  @override
  State<LocationSelectionScreen> createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  bool _isSelectingCity = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında il listesini yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PrayerTimeProvider>(context, listen: false).fetchCities();
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSelectingCity ? 'Şehir Seçin' : 'İlçe Seçin'),
        leading: !_isSelectingCity ? BackButton(
          onPressed: () {
            setState(() {
              _isSelectingCity = true;
              _searchQuery = '';
              _searchController.clear();
            });
          },
        ) : null,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: _isSelectingCity ? 'Şehir ara...' : 'İlçe ara...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: _searchQuery.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _searchController.clear();
                        });
                      },
                    )
                  : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: Consumer<PrayerTimeProvider>(
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
                            if (_isSelectingCity) {
                              provider.fetchCities();
                            } else if (provider.selectedCity != null) {
                              provider.fetchDistricts(provider.selectedCity!.id);
                            }
                          },
                          child: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  );
                }
                
                return _isSelectingCity
                    ? _buildCityList(context, provider)
                    : _buildDistrictList(context, provider);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCityList(BuildContext context, PrayerTimeProvider provider) {
    // Arama sorgusuna göre şehirleri filtrele
    final filteredCities = _searchQuery.isEmpty
        ? provider.cities
        : provider.cities.where((city) => 
            city.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    
    if (filteredCities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Arama sonucu bulunamadı',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: filteredCities.length,
      itemBuilder: (context, index) {
        final city = filteredCities[index];
        final isSelected = provider.selectedCity?.id == city.id;
        
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : null,
          child: ListTile(
            title: Text(city.name),
            trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green) : null,
            onTap: () async {
              await provider.selectCity(city);
              setState(() {
                _isSelectingCity = false;
                _searchQuery = '';
                _searchController.clear();
              });
            },
          ),
        );
      },
    );
  }
  
  Widget _buildDistrictList(BuildContext context, PrayerTimeProvider provider) {
    // Arama sorgusuna göre ilçeleri filtrele
    final filteredDistricts = _searchQuery.isEmpty
        ? provider.districts
        : provider.districts.where((district) => 
            district.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    
    if (filteredDistricts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Arama sonucu bulunamadı',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: filteredDistricts.length,
      itemBuilder: (context, index) {
        final district = filteredDistricts[index];
        final isSelected = provider.selectedDistrict?.id == district.id;
        
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : null,
          child: ListTile(
            title: Text(district.name),
            trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green) : null,
            onTap: () async {
              await provider.selectDistrict(district);
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }
}