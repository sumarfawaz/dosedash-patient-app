import 'package:DoseDash/CustomWidgets/AgeRangeSelector.dart';
import 'package:DoseDash/CustomWidgets/CitySelector.dart';
import 'package:DoseDash/Services/AuthService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DeliveryRegistrationScreen extends StatefulWidget {
   DeliveryRegistrationScreen({Key? key}) : super(key: key); // Constructor with key parameter

  @override
  _DeliveryRegistrationScreen createState() => _DeliveryRegistrationScreen();
}

// _PharmacyRegisterScreenState class
class _DeliveryRegistrationScreen extends State<DeliveryRegistrationScreen> {

// Creating instances of TextEditingController and FocusNode for each input field
  final TextEditingController _fnameController = TextEditingController();
  final TextEditingController _lnameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _VnumController = TextEditingController();
  final TextEditingController _NICNumController = TextEditingController();
  final TextEditingController _LicIDController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _bankAccountController = TextEditingController();
  final TextEditingController _bankBranchController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController = TextEditingController();
 

  final FocusNode _fnameFocus = FocusNode();
  final FocusNode _lnameFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _VnumFocus = FocusNode();
  final FocusNode _NICnumFocus = FocusNode();
  final FocusNode _LicIDFocus = FocusNode();
  final FocusNode _bankNameFocus = FocusNode();
  final FocusNode _bankAccountFocus = FocusNode();
  final FocusNode _bankBranchFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _rePasswordFocus = FocusNode();






  bool _agreeToTerms = false; // State to track if user agrees to terms
  String? _selectedCity; // State to track selected city
  bool _isLoading = false; // State to track loading state
  String? _selectedAgeRange2; // Selected age range





@override
  void dispose() {
    // Disposing all controllers and focus nodes to prevent memory leaks
    _fnameController.dispose();
    _fnameFocus.dispose();
    _lnameController.dispose();
    _lnameFocus.dispose();
    _addressController.dispose();
    _addressFocus.dispose();
    _phoneController.dispose();
    _phoneFocus.dispose();
    _VnumController.dispose();
    _VnumFocus.dispose();
    _NICNumController.dispose();
    _NICnumFocus.dispose();
    _LicIDController.dispose();
    _LicIDFocus.dispose();
    _bankNameController.dispose();
    _bankNameFocus.dispose();
    _bankAccountController.dispose();
    _bankAccountFocus.dispose();
    _bankBranchController.dispose();
    _bankBranchFocus.dispose();
    _emailController.dispose();
    _emailFocus.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    _repeatPasswordController.dispose();
    _rePasswordFocus.dispose();
    super.dispose();
  }



  // Method to start loading
  void _startLoading() {
    setState(() {
      _isLoading = true; // Setting loading state to true
    });
  }

  // Method to stop loading
  void _stopLoading() {
    setState(() {
      _isLoading = false; // Setting loading state to false
    });
  }

  // Method to perform sign up
  void _performSignUp() async {
    // Validating input fields
    if (_fnameController.text.isEmpty) {
      Fluttertoast.showToast(msg: "First name cannot be empty");
      FocusScope.of(context).requestFocus(_fnameFocus);
    }else if (_lnameController.text.isEmpty) {
      Fluttertoast.showToast(msg: "last name cannot be empty");
      FocusScope.of(context).requestFocus(_lnameFocus);
       } else if (_selectedAgeRange2 == null) {
      Fluttertoast.showToast(msg: "Age Category cannot be empty");
    } else if (_addressController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Address cannot be empty");
      FocusScope.of(context).requestFocus(_addressFocus);
    } else if (_phoneController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Phone number cannot be empty");
      FocusScope.of(context).requestFocus(_phoneFocus);
    } else if (_selectedCity == null) {
      Fluttertoast.showToast(msg: "City cannot be empty");
    } else if (_VnumController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Vehicle number cannot be empty");
      FocusScope.of(context).requestFocus(_VnumFocus);
    } else if (_phoneController.text.length!= 10) {
      Fluttertoast.showToast(msg: "Phone number must be exactly 10 digits");
      FocusScope.of(context).requestFocus(_phoneFocus);
    } else if (_NICNumController.text.isEmpty) {
      Fluttertoast.showToast(msg: "NIC number cannot be empty");
      FocusScope.of(context).requestFocus(_NICnumFocus);
    } else if (_LicIDController.text.isEmpty) {
      Fluttertoast.showToast(msg: "License ID cannot be empty");
      FocusScope.of(context).requestFocus(_LicIDFocus);
    } else if (_bankNameController.text.isEmpty) {
      Fluttertoast.showToast(msg:"Bank name cannot be empty");
      FocusScope.of(context).requestFocus(_bankNameFocus);
    } else if (_bankAccountController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Bank account number cannot be empty");
      FocusScope.of(context).requestFocus(_bankAccountFocus);
    } else if (_bankBranchController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Bank Branch cannot be empty");
      FocusScope.of(context).requestFocus(_bankBranchFocus);
    } else if (_emailController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Email cannot be empty");
      FocusScope.of(context).requestFocus(_emailFocus);
    }else if (_passwordController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Enter password");
      FocusScope.of(context).requestFocus(_passwordFocus);
    } else if (_repeatPasswordController.text.toString().trim() !=
        _passwordController.text.toString().trim()) {
      Fluttertoast.showToast(msg: "Passwords don't match");
      FocusScope.of(context).requestFocus(_passwordFocus);
       } else if (_selectedAgeRange2 == null) {
      Fluttertoast.showToast(msg: "Please select an age range");
    } else if (!_agreeToTerms) {
      Fluttertoast.showToast(msg: "Please agree to terms and conditions");
    } else {
      _startLoading(); // Starting loading
      await Authservice().signupDeliveryPerson( // Calling signupDeliveryPerson method of Authservice
      context: context, 
      deliverypersonFName:_fnameController.text,
      deliverypersonLName:_lnameController.text,
      deliveryPersonAddress:_addressController.text,
      phoneNumber: _phoneController.text,
      vehicleNumber:_VnumController.text,
      NICnumber:_NICNumController.text,
      LicenseID: _LicIDController.text,
      city: _selectedCity!,
      bankName: _bankNameController.text,
      bankAccountNo: _bankAccountController.text,
      bankBranch: _bankBranchController.text,
      email: _emailController.text,
      password: _passwordController.text,
      agerange: _selectedAgeRange2!,
  
      );
      _stopLoading(); // Stopping loading
    }
  }
  


//----------------------------------------------------------------------------------------------------------------------




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery Personnel Registration'),
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
                            // Creating input fields for each input
                            TextField(
                              decoration: InputDecoration(
                                labelText: 'First Name *',
                                border: OutlineInputBorder(),
                              ),
                                controller: _fnameController,
                                focusNode: _fnameFocus,               
                            ),
                            
