import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UploadMedicineScreen extends StatefulWidget {
  const UploadMedicineScreen({Key? key}) : super(key: key);

  @override
  _UploadMedicineScreenState createState() => _UploadMedicineScreenState();
}

class _UploadMedicineScreenState extends State<UploadMedicineScreen> {
  final _formKey = GlobalKey<FormState>();

  File? _medicineImage;
  String? _medicineImageBase64;
  String _brandName = '';
  String _medicineName = '';
  double _unitPrice = 0.0;
  String _dosage = '';
  bool _prescriptionRequired = false;
  
  String _medicineCategory = '';

  final picker = ImagePicker();

  Future<void> _uploadImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _medicineImage = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        // Convert image to Base64 string
        if (_medicineImage != null) {
          await _convertImageToBase64();
        }

        // Save medicine data to Firestore
        await _saveMedicineData();

        // Show success message or navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Medicine uploaded successfully')),
        );
      } catch (error) {
        print('Error uploading medicine: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload medicine')),
        );
      }
    }
  }

  Future<void> _convertImageToBase64() async {
    final bytes = await _medicineImage!.readAsBytes();
    _medicineImageBase64 = base64Encode(bytes);
  }

  Future<void> _saveMedicineData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userid');

    // Ensure userId is not null
    if (userId != null) {
      await FirebaseFirestore.instance.collection('medicines').add({
        'pharmacyId': userId,
        'brandName': _brandName,
        'medicineName': _medicineName,
        'unitPrice': _unitPrice,
        'dosage': _dosage,
        'prescriptionRequired': _prescriptionRequired,
        'medicineCategory': _medicineCategory,
        'uploadDateTime': Timestamp.now(),
        'medicineImageBase64': _medicineImageBase64,
      });
    } else {
      print('User ID not found in SharedPreferences.');
      throw Exception('User ID not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Medicine'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: _medicineImage != null
                          ? FileImage(_medicineImage!)
                          : AssetImage('assets/images/placeholder.png')
                              as ImageProvider,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _uploadImage,
                  child: Text('Upload Image'),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Please enter all the required data which is denoted by (*) to create new medicines',
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'Brand Name *', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter brand name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _brandName = value!;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'Medicine Name *', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter medicine name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _medicineName = value!;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'Unit Price *', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) {
                    return 'Please enter valid unit price';
                  }
                  return null;
                },
                onSaved: (value) {
                  _unitPrice = double.parse(value!);
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'Dosage *', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter dosage information';
                  }
                  return null;
                },
                onSaved: (value) {
                  _dosage = value!;
                },
              ),
              SizedBox(height: 20),
              CheckboxListTile(
                title: Text('Prescription Required'),
                value: _prescriptionRequired,
                onChanged: (value) {
                  setState(() {
                    _prescriptionRequired = value!;
                  });
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'Medicine Category *',
                    border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter medicine category';
                  }
                  return null;
                },
                onSaved: (value) {
                  _medicineCategory = value!;
                },
              ),
              SizedBox(height: 20),
              // ElevatedButton(
              //   onPressed: _uploadImage,
              //   child: Text('Upload Image'),
              // ),
              SizedBox(
                height: 20,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Upload Medicine'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
