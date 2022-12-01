import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:locations/src/screens/new_location_screen.dart';
import 'package:locations/src/screens/settings.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/auth.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  static const routeName = '/home';
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String version = 'VP:${dotenv.get("VERSION_APP")}';
  String device = '';

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final prefs = await SharedPreferences.getInstance();
    device = prefs.getString('device')!;
    setState(() {
      print('Device $device');
    });
  }

  void connecion(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) {
        return AlertDialog(
          title: Text('Settings'),
          content: Settings(),
          //behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

  void logout(BuildContext ctx) {
    Provider.of<Auth>(context, listen: false).logout();
    Navigator.of(context).pushReplacementNamed('/auth');
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      /* appBar: AppBar(
        title: Text(''),
      ),
      drawer: AppDrawer(), */
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(38, 96, 159, 0).withOpacity(0.5),
                  Color.fromRGBO(14, 78, 148, 0).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          Center(
            child: Material(
              color: Colors.blue,
              elevation: 8,
              borderRadius: BorderRadius.circular(30),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(30)),
                child: FloatingActionButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  splashColor: Colors.black26,
                  heroTag: 'loc',
                  onPressed: () {
                    Navigator.of(context).pushNamed(LocScreen.routeName);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warehouse,
                        size: 120,
                      ),
                      Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text('$version   Device: $device'),
            ),
          )
        ],
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 31, top: 80),
            child: Align(
              alignment: Alignment.topLeft,
              child: FloatingActionButton(
                heroTag: 'exit',
                onPressed: () => logout(context),
                child: Icon(Icons.exit_to_app),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 31, top: 80),
            child: Align(
              alignment: Alignment.topRight,
              child: FloatingActionButton(
                heroTag: 'set',
                onPressed: () => connecion(context),
                child: Icon(Icons.settings),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
