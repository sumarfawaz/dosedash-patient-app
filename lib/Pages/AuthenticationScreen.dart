import 'package:flutter/material.dart';

class AuthenticationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Authentication'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Welcome',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              //Row(
              //mainAxisAlignment:
              //MainAxisAlignment.center, // Center buttons horizontally
              //children: [
              ElevatedButton(
                onPressed: () {
                  // Implement your authentication logic here
                },
                child: Text('Login'),
              ),
              SizedBox(width: 20), // Add spacing between buttons

              GestureDetector(
                onTap: () {
                  // Navigate to the registration screen
                  Navigator.pushNamed(context, '/register');
                },
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    'No Account? Click here',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              //],
              //),
            ],
          ),
        ),
      ),
    );
  }
}
