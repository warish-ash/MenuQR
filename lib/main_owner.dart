// lib/main.dart - UPDATED FOR OWNER SIDE

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'provider/cart_provider.dart';
import 'screens/owner/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: MaterialApp(
        title: 'MenuQR Owner',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.red,
          primaryColor: Color(0xFFFF6B6B),
          scaffoldBackgroundColor: Color(0xFFF7F7F7),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 1,
          ),
          fontFamily: 'Roboto',
        ),
        home: LoginScreen(), // Start with login for owner side
      ),
    );
  }
}