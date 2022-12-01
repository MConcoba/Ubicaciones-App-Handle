import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/connection.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final serverController = TextEditingController();
  final dataController = TextEditingController();
  final userController = TextEditingController();
  final passwordNewController = TextEditingController();
  final passwordController = TextEditingController();

  var _isLoading = false;
  var _isVerify = false;

  _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.getString("serve").toString() != 'null'
        ? serverController.text = prefs.getString("serve").toString()
        : serverController.text = '';

    prefs.getString("db").toString() != 'null'
        ? dataController.text = prefs.getString("db").toString()
        : dataController.text = '';

    prefs.getString("user").toString() != 'null'
        ? userController.text = prefs.getString("user").toString()
        : userController.text = '';

    prefs.getString("pass").toString() != 'null'
        ? passwordNewController.text = prefs.getString("pass").toString()
        : passwordNewController.text = '';
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occurred!'),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.pop(ctx);
            },
          )
        ],
      ),
    );
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(
            margin: EdgeInsets.only(left: 7),
            child: Text("Connecting..."),
          ),
        ],
      ),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> connect() async {
    final enteredServer = serverController.text;
    final enteredData = dataController.text;
    final enteredUser = userController.text;
    final enteredPassNew = passwordNewController.text;
    final enteredPassword = passwordController.text;

    if (!_isVerify) {
      if (enteredPassword == 'a') {
        log('sd');
        _saveToStorage();
        setState(() {
          _isVerify = true;
          FocusScope.of(context).unfocus();
        });
      } else {
        print('here');
        return;
      }
    } else {
      if (enteredServer.isEmpty ||
          enteredData.isEmpty ||
          enteredUser.isEmpty ||
          enteredPassNew.isEmpty) {
        return;
      }

      setState(() {
        FocusScope.of(context).unfocus();
      });

      try {
        bool c = false;
        var s = await showLoaderDialog(context);

        await Connection()
            .connect(enteredServer, enteredData, enteredUser, enteredPassNew);

        Provider.of<Connection>(context, listen: false).save(
          enteredServer,
          enteredData,
          enteredUser,
          enteredPassNew,
        );

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
      } on SocketException catch (e) {
        print(e.toString());
        _showErrorDialog(e.toString());
      } catch (e) {
        _showErrorDialog(e.toString());
      }
    }
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
                  decoration: const InputDecoration(labelText: 'User'),
                  textInputAction: TextInputAction.next,
                  controller: userController,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Password'),
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
                      ),
                    ),
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
