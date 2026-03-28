import 'package:tellme/api/api.dart';
import 'package:tellme/screens/auth_screen.dart/login_screen.dart';
import 'package:tellme/screens/home_screen.dart';

import 'package:flutter/material.dart';
import 'package:tellme/main.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 1500), () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white,
          statusBarColor: Colors.white,
        ),
      );

      if (Apis.auth.currentUser != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    md = MediaQuery.of(context).size;
    return Scaffold(
      body: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOutExpo,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Stack(
              children: [
                Positioned(
                  top: md.height * .20 + (1 - value) * 50,
                  left: md.width * .25,
                  width: md.width * .5,
                  child: Image.asset('assets/images/tellme_app_icon.png'),
                ),
                Positioned(
                  bottom: md.height * .20 - (1 - value) * 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'MADE BY SUMIT KUMAR YADAV ☠',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).primaryColor,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
