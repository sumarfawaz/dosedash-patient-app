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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SelectionButton(
                  imagePath: 'assets/images/patient.jpg',
                  text: 'Patient',
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                ),
                SizedBox(width: 20), // Space between buttons
                SelectionButton(
                  imagePath: 'assets/images/pharmacy.jpg',
                  text: 'Pharmacy',
                  onPressed: () {
                    Navigator.pushNamed(context, '/pharmacyregister');
                  },
                ),
              ],
            ),
            SizedBox(height: 80), // Space between rows
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SelectionButton(
                  imagePath: 'assets/images/DeliveryPersonlogo.jpg', // Changed image path
                  text: 'Delivery Personnel',
                  onPressed: () {
                    // Handle delivery person selection
                    Navigator.pushNamed(context, '/deliveryregister'); // Added route
                  },
                ),
              ],
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
