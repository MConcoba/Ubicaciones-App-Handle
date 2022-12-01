import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import './src/providers/auth.dart';
import './src/providers/connection.dart';
import './src/screens/home.dart';
import './src/screens/login.dart';
import './src/screens/new_location_screen.dart';
import './src/screens/splash_screen.dart';

void main() async {
  await dotenv
    ..load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProvider.value(
          value: Connection(),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Location',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            secondaryHeaderColor: Colors.red,
          ),
          home: auth.isAuth
              ? const Home()
              : FutureBuilder(
                  future: auth.tryAutoLogin(ctx),
                  builder: (ctx, authResult) =>
                      authResult.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            Home.routeName: (ctx) => const Home(),
            AuthScreen.routeName: (ctx) => AuthScreen(),
            LocScreen.routeName: (ctx) => LocScreen(),
          },
        ),
      ),
    );
  }
}
