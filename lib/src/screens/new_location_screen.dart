import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:honeywell_scanner/honeywell_scanner.dart';

import '../models/package.dart';
import '../providers/connection.dart';
import '../widgets/wr_lists.dart';

class LocScreen extends StatefulWidget {
  const LocScreen({Key? key}) : super(key: key);
  static const routeName = '/location';

  @override
  State<LocScreen> createState() => _LocScreenState();
}

class _LocScreenState extends State<LocScreen>
    with WidgetsBindingObserver
    implements ScannerCallback {
  HoneywellScanner honeywellScanner = HoneywellScanner();

  String? errorMessage;

  bool exLocation = false;
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
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    honeywellScanner.scannerCallback = this;
    startScanner();
    configSong();
  }

  Future<void> startScanner() async {
    start();
    updateScanProperties();
    isDeviceSupported = await honeywellScanner.isSupported();
    if (mounted) setState(() {});
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
  void onDecoded(ScannedData? scannedData) async {
    bool res = await _submit(scannedData?.code.toString());
    if (res) {
    } else {
      setState(() {
        cone = Colors.red;
      });
    }
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
              start();
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Future<bool> _submit(String? code) async {
    String bulto = code!.substring(2);
    try {
      if (!exLocation) {
        randonColor();
        Map<String, dynamic> a = await Connection().getLocaion(code);
        setState(() {
          exLocation = true;
          idLocation = a['Ubicacionid'].toString();
          nameLocation = a['Nombre'].toString();
        });
      } else {
        await Connection().postLocation(bulto, idLocation);
        validationPackages(bulto, true);
      }
      return true;
    } on HttpException catch (error) {
      if (exLocation) {
        validationPackages(bulto, false);
      } else {
        await alertError(error.toString());
      }
      return false;
    } catch (error) {
      if (exLocation) {
        validationPackages(bulto, false);
      } else {
        await alertError(error.toString());
      }
      return false;
    }
  }

  Future<void> validationPackages(String? code, bool valid) async {
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
      newPgk.descrition = 'BULTO INVALIDO :|: $code';
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

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: cone,
      appBar: AppBar(
        title: const Text('New Location'),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(20.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 8.0,
              child: Container(
                height: 100,
                constraints: BoxConstraints(minHeight: 100),
                width: deviceSize.width,
                padding: EdgeInsets.only(top: 10),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'Location:',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        nameLocation,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '\nID:',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        idLocation,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (exLocation) ...[
            Padding(
              padding: const EdgeInsets.only(top: 130, right: 10, left: 10),
              child: Container(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 8.0,
                  color: cone,
                  child: Container(
                    height: 100,
                    constraints: BoxConstraints(minHeight: 100),
                    width: deviceSize.width,
                    padding: EdgeInsets.only(top: 25),
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            textAlign: TextAlign.center,
                            currentPgk,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
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

  Future<void> start() async {
    if (await honeywellScanner.startScanner()) {
      setState(() {
        scannerEnabled = true;
      });
    }
  }

  Future<void> stop() async {
    if (await honeywellScanner.startScanner()) {
      setState(() {
        scannerEnabled = false;
      });
    }
  }

  Future<void> alertError(String e) async {
    cone = Colors.red;
    int result = await player.playBytes(audiobytes);
    if (result == 1) {
      await honeywellScanner.stopScanner();
      _showErrorDialog(e);
    } else {
      print("Error while playing audio.");
    }
  }

  void updateScanProperties() {
    List<CodeFormat> codeFormats = [];

    codeFormats.add(CodeFormat.EAN_13);
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
    honeywellScanner.setProperties(properties);
  }

  @override
  void dispose() {
    honeywellScanner.stopScanner();
    super.dispose();
  }
}
