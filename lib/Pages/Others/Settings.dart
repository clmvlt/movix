import 'package:flutter/material.dart';
import 'package:movix/Pages/Others/SoundPackPage.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Services/scanner.dart';
import 'package:movix/Services/sound.dart';

import '../../Services/settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  ScanMode _selectedScanMode = Globals.SCAN_MODE;
  SoundPack _selectedSoundPack = Globals.SOUND_PACK;
  String _selectedMapApp = Globals.MAP_APP;
  bool _isDarkMode = Globals.DARK_MODE;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final darkMode = await getDarkMode();
    setState(() {
      _isDarkMode = darkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Globals.COLOR_BACKGROUND,
      appBar: AppBar(
        toolbarTextStyle: Globals.appBarTextStyle,
        titleTextStyle: Globals.appBarTextStyle,
        title: Text('Paramètres', style: TextStyle(color: Globals.COLOR_TEXT_LIGHT)),
        backgroundColor: Globals.COLOR_MOVIX,
        foregroundColor: Globals.COLOR_TEXT_LIGHT,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        children: <Widget>[
          _buildSectionHeader('Apparence'),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
            color: Globals.COLOR_SURFACE,
            margin: EdgeInsets.zero,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Globals.COLOR_MOVIX.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.dark_mode, color: Globals.COLOR_MOVIX, size: 20),
              ),
              title: Text(
                'Mode sombre',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Globals.COLOR_TEXT_DARK,
                ),
              ),
              trailing: Switch(
                value: _isDarkMode,
                onChanged: (value) async {
                  await setDarkMode(value);
                  setState(() {
                    _isDarkMode = value;
                  });
                },
                activeColor: Globals.COLOR_MOVIX,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('Préférences'),
          const SizedBox(height: 8),
          _buildSelectableCard<ScanMode>(
            context,
            title: 'Scanneur',
            subtitle: _selectedScanMode.name,
            icon: Icons.qr_code_scanner,
            options: ScanMode.values,
            getLabel: (mode) => mode.name,
            onSelected: (value) {
              setState(() {
                setScanMode(value.name);
                _selectedScanMode = value;
              });
            },
          ),
          const SizedBox(height: 12),
          _buildSelectableCard<SoundPack>(
            context,
            title: 'Pack de sons',
            subtitle: _selectedSoundPack.name,
            icon: Icons.music_note,
            options: SoundPack.values,
            getLabel: (s) => s.name,
            onSelected: (value) {
              setState(() {
                setSoundPack(value.name);
                _selectedSoundPack = value;
              });
            },
            trailing: IconButton(
              icon: Icon(Icons.list, color: Globals.COLOR_TEXT_GRAY),
              onPressed: () => _openSoundPackPage(_selectedSoundPack),
              tooltip: 'Voir les sons',
            ),
          ),
          const SizedBox(height: 12),
          _buildSelectableCard<String>(
            context,
            title: 'Application de carte',
            subtitle: _selectedMapApp,
            icon: Icons.map,
            options: const ["Google Maps", "Waze"],
            getLabel: (s) => s,
            onSelected: (value) {
              setState(() {
                _selectedMapApp = value;
                setMapApp(value);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Globals.COLOR_TEXT_GRAY,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSelectableCard<T>(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<T> options,
    required String Function(T) getLabel,
    required void Function(T) onSelected,
    Widget? trailing,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: Globals.COLOR_SURFACE,
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: () => _showSelectionDialog<T>(
            context, title, options, getLabel, onSelected),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Globals.COLOR_MOVIX.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Globals.COLOR_MOVIX, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Globals.COLOR_TEXT_DARK,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Globals.COLOR_TEXT_GRAY,
            fontSize: 14,
          ),
        ),
        trailing: trailing ?? Icon(
          Icons.chevron_right,
          color: Globals.COLOR_TEXT_GRAY,
          size: 20,
        ),
      ),
    );
  }

  void _showSelectionDialog<T>(
    BuildContext context,
    String title,
    List<T> options,
    String Function(T) getLabel,
    void Function(T) onSelected,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Globals.COLOR_SURFACE,
              Globals.COLOR_SURFACE.withOpacity(0.95),
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: Globals.COLOR_TEXT_GRAY.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 48,
                height: 5,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: Globals.COLOR_TEXT_GRAY.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Globals.COLOR_MOVIX.withOpacity(0.15),
                            Globals.COLOR_MOVIX.withOpacity(0.08),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.tune,
                        color: Globals.COLOR_MOVIX,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Globals.COLOR_TEXT_DARK,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Divider
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Globals.COLOR_TEXT_GRAY.withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...options.asMap().entries.map((entry) {
                final option = entry.value;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Globals.COLOR_SURFACE_SECONDARY.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Globals.COLOR_TEXT_GRAY.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    leading: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Globals.COLOR_MOVIX,
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(
                      getLabel(option),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Globals.COLOR_TEXT_DARK,
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Globals.COLOR_MOVIX.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Globals.COLOR_MOVIX,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      onSelected(option);
                    },
                  ),
                );
              }),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openSoundPackPage(SoundPack soundPack) async {
    Navigator.push(
      context,
      MaterialPageRoute<Widget>(
        builder: (context) => SoundPackPage(soundPack: soundPack),
      ),
    );
  }
}
