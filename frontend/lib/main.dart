import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'screens/add_person.dart';
import 'screens/update_person.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'services/auth_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contact App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: SplashScreen(),
      routes: {
        '/connexion': (context) => LoginScreen(),
        '/inscription': (context) => RegisterScreen(),
        '/accueil': (context) => HomeScreen(),
        '/ajouter': (context) => AddPersonScreen(),
        '/modifier': (context) => ModifierContactPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Check if user is logged in
    final isLoggedIn = await AuthService.isLoggedIn();
    
    // Navigate to appropriate screen
    await Future.delayed(Duration(milliseconds: 500));
    
    if (mounted) {
      if (isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/accueil');
      } else {
        Navigator.pushReplacementNamed(context, '/connexion');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo.shade700,
              Colors.indigo.shade400,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.contacts,
                size: 100,
                color: Colors.white,
              ),
              SizedBox(height: 24),
              Text(
                'Contact App',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 24),
              CircularProgressIndicator(
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
