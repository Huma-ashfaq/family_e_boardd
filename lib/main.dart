import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_plan/Screens/main_module_screen.dart';
import 'Screens/auth_screen.dart';
import 'Screens/main_screen.dart';
import 'firebase_options.dart'; // Assuming you have this file for Firebase configuration
import 'package:flutter_dotenv/flutter_dotenv.dart';

final firebaseauth = FirebaseAuth.instance;

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: const FirebaseOptions(
      apiKey:'AIzaSyCdF8PcLo4_AVhEE-D1Hx8BN5pZW7vgO_Q',
      appId: '1:634776364804:android:460654d8c46b4070429251',
      messagingSenderId: '634776364804',
      projectId: 'mealandexpense'));
      //options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final kDarkColorScheme = ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 33, 103, 255),
    brightness: Brightness.dark,
  );

  final kLightColorScheme = ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 33, 103, 255),
    brightness: Brightness.light,
  );

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    home: StreamBuilder(
      stream: firebaseauth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ModuleScreen();
        }
        return const AuthScreen();
      },
    ),
    darkTheme: ThemeData(
      useMaterial3: true,
      colorScheme: kLightColorScheme,
      textTheme: GoogleFonts.latoTextTheme(),
    ),
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: kLightColorScheme,
    ),
  );
}
