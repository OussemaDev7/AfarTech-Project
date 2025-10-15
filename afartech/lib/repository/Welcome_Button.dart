import 'package:flutter/material.dart';
import 'package:afartech/screens/signup_screen.dart';

class WelcomeButton extends StatelessWidget {
  const WelcomeButton({super.key, this.ButtonText, this.onPressed});
  final String? ButtonText;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.deepOrangeAccent,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),

        child: Text(
          ButtonText!,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
