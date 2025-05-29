import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final ThemeMode currentThemeMode;
  const SettingsScreen({super.key, required this.currentThemeMode});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ThemeMode _selectedMode;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.currentThemeMode;
  }

  void _onSwitchChanged(bool value) {
    setState(() {
      _selectedMode = value ? ThemeMode.dark : ThemeMode.light;
    });
    Navigator.of(context).pop(_selectedMode);
  }

  void _onSystemTap() {
    setState(() {
      _selectedMode = ThemeMode.system;
    });
    Navigator.of(context).pop(_selectedMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        children: [
          const ListTile(
            title: Text(
              'Appearance',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: _selectedMode == ThemeMode.dark,
            onChanged: (value) => _onSwitchChanged(value),
            secondary: const Icon(Icons.dark_mode),
          ),
          ListTile(
            leading: const Icon(Icons.brightness_auto),
            title: const Text('System Default'),
            trailing:
                _selectedMode == ThemeMode.system
                    ? const Icon(Icons.check, color: Colors.deepPurple)
                    : null,
            onTap: _onSystemTap,
          ),
        ],
      ),
    );
  }
}
