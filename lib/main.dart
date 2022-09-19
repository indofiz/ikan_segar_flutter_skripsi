import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ikan_laut_skripsi/components/dismissKeyboard.dart';
import 'package:ikan_laut_skripsi/home_page.dart';
import 'package:ikan_laut_skripsi/splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final pref = await SharedPreferences.getInstance();
  final isEmail = pref.getBool('isEmail') ?? false;
  await Firebase.initializeApp();
  runApp(MyApp(isEmail: isEmail));
}

class MyApp extends StatelessWidget {
  final bool isEmail;
  const MyApp({Key? key, required this.isEmail}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: isEmail == true ? const HomePage() : const SplashScreen(),
      ),
    );
  }
}
