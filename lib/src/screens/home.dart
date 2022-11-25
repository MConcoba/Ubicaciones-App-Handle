import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:locations/src/screens/connection.dart';
import 'package:locations/src/widgets/app_drawer.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  static const routeName = '/home';
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  void connecion(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) {
        return AlertDialog(
          title: Text('Settings'),
          content: ConnectionDB(),
          //behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

  void logout(BuildContext ctx) {
    // Navigator.of(context).pop();
    // Navigator.of(context).pushReplacementNamed('/');
    Provider.of<Auth>(context, listen: false).logout();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: AppDrawer(),

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
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: Text('Home'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      /* floatingActionButton: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 31, top: 50),
              child: Align(
                alignment: Alignment.topLeft,
                child: FloatingActionButton(
                  onPressed: () => logout(context),
                  child: Icon(Icons.exit_to_app),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 31, top: 50),
              child: Align(
                alignment: Alignment.topRight,
                child: FloatingActionButton(
                  onPressed: () => connecion(context),
                  child: Icon(Icons.settings),
                ),
              ),
            ),
          ],
        ) */
      //floatingActionButtonLocation: FloatingActionButtonLocation.endTop,

      /* floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.settings),
        onPressed: () => connecion(context),
      ), */
    );
  }
}
