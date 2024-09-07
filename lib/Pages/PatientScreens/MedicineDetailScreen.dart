import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:DoseDash/Pages/PatientScreens/PatientHomeScreen.dart';

class MedicineDetailScreen extends StatefulWidget {
  final Medicine medicine;
  final Function(Medicine) addToCart;

  const MedicineDetailScreen({
    Key? key,
    required this.medicine,
    required this.addToCart,
  }) : super(key: key);

  @override
  _MedicineDetailScreenState createState() => _MedicineDetailScreenState();
}

class _MedicineDetailScreenState extends State<MedicineDetailScreen> {
  int _quantity = 1; // Initial quantity

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medicine Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fixed size for the image container
            Container(
              height: 500, // Set a fixed height for the image
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
                child: Image.memory(
                  base64Decode(widget.medicine.image),
                  fit: BoxFit.contain, // Ensures the image covers the container
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.medicine.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Brand: ${widget.medicine.brand}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Price: රු${widget.medicine.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF11BA63),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Quantity selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 20),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                if (_quantity > 1)
                                  _quantity--; // Prevent negative or zero quantity
                              });
                            },
                            icon: Icon(Icons.remove, color: Colors.red),
                          ),
                          Text(
                            _quantity.toString(),
                            style: TextStyle(fontSize: 18),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _quantity++;
                              });
                            },
                            icon: Icon(Icons.add, color: Colors.green),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _addToCart, // Calls the _addToCart method
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        backgroundColor:
                            Color(0xFF11BA63), // Button background color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Add to Cart',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to handle adding the medicine to cart
  void _addToCart() {
    setState(() {
      widget.medicine.quantity = _quantity; // Set the quantity for the medicine
      widget.addToCart(widget
          .medicine); // Call the addToCart function passed from the parent
    });
    Navigator.pop(
        context); // Return to the previous screen after adding to cart
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('$_quantity ${widget.medicine.name} added to cart')),
    );
  }
}
