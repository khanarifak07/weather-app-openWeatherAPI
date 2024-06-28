import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:weather_app_open_weather/config.dart';
import 'package:weather_app_open_weather/model/weather_model.dart';

class HomePageFutureBuilder extends StatefulWidget {
  const HomePageFutureBuilder({super.key});

  @override
  State<HomePageFutureBuilder> createState() => _HomePageFutureBuilderState();
}

class _HomePageFutureBuilderState extends State<HomePageFutureBuilder> {
  Future<WeatherModel?> fetchWeather(String city) async {
    try {
      //make dio get request
      Response response = await dio.get("$baseUrl?appid=$apiKey&q=$city");
      //handle response
      if (response.statusCode == 200) {
        log(response.data.toString());
        var json = response.data;
        var weatherData = WeatherModel.fromJson(json);
        return weatherData;
      } else {
        log("Error ${response.statusCode}");
      }
    } catch (e) {
      log("Eror while fetching weather $e");
    }
    return null;
  }

  // @override
  // void initState() {
  //   if (cityController.text.isEmpty) {
  //     fetchWeather('Mumbai');
  //   }
  //   super.initState();
  // }

  TextEditingController cityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: cityController,
              decoration: InputDecoration(
                hintText: "Search here...",
                suffixIcon: IconButton(
                  onPressed: () async {
                    final city = cityController.text;
                    if (city.isNotEmpty) {
                      var data = await fetchWeather(city);
                      setState(() {});
                    }
                    print("Presssssed");
                  },
                  icon: const Icon(Icons.search),
                ),
              ),
            ),
            FutureBuilder(
              future: cityController.text.isEmpty
                  ? fetchWeather('Mumbai')
                  : fetchWeather(cityController.text),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error: ${snapshot.hasError}"),
                  );
                } else if (snapshot.hasData && snapshot.data != null) {
                  if (snapshot.data == null) {
                    return const Center(
                      child: Text("No Data"),
                    );
                  } else {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(snapshot.data!.name),
                          Text(snapshot.data!.dt.toString()),
                          Column(
                            children: snapshot.data!.weather
                                .map((e) => Column(
                                      children: [
                                        Text(e.description),
                                        Text(e.icon)
                                      ],
                                    ))
                                .toList(),
                          )
                        ],
                      ),
                    );
                  }
                }
                return const Center(child: Text("City not found"));
              },
            ),
          ],
        ),
      ),
    );
  }
}
