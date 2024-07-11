import 'package:flutter/material.dart';

class SplashScreenModel extends ChangeNotifier {
  late FocusNode unfocusNode;

  SplashScreenModel() {
    unfocusNode = FocusNode();
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    super.dispose();
  }
}
