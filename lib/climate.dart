import 'dart:ui';
import 'package:calender_app/additional_information.dart';
import 'package:calender_app/hourly_forcast.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Climateapp extends StatefulWidget {
  const Climateapp({super.key});

  @override
  State<Climateapp> createState() => _ClimateappState();
}

class _ClimateappState extends State<Climateapp> {
  @override
  void initState() {
    super.initState();
    getcurrentweather();
  }

  Future<Map<String, dynamic>> getcurrentweather() async {
    final url = Uri.parse(
        'https://api.weatherapi.com/v1/forecast.json?key=c64980e3c02f4d019bc165516251207&q=29.8543,77.8880&days=2&aqi=no&alerts=no');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed: ${response.statusCode} → ${response.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                setState(() {}); 
              },
              icon: const Icon(Icons.refresh))
        ],
      ),
      body: FutureBuilder(
        future: getcurrentweather(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data!;
          final temp = data['current']['temp_c'];
          final currentsky = data['current']['condition']['text'];
          final pressure = data['current']['pressure_mb'];
          final humidity = data['current']['humidity'];
          final windspeed = data['current']['wind_mph'];

          final List<dynamic> hourlyDataList = data['forecast']['forecastday'][0]['hour'];
          final List<dynamic> hourlyDataList2 = data['forecast']['forecastday'][1]['hour'];

          final List<dynamic> allhours = [...hourlyDataList, ...hourlyDataList2];

          final String currenttimestr = data['current']['last_updated'];
          final DateTime currenttime = DateTime.parse(currenttimestr);
          final int currenthour = currenttime.hour;

          int startindex = 0;
          for (int i = 0; i < allhours.length; i++) {
            final String hourlyTimeStr = allhours[i]['time'];
            final DateTime hourlyTime = DateTime.parse(hourlyTimeStr);
            if (currenttime.isBefore(hourlyTime) || currenthour == hourlyTime.hour) {
              startindex = i;
              break;
            }
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                width: double.infinity,
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 10,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              '$temp °C',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
                            ),
                            const SizedBox(height: 5),
                            Icon(
                              currentsky.toLowerCase().contains('cloud') || currentsky.toLowerCase().contains('rain')
                                  ? Icons.cloud
                                  : Icons.sunny,
                              size: 30,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              currentsky.toString(),
                              style: const TextStyle(fontSize: 20),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Hourly Forecast',
                style: TextStyle(fontSize: 25),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (int i = startindex+1; i < startindex + 6 && i < allhours.length; i++)
                      Hourlyforcast(
                        hourlyforcasttime:
                            DateFormat.j().format(DateTime.parse(allhours[i]['time'])),
                        image: allhours[i]['condition']['text']
                                .toString()
                                .toLowerCase()
                                .contains("rain")
                            ? Icons.cloud
                            : Icons.sunny,
                        temperature: '${allhours[i]['temp_c']}°C',
                      )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Additional Information',
                style: TextStyle(fontSize: 25),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Additionalinfo(
                    icon: Icons.beach_access,
                    label: 'Pressure',
                    value: pressure.toString(),
                  ),
                  Additionalinfo(
                    icon: Icons.air,
                    label: 'Wind Speed',
                    value: windspeed.toString(),
                  ),
                  Additionalinfo(
                    icon: Icons.water_drop,
                    label: 'Humidity',
                    value: humidity.toString(),
                  ),
                ],
              )
            ]),
          );
        },
      ),
    );
  }
}
