import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'views/splashScreen.dart';

void main() async {
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ParentApp());
}

class ParentApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 1, 117, 70)),
        useMaterial3: true,
        fontFamily: 'RB',
      ),
      locale: Locale('ar'), // تحديد اللغة الافتراضية
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl, // جعل التطبيق بالكامل RTL
          child: child!,
        );
      },
      home: SplashScreen(),
      // home: StreamBuilder(
      //   stream: AuthService()._auth.authStateChanges(),
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.active) {
      //       return snapshot.hasData ? HomeScreen() : LoginScreen();
      //     }
      //     return Center(child: CircularProgressIndicator());
      //   },
      // ),
    );
  }
}