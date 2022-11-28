import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:locations/src/providers/connection.dart';
import 'package:locations/src/screens/home.dart';
import 'package:locations/src/screens/login.dart';
import 'package:locations/src/screens/new_location_screen.dart';
import 'package:locations/src/screens/splash_screen.dart';
import 'package:provider/provider.dart';

import './src/providers/auth.dart';

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
          /* : FutureBuilder(
                  future: auth.tryAutoLogin(),
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ), */
          //  : AuthScreen(),
          routes: {
            Home.routeName: (ctx) => const Home(),
            AuthScreen.routeName: (ctx) => AuthScreen(),
            LocScreen.routeName: (ctx) => LocScreen(),
            // LocationScreen.routeName: (ctx) => LocationScreen(),
          },
        ),
      ),
    );
    /* return MaterialApp(
      title: 'Personal  Expenses',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        secondaryHeaderColor: Colors.red,
        // appBarTheme:
      ),
      home: AuthScreen(),
    ); */
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
