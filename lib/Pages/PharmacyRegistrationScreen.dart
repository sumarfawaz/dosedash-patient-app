import 'package:DoseDash/CustomWidgets/CitySelector.dart';
import 'package:DoseDash/Pages/MapScreens/MapScreen.dart';
import 'package:DoseDash/Services/AuthService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PharmacyRegisterScreen extends StatefulWidget {
  PharmacyRegisterScreen({Key? key}) : super(key: key);

  @override
  _PharmacyRegisterScreenState createState() => _PharmacyRegisterScreenState();
}

class _PharmacyRegisterScreenState extends State<PharmacyRegisterScreen> {
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _pharmacyNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _coordinatesController = TextEditingController(); // New controller for coordinates
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _bankAccountController = TextEditingController();
  final TextEditingController _bankBranchController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController =
      TextEditingController();

  final FocusNode _licenseFocus = FocusNode();
  final FocusNode _pharmacyNameFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _coordinatesFocus = FocusNode(); // New FocusNode for coordinates
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _bankNameFocus = FocusNode();
  final FocusNode _bankAccountFocus = FocusNode();
  final FocusNode _bankBranchFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _rePasswordFocus = FocusNode();

  bool _agreeToTerms = false; // State to track if user agrees to terms
  bool _isLoading = false;

  @override
  void dispose() {
    _licenseController.dispose();
    _pharmacyNameController.dispose();
    _addressController.dispose();
    _coordinatesController.dispose(); // Dispose the new controller
    _phoneController.dispose();
    _bankNameController.dispose();
    _bankAccountController.dispose();
    _bankBranchController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    _licenseFocus.dispose();
    _pharmacyNameFocus.dispose();
    _addressFocus.dispose();
    _coordinatesFocus.dispose(); // Dispose the new FocusNode
    _phoneFocus.dispose();
    _bankNameFocus.dispose();
    _bankAccountFocus.dispose();
    _bankBranchFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _rePasswordFocus.dispose();
    super.dispose();
  }

