import 'package:flutter/material.dart';
import 'package:afartech/repository/Welcome_Button.dart';
import 'package:afartech/screens/signin_screen.dart';
import 'package:afartech/screens/signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 200,
                      height: 200,
                    ),
                    Text(
                      'Welcome To AfarTech',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1a237e),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Your trusted technology partner',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    children: [
                      Expanded(
                        child: WelcomeButton(
                          ButtonText: 'signup',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpScre(),
                              ),
                            );
                          },
                        ),
                      ),

                      Expanded(
                        child: WelcomeButton(
                          ButtonText: 'signin',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignInScre(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
