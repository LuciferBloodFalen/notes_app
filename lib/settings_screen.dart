import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

class SettingsScreen extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final Widget? drawer;
  const SettingsScreen({
    super.key,
    required this.currentThemeMode,
    this.drawer,
  });

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
    HapticFeedback.lightImpact();
    _announce(
      'Theme changed to ${_selectedMode == ThemeMode.dark ? 'Dark' : 'Light'} mode',
      context,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Theme changed to ${_selectedMode == ThemeMode.dark ? 'Dark' : 'Light'} mode',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _onSystemTap() {
    setState(() {
      _selectedMode = ThemeMode.system;
    });
    Navigator.of(context).pop(_selectedMode);
    HapticFeedback.lightImpact();
    _announce('Theme changed to System Default', context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Theme changed to System Default'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _announce(String message, BuildContext context) {
    SemanticsService.announce(message, Directionality.of(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: widget.drawer,
      appBar: AppBar(
        leading:
            widget.drawer != null
                ? Builder(
                  builder:
                      (context) => IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                )
                : null,
        title: const Text('Settings'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
            secondary: const Icon(Icons.dark_mode, color: Colors.deepPurple),
            activeColor: Colors.deepPurple,
          ),
          ListTile(
            leading: const Icon(
              Icons.brightness_auto,
              color: Colors.deepPurple,
            ),
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
