import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutterapp/widigts/fourbutton.dart';
import 'package:flutterapp/widigts/screen.dart';
import 'dart:convert';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vibration/vibration.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Initializing the Bluetooth connection state to be unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  // Get the instance of the Bluetooth
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  // Track the Bluetooth connection with the remote device
  BluetoothConnection connection;

  int _deviceState;

  bool isDisconnecting = false;
  var _isSwitchOn = false;
  // To track whether the device is still connected to Bluetooth
  bool get isConnected => connection != null && connection.isConnected;

  // Define some variables, which will be required later
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice _device;
  bool _connected = false;
  bool _isButtonUnavailable = false;
  bool _isScreenOn = false;

  Map<String, Color> colors = {
    'onBorderColor': Colors.green,
    'offBorderColor': Colors.red,
    'neutralBorderColor': Colors.transparent,
    'onTextColor': Colors.green[700],
    'offTextColor': Colors.red[700],
    'neutralTextColor': Colors.blue,
  };

  @override
  void initState() {
    super.initState();
    //hide system bar
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    _deviceState = 0; // neutral

    // If the bluetooth of the device is not enabled,
    // then request permission to turn on bluetooth
    // as the app starts up
    enableBluetooth();

    // Listen for further state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
        if (_bluetoothState == BluetoothState.STATE_OFF) {
          _isButtonUnavailable = true;
        }
        getPairedDevices();
      });
    });
  }

  @override
  void dispose() {
    // Avoid memory leak and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  // Request Bluetooth permission from the user
  Future<void> enableBluetooth() async {
    // Retrieving the current Bluetooth state
    _bluetoothState = await FlutterBluetoothSerial.instance.state;

    // If the bluetooth is off, then turn it on first
    // and then retrieve the devices that are paired.
    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices();
      return true;
    } else {
      await getPairedDevices();
    }
    return false;
  }

  // For retrieving and storing the paired devices
  // in a list.
  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    // To get the list of paired devices
    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

    // It is an error to call [setState] unless [mounted] is true.
    if (!mounted) {
      return;
    }

    // Store the [devices] list in the [_devicesList] for accessing
    // the list outside this class
    setState(() {
      _devicesList = devices;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.lightBlue,
      body: Padding(
        padding: const EdgeInsets.only(
          right: 8,
          left: 8,
          top: 20,
          bottom: 5,
        ),
        child: Stack(
          alignment: Alignment.topRight,
          children: <Widget>[
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                  color: Colors.white),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 5,
                  ),
                  controler(),
                  SizedBox(
                    width: 5,
                  ),
                  Screen(_isScreenOn),
                  SizedBox(
                    width: 5,
                  ),
                  fourbutton()
                ],
              ),
            ),
            RawMaterialButton(
              fillColor: Colors.blue[200],
              shape: CircleBorder(),
              child: Icon(
                Icons.bluetooth,
                color: Colors.white,
              ),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        elevation: 16,
                        child: Container(
                          height: 450.0,
                          width: 360.0,
                          child: Container(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Visibility(
                                  visible: _isButtonUnavailable &&
                                      _bluetoothState ==
                                          BluetoothState.STATE_ON,
                                  child: LinearProgressIndicator(
                                    backgroundColor: Colors.yellow,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.red),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          'Enable Bluetooth',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Switch(
                                        value: _bluetoothState.isEnabled,
                                        onChanged: (bool value) {
                                          future() async {
                                            if (value) {
                                              await FlutterBluetoothSerial
                                                  .instance
                                                  .requestEnable();
                                            } else {
                                              await FlutterBluetoothSerial
                                                  .instance
                                                  .requestDisable();
                                            }

                                            await getPairedDevices();
                                            _isButtonUnavailable = false;

                                            if (_connected) {
                                              _disconnect();
                                            }
                                          }

                                          future().then((_) {
                                            setState(() {});
                                          });
                                        },
                                      )
                                    ],
                                  ),
                                ),
                                Stack(
                                  children: <Widget>[
                                    Column(
                                      children: <Widget>[
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8),
                                          child: Text(
                                            "PAIRED DEVICES",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.blue),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(
                                                'Device:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              DropdownButton(
                                                items: _getDeviceItems(),
                                                onChanged: (value) => setState(
                                                    () => _device = value),
                                                value: _devicesList.isNotEmpty
                                                    ? _device
                                                    : null,
                                              ),
                                              RaisedButton(
                                                onPressed: _isButtonUnavailable
                                                    ? null
                                                    : _connected
                                                        ? _disconnect
                                                        : _connect,
                                                child: Text(_connected
                                                    ? 'Disconnect'
                                                    : 'Connect'),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              side: new BorderSide(
                                                color: _deviceState == 0
                                                    ? colors[
                                                        'neutralBorderColor']
                                                    : _deviceState == 1
                                                        ? colors[
                                                            'onBorderColor']
                                                        : colors[
                                                            'offBorderColor'],
                                                width: 3,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                            ),
                                            elevation:
                                                _deviceState == 0 ? 4 : 0,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Text(
                                                      "DEVICE 1",
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        color: _deviceState == 0
                                                            ? colors[
                                                                'neutralTextColor']
                                                            : _deviceState == 1
                                                                ? colors[
                                                                    'onTextColor']
                                                                : colors[
                                                                    'offTextColor'],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            "NOTE: If you cannot find the device in the list, please pair the device by going to the bluetooth settings",
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            ),
                                          ),
                                          RaisedButton(
                                            elevation: 2,
                                            child: Text("Bluetooth Settings"),
                                            onPressed: () {
                                              FlutterBluetoothSerial.instance
                                                  .openSettings();
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    });
              },
            )
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devicesList.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      _devicesList.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name),
          value: device,
        ));
      });
    }
    return items;
  }

  // Method to connect to bluetooth
  void _connect() async {
    setState(() {
      _isButtonUnavailable = true;
    });
    if (_device == null) {
      show('No device selected');
    } else {
      if (!isConnected) {
        await BluetoothConnection.toAddress(_device.address)
            .then((_connection) {
          print('Connected to the device');
          connection = _connection;
          setState(() {
            _connected = true;
          });

          connection.input.listen(null).onDone(() {
            if (isDisconnecting) {
              print('Disconnecting locally!');
            } else {
              print('Disconnected remotely!');
            }
            if (this.mounted) {
              setState(() {});
            }
          });
        }).catchError((error) {
          print('Cannot connect, exception occurred');
          print(error);
        });
        show('Device connected');

        setState(() => _isButtonUnavailable = false);
      }
    }
  }

  // void _onDataReceived(Uint8List data) {
  //   // Allocate buffer for parsed data
  //   int backspacesCounter = 0;
  //   data.forEach((byte) {
  //     if (byte == 8 || byte == 127) {
  //       backspacesCounter++;
  //     }
  //   });
  //   Uint8List buffer = Uint8List(data.length - backspacesCounter);
  //   int bufferIndex = buffer.length;

  //   // Apply backspace control character
  //   backspacesCounter = 0;
  //   for (int i = data.length - 1; i >= 0; i--) {
  //     if (data[i] == 8 || data[i] == 127) {
  //       backspacesCounter++;
  //     } else {
  //       if (backspacesCounter > 0) {
  //         backspacesCounter--;
  //       } else {
  //         buffer[--bufferIndex] = data[i];
  //       }
  //     }
  //   }
  // }

  // Method to disconnect bluetooth
  void _disconnect() async {
    setState(() {
      _isButtonUnavailable = true;
      _deviceState = 0;
    });

    await connection.close();
    show('Device disconnected');
    if (!connection.isConnected) {
      setState(() {
        _connected = false;
        _isButtonUnavailable = false;
      });
    }
  }

  // Method to send message,
  // for turning the Bluetooth device on
  void _sendRightMessageToBluetooth() async {
    connection.output.add(utf8.encode("1"));
    await connection.output.allSent;
    show('Device Turned Right');
    setState(() {
      _deviceState = 1; // device o
    });
  }

  // Method to send message,
  // for turning the Bluetooth device off
  void _sendLeftMessageToBluetooth() async {
    connection.output.add(utf8.encode("2"));
    await connection.output.allSent;
    show('Device Turned Left');
    setState(() {
      _deviceState = -1; // device off
    });
  }

  // Method to send message,
  // for turning the Bluetooth device off
  void _sendUpMessageToBluetooth() async {
    connection.output.add(utf8.encode("0"));
    await connection.output.allSent;
    show('Device Turned up');
    setState(() {
      _deviceState = -1; // device off
    });
  }

  void _senddownMessageToBluetooth() async {
    connection.output.add(utf8.encode("3"));
    await connection.output.allSent;
    show('Device Turned down');
    setState(() {
      _deviceState = -1; // device off
    });
  }

  // Method to show a Snackbar,
  // taking message as the text
  Future show(
    String message, {
    Duration duration: const Duration(seconds: 3),
  }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        content: new Text(
          message,
        ),
        duration: duration,
      ),
    );
  }

