import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:weather_app_open_weather/config.dart';
import 'package:weather_app_open_weather/model/weather_model.dart';
import 'package:weather_app_open_weather/theme/theme_provider.dart';
import 'package:weather_app_open_weather/widgets/sunrise_sunset_widget.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  WeatherModel? weatherData;
  TextEditingController searchCtrl = TextEditingController();
  bool isLoading = false;

  //get current location and weather by geolocator package
  Future<void> getCurrentLocationAndWeather() async {
    setState(() {
      isLoading = true;
    });
    try {
      //check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location service are disabled');
      }

      //Check for location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception("Location permission is denied");
        }
      }
      //
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      //get the current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      //get the city name by lat lon with the help of position
      String city =
          await getCityNameCoordinates(position.longitude, position.latitude);
      //get the weather
      WeatherModel? data = await getWeather(city);
      setState(() {
        weatherData = data;
        isLoading = false;
      });
    } catch (e) {
      log("Error while getting current location and weather $e");
    }
  }

  //get weather by city
  Future<WeatherModel?> getWeather(String city) async {
    try {
      //male dio request
      Response response = await dio.get("$baseUrl?appid=$apiKey&q=$city");
      //handle response
      if (response.statusCode == 200) {
        print(response.data);
        // List<dynamic> weatherData = response.data;
        // List<WeatherModel> weather =
        //     weatherData.map((e) => WeatherModel.fromJson(e)).toList();
        var weatherModel = WeatherModel.fromJson(response.data);

        //1.First approach to assign the fetched data
        // setState(() {
        //   weatherData = weatherModel;
        // });

        return weatherModel;
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      log("Error while getting weather $e");
    }
    return null;
  }

  //get city name by lat lon
  Future<String> getCityNameCoordinates(double lon, double lat) async {
    //maek dio get request
    Response response =
        await dio.get('$baseUrl?appid=$apiKey&lon=$lon&lat=$lat');
    //handle response
    if (response.statusCode == 200) {
      String city = response.data['name'];
      return city;
    } else {
      log('Error while getting city name based on lat lon ${response.statusCode}');
      throw Exception('Failed to get city name');
    }
  }

  @override
  void initState() {
    getCurrentLocationAndWeather();
    super.initState();
  }

  //second approach to assign the fetche data
  // void initState() {
  //   super.initState();
  //   fetchWeather('Mumbai').then((data) {  //if we are doing like this then again we need to assing the fetched data to new data as mentoin below
  //     setState(() {
  //       weatherDatas = data;
  //     });
  //   });
  // }

  String formattedDate = DateFormat('EEE, MMM d, ' 'yy').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themePro = ref.watch(themeProvider);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: theme.colorScheme.primary,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.primary,
          title: const Text("Weather"),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                themePro.toggleTheme();
              },
              icon: themePro.isDarkMode
                  ? const Icon(
                      Icons.light_mode,
                    )
                  : const Icon(
                      Icons.dark_mode,
                    ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
          child: ListView(
            children: [
              Container(
                // padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(30)),
                child: TextField(
                  controller: searchCtrl,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10),
                    border: InputBorder.none,
                    hintText: "Search for city...",
                    prefixIcon: IconButton(
                      onPressed: () async {
                        if (searchCtrl.text.isNotEmpty) {
                          setState(() {
                            isLoading = true;
                          });
                          // await Future.delayed(const Duration(seconds: 1));
                          WeatherModel? data =
                              await getWeather(searchCtrl.text);
                          setState(() {
                            weatherData = data;
                            isLoading = false;
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Please Enter Something")));
                        }
                      },
                      icon: const Icon(IconlyLight.search),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                  child: isLoading
                      ? const Center(
                          child: Text("Loading data..."),
                        )
                      : weatherData != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(30),
                                  width: double.maxFinite,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.secondary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${weatherData!.name},',
                                            style: const TextStyle(
                                                fontSize: 30,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                                color:
                                                    theme.colorScheme.primary,
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            padding: const EdgeInsets.all(10),
                                            child: Text(
                                              formattedDate,
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          )
                                        ],
                                      ),
                                      Text(
                                        weatherData!.sys.country,
                                        style: const TextStyle(
                                          fontSize: 30,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${weatherData!.main.tempInCelsius.toStringAsFixed(0)}°',
                                            style: const TextStyle(
                                                fontSize: 60,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Column(
                                            children: weatherData!.weather
                                                .map(
                                                  (e) => Column(
                                                    children: [
                                                      e.main == 'Rain'
                                                          ? Image.asset(
                                                              'assets/images/rain.png',
                                                              height: 100,
                                                            )
                                                          : e.main == 'Clouds'
                                                              ? Image.asset(
                                                                  'assets/images/clouds.png',
                                                                  height: 60,
                                                                )
                                                              : e.main ==
                                                                      'Sunny'
                                                                  ? Image.asset(
                                                                      'assets/images/sunny.png',
                                                                      height:
                                                                          60,
                                                                    )
                                                                  : const SizedBox
                                                                      .shrink()
                                                    ],
                                                  ),
                                                )
                                                .toList(),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  "Sunrise & Sunset",
                                  style: TextStyle(fontSize: 20),
                                ),
                                const SizedBox(height: 10),
                                SunriseSunsetWidget(
                                    theme: theme,
                                    weatherData: weatherData,
                                    title: 'Sunrise',
                                    time: weatherData!.sys.sunriseFormatted,
                                    timeUntil: weatherData!
                                        .sys.formattedTimeUntilSunrise),
                                const SizedBox(height: 15),
                                SunriseSunsetWidget(
                                  theme: theme,
                                  weatherData: weatherData,
                                  title: 'Sunset',
                                  time: weatherData!.sys.sunsetFormatted,
                                  timeUntil:
                                      weatherData!.sys.formattedTimeUntilSunset,
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                      color: theme.colorScheme.secondary,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            children: [
                                              Image.asset(
                                                  'assets/images/min.png',
                                                  height: 20),
                                              const SizedBox(height: 6),
                                              Text(
                                                '${weatherData!.main.tempMinInCelsius.toStringAsFixed(0)}°',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16),
                                              ),
                                              const Text("Min. Temp"),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Image.asset(
                                                  'assets/images/feelslike.png',
                                                  height: 20),
                                              const SizedBox(height: 6),
                                              Text(
                                                '${weatherData!.main.feelsLikeInCelsius.toStringAsFixed(0)}°',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16),
                                              ),
                                              const Text("Feels Like"),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Image.asset(
                                                  'assets/images/max.png',
                                                  height: 20),
                                              const SizedBox(height: 6),
                                              Text(
                                                '${weatherData!.main.tempMaxInCelsius.toStringAsFixed(0)}°',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16),
                                              ),
                                              const Text("Max. Temp"),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            children: [
                                              Image.asset(
                                                  'assets/images/humidity.png',
                                                  height: 20),
                                              const SizedBox(height: 6),
                                              Text(
                                                '${weatherData!.main.tempMinInCelsius.toStringAsFixed(0)}°',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16),
                                              ),
                                              const Text("Humidity"),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Image.asset(
                                                  'assets/images/wind.png',
                                                  height: 20),
                                              const SizedBox(height: 6),
                                              Text(
                                                '${weatherData!.main.feelsLikeInCelsius.toStringAsFixed(0)}°',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16),
                                              ),
                                              const Text("Wind"),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Image.asset(
                                                  'assets/images/visibility.png',
                                                  height: 20),
                                              const SizedBox(height: 6),
                                              Text(
                                                '${weatherData!.main.tempMaxInCelsius.toStringAsFixed(0)}°',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16),
                                              ),
                                              const Text("Visibility"),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            )
                          : const Text("No Data")),
            ],
          ),
        ));
  }
}
