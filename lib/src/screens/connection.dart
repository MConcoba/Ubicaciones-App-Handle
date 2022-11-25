import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sql_conn/sql_conn.dart';

import '../providers/setting.dart';

class ConnectionDB extends StatefulWidget {
  const ConnectionDB({Key? key}) : super(key: key);

  @override
  State<ConnectionDB> createState() => _ConnectionDBState();
}

class _ConnectionDBState extends State<ConnectionDB> {
  final LocalStorage storage = new LocalStorage('todo_app');

  final serverController = TextEditingController()
    ..text = "qsus.quickshipping.com";
  final dataController = TextEditingController()..text = "QuickShippingBAK";
  final passwordOldController = TextEditingController()
    ..text = "accesoRAPIDOsqlALL*";
  final passwordNewController = TextEditingController()
    ..text = "accesoRAPIDOsqlALL*";
  final passwordController = TextEditingController();

  var _isLoading = false;
  var _isVerify = false;

  _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();

    /* prefs.getString("serve").toString() != 'null'
        ? serverController.text = prefs.getString("serve").toString()
        : serverController.text = '';

    prefs.getString("db").toString() != 'null'
        ? dataController.text = prefs.getString("db").toString()
        : dataController.text = '';

    prefs.getString("pass").toString() != 'null'
        ? passwordOldController.text = prefs.getString("pass").toString()
        : passwordOldController.text = '';

    prefs.getString("pass").toString() != 'null'
        ? passwordNewController.text = prefs.getString("pass").toString()
        : passwordNewController.text = ''; */
  }

  Future<void> connect() async {
    final enteredServer = serverController.text;
    final enteredData = dataController.text;
    final enteredPassOld = passwordOldController.text;
    final enteredPassNew = passwordNewController.text;
    final enteredPassword = passwordController.text;

    if (!_isVerify) {
      if (enteredPassword == 'a') {
        log('sd');
        _saveToStorage();
        setState(() {
          _isVerify = true;
          FocusScope.of(context).unfocus();
          //return;
        });
      } else {
        print('here');
        return;
      }
    } else {
      if (enteredServer.isEmpty ||
          enteredData.isEmpty ||
          enteredPassOld.isEmpty ||
          enteredPassNew.isEmpty) {
        return;
      }

      setState(() {
        // _isLoading = true;
        FocusScope.of(context).unfocus();
      });

      try {
        showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              title: Text(""),
              content: Text('Conectado...'),
            );
          },
        );

        await SqlConn.connect(
          ip: enteredServer,
          port: '1433',
          databaseName: enteredData,
          username: 'computo',
          password: 'accesoRAPIDOsqlALL*',
        );
        Provider.of<Setting>(context, listen: false).save(
          enteredServer,
          enteredData,
          'computo',
          enteredPassNew,
        );
        /* setState(() {
          _isLoading = false;
          FocusScope.of(context).unfocus();
        }); */

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Status'),
              content: Text('Connextion'),
              actions: <Widget>[
                FlatButton(
                  child: Text('Okay'),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          },
        );
      } catch (e) {
        print(e);
        Object as = e;
        showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              title: Text('Error'),
              content: Text('e'),
            );
          },
        );
      } finally {
        // Navigator.pop(context);
      }
    }

    //Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Container(
        height: !_isVerify ? 150 : 320,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            if (_isLoading) ...[
              const Center(
                child: CircularProgressIndicator(),
              ),
            ] else ...[
              if (!_isVerify) ...[
                TextField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  controller: passwordController,
                  onSubmitted: (_) => connect(),
                ),
              ] else ...[
                TextField(
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Server'),
                  textInputAction: TextInputAction.next,
                  controller: serverController,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Data Base'),
                  textInputAction: TextInputAction.next,
                  controller: dataController,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Old Password'),
                  textInputAction: TextInputAction.next,
                  controller: passwordOldController,
                  obscureText: true,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'New Password'),
                  controller: passwordNewController,
                  obscureText: true,
                  onSubmitted: (_) => connect(),
                ),
              ],
              Center(
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  direction: Axis.horizontal,
                  children: [
                    Container(
                        margin: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                        child: RaisedButton(
                          child: Text(!_isVerify ? 'Accept' : 'Save'),
                          onPressed: connect,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10.0),
                          color: Theme.of(context).primaryColor,
                          textColor:
                              Theme.of(context).primaryTextTheme.button?.color,
                        )),
                    Container(
                        margin: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                        child: RaisedButton(
                          onPressed: (() {
                            Navigator.of(context).pop();
                          }),
                          child: Text(' Cancel'),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10.0),
                          color: Theme.of(context).secondaryHeaderColor,
                          textColor:
                              Theme.of(context).primaryTextTheme.button?.color,
                        )),
                  ],
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
