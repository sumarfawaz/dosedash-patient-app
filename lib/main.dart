import 'package:flutter/material.dart';
import './Pages/SplashScreen.dart';
import './Pages/AuthenticationScreen.dart'; // Import your authentication screen
import 'Pages/RegistrationScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreenWidget(),
        '/authentication': (context) =>
            AuthenticationScreen(), // Define your authentication screen route
        '/register': (context) =>
            RegisterScreen(), // Define your registration screen route
      },
    );
  }
}
