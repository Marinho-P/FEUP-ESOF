
import 'package:app/resources/notification_methods.dart';
import 'package:app/theme/theme_provider.dart';

import 'package:flutter/material.dart';
import 'package:app/widgets/logo.dart';
import 'package:app/screens/sign_in_screen.dart';
import 'package:app/screens/main_screen.dart';
import 'package:app/screens/verify_email_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool notifications = prefs.getBool("Notifications") ?? false;
    bool isDarkTheme = prefs.getBool("isDarkTheme") ?? false; // Default to false if value is null
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if(FirebaseAuth.instance.currentUser != null && notifications){
      NotificationMethods().initNotifications();
    }
    
    runApp(ChangeNotifierProvider(create: (context) => ThemeProvider(isDarkMode:isDarkTheme),
      child: const MyApp(),
    ),
    );
  } catch (error) {
    print('Firebase initialization error: $error');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {

    return Consumer<ThemeProvider>(
        builder: (context,themeProvider,child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            home: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    User? user = snapshot.data;
                    if (user == null) {
                       return InitialScreen();
                    } else if (!user.emailVerified) {
                        return InitialScreen();
            } else {
              return MainScreen();
            }
          }
          return const CircularProgressIndicator();
        },
      ),
            theme: themeProvider.getTheme,
          );
        },
    );
      }
}


class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          const SizedBox(height: 50),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFD0FCB3),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(56),
                  topRight: Radius.circular(56),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Transform.translate(
                    offset: const Offset(0, 70),
                    child: SvgPicture.asset(
                      'lib/assets/get_started_background.svg',
                      fit: BoxFit.fitHeight,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const SizedBox(height: 60),
                      const MainLogo(),
                      const Spacer(),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0A2E36),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            minimumSize: const Size(308, 56),
                          ),
                          child: const Text(
                            'Get Started',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Ruda',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
