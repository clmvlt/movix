import 'package:flutter/material.dart';
import 'package:movix/Pages/Others/SoundPackPage.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Services/map_service.dart';
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
  MapApp _selectedMapApp = Globals.MAP_APP;
  ScanSpeed _selectedScanSpeed = Globals.SCAN_SPEED;
  bool _isDarkMode = Globals.DARK_MODE;
  bool _vibrationsEnabled = Globals.VIBRATIONS_ENABLED;
  bool _soundEnabled = Globals.SOUND_ENABLED;
  bool _autoLaunchGps = Globals.AUTO_LAUNCH_GPS;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final darkMode = await getDarkMode();
    final vibrationsEnabled = await getVibrationsEnabled();
    final soundEnabled = await getSoundEnabled();
    final autoLaunchGps = await getAutoLaunchGps();
    final scanSpeed = await getScanSpeed();
    setState(() {
      _isDarkMode = darkMode;
      _vibrationsEnabled = vibrationsEnabled;
      _soundEnabled = soundEnabled;
      _autoLaunchGps = autoLaunchGps;
      _selectedScanSpeed = scanSpeed;
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
          // === APPARENCE ===
          _buildSectionHeader('Apparence'),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
            color: Globals.COLOR_SURFACE,
            margin: EdgeInsets.zero,
            child: _buildSwitchTile(
              icon: Icons.dark_mode,
              title: 'Mode sombre',
              value: _isDarkMode,
              onChanged: (bool value) async {
                await setDarkMode(value);
                setState(() => _isDarkMode = value);
              },
            ),
          ),

          // === VIBRATIONS ===
          const SizedBox(height: 24),
          _buildSectionHeader('Vibrations'),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
            color: Globals.COLOR_SURFACE,
            margin: EdgeInsets.zero,
            child: _buildSwitchTile(
              icon: Icons.vibration,
              title: 'Vibrations',
              subtitle: 'Vibrer lors du scan de colis',
              value: _vibrationsEnabled,
              onChanged: (bool value) async {
                await setVibrationsEnabled(value);
                setState(() => _vibrationsEnabled = value);
              },
            ),
          ),

          // === SONS ===
          const SizedBox(height: 24),
          _buildSectionHeader('Sons'),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
            color: Globals.COLOR_SURFACE,
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                _buildSwitchTile(
                  icon: Icons.volume_up,
                  title: 'Sons activés',
                  subtitle: 'Jouer un son lors du scan de colis',
                  value: _soundEnabled,
                  onChanged: (bool value) async {
                    await setSoundEnabled(value);
                    setState(() => _soundEnabled = value);
                  },
                ),
                _buildDivider(),
                _buildSelectableTileWithPreview<SoundPack>(
                  context,
                  title: 'Pack de sons',
                  subtitle: _selectedSoundPack.name,
                  icon: Icons.music_note,
                  options: SoundPack.values,
                  getLabel: (SoundPack s) => s.name,
                  onSelected: (SoundPack value) {
                    setState(() {
                      setSoundPack(value.name);
                      _selectedSoundPack = value;
                    });
                  },
                  onPreview: () => _openSoundPackPage(_selectedSoundPack),
                ),
              ],
            ),
          ),

          // === SCANNER ===
          const SizedBox(height: 24),
          _buildSectionHeader('Scanner'),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
            color: Globals.COLOR_SURFACE,
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                _buildSelectableTile<ScanMode>(
                  context,
                  title: 'Mode de scan',
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
                _buildDivider(),
                _buildSelectableTile<ScanSpeed>(
                  context,
                  title: 'Vitesse de scan',
                  subtitle: _selectedScanSpeed.displayName,
                  icon: Icons.speed,
                  options: ScanSpeed.values,
                  getLabel: (speed) => speed.displayName,
                  onSelected: (value) {
                    setState(() {
                      setScanSpeed(value);
                      _selectedScanSpeed = value;
                    });
                  },
                ),
              ],
            ),
          ),

          // === NAVIGATION ===
          const SizedBox(height: 24),
          _buildSectionHeader('Navigation'),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
            color: Globals.COLOR_SURFACE,
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                _buildSelectableTile<MapApp>(
                  context,
                  title: 'Application de carte',
                  subtitle: _selectedMapApp.displayName,
                  icon: Icons.map,
                  options: MapService.getAvailableApps(),
                  getLabel: (MapApp app) => app.displayName,
                  onSelected: (MapApp value) {
                    setState(() {
                      _selectedMapApp = value;
                      setMapApp(value);
                    });
                  },
                ),
                _buildDivider(),
                _buildSwitchTile(
                  icon: Icons.navigation,
                  title: 'Lancement auto du GPS',
                  subtitle: 'Ouvrir le GPS après validation de livraison',
                  value: _autoLaunchGps,
                  onChanged: (bool value) async {
                    await setAutoLaunchGps(value);
                    setState(() => _autoLaunchGps = value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
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

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Globals.COLOR_TEXT_GRAY.withOpacity(0.1),
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Globals.COLOR_ADAPTIVE_ACCENT.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Globals.COLOR_ADAPTIVE_ACCENT, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Globals.COLOR_TEXT_DARK,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: Globals.COLOR_TEXT_GRAY,
                fontSize: 13,
              ),
            )
          : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Globals.COLOR_ADAPTIVE_ACCENT,
      ),
    );
  }

  Widget _buildSelectableTile<T>(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<T> options,
    required String Function(T) getLabel,
    required void Function(T) onSelected,
    Widget? trailing,
  }) {
    return ListTile(
      onTap: () => _showSelectionDialog<T>(
          context, title, options, getLabel, onSelected),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Globals.COLOR_ADAPTIVE_ACCENT.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Globals.COLOR_ADAPTIVE_ACCENT, size: 20),
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
    );
  }

  Widget _buildSelectableTileWithPreview<T>(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<T> options,
    required String Function(T) getLabel,
    required void Function(T) onSelected,
    required VoidCallback onPreview,
  }) {
    return ListTile(
      onTap: () => _showSelectionDialog<T>(
          context, title, options, getLabel, onSelected),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Globals.COLOR_ADAPTIVE_ACCENT.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Globals.COLOR_ADAPTIVE_ACCENT, size: 20),
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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.headphones, color: Globals.COLOR_TEXT_GRAY, size: 20),
            onPressed: onPreview,
            tooltip: 'Écouter les sons',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right,
            color: Globals.COLOR_TEXT_GRAY,
            size: 20,
          ),
        ],
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
            color: Globals.COLOR_ADAPTIVE_ACCENT.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Globals.COLOR_ADAPTIVE_ACCENT, size: 20),
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
      useRootNavigator: true,
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
                            Globals.COLOR_ADAPTIVE_ACCENT.withOpacity(0.15),
                            Globals.COLOR_ADAPTIVE_ACCENT.withOpacity(0.08),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.tune,
                        color: Globals.COLOR_ADAPTIVE_ACCENT,
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
                        color: Globals.COLOR_ADAPTIVE_ACCENT,
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
                        color: Globals.COLOR_ADAPTIVE_ACCENT.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Globals.COLOR_ADAPTIVE_ACCENT,
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      // Délai pour iOS 18 compatibility
                      await Future<void>.delayed(const Duration(milliseconds: 100));
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
