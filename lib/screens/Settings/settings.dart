import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Provider para gestionar el tema y tamaño de fuente
class SettingsProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  double _fontSize = 16.0;

  bool get isDarkMode => _isDarkMode;
  double get fontSize => _fontSize;

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setFontSize(double size) {
    _fontSize = size;
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => SettingsProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return MaterialApp(
          theme: settings.isDarkMode ? ThemeData.dark() : ThemeData.light(),
          home: SettingsScreen(),
        );
      },
    );
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: Column(
        children: [
          SwitchListTile(
            title: Text("Dark Mode"),
            value: settings.isDarkMode,
            onChanged: (value) => settings.toggleDarkMode(),
          ),
          ListTile(
            title: Text("Font Size"),
            subtitle: Slider(
              min: 12.0,
              max: 24.0,
              value: settings.fontSize,
              onChanged: (value) => settings.setFontSize(value),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                "Text Example",
                style: TextStyle(fontSize: settings.fontSize),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
