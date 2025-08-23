import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/API/pharmacy_fetcher.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Models/Pharmacy.dart';
import 'package:movix/Services/globals.dart';
import 'package:url_launcher/url_launcher.dart';

class PharmaciesPage extends StatefulWidget {
  const PharmaciesPage({super.key});

  @override
  State<PharmaciesPage> createState() => _PharmaciesPageState();
}

class _PharmaciesPageState extends State<PharmaciesPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _cipController = TextEditingController();
  List<Pharmacy> _pharmacies = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _cipController.dispose();
    super.dispose();
  }

  Future<void> _searchPharmacies(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _pharmacies = [];
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await searchPharmaciesGlobal(query.trim());
      setState(() {
        _pharmacies = results;
        _isLoading = false;
        if (results.isEmpty) {
          _errorMessage = 'Aucune pharmacie trouvée pour cette recherche';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur lors de la recherche: $e';
        _pharmacies = [];
      });
    }
  }


  Future<void> _openMap(double latitude, double longitude, String name) async {
    final Uri mapUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    if (await canLaunchUrl(mapUri)) {
      await launchUrl(mapUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: Globals.darkModeNotifier,
      builder: (context, isDarkMode, child) {
        return Scaffold(
          backgroundColor: Globals.COLOR_BACKGROUND,
          appBar: AppBar(
            backgroundColor: Globals.COLOR_MOVIX,
            title: Text(
              'Recherche Pharmacies',
              style: TextStyle(color: Globals.COLOR_TEXT_LIGHT),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Globals.COLOR_TEXT_LIGHT),
              onPressed: () => context.pop(),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Nom, adresse, code postal...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.tune),
                          onPressed: _showAdvancedSearch,
                          tooltip: 'Recherche avancée',
                        ),
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _searchPharmacies('');
                            },
                          ),
                      ],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Globals.COLOR_SURFACE,
                  ),
                  onChanged: (value) {
                    setState(() {});
                    if (value.length >= 3) {
                      _searchPharmacies(value);
                    } else if (value.isEmpty) {
                      _searchPharmacies('');
                    }
                  },
                  onSubmitted: _searchPharmacies,
                ),
              ),
              if (_isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              if (_errorMessage != null && !_isLoading)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Globals.COLOR_TEXT_SECONDARY,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Globals.COLOR_TEXT_SECONDARY,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              if (_pharmacies.isEmpty && !_isLoading && _errorMessage == null)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_pharmacy,
                          size: 64,
                          color: Globals.COLOR_TEXT_SECONDARY,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Recherchez une pharmacie',
                          style: TextStyle(
                            color: Globals.COLOR_TEXT_SECONDARY,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Entrez au moins 3 caractères',
                          style: TextStyle(
                            color: Globals.COLOR_TEXT_SECONDARY,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_pharmacies.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: _pharmacies.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final pharmacy = _pharmacies[index];
                      return _buildPharmacyCard(pharmacy);
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPharmacyCard(Pharmacy pharmacy) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Globals.COLOR_SURFACE,
      child: InkWell(
        onTap: () {
          // Créer une command temporaire avec la pharmacie sélectionnée
          final tempCommand = Command(
            id: 'temp_${pharmacy.cip}',
            pharmacy: pharmacy,
          );
          context.push('/pharmacy', extra: {'command': tempCommand});
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pharmacy.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Globals.COLOR_TEXT_DARK,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (pharmacy.firstName.isNotEmpty || pharmacy.lastName.isNotEmpty)
                        Text(
                          '${pharmacy.firstName} ${pharmacy.lastName}'.trim(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Globals.COLOR_TEXT_SECONDARY,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Globals.COLOR_SURFACE_SECONDARY,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'CIP: ${pharmacy.cip}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Globals.COLOR_TEXT_DARK,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildAddressSection(pharmacy),
            const SizedBox(height: 12),
            _buildActionButtons(pharmacy),
            if (pharmacy.informations.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Globals.COLOR_SURFACE_SECONDARY,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informations:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Globals.COLOR_TEXT_DARK,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pharmacy.informations,
                      style: TextStyle(
                        fontSize: 14,
                        color: Globals.COLOR_TEXT_DARK,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressSection(Pharmacy pharmacy) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.location_on,
              size: 16,
              color: Globals.COLOR_TEXT_SECONDARY,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                pharmacy.address1,
                style: TextStyle(
                  fontSize: 14,
                  color: Globals.COLOR_TEXT_DARK,
                ),
              ),
            ),
          ],
        ),
        if (pharmacy.address2.isNotEmpty) ...[
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              pharmacy.address2,
              style: TextStyle(
                fontSize: 14,
                color: Globals.COLOR_TEXT_DARK,
              ),
            ),
          ),
        ],
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            '${pharmacy.postalCode} ${pharmacy.city}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Globals.COLOR_TEXT_DARK,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Pharmacy pharmacy) {
    return Row(
      children: [
        if (pharmacy.latitude != 0 || pharmacy.longitude != 0)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _openMap(pharmacy.latitude, pharmacy.longitude, pharmacy.name),
              icon: const Icon(Icons.map, size: 16),
              label: const Text('Itinéraire'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Globals.COLOR_MOVIX,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showAdvancedSearch() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Globals.COLOR_SURFACE,
        title: Text(
          'Recherche avancée',
          style: TextStyle(color: Globals.COLOR_TEXT_DARK),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nom de la pharmacie',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Globals.COLOR_SURFACE_SECONDARY,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Adresse',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Globals.COLOR_SURFACE_SECONDARY,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _postalCodeController,
                      decoration: InputDecoration(
                        labelText: 'Code postal',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Globals.COLOR_SURFACE_SECONDARY,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        labelText: 'Ville',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Globals.COLOR_SURFACE_SECONDARY,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _cipController,
                decoration: InputDecoration(
                  labelText: 'Code CIP',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Globals.COLOR_SURFACE_SECONDARY,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _nameController.clear();
              _addressController.clear();
              _cityController.clear();
              _postalCodeController.clear();
              _cipController.clear();
            },
            child: Text(
              'Effacer',
              style: TextStyle(color: Globals.COLOR_TEXT_SECONDARY),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: TextStyle(color: Globals.COLOR_TEXT_SECONDARY),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performAdvancedSearch();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Globals.COLOR_MOVIX,
              foregroundColor: Colors.white,
            ),
            child: const Text('Rechercher'),
          ),
        ],
      ),
    );
  }

  Future<void> _performAdvancedSearch() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await searchPharmacies(
        name: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
        postalCode: _postalCodeController.text.trim().isEmpty ? null : _postalCodeController.text.trim(),
        cip: _cipController.text.trim().isEmpty ? null : _cipController.text.trim(),
      );
      
      setState(() {
        _pharmacies = results;
        _isLoading = false;
        if (results.isEmpty) {
          _errorMessage = 'Aucune pharmacie trouvée avec ces critères';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur lors de la recherche: $e';
        _pharmacies = [];
      });
    }
  }
}