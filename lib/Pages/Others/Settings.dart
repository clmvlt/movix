import 'package:flutter/material.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Services/scanner.dart';
import '../../Services/settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedScanMode = Globals.SCAN_MODE;
  String _selectedSoundPack = Globals.SOUND_PATH == "mario" ? "Mario" : "Basic";
  String _selectedMapApp = Globals.MAP_APP;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarTextStyle: Globals.appBarTextStyle,
        titleTextStyle: Globals.appBarTextStyle,
        title: const Text('Paramètres'),
        backgroundColor: Globals.COLOR_MOVIX,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          _buildSelectableCard(
            context,
            title: 'Scanneur',
            subtitle: _selectedScanMode,
            icon: Icons.qr_code_scanner,
            options: const ["Camera", "DT50", "Manuel"],
            onSelected: (value) {
              setState(() {
                setScanMode(value);
                _selectedScanMode = value;
              });
            },
          ),
          const SizedBox(height: 20),
          _buildSelectableCard(
            context,
            title: 'Pack de sons',
            subtitle: _selectedSoundPack,
            icon: Icons.music_note,
            options: const ["Basic", "Mario"],
            onSelected: (value) {
              setState(() {
                final soundValue = value.toLowerCase();
                setSoundPATH(soundValue);
                _selectedSoundPack = value;
              });
            },
          ),
          const SizedBox(height: 20),
          _buildSelectableCard(
            context,
            title: 'Application de carte',
            subtitle: _selectedMapApp,
            icon: Icons.map,
            options: const ["Google Maps", "Waze"],
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

  Widget _buildSelectableCard(BuildContext context,
      {required String title,
      required String subtitle,
      required IconData icon,
      required List<String> options,
      required Function(String) onSelected}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: ListTile(
        onTap: () => _showSelectionDialog(context, title, options, onSelected),
        leading: Icon(icon, color: Globals.COLOR_MOVIX),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  void _showSelectionDialog(BuildContext context, String title,
      List<String> options, Function(String) onSelected) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ...options.map((option) => ListTile(
                title: Text(option),
                onTap: () {
                  Navigator.pop(context);
                  onSelected(option);
                },
              )),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
