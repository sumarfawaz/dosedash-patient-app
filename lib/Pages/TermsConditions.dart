import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms and Conditions'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms and Conditions',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              '1. Introduction',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Welcome to DoseDash. These terms and conditions outline the rules and regulations for the use of our application.',
            ),
            SizedBox(height: 20),
            Text(
              '2. User Responsibilities',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'By accessing this app, you agree to comply with these terms and conditions. You must not use the app in any way that causes, or may cause, damage to the app or impairment of the availability or accessibility of the app.',
            ),
            // Add more sections as needed
            SizedBox(height: 20),
            Text(
              '3. Modifications to Terms',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'We reserve the right to amend these terms and conditions at any time. It is your responsibility to check these terms periodically for changes.',
            ),
            SizedBox(height: 20),
            Text(
              '4. Contact Us',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'If you have any questions about these Terms, please contact us.',
            ),
          ],
        ),
      ),
    );
  }
}
