import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:file_picker/file_picker.dart';
import 'package:homefoo_restaurant/api.dart';
import 'package:homefoo_restaurant/beforeapprove.dart';
import 'package:homefoo_restaurant/home.dart';
import 'package:homefoo_restaurant/register.dart';

import 'package:shared_preferences/shared_preferences.dart'; // Added import for shared_preferences

import 'package:http/http.dart' as http;

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  TextEditingController email = TextEditingController();

  TextEditingController password = TextEditingController();

  var selectedfile;
  api a = api();
  @override
  void initState() {
    super.initState();
  }

  Future<void> storeUserId(String userId, String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    await prefs.setString('token', token);
  }

  void Rlogin() async {
    try {
      var response = await http.post(
        Uri.parse(
            "https://describes-soldier-hourly-cartoon.trycloudflare.com/HOMFOO-restaurant/login/"),
        body: {
          'email': email.text,
          'password': password.text,
        },
      );
print("==========>>>>>>>>>.${response.body}");
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        var status = responseData['status'];
        if (status == 'login success') {
          var userId = responseData['user_id'];
          // Extract user ID
          var token = responseData['token'];
          setState(() {
            userId = userId.toString();
          });

          await storeUserId(
              userId, token); // Store user ID in shared preferences

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => home()),
          );
        } else {
          showSnackbar('Login failed: $status');
        }
      } else {
        showSnackbar('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      showSnackbar('Error: $e');
    }
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Builder(builder: (BuildContext scaffoldContext) {
          return SingleChildScrollView(
            child: Container(
                child: Column(
              children: [
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
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, left: 50),
                    child: Row(
                      children: [
                        Image.asset(
                          "lib/assets/logo.png",
                          width: 250,
                          height: 250,
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
                    Text(
                      "Welcom Back !",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ],
                ),

                SizedBox(height: 15),

                Container(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Container(
                          child: Column(
                            children: [
                              SizedBox(
                                height: 15,
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              TextField(
                                controller: email,
                                decoration: InputDecoration(
                                  labelText: 'email',
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: const Color.fromARGB(
                                            255,
                                            165,
                                            165,
                                            165)), // Change border color here
                                    borderRadius: BorderRadius.circular(
                                        10.0), // Optional: change border radius
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color.fromARGB(
                                                255, 170, 170, 170)
                                            .withOpacity(
                                                0.5)), // Change enabled border color here
                                    borderRadius: BorderRadius.circular(
                                        10.0), // Optional: change border radius
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color.fromARGB(255, 188, 2,
                                            2)), // Change focused border color here
                                    borderRadius: BorderRadius.circular(
                                        10.0), // Optional: change border radius
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  prefixIcon: Icon(Icons
                                      .email), // Changed icon to lock for password
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 16.0),
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              TextField(
                                controller: password,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: const Color.fromARGB(
                                            255,
                                            165,
                                            165,
                                            165)), // Change border color here
                                    borderRadius: BorderRadius.circular(
                                        10.0), // Optional: change border radius
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color.fromARGB(
                                                255, 170, 170, 170)
                                            .withOpacity(
                                                0.5)), // Change enabled border color here
                                    borderRadius: BorderRadius.circular(
                                        10.0), // Optional: change border radius
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color.fromARGB(255, 188, 2,
                                            2)), // Change focused border color here
                                    borderRadius: BorderRadius.circular(
                                        10.0), // Optional: change border radius
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  prefixIcon: Icon(Icons
                                      .lock), // Changed icon to lock for password
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 16.0),
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => waiting()));
                              },
                              child: Text(
                                "forgot Password ?",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 172, 172, 172)),
                              )),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Register()));
                              },
                              child: Text(
                                "Register a new membership",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 172, 172, 172)),
                              )),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: 20,
                ),
                // Sign In Button
                Container(
                  width: MediaQuery.of(context).size.width *
                      0.6, // Set button width as half of the screen width
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(20.0), // Border radius for button
                    color: const Color.fromARGB(255, 243, 33, 33),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Rlogin();
                    },
                    child: Text(
                      "Sign In",
                      style: TextStyle(
                        color: Colors.white, // Text color
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ],
            )),
          );
        }));
  }
}
