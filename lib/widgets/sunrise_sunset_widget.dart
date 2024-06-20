import 'package:flutter/material.dart';
import 'package:weather_app_open_weather/model/weather_model.dart';

class SunriseSunsetWidget extends StatelessWidget {
  const SunriseSunsetWidget({
    super.key,
    required this.theme,
    required this.weatherData, required this.title, required this.timeUntil, required this.time,
  });

  final ThemeData theme;
  final String title;
  final String timeUntil;
  final String time;
  final WeatherModel? weatherData;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: theme.colorScheme.secondary,
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Image.asset('assets/images/sunrise.png', height: 50),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                time,
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
          const Spacer(),
          Text(
            timeUntil,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
