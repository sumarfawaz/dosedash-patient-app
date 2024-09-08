import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:DoseDash/Pages/PatientScreens/PatientHomeScreen.dart';

class MedicineDetailScreen extends StatefulWidget {
  final Medicine medicine;
  final Function(Medicine) addToCart;

  MedicineDetailScreen({required this.medicine, required this.addToCart});

  @override
  _MedicineDetailScreenState createState() => _MedicineDetailScreenState();
}

class _MedicineDetailScreenState extends State<MedicineDetailScreen> {
  int _quantity = 1;

  void _addToCart() {
    setState(() {
      widget.medicine.quantity = _quantity;
      widget.addToCart(widget.medicine);
    });
    Navigator.pop(
        context); // Return to the previous screen after adding to cart
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medicine Details'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                widget.medicine.image.isNotEmpty
                    ? Image.memory(
                        base64Decode(widget.medicine.image),
                        fit: BoxFit.cover,
                      )
                    : Container(), // Placeholder if no image
                SizedBox(height: 20),
                Text(
                  widget.medicine.name,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  widget.medicine.brand,
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                Text(
                  '\රු${widget.medicine.price.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          if (_quantity > 1) _quantity--;
                        });
                      },
                    ),
                    Text(
                      _quantity.toString(),
                      style: TextStyle(fontSize: 18),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          _quantity++;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addToCart,
                  child: Text('Add to Cart'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
