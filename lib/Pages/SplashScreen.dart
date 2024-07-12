import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Models/SplashScreenModel.dart'; // Import your SplashScreenModel
import './AuthenticationScreen.dart'; // Import your authentication screen
import '../Pages/PatientScreens/PatientHomeScreen.dart'; // Import your home screen or desired screen

class SplashScreenWidget extends StatefulWidget {
  const SplashScreenWidget({Key? key}) : super(key: key);

  @override
  State<SplashScreenWidget> createState() => _SplashScreenWidgetState();
}

class _SplashScreenWidgetState extends State<SplashScreenWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Delay execution using addPostFrameCallback to ensure context is fully initialized
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Provider.of<SplashScreenModel>(context, listen: false).checkLoginStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SplashScreenModel(),
      child: Consumer<SplashScreenModel>(
        builder: (context, model, _) {
          // Listen to changes in SplashScreenModel and react accordingly
          if (model.isLoading) {
            // Display loading indicator while checking login status
            // return Scaffold(
            //   backgroundColor: Colors.white,
            //   body: Center(
            //     child: CircularProgressIndicator(),
            //   ),
            // );
            return Scaffold(
              key: scaffoldKey,
              backgroundColor: Colors.white,
              body: SafeArea(
                top: true,
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      child: const Text(
                        'Group 09',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Readex Pro',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            // Determine where to navigate based on login status
            if (model.isLoggedIn) {
              // Navigate to home screen
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                Navigator.pushReplacementNamed(context, '/patienthome');
              });
            } else {
              // Navigate to authentication screen
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                Navigator.pushReplacementNamed(context, '/authentication');
              });
            }

            // Placeholder UI while navigation occurs
            return Scaffold(
              key: scaffoldKey,
              backgroundColor: Colors.white,
              body: SafeArea(
                top: true,
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      child: const Text(
                        'Group 09',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Readex Pro',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
