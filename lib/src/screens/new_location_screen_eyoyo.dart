import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:locations/src/models/http_exception.dart';
import 'package:locations/src/models/package.dart';
import 'package:locations/src/providers/connection.dart';
import 'package:locations/src/widgets/wr_lists.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class EyoyoScanner extends StatefulWidget {
  const EyoyoScanner({Key? key}) : super(key: key);
  static const routeName = '/location-eyoyo';

  @override
  State<EyoyoScanner> createState() => _EyoyoScannerState();
}

class _EyoyoScannerState extends State<EyoyoScanner>
    with WidgetsBindingObserver {
  double _keyboardHeight = 0;
  bool isKeyboardActive = true;
  final FocusNode _focusNode = FocusNode();
  String _textFieldValue = '';
  bool _isTextFieldVisible = true;
  TextEditingController _textEditingController = TextEditingController();
  bool nuevo_scaneo = false;

  bool exLocation = false;
  bool firstLocation = false;
  Color cone = Colors.white;
  String idLocation = '';
  String nameLocation = '';
  String currentPgk = '';
  final List<Package> _paquetes = [];

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    updateKeyboardStatus(context);
  }

  @override
  void initState() {
    super.initState();
    // isKeyboardActive = true;
    WidgetsBinding.instance.addObserver(this);
    _focusNode.addListener(() {
      setState(() {}); // actualiza el estado cuando cambia el focus
    });
  }

  Future<void> locacion(String? code) async {
    print(code);
    _submit(code);
    setState(() {
      _textEditingController.clear();
      this._textFieldValue = code!;
    });
  }

  void updateKeyboardStatus(BuildContext context) {
    final teclado = MediaQuery.of(context).viewInsets.bottom > 0;
    print(teclado);
    // Si el teclado está activo, actualiza la variable _keyboardHeight con el tamaño del teclado
    if (!teclado) {
      setState(() {
        _keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        this.isKeyboardActive = true;
      });
    } else {
      setState(() {
        this.isKeyboardActive = false;
        this._keyboardHeight = 0;
      });
    }
  }

  Future<bool> _submit(String? code) async {
    print(code!.length);
    code.length == 10 ? exLocation = false : exLocation = true;
    String bulto = code.substring(2);
    try {
      if (!exLocation) {
        Map<String, dynamic> a = await Connection().getLocaion(code);
        randonColor();
        if (firstLocation) {
          newLocation(a['Nombre'].toString(), true, '');
        }
        setState(() {
          exLocation = true;
          firstLocation = true;
          idLocation = a['Ubicacionid'].toString();
          nameLocation = a['Nombre'].toString();
        });
      } else {
        await Connection().postLocation(bulto, idLocation);
        validationPackages(bulto, true, '');
      }
      return true;
    } on HttpException catch (error) {
      if (exLocation) {
        validationPackages(bulto, false, error.toString());
      } else {
        newLocation(code, false, error.toString());
      }
      return false;
    } catch (error) {
      if (exLocation) {
        validationPackages(bulto, false, error.toString());
      } else {
        newLocation(code, false, error.toString());

        // await alertError(error.toString());
      }
      return false;
    }
  }

  Future<void> newLocation(String? code, bool valid, String? error) async {
    var ico = Icon(Icons.house_rounded);
    final newPgk = Package(
      location: nameLocation,
      wr: code!,
      date: DateTime.now(),
      color: cone,
      icono: ico,
      descrition: 'NUEVA UBICACION :|: $code',
    );

    if (!valid) {
      newPgk.icono = Icon(Icons.error, color: Colors.red);
      newPgk.descrition = '$error :|: $code';
      await alertError(error.toString());
    } else {
      randonColor();
      newPgk.icono = Icon(
        Icons.house_rounded,
        color: cone,
      );
    }

    setState(() {
      currentPgk = newPgk.descrition;
      _paquetes.add(newPgk);
    });
  }

  Future<void> validationPackages(
      String? code, bool valid, String? error) async {
    var a = Icon(Icons.check_box);
    final newPgk = Package(
      location: nameLocation,
      wr: code!,
      date: DateTime.now(),
      color: cone,
      icono: a,
      descrition: 'UBICADO :|: $nameLocation BULTO $code',
    );
    if (!valid) {
      newPgk.icono = Icon(Icons.error, color: Colors.red);
      newPgk.descrition = '$error :|: $code';
      await alertError(newPgk.descrition);
    } else {
      randonColor();
      newPgk.icono = Icon(
        Icons.check_box,
        color: cone,
      );
    }

    setState(() {
      currentPgk = newPgk.descrition;
      _paquetes.add(newPgk);
    });
  }

  void randonColor() {
    var list = ['green', 'yellow', 'pink', 'cyan', 'brown', 'purple'];
    var current = cone;
    do {
      List<Color> colors = [
        Colors.purple,
        Colors.tealAccent,
        Colors.brown,
        Colors.yellow,
        Colors.teal,
        Color(0xFF003B6B)
      ];

      Random random = Random();
      int cindex = random.nextInt(colors.length);
      Color tempcol = colors[cindex];

      setState(() {
        cone = tempcol;
      });
    } while (current == cone);
  }

  /*  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Location'),
      ),
      body: Column(
        children: [
          
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                width: 90.w,
                height: 35.h,
                //color: Colors.amber,
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 5,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text('El teclado está activo: $isKeyboardActive'),
                        Text('La altura del teclado es: $_keyboardHeight'),
                        Text('El focus está activo: ${_focusNode.hasFocus}'),
                        Text('Valor del TextField: $_textFieldValue'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isTextFieldVisible = !_isTextFieldVisible;
          });
        },
        child:
            Icon(_isTextFieldVisible ? Icons.visibility_off : Icons.visibility),
      ),
    );
  } */

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: cone,
      appBar: AppBar(
        title: const Text('New Location'),
      ),
      body: Column(
        children: [
          TextField(
            autofocus: true,
            focusNode: _focusNode,
            controller: _textEditingController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              isCollapsed: true,
            ),
            style: TextStyle(fontSize: 12, color: Colors.white),
            maxLines: 1,
            //maxLength: 10,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            onEditingComplete: () {
              _focusNode.requestFocus();
            },
            onChanged: (value) {
              print(value);
              if (value.length == 16) {
                print('16 --' + value);
                locacion(value);
              }
              setState(() {
                _textEditingController.clear();
                // this._textFieldValue = code!;
              });
              /* if (value.length == 10) {
                print('10 --' + value);

                this.nuevo_scaneo = true;
                locacion(value);
              } */
            },
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                width: 90.w,
                height: 15.h,
                //color: Colors.amber,
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 5,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        RichText(
                          text: TextSpan(
                            text: 'Location:   ',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 15,
                              // fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text: nameLocation,
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            text: '\nID:   ',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 15,
                              // fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text: idLocation,
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (firstLocation) ...[
            Padding(
              padding: const EdgeInsets.all(10),
              //child: Container(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 8.0,
                color: cone,
                child: Container(
                  width: 90.w,
                  height: 10.h,
                  //padding: EdgeInsets.only(top: 25),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          textAlign: TextAlign.center,
                          currentPgk,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 0.23.dp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: PackageList(
                  transactions: _paquetes,
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Future<void> alertError(String e) async {
    cone = Colors.red;
    /* int result = await player.playBytes(audiobytes);
    if (result == 1) {
      await honeywellScanner.stopScanner();
      _showErrorDialog(e);
    } else {
      print("Error while playing audio.");
    } */
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.dispose(); // libera el recurso cuando se destruye el widget
    super.dispose();
  }
}
