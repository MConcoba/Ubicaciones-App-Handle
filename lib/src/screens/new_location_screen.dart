import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:honeywell_scanner/honeywell_scanner.dart';
import 'package:locations/src/models/package.dart';
import 'package:locations/src/providers/connection.dart';
import 'package:locations/src/widgets/wr_lists.dart';

class LocScreen extends StatefulWidget {
  const LocScreen({Key? key}) : super(key: key);
  static const routeName = '/location';

  @override
  State<LocScreen> createState() => _LocScreenState();
}

class _LocScreenState extends State<LocScreen>
    with WidgetsBindingObserver
    implements ScannerCallback {
  final locatedController = TextEditingController();
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

  final serverController = TextEditingController();
  ScrollController listScrollController = ScrollController();

  final List<Package> _paquetes = [];

  @override
  void initState() {
    super.initState();
    //setLocated();
    WidgetsBinding.instance.addObserver(this);
    honeywellScanner.scannerCallback = this;
    // honeywellScanner.onScannerDecodeCallback = onDecoded;
    // honeywellScanner.onScannerErrorCallback = onError;
    init();
    configS();
  }

  Future<void> configS() async {
    Future.delayed(Duration.zero, () async {
      ByteData bytes =
          await rootBundle.load(audioasset); //load audio from assets
      audiobytes =
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
      //convert ByteData to Uint8List

      player.onDurationChanged.listen((Duration d) {
        //get the duration of audio
        maxduration = d.inMilliseconds;
        setState(() {});
      });

      player.onAudioPositionChanged.listen((Duration p) {
        currentpos =
            p.inMilliseconds; //get the current position of playing audio

        //generating the duration label
        int shours = Duration(milliseconds: currentpos).inHours;
        int sminutes = Duration(milliseconds: currentpos).inMinutes;
        int sseconds = Duration(milliseconds: currentpos).inSeconds;

        int rhours = shours;
        int rminutes = sminutes - (shours * 60);
        int rseconds = sseconds - (sminutes * 60 + shours * 60 * 60);

        currentpostlabel = "$rhours:$rminutes:$rseconds";

        setState(() {
          //refresh the UI
        });
      });
    });
  }

  Future<void> init() async {
    start();
    updateScanProperties();
    isDeviceSupported = await honeywellScanner.isSupported();
    if (mounted) setState(() {});
  }

  @override
  void onDecoded(ScannedData? scannedData) async {
    print(scannedData?.code.toString());
    bool res = await _submit(scannedData?.code.toString());
    if (res) {
    } else {
      setState(() {
        cone = Colors.red;
      });
      badRead();
    }
  }

  @override
  void onError(Exception error) {
    print(error);
    setState(() {
      cone = Colors.red;
      errorMessage = error.toString();
    });
  }

  void _showErrorDialo(String message) {
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
        randon();
        Map<String, dynamic> a = await Connection().getLocaion(code);
        print('pantalla  ${a.length}');
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
      // await alertError(error.toString());
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
    // = code!.substring(2);
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
      randon();
      newPgk.icono = Icon(
        Icons.check_box,
        color: cone,
      );
    }

    setState(() {
      currentPgk = newPgk.descrition;
      _paquetes.add(newPgk);
    });
    // return dato;
  }

  Future showAlert(BuildContext context) async {
    await Future.delayed(Duration(seconds: 0));
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text('Welcome To Our App :) .'),
          content: TextField(
            decoration: const InputDecoration(labelText: 'Located'),
            autofocus: true,
            controller: locatedController,
          ),
          actions: <Widget>[
            FlatButton(
              child: new Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void setLocated() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Location'),
        content: TextField(
          decoration: const InputDecoration(labelText: 'Located'),
          controller: locatedController,
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  void randon() {
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
      _showErrorDialo(e);
      print("audio is playing.");
    } else {
      print("Error while playing audio.");
    }
  }

  void updateScanProperties() {
    List<CodeFormat> codeFormats = [];

    ///codeFormats.add(CodeFormat.AZTEC);

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
  void badRead() async {
    print('here');
  }

  @override
  void dispose() {
    print('go');
    honeywellScanner.stopScanner();
    super.dispose();
  }
}