                              SizedBox(height: 20),

                              TextField(
                              decoration: InputDecoration(
                                labelText: 'Last Name *',
                                border: OutlineInputBorder(),
                              ),
                                controller: _lnameController,
                                focusNode: _lnameFocus,               
                            ),

                            SizedBox(height: 20),
                    AgeRangeSelector(
                      onAgeRangeSelected: (ageRange) {
                        setState(() {
                          _selectedAgeRange2 = ageRange;
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
                            
                             TextField(
                              decoration: InputDecoration(
                                labelText: 'Phone Number *',
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
                                labelText: 'Vehicle Number *',
                                border: OutlineInputBorder(),
                              ),
                                    controller: _VnumController,
                                    focusNode: _VnumFocus,           
                            ),
                            
                               SizedBox(height: 20),
                            
                             TextField(
                              decoration: InputDecoration(
                                labelText: ' NIC number *',
                                border: OutlineInputBorder(),
                              ),
                                     controller: _NICNumController,
                                    focusNode: _NICnumFocus,   
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(12),
                              ],         
                            ),
                            
                               SizedBox(height: 20),
                            
                             TextField(
                              decoration: InputDecoration(
                                labelText: 'License ID *',
                                border: OutlineInputBorder(),
                              ),
                                    controller: _LicIDController,
                                    focusNode: _LicIDFocus,   
                                     keyboardType: TextInputType.number,
                                    inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(12),
                              ],           
                            ),
                                
                                SizedBox(height: 20),

                             Cityselector(onCityselector: (city) {
                                setState(() {
                                 _selectedCity = city; // Updating selected city state
                              });
                             }),
                            
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

                    Row(children: [
                      
                       Checkbox(
                          value: _agreeToTerms, // Using agreement state variable
                          onChanged: (value) {
                            setState(() {
                              _agreeToTerms = value!; // Updating agreement state variable
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
                        // Creating a link for terms and conditions
                        GestureDetector(
                          onTap: () {
                            // Navigating to terms and conditions screen
                            Navigator.pushNamed(context, '/terms_conditions');
                          },
                          child: Text(
                            'Terms and Conditions', // Displaying text "Terms and Conditions"
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                              fontSize: 16,
                            ),
                          ),
                        ),
                       ],)
                            

                     ],
                   ),
                ),
              ),
            ),

           Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, // Stretching column to full width
              children: [
                // Creating a button to submit the form
                Stack(alignment: Alignment.center, children: [
                  ElevatedButton(
                     // Disabling button if loading
                    onPressed:_isLoading ? null : _performSignUp,
                    child: Text('Register'), // Displaying text "Register"
                  ),
                 
                 if (_isLoading)
                    Positioned(
                      child: CircularProgressIndicator( // Displaying loading indicator if loading
                        color: Colors.white,
                      ),
                    ),


                ]),
                SizedBox(height: 10),


                // Creating a link to navigate back to the authentication screen
                TextButton(
                  onPressed: () {
                    // Navigating back to the authentication screen
                    CircularProgressIndicator();
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.pushReplacementNamed(
                          context, '/authentication');
                    });
                  },
                  child: Text(
                    'Already have an account? Login', // Displaying text "Already have an account? Login"
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          )

        ],
      ),
    );
  }
}





