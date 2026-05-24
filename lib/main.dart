import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const CardVodafoneApp());
}

class CardVodafoneApp extends StatelessWidget {
  const CardVodafoneApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Vodafone',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const SplashScreen(),
    );
  }
}
