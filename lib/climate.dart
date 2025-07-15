import 'dart:ui';
import 'package:calender_app/additional_information.dart';
import 'package:calender_app/hourly_forcast.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';


class Climateapp extends StatefulWidget{
  const Climateapp({super.key});

  @override
  State<Climateapp> createState() => _ClimateappState();
}

class _ClimateappState extends State<Climateapp> {
  @override
  void initState(){
  super.initState();
  getcurrentweather();

  }
  Future<Map<String,dynamic>> getcurrentweather() async {
   
final url = Uri.parse('https://api.weatherapi.com/v1/forecast.json?key=c64980e3c02f4d019bc165516251207&q=29.8543,77.8880&days=7&aqi=no&alerts=no');
    
    final response = await http.get(url);
      if (response.statusCode == 200) {
    return jsonDecode(response.body) as Map<String, dynamic>;
  } else {
    throw Exception('Failed: ${response.statusCode} → ${response.reasonPhrase}');
  }
}

  @override
  Widget build(BuildContext context){
    return  Scaffold(
      appBar: AppBar(
        title:const Text(
          'weather app',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: 
          (){
            print('refresh');
          }, icon:const Icon(Icons.refresh))
        ],

      ),
      body: FutureBuilder(
        future: getcurrentweather(),
        builder: (context, snapshot) {
          print(snapshot);
          if (snapshot.connectionState == ConnectionState.waiting){
            return const Center(
              child:  CircularProgressIndicator.adaptive()
              );
          }
          if(snapshot.hasError){
            return  Center( child: Text(
              snapshot.error.toString()
              ));
          }
          final data = snapshot.data!;
          final temp = data['current']['temp_c'];
          final currentsky = data['current']['condition']['text'];
          final pressure =data['current']['pressure_mb'];
          final humidity =data['current']['humidity'];
          final windspeed = data['current']['wind_mph'];
          final List<dynamic> hourlyDataList = data['forecast']['forecastday'][0]['hour']; 

          final String currenttimestr = data['current']['last_updated'];
          final DateTime currenttime = DateTime.parse(currenttimestr);
          final int currenthour = currenttime.hour;

          int startindex = 0;
          for ( int i =0 ; i<hourlyDataList.length; i++){
          final String hourlyTimeStr = hourlyDataList[i]['time'];
          final DateTime hourlyTime = DateTime.parse(hourlyTimeStr);
       if (currenthour == hourlyTime.hour)
       {
          startindex = i;
          break;
       }
          
          }

          
      return Padding(
          padding: const EdgeInsets.all(16.0),
          child:   Column(
            crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                SizedBox(
                  width: double.infinity,
                
               child: Card(
                shape: RoundedRectangleBorder
                (borderRadius: BorderRadius.circular(16)),
                elevation: 10,
            child:ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                 sigmaX:10, 
                 sigmaY: 10
                  ),
                child:  Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('$temp °C',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                      ),
                   const   SizedBox(height: 5,),
                      Icon(
                        currentsky =='Clouds' || currentsky =='rain' || currentsky == 'Partly Cloudy' || currentsky == 'Patchy rain nearby'
                        ?Icons.cloud
                        : Icons.sunny,
                      size: 30,
                      ),
                      const SizedBox(height: 5,),
                          
                          Text(
                            currentsky.toString(),
                           style:const TextStyle(
                          fontSize: 20,
                          ),
                          )
                    ],
                  ),
                ),
              ),
            )
            )
                ),
                
                      const  SizedBox(height: 20,),
                       const  Text('Hourly Forecast',
                       style:TextStyle(
                        fontSize: 25
                       ),
                       ),
                          SingleChildScrollView(
             scrollDirection:Axis.horizontal,
         child:   Row(
          
           children:  [

                       for (int i = startindex; i < startindex + 5 && i < hourlyDataList.length; i++)

                   Hourlyforcast(
                      hourlyforcasttime:DateFormat.j().format(DateTime.parse(hourlyDataList[i+1]['time'])),
                       image: Icons.cloud,
                     temperature: '${hourlyDataList[i+1]['temp_c']}°C',

                   
                   )
           ],
              ),
             ),
             
                       const  Text('Additional Information',
                       style:TextStyle(
                        fontSize: 25
                       ),
                       
                       ),
                      const SizedBox(height: 20,),
                     Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                       Additionalinfo(
                        icon: Icons.beach_access,
                        label: 'pressure',
                        value: pressure.toString(),
                       ),
                       Additionalinfo(
                         icon: Icons.air,
                        label: 'wind speed',
                        value: windspeed.toString(),
                       ),
                       Additionalinfo(
                          icon: Icons.water_drop,
                        label: 'humidity',
                        value: humidity.toString(),
                       ), 
                       
                      ],
                    )
                      
            ]//children
            ),
        );
          }
        
      ),
      );


    
  }
}
