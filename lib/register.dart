import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:file_picker/file_picker.dart';
import 'package:homefoo_restaurant/api.dart';
import 'package:homefoo_restaurant/beforeapprove.dart';
import 'package:homefoo_restaurant/login.dart';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';


import 'package:http/http.dart' as http;

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCurrentPosition();
  }
  TextEditingController name= TextEditingController();
  TextEditingController owner= TextEditingController();
  TextEditingController place= TextEditingController();
  TextEditingController email= TextEditingController();
  TextEditingController phone= TextEditingController();
  TextEditingController password= TextEditingController();
    TextEditingController Confirm= TextEditingController();


  String? _currentAddress;
  Position? _currentPosition;


   Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      _getAddressFromLatLng(_currentPosition!);
    }).catchError((e) {
      debugPrint(e);
    });

    print( _currentPosition!.latitude);
    print( _currentPosition!.latitude);
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
            _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            ' ${place.subLocality} ${place.subAdministrativeArea}';
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }


  
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }


   
    var selectedfile;
    api a=api();



void RegisterUserData(
  String url,
  String name,
  String ownerName,
  String place,
  String email,
  String phone,
  String password,
  String confirm,
  File? selectedImage,
  BuildContext scaffoldContext,
) async {
  try {
    // Fetch user's current location
    Position? _currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    print("selectedImage is $selectedImage");
    print(_currentPosition?.latitude.toString());
    print(_currentPosition?.longitude.toString());

    // Check if location data is available
    if (_currentPosition == null) {
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          content: Text('Location data not available.'),
        ),
      );
      return;
    }

    // Proceed with registration using location data
    if (name.isEmpty || phone.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          content: Text('Please fill out all fields.'),
        ),
      );
      return;
    } else if (password != confirm) {
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          content: Text('Password Mismatched'),
        ),
      );
      return;
    }

    var request = http.MultipartRequest('POST', Uri.parse(url));
    // Add text fields to the request
    request.fields['name'] = name;
    request.fields['owner_name'] = ownerName;
    request.fields['location'] = place;
    request.fields['email'] = email;
    request.fields['phone'] = phone;
    request.fields['password'] = password;
    request.fields['latitude'] = _currentPosition.latitude.toString();
    request.fields['longitude'] = _currentPosition.longitude.toString();

    // Add image to the request if it is not null and the file exists
    if (selectedImage != null && await selectedImage.exists()) {
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        selectedImage.path,
      ));
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    // Handle response based on status code
    if (response.statusCode == 200) {
      // Registration successful
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          content: Text('Registered Successfully.'),
        ),
      );
      Navigator.pushReplacement(
        scaffoldContext,
        MaterialPageRoute(builder: (context) => waiting()),
      );
    } else if (response.statusCode == 400) {
      // Handle validation errors or other specific errors from the server
      // Show an alert dialog with the error message
      Map<String, dynamic> responseData = jsonDecode(response.body);
      String errorMessage = responseData['message'] ?? 'Something went wrong.';
      showDialog(
        context: scaffoldContext,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text(errorMessage),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    } else {
      // Handle other status codes (e.g., 500, 404)
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          content: Text('Something went wrong. Please try again later.'),
        ),
      );
    }
  } catch (e) {
    // Handle network errors or exceptions
    print("Error: $e");
    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
      SnackBar(
        content: Text('Network error. Please check your connection.'),
      ),
    );
  }
}


  //select  image from gallery or camera

 File? selectedImage;

    void imageSelect() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null) {
        setState(() {
          selectedImage = File(result.files.single.path!);
          print("================$selectedImage");
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("image1 selected successfully."),
          backgroundColor: Color.fromARGB(173, 120, 249, 126),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error while selecting the file."),
        backgroundColor: Colors.red,
      ));
    }
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
              children: [
                 Container(
            width: MediaQuery.of(context).size.width * 10,
            height: 150,
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
              padding: const EdgeInsets.only(top: 0, left: 50),
              child: Row(
          children: [
            Image.asset(
              "lib/assets/logo.png",
              width: 240,
              height: 240,
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
                                Text("Register Now !",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                              ],
                  ),
                
                SizedBox(height: 15),
          
                Container(
                  child: Column(
                    children: [
          
                           
                Padding(
            padding: const EdgeInsets.only(left: 20,right: 20),
            child: Container(
              child: Column(
                children: [
                   TextField(
                    controller: name,
                decoration: InputDecoration(
                  labelText: 'Restaurants Name',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: const Color.fromARGB(255, 165, 165, 165)), // Change border color here
                    borderRadius: BorderRadius.circular(10.0), // Optional: change border radius
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 170, 170, 170).withOpacity(0.5)), // Change enabled border color here
                    borderRadius: BorderRadius.circular(10.0), // Optional: change border radius
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 188, 2, 2)), // Change focused border color here
                    borderRadius: BorderRadius.circular(10.0), // Optional: change border radius
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.person),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                ),
              ),
              SizedBox(height: 15,),
              TextField(
                    controller: owner,
                decoration: InputDecoration(
                  labelText: 'Owner Name',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: const Color.fromARGB(255, 165, 165, 165)), // Change border color here
                    borderRadius: BorderRadius.circular(10.0), // Optional: change border radius
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 170, 170, 170).withOpacity(0.5)), // Change enabled border color here
                    borderRadius: BorderRadius.circular(10.0), // Optional: change border radius
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 188, 2, 2)), // Change focused border color here
                    borderRadius: BorderRadius.circular(10.0), // Optional: change border radius
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.person),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                ),
              ),
               SizedBox(height: 15,),
              TextField(
                    controller: place,
                decoration: InputDecoration(
                  labelText: 'Place of Restaurants',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: const Color.fromARGB(255, 165, 165, 165)), // Change border color here
                    borderRadius: BorderRadius.circular(10.0), // Optional: change border radius
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 170, 170, 170).withOpacity(0.5)), // Change enabled border color here
                    borderRadius: BorderRadius.circular(10.0), // Optional: change border radius
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color:  Color.fromARGB(255, 188, 2, 2)), // Change focused border color here
                    borderRadius: BorderRadius.circular(10.0), // Optional: change border radius
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.location_city),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                ),
              ),
             
              SizedBox(height: 15,),
              TextField(
                 controller: email,
                decoration: InputDecoration(
                  labelText: 'email',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: const Color.fromARGB(255, 165, 165, 165)), // Change border color here
                    borderRadius: BorderRadius.circular(10.0), // Optional: change border radius
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 170, 170, 170).withOpacity(0.5)), // Change enabled border color here
                    borderRadius: BorderRadius.circular(10.0), // Optional: change border radius
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 188, 2, 2)), // Change focused border color here
                    borderRadius: BorderRadius.circular(10.0), // Optional: change border radius
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.email), // Changed icon to lock for password
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                ),
              ),
              SizedBox(height: 15,),
              TextField(
                 controller: phone,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: const Color.fromARGB(255, 165, 165, 165)), // Change border color here
                    borderRadius: BorderRadius.circular(10.0), // Optional: change border radius
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 170, 170, 170).withOpacity(0.5)), // Change enabled border color here
                    borderRadius: BorderRadius.circular(10.0), // Optional: change border radius
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 188, 2, 2)), // Change focused border color here
                    borderRadius: BorderRadius.circular(10.0), // Optional: change border radius
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.phone),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                ),
              ),
              SizedBox(height: 15,),
              TextField(
                 controller: password,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: const Color.fromARGB(255, 165, 165, 165)), // Change border color here
                    borderRadius: BorderRadius.circular(10.0), // Optional: change border radius
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 170, 170, 170).withOpacity(0.5)), // Change enabled border color here
                    borderRadius: BorderRadius.circular(10.0), // Optional: change border radius
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 188, 2, 2)), // Change focused border color here
                    borderRadius: BorderRadius.circular(10.0), // Optional: change border radius
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.lock), // Changed icon to lock for password
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                ),
              ),
              SizedBox(height: 15,),
              TextField(
                controller: Confirm,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: const Color.fromARGB(255, 165, 165, 165)), // Change border color here
                    borderRadius: BorderRadius.circular(10.0), // Optional: change border radius
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 170, 170, 170).withOpacity(0.5)), // Change enabled border color here
                    borderRadius: BorderRadius.circular(10.0), // Optional: change border radius
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 188, 2, 2)), // Change focused border color here
                    borderRadius: BorderRadius.circular(10.0), // Optional: change border radius
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.lock),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                ),
              ),
              SizedBox(height: 15,),
              

                   GestureDetector(
                  onTap: () {
                    imageSelect();
                  },
                   child: Container(
                    
                     height: 55,
                     decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(10),
                       color: Color.fromARGB(255, 224, 223, 223),
                     ),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Image.asset(
                           'lib/assets/upload.png', // Replace 'upload_icon.png' with your image asset path
                           width: 24, // Adjust the width of the image
                           height: 24, // Adjust the height of the image
                           color: Color.fromARGB(255, 2, 2, 2), // Adjust the color of the image
                         ),
                         SizedBox(width: 10), // Spacer between icon and text
                         Text(
                           "Select Image",
                           style: TextStyle(color: const Color.fromARGB(255, 116, 116, 116)),
                         ),
                       ],
                     ),
                     
                   ),
                 ),

              

              
              
              
                ],
              ),
            ),
                ),
               
          
                    ],
                  ),
                ),
               
             
                Padding(
                  padding: const EdgeInsets.only(right: 25),
                
                        child:  Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                  
                            
          
                              GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>login()));
                              },
                              child: Text("Sign In",style: TextStyle(color:Color.fromARGB(255, 172, 172, 172)),)),
                                  ],
                                ),
                               
                  
                  
                          
                  
                  
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
               
                RegisterUserData(a.restreg,name.text,owner.text,place.text,email.text,phone.text,password.text,Confirm.text,selectedImage,scaffoldContext);
              },
              child: Text(
                "sign Up",
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