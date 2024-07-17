import 'package:DoseDash/Pages/RegistrationScreen.dart';
import 'package:flutter/material.dart';

class SelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Type',
          textAlign: TextAlign.center,
        ),
        //automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SelectionButton(
              imagePath: 'assets/images/patient.jpg',
              text: 'Patient',
              onPressed: () {
                //await Future.delayed(const Duration(seconds: 1));
                Navigator.pushNamed(context, '/register');
              },
            ),
            SizedBox(width: 20), // Space between buttons
            SelectionButton(
              imagePath: 'assets/images/pharmacy.jpg',
              text: 'Pharmacy',
              onPressed: () {
                // Handle pharmacy selection
                Navigator.pushNamed(context, '/pharmacyregister');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SelectionButton extends StatelessWidget {
  final String imagePath;
  final String text;
  final VoidCallback onPressed;

  const SelectionButton({
    required this.imagePath,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, height: 100, width: 100),
          SizedBox(height: 10),
          Text(
            text,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
