import 'package:flutter/material.dart';
import './pages/splash.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import './theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

void main() {
  runApp(ChangeNotifierProvider<DynamicTheme>(
      create: (_) => DynamicTheme(),
      child: MyApp(),
    ),
    );
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DynamicTheme>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeProvider.getDarkMode() ? ThemeData.dark() : ThemeData.light(),
      home: splashScreen(4),
    );
  }
}