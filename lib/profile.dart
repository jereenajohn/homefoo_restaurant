import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';


import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class home extends StatefulWidget {
  // var user_id;
 home({super.key });

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {

    void initState() {
    // TODO: implement initState
    super.initState();
   
  }

  
  

  @override
  Widget build(BuildContext context) {
     double screenWidth = MediaQuery.of(context).size.width;
    double carouselWidth = screenWidth * 0.9;
    return Scaffold(
      backgroundColor: Colors.white,

      body: 
 SingleChildScrollView(
   child: Container(
    child: Column(
      children: [
        Container(
          decoration: BoxDecoration(
             boxShadow: [
        BoxShadow(
          color: const Color.fromARGB(255, 183, 183, 183).withOpacity(0.5), // Shadow color
          spreadRadius: 5,
          blurRadius: 10,
          offset: Offset(0, 3), // changes position of shadow
        ),
      ],
   
            color: Colors.white, // Background color
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              children: [
                Column(
                  children: [
                    Image.asset(
                      "lib/assets/logo.png",
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              
   
              
              ],
            ),
          ),
        ),
        SizedBox(height: 17,),

        
   
   
   Padding(
     padding: const EdgeInsets.only(),
     child: Container(
      color: Colors.white,
       child: Column(
                      children: [
                         
                         
       
        
          ],
        ),
     ),
   ),]
   )
   ),
 )


    );
  }
}