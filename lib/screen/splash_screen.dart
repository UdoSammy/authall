// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:authall/provider/sign_in_provider.dart';
import 'package:authall/screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    final sp = context.read<SignInProvider>();

    Timer(Duration(seconds: 4), () { 
      sp.isSignedIn == false ? Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen())) :
       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    });


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Image.asset('images/splash.png',),
        ),
      ),
    );
  }
}
