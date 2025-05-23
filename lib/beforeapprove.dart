import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:file_picker/file_picker.dart';
import 'package:homefoo_restaurant/login.dart';


import 'package:http/http.dart' as http;

class waiting extends StatefulWidget {
  const waiting({super.key});

  @override
  State<waiting> createState() => _waitingState();
}

class _waitingState extends State<waiting> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
 
   
   
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:Builder(
        builder: (BuildContext scaffoldContext) {
          return SingleChildScrollView(
            child: Container(
              child: Column(
             
                mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 100),
                 Container(
            width: MediaQuery.of(context).size.width * 10,
            height: 200,
            decoration: BoxDecoration(
             
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 255, 255, 255),
                  Color.fromARGB(255, 255, 255, 255),
                ],
              ),
          
              
            ),
            child:  Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "lib/assets/wait.gif",
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ],
              ),
            ),
                ),
               // Adds spacing between the container and text fields
              
               Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Wait until Your request Is Approved!",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),),
                              ],
                  ),
                
                SizedBox(height: 15),

                   Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("You will Recive a approval  email on your Registerd email!",style: TextStyle(fontSize: 10,color: Colors.grey),),
                              ],
                  ),


                   SizedBox(height: 20,),
                // Sign In Button
                Container(
            width: MediaQuery.of(context).size.width * 0.6, // Set button width as half of the screen width
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0), // Border radius for button
              color: const Color.fromARGB(255, 243, 33, 33),
            ),
            child: TextButton(
              onPressed: () {

             Navigator.push(context, MaterialPageRoute(builder: (context)=>login()));


                
               
              },
              child: Text(
                "sign In",
                style: TextStyle(
                  color: Colors.white, // Text color
                  fontSize: 16.0,
                ),
              ),
            ),
                ),
                
          
             
               
             
               
              
                
          
          
          
              ],
            )
            
            ),
          );
        }
      )

    
  );




  }
}