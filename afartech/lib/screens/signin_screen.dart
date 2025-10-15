import 'package:flutter/material.dart';

class SignInScre extends StatefulWidget {
  const SignInScre({super.key});

  @override
  State<SignInScre> createState() => _signInScreState();
}

class _signInScreState extends State<SignInScre> {
  TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SignIn')),
      body: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Nom
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 20),

            // Email
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 20),

            // Password
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 30),

            // Bouton
            ElevatedButton(
              onPressed: () {
                // Affiche dans la console
                print('Name: ${_nameController.text}');
                print('Email: ${_emailController.text}');
                print('Password: ${_passwordController.text}');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1a237e),
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(
                'SignIn',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
