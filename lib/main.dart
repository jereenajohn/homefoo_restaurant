import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homefoo_restaurant/additems.dart';
import 'package:homefoo_restaurant/home.dart';
import 'package:homefoo_restaurant/login.dart';

void main() {
  runApp(homefoo());
}

class homefoo extends StatefulWidget {
  const homefoo({super.key});

  @override
  State<homefoo> createState() => _homefooState();
}

class _homefooState extends State<homefoo> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.white
            // Set your desired color here
            ));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: manege(),
    );
  }
}

class manege extends StatefulWidget {
  const manege({super.key});

  @override
  State<manege> createState() => _manegeState();
}

class _manegeState extends State<manege> {
  void fetchdata() {}

  @override
  Widget build(BuildContext context) {
    return login();
  }
}
