import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app_open_weather/config.dart';
import 'package:weather_app_open_weather/model/weather_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: searchCtrl,
            decoration: InputDecoration(
              hintText: "Search here...",
              suffixIcon: IconButton(
                onPressed: () async {
                  if (searchCtrl.text.isNotEmpty) {
                    setState(() {
                      isLoading = true;
                    });
                    // await Future.delayed(const Duration(seconds: 1));
                    WeatherModel? data = await getWeather(searchCtrl.text);
                    setState(() {
                      weatherData = data;
                      isLoading = false;
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Please Enter Something")));
                  }
                },
                icon: const Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
              child: isLoading
                  ? const CircularProgressIndicator()
                  : weatherData != null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(weatherData!.name),
                            Text(weatherData!.main.tempInCelsius
                                .toStringAsFixed(2)),
                            Text(weatherData!.visibility.toString()),
                            Column(
                              children: weatherData!.weather
                                  .map((e) => Column(
                                        children: [
                                          Text(e.description),
                                          Text(e.icon)
                                        ],
                                      ))
                                  .toList(),
                            )
                          ],
                        )
                      : const Text("No Data")),
        ],
      ),
    ));
  }
}
