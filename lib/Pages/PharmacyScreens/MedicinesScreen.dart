import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MedicinesScreen extends StatefulWidget {
  @override
  _MedicinesScreenState createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends State<MedicinesScreen> {
  late Future<String?> _userIdFuture;

  @override
  void initState() {
    super.initState();
    _userIdFuture = _getUserId();
  }

  Future<String?> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userid');
  }

  Future<void> _deleteMedicine(String docId) async {
    await FirebaseFirestore.instance
        .collection('medicines')
        .doc(docId)
        .delete();
  }

  Future<void> _updateMedicine(DocumentSnapshot doc) async {
    final _formKey = GlobalKey<FormState>();
    String brandName = doc['brandName'];
    String medicineName = doc['medicineName'];
    double unitPrice = doc['unitPrice'];
    String dosage = doc['dosage'];
    bool prescriptionRequired = doc['prescriptionRequired'];
    String medicineCategory = doc['medicineCategory'];

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Update Medicine'),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: brandName,
                        decoration: InputDecoration(labelText: 'Brand Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter brand name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          brandName = value!;
                        },
                      ),
                      TextFormField(
                        initialValue: medicineName,
                        decoration: InputDecoration(labelText: 'Medicine Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter medicine name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          medicineName = value!;
                        },
                      ),
                      TextFormField(
                        initialValue: unitPrice.toString(),
                        decoration: InputDecoration(labelText: 'Unit Price'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || double.tryParse(value) == null) {
                            return 'Please enter valid unit price';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          unitPrice = double.parse(value!);
                        },
                      ),
                      TextFormField(
                        initialValue: dosage,
                        decoration: InputDecoration(labelText: 'Dosage'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter dosage information';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          dosage = value!;
                        },
                      ),
                      CheckboxListTile(
                        title: Text('Prescription Required'),
                        value: prescriptionRequired,
                        onChanged: (value) {
                          setState(() {
                            prescriptionRequired = value!;
                          });
                        },
                      ),
                      TextFormField(
                        initialValue: medicineCategory,
                        decoration:
                            InputDecoration(labelText: 'Medicine Category'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter medicine category';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          medicineCategory = value!;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      await FirebaseFirestore.instance
                          .collection('medicines')
                          .doc(doc.id)
                          .update({
                        'brandName': brandName,
                        'medicineName': medicineName,
                        'unitPrice': unitPrice,
                        'dosage': dosage,
                        'prescriptionRequired': prescriptionRequired,
                        'medicineCategory': medicineCategory,
                      });

                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medicines'),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: FutureBuilder<String?>(
        future: _userIdFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('User ID not found.'));
          }

          String userId = snapshot.data!;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('medicines')
                .where('pharmacyId', isEqualTo: userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No medicines found.'));
              }

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot doc = snapshot.data!.docs[index];
                  String imageBase64 = doc['medicineImageBase64'];
                  Image? image;
                  if (imageBase64.isNotEmpty) {
                    image = Image.memory(base64Decode(imageBase64));
                  }

                  return Card(
                    child: ListTile(
                      leading: image != null
                          ? Container(
                              width: 50,
                              height: 50,
                              child: image,
                            )
                          : null,
                      title: Text(doc['medicineName']),
                      subtitle: Text(doc['brandName']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _updateMedicine(doc),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteMedicine(doc.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