//controller

  Widget controler() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Neumorphic(
          style: NeumorphicStyle(
              shape: NeumorphicShape.convex,
              boxShape: NeumorphicBoxShape.circle(),
              depth: 10,
              oppositeShadowLightSource: false,
              shadowLightColor: Colors.white,
              color: Colors.grey.withOpacity(0.7)),
          child: Container(
            height: 150,
            width: 150,
            decoration: BoxDecoration(shape: BoxShape.circle),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Neumorphic(
                  style: NeumorphicStyle(
                      shape: NeumorphicShape.convex,
                      boxShape: NeumorphicBoxShape.circle(),
                      depth: 10,
                      shadowLightColor: Colors.white,
                      color: Colors.grey.withOpacity(0.7)),
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(shape: BoxShape.circle),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Vibration.vibrate(
                          duration: 100,
                        );
                        if (_connected) {
                          _sendUpMessageToBluetooth();
                        }
                      },
                      child: Container(
                          height: 60,
                          width: 40,
                          decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(35),
                                  bottomRight: Radius.circular(35))),
                          child: SvgPicture.asset(
                            "assets/top.svg",
                            fit: BoxFit.fill,
                          )),
                    ),
                    Row(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            Vibration.vibrate(
                              duration: 100,
                            );
                            if (_connected) {
                              _sendLeftMessageToBluetooth();
                            }
                          },
                          child: Container(
                            height: 40,
                            width: 60,
                            child: SvgPicture.asset(
                              "assets/left.svg",
                              fit: BoxFit.fill,
                            ),
                            decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(30),
                                    bottomRight: Radius.circular(30))),
                          ),
                        ),
                        Expanded(child: Container()),
                        GestureDetector(
                          onTap: () {
                            Vibration.vibrate(
                              duration: 100,
                            );
                            if (_connected) {
                              _sendRightMessageToBluetooth();
                            }
                          },
                          child: Container(
                            height: 40,
                            width: 60,
                            decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(30),
                                    topLeft: Radius.circular(30))),
                            child: SvgPicture.asset(
                              "assets/right.svg",
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Vibration.vibrate(
                          duration: 100,
                        );
                        if (_connected) {
                          _senddownMessageToBluetooth();
                        }
                      },
                      child: Container(
                        height: 50,
                        width: 40,
                        decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30))),
                        child: SvgPicture.asset(
                          "assets/bottom.svg",
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RaisedButton(
            onPressed: () {
              if (_isScreenOn == false) {
                setState(() {
                  _isScreenOn = true;
                });
              } else {
                setState(() {
                  _isScreenOn = false;
                });
              }
            },
            child: _isScreenOn ? Text("stop") : Text("start"),
            color: Colors.grey,
          ),
        )
      ],
    );
  }
}
