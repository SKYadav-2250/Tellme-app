import 'dart:developer';
import 'dart:io';

import 'package:tellme/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:tellme/main.dart';
import 'package:tellme/api/api.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tellme/helper/dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  void _handleSignIn() async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    Dialogs.showProgressbar(context);

    final user = await _signInWithGoogle();

    if (user != null) {
      Navigator.pop(context);
      log('\nUser:${user.user}');

      log('\nUserAdditinaldata:${user.additionalUserInfo}');

      if (await Apis.userExists()) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const HomeScreen();
            },
          ),
        );
      } else {
        await Apis.createUser().then((value) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const HomeScreen();
              },
            ),
          );
        });
      }
    }
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      log('googleUser : $googleUser');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await Apis.auth.signInWithCredential(credential);
    } catch (e) {
      print(e);

      log('_signInWithGoogle : $e');

      // throw Exception(e);
      Dialogs.showSnackbar(
        context,
        'something went wrong check intrenet connection',
        false,
      );
      Navigator.pop(context);

      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    md = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('Welcome to Tellme', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: Theme.of(context).brightness == Brightness.dark 
                ? [const Color(0xFF201A30), const Color(0xFF13131A)] 
                : [const Color(0xFFEADDFF), const Color(0xFFF8F9FA)],
          ),
        ),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Stack(
              children: [
                Positioned(
                  top: md.height * 0.15 + (1 - value) * -50,
                  left: 0,
                  right: 0,
                  child: Opacity(
                    opacity: value,
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/tellme_app_icon.png',
                          height: md.height * 0.25,
                        ),
                        SizedBox(height: md.height * 0.04),
                        Text(
                          'Connect effortlessly.',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: md.height * 0.15 + (1 - value) * -50,
                  left: md.width * 0.10,
                  width: md.width * 0.80,
                  height: md.height * 0.07,
                  child: Opacity(
                    opacity: value,
                    child: ElevatedButton(
                      onPressed: _handleSignIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6200EA),
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor: const Color(0xFF6200EA).withAlpha(100),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            // Fallback to whatsapp_image if google icon not present
                            child: Image.asset(
                              'assets/images/whatsapp_image.png',
                              height: 24,
                              width: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'Sign in with Google',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
