import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String apiKey = dotenv.env['API_KEY']!;
const String baseUrl = "http://api.openweathermap.org/data/2.5/weather";
//create dio instance
final Dio dio = Dio();
