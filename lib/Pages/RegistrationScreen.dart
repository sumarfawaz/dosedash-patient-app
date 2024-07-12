import 'package:DoseDash/Services/AuthService.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

  // Focus nodes for email and password fields
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _rePasswordFocus = FocusNode();

  bool _agreeToTerms = false; // State to track if user agrees to terms

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _rePasswordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image at the top
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
                      'Create Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      controller: _emailController,
                      focusNode: _emailFocus,
                    ),
                    SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      obscureText: true,
                    ),
                    SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Repeat Password',
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
                ElevatedButton(
                  onPressed: () async {
                    if (_emailController.text.isEmpty) {
                      Fluttertoast.showToast(msg: "Email cannot be empty");
                      FocusScope.of(context).requestFocus(_emailFocus);
                    } else if (_passwordController.text.isEmpty) {
                      Fluttertoast.showToast(msg: "Password cannot be empty");
                      FocusScope.of(context).requestFocus(_passwordFocus);
                    } else if (_repeatPasswordController.text.isEmpty) {
                      Fluttertoast.showToast(
                          msg: "Please re-enter the password");
                      FocusScope.of(context).requestFocus(_rePasswordFocus);
                    } else if (_repeatPasswordController.text
                            .toString()
                            .trim() !=
                        _passwordController.text.toString().trim()) {
                      Fluttertoast.showToast(msg: "Passwords don't match");
                      FocusScope.of(context).requestFocus(_passwordFocus);
                    } else if (!_agreeToTerms) {
                      Fluttertoast.showToast(
                          msg: "Please agree to terms and conditions");
                    } else {
                      await Authservice().signup(
                          email: _emailController.text,
                          password: _passwordController.text,
                          context: context);
                    }
                  },
                  child: Text('Register'),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    // Navigate back to the authentication screen
                    Navigator.pop(context);
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
