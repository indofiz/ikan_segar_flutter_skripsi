import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ikan_laut_skripsi_v2/components/dismiss_keyboard.dart';
import 'package:ikan_laut_skripsi_v2/home_page.dart';
import 'package:ikan_laut_skripsi_v2/splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final pref = await SharedPreferences.getInstance();
  final isEmail = pref.getBool('isEmail') ?? false;
  final email = pref.getString('email') ?? '';
  await Firebase.initializeApp();
  runApp(MyApp(isEmail: isEmail, email: email));
}

class MyApp extends StatelessWidget {
  final bool isEmail;
  final String email;
  const MyApp({Key? key, required this.isEmail, required this.email})
      : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: isEmail == true
            ? HomePage(email: email)
            : SplashScreen(email: email),
      ),
    );
  }
}
