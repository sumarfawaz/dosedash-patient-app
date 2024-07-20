import 'package:DoseDash/CustomWidgets/CitySelector.dart';
import 'package:DoseDash/Pages/AuthenticationScreen.dart';
import 'package:DoseDash/Services/AuthService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../CustomWidgets/AgeRangeSelector.dart';

class RegisterScreen extends StatefulWidget {
  RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController =
      TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _rePasswordFocus = FocusNode();
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();

  bool _agreeToTerms = false; // State to track if user agrees to terms
  String? _selectedAgeRange;
  String? _selectedCity;
  bool _isLoading = false; // Loading state

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _rePasswordFocus.dispose();
    _firstNameController.dispose();
    _firstNameFocus.dispose();
    _lastNameController.dispose();
    _lastNameFocus.dispose();
    _addressController.dispose();
    _addressFocus.dispose();
    _phoneController.dispose();
    _phoneFocus.dispose();
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

  void _performSignUp() async {
    if (_firstNameController.text.isEmpty) {
      Fluttertoast.showToast(msg: "First name cannot be empty");
      FocusScope.of(context).requestFocus(_firstNameFocus);
    } else if (_lastNameController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Last name cannot be empty");
      FocusScope.of(context).requestFocus(_lastNameFocus);
    } else if (_selectedAgeRange == null) {
      Fluttertoast.showToast(msg: "Age Category cannot be empty");
    } else if (_addressController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Address cannot be empty");
      FocusScope.of(context).requestFocus(_addressFocus);
    } else if (_selectedCity == null) {
      Fluttertoast.showToast(msg: "Area cannot be empty");
    } else if (_phoneController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Phone number cannot be empty");
      FocusScope.of(context).requestFocus(_phoneFocus);
    } else if (_phoneController.text.length != 10) {
      Fluttertoast.showToast(msg: "Phone number must be exactly 10 digits");
      FocusScope.of(context).requestFocus(_phoneFocus);
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
    } else if (_selectedAgeRange == null) {
      Fluttertoast.showToast(msg: "Please select an age range");
    } else if (!_agreeToTerms) {
      Fluttertoast.showToast(msg: "Please agree to terms and conditions");
    } else {
      _startLoading();
      await Authservice().signup(
        email: _emailController.text,
        password: _passwordController.text,
        firstname: _firstNameController.text,
        lastname: _lastNameController.text,
        agerange: _selectedAgeRange!,
        address: _addressController.text,
        city: _selectedCity!,
        phone: _phoneController.text,
        context: context,
      );
      _stopLoading();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Registration'),
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
                        labelText: 'First Name *',
                        border: OutlineInputBorder(),
                      ),
                      controller: _firstNameController,
                      focusNode: _firstNameFocus,
                    ),
                    SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Last Name *',
                        border: OutlineInputBorder(),
                      ),
                      controller: _lastNameController,
                      focusNode: _lastNameFocus,
                    ),
                    SizedBox(height: 20),
                    AgeRangeSelector(
                      onAgeRangeSelected: (ageRange) {
                        setState(() {
                          _selectedAgeRange = ageRange;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Address *',
                        border: OutlineInputBorder(),
                      ),
                      controller: _addressController,
                      focusNode: _addressFocus,
                    ),
                    SizedBox(height: 20),
                    Cityselector(onCityselector: (city) {
                      setState(() {
                        _selectedCity = city;
                      });
                    }),
                    SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Phone number *',
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
