import 'dart:async';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:news1/home.dart';

class Splashpg extends StatefulWidget {
  const Splashpg({super.key});

  @override
  State<Splashpg> createState() => _SplashpgState();
}

class _SplashpgState extends State<Splashpg> {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return Home();
      }));
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 1;
    final width = MediaQuery.sizeOf(context).width * 1;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          Colors.blue.shade900,
          Colors.blue.shade800,
          Colors.blue.shade700,
          Colors.blue.shade600,
          Colors.blue.shade400,
          Colors.blue.shade200
        ], begin: Alignment.centerLeft, end: Alignment.centerRight)),
        // color: Colors.lightBlueAccent,
        //   gradient: LinearGradient(colors: [Colors.black12,Colors.black],begin: Alignment.topCenter,end: Alignment.bottomCenter)
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Text(
              "BULLETIN FEED APPLICATION",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 50,
                  fontStyle: FontStyle.italic,
                  color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}



