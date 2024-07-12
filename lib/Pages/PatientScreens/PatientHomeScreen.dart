import 'package:DoseDash/Services/AuthService.dart';
import 'package:flutter/material.dart';

class Patienthomescreen extends StatelessWidget {
  const Patienthomescreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to DoseDash Patient Hub!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await Authservice().signout(context: context);
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
