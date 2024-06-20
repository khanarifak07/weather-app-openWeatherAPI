import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_app_open_weather/screen/home_page.dart';
import 'package:weather_app_open_weather/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  dotenv.load(fileName: ".env");
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themePro = ref.watch(themeProvider);
    return MaterialApp(
      theme: themePro.themeData,
      home: const HomePage(),
    );
  }
}
