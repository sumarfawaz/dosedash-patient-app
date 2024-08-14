import 'package:DoseDash/Models/SplashScreenModel.dart';
import 'package:DoseDash/Pages/DeliveryPersonScreens/DeliveryhomeScreen.dart';
import 'package:DoseDash/Pages/DeliveryRegistrationScreen.dart';
import 'package:DoseDash/Pages/MapScreens/MapScreen.dart';
import 'package:DoseDash/Pages/PasswordRecovreyScreen.dart';
import 'package:DoseDash/Pages/PatientScreens/PatientHomeScreen.dart';
import 'package:DoseDash/Pages/PharmacyRegistrationScreen.dart';
import 'package:DoseDash/Pages/PharmacyScreens/PharmacyHomeScreen.dart';
import 'package:DoseDash/Pages/SelectionScreen.dart';
import 'package:DoseDash/Pages/TermsConditions.dart';
import 'package:DoseDash/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './Pages/SplashScreen.dart';
import './Pages/AuthenticationScreen.dart'; // Import your authentication screen
import 'Pages/RegistrationScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ChangeNotifierProvider(
      create: (_) => SplashScreenModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreenWidget(),
        '/authentication': (context) =>
            AuthenticationScreen(), // Define your authentication screen route
        '/register': (context) => RegisterScreen(),
        '/patienthome': (context) => Patienthomescreen(),
        '/terms_conditions': (context) => TermsConditionsScreen(),
        '/selectionscreen': (context) => SelectionScreen(),
        '/pharmacyregister': (context) => PharmacyRegisterScreen(),
        '/pharmacyhome': (context) => PharmacyHomeScreen(),
        '/passwordrecovery': (context) => PasswordRecoveryScreen(),
        '/deliveryregister': (context) => DeliveryRegistrationScreen(),
        '/deliveryhomescreen': (context) => DeliveryHomeScreen(),

        //  // Define your registration screen route
      },
    );
  }
}