  void _startLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  void _stopLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  void _openMapScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Mapscreen(userRole: 'pharmacy'),
      ),
    );

    if (result != null) {
      if (result is Map<String, dynamic>) {
        // Handle both address and coordinates for pharmacy
        String address = result['address'];
        String coordinates = result['coordinates'];

        // Update the address and coordinates fields
        setState(() {
          _addressController.text = address;
          _coordinatesController.text = coordinates;
        });
      } else if (result is String) {
        // Handle only address or coordinates
        setState(() {
          _addressController.text = result;
        });
      }
    }
  }

  void _performSignUp() async {
    if (_licenseController.text.isEmpty) {
      Fluttertoast.showToast(msg: "License number cannot be empty");
      FocusScope.of(context).requestFocus(_licenseFocus);
    } else if (_pharmacyNameController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Pharmacy name cannot be empty");
      FocusScope.of(context).requestFocus(_pharmacyNameFocus);
    } else if (_addressController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Address cannot be empty");
      FocusScope.of(context).requestFocus(_addressFocus);
    } else if (_phoneController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Phone number cannot be empty");
      FocusScope.of(context).requestFocus(_phoneFocus);
    } else if (_phoneController.text.length != 10) {
      Fluttertoast.showToast(msg: "Phone number must be exactly 10 digits");
      FocusScope.of(context).requestFocus(_phoneFocus);
    } else if (_bankNameController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Bank name cannot be empty");
      FocusScope.of(context).requestFocus(_bankNameFocus);
    } else if (_bankAccountController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Bank account number cannot be empty");
      FocusScope.of(context).requestFocus(_bankAccountFocus);
    } else if (_bankBranchController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Bank branch cannot be empty");
      FocusScope.of(context).requestFocus(_bankBranchFocus);
    } else if (_emailController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Email cannot be empty");
      FocusScope.of(context).requestFocus(_emailFocus);
    } else if (_passwordController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Password cannot be empty");
      FocusScope.of(context).requestFocus(_passwordFocus);
    } else if (_repeatPasswordController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Please re-enter the password");
      FocusScope.of(context).requestFocus(_rePasswordFocus);
    } else if (_repeatPasswordController.text.toString().trim() !=
        _passwordController.text.toString().trim()) {
      Fluttertoast.showToast(msg: "Passwords don't match");
      FocusScope.of(context).requestFocus(_passwordFocus);
    } else if (!_agreeToTerms) {
      Fluttertoast.showToast(msg: "Please agree to terms and conditions");
    } else {
      _startLoading();
      await Authservice().signupPharmacy(
        email: _emailController.text,
        password: _passwordController.text,
        licenseNo: _licenseController.text,
        pharmacyName: _pharmacyNameController.text,
        address: _addressController.text,
        coordinates: _coordinatesController.text, // Pass the coordinates 
        phone: _phoneController.text,
        bankName: _bankNameController.text,
        bankAccountNo: _bankAccountController.text,
        bankBranch: _bankBranchController.text,
        context: context,
      );
      _stopLoading();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pharmacy Registration'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo.png',
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Please enter all the required data which is denoted by (*) to complete the onboarding process',
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Pharmacy License Number *',
                        border: OutlineInputBorder(),
                      ),
                      controller: _licenseController,
                      focusNode: _licenseFocus,
                    ),
                    SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Pharmacy Name *',
                        border: OutlineInputBorder(),
                      ),
                      controller: _pharmacyNameController,
                      focusNode: _pharmacyNameFocus,
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: _openMapScreen,
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Click to Find Address *',
                          border: OutlineInputBorder(),
                        ),
                        controller: _addressController,
                        focusNode: _addressFocus,
                        enabled: false, // Add this line to make the field not editable
                      ),
                    ),

                    SizedBox(height: 20),

                    // New TextField for Coordinates
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Coordinates',
                        border: OutlineInputBorder(),
                      ),
                      controller: _coordinatesController,
                      enabled: false,
                      ),
                     

                    SizedBox(height: 20),

                   
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Pharmacy Contact *',
                        border: OutlineInputBorder(),
                      ),
                      controller: _phoneController,
                      focusNode: _phoneFocus,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                    ),
                    SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Bank Name *',
                        border: OutlineInputBorder(),
                      ),
                      controller: _bankNameController,
                      focusNode: _bankNameFocus,
                    ),
                    SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Bank Account Number *',
                        border: OutlineInputBorder(),
                      ),
                      controller: _bankAccountController,
                      focusNode: _bankAccountFocus,
                    ),
                    SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Bank Branch *',
                        border: OutlineInputBorder(),
                      ),
                      controller: _bankBranchController,
                      focusNode: _bankBranchFocus,
                    ),
                    SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Email *',
                        border: OutlineInputBorder(),
                      ),
                      controller: _emailController,
                      focusNode: _emailFocus,
                    ),
                    SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Password *',
                        border: OutlineInputBorder(),
                      ),
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      obscureText: true,
                    ),
                    SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Repeat Password *',
                        border: OutlineInputBorder(),
                      ),
                      controller: _repeatPasswordController,
                      obscureText: true,
                      focusNode: _rePasswordFocus,
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Checkbox(
                          value: _agreeToTerms,
                          onChanged: (value) {
                            setState(() {
                              _agreeToTerms = value!;
                            });
                          },
                        ),
                        Text(
                          "I Agree to ",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Navigate to the terms and conditions screen
                            Navigator.pushNamed(context, '/terms_conditions');
                          },
                          child: Text(
                            'Terms and Conditions',
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(alignment: Alignment.center, children: [
                  ElevatedButton(
                    onPressed: _isLoading ? null : _performSignUp,
                    child: Text('Register'),
                  ),
                  if (_isLoading)
                    Positioned(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                ]),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    // Navigate back to the authentication screen
                    CircularProgressIndicator();
                    WidgetsBinding.instance!.addPostFrameCallback((_) {
                      Navigator.pushReplacementNamed(
                          context, '/authentication');
                    });
                  },
                  child: Text(
                    'Already have an account? Login',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
