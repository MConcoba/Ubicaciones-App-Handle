import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:flutter_datawedge/models/scan_result.dart';
import 'package:flutter_datawedge/models/scanner_status.dart';
import 'package:honeywell_scanner/honeywell_scanner.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../models/package.dart';
import '../providers/connection.dart';
import '../widgets/wr_lists.dart';

class ZebraScreen extends StatefulWidget {
  const ZebraScreen({Key? key}) : super(key: key);
  static const routeName = '/location-zebra';

  @override
  State<ZebraScreen> createState() => _ZebraScreenState();
}

class _ZebraScreenState extends State<ZebraScreen> {
  late StreamSubscription<ScanResult> onScanResultListener;
  late StreamSubscription<ScannerStatus> onScannerStatusListener;
  List<ScanResult> scanResults = [];
  String _lastStatus = '';
  late FlutterDataWedge fdw;

  String? errorMessage;

  bool exLocation = false;
  bool firstLocation = false;
  String idLocation = '';
  String nameLocation = '';
  String currentPgk = '';
  DateTime currentTime = DateTime.now();

  int maxduration = 100;
  int currentpos = 0;
  String currentpostlabel = "00:00";
  String audioasset = "assets/audio/error.mp3";
  bool isplaying = false;
  bool audioplayed = false;
  late Uint8List audiobytes;
  AudioPlayer player = AudioPlayer();

  Color cone = Colors.white;

  bool isDeviceSupported = false;
  bool scannerEnabled = false;

  final List<Package> _paquetes = [];

  @override
  void initState() {
    exLocation = false;
    firstLocation = false;
    super.initState();
    // WidgetsBinding.instance.addObserver(this);
    initScanner();
    configSong();
  }

  Future<void> configSong() async {
    Future.delayed(Duration.zero, () async {
      ByteData bytes = await rootBundle.load(audioasset);
      audiobytes =
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);

      player.onDurationChanged.listen((Duration d) {
        maxduration = d.inMilliseconds;
        setState(() {});
      });

      player.onAudioPositionChanged.listen((Duration p) {
        currentpos = p.inMilliseconds;
        int shours = Duration(milliseconds: currentpos).inHours;
        int sminutes = Duration(milliseconds: currentpos).inMinutes;
        int sseconds = Duration(milliseconds: currentpos).inSeconds;

        int rhours = shours;
        int rminutes = sminutes - (shours * 60);
        int rseconds = sseconds - (sminutes * 60 + shours * 60 * 60);

        currentpostlabel = "$rhours:$rminutes:$rseconds";
      });
    });
  }

  @override
  void onError(Exception error) {
    setState(() {
      cone = Colors.red;
      errorMessage = error.toString();
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occurred!'),
        content: Text(message),
        backgroundColor: cone,
        actions: <Widget>[
          FlatButton(
            child: Text('Okay'),
            onPressed: () {
              fdw.enableScanner(true);
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: cone,
      appBar: AppBar(
        title: const Text('New Location Zebra'),
      ),
      body: Column(
        children: [
          Text('Last status: ' + _lastStatus,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9)),
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
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 15,
                              // fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text: nameLocation,
                                style: TextStyle(
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
    int result = await player.playBytes(audiobytes);
    if (result == 1) {
      //await honeywellScanner.stopScanner();
      fdw.enableScanner(false);
      _showErrorDialog(e);
    } else {
      print("Error while playing audio.");
    }
  }

  void updateScanProperties() {
    List<CodeFormat> codeFormats = [];

    // codeFormats.add(CodeFormat.EAN_13);
    Map<String, dynamic> properties = {
      // ...CodeFormatUtils.getAsPropertiesComplement(codeFormats),
      'NTF_BAD_READ_ENABLED': true,
      'NTF_GOOD_READ_ENABLED': true,
      'TRIG_CONTROL_MODE': true,
      'TRIGGER_SETTINGS': true,
      'NOTIFICATION_SETTINGS': true,
      'goodRead': true,
      'badRead': true,
    };
    //honeywellScanner.setProperties(properties);
  }

  void initScanner() {
    if (Platform.isAndroid) {
      fdw = FlutterDataWedge(profileName: 'FlutterDataWedge');
      bool res;
      onScanResultListener =
          fdw.onScanResult.listen((result) => setState(() async => {
                scanResults.add(result),
                res = await _submit(result.data),
                if (res)
                  {}
                else
                  {
                    setState(() {
                      cone = Colors.red;
                    })
                  }
              }));
      onScannerStatusListener = fdw.onScannerStatus.listen(
          (status) => setState(() => _lastStatus = status.status.value));
    }
  }

  @override
  void dispose() {
    //honeywellScanner.stopScanner();
    onScanResultListener.cancel();
    onScannerStatusListener.cancel();
    super.dispose();
  }
}
