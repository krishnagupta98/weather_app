import 'package:flutter/material.dart';

class Hourlyforcast extends StatelessWidget {
  final IconData image;
  final String hourlyforcasttime;
  final String temperature; 
  const Hourlyforcast({
    super.key,
     required this.image, 
     required this.hourlyforcasttime, 
     required this.temperature,
  });

  @override
  Widget build(BuildContext context) {
    return  Card(
           child: Padding(
             padding:const EdgeInsets.all(8.0),
             child: Column(
               children: [
                const  SizedBox(
                 width: 70,
               ),
                 Text(hourlyforcasttime,
                 style: const  TextStyle(
                   fontSize:16
                 ),
                 ),
                const SizedBox(height: 5,),
                 Icon(
                image,
                   size: 30,
                   ),   
                  const SizedBox(height: 5,),
                   Text('$temperature°C')
                  ],
               ),
           ),
    ); //card 1
  }}