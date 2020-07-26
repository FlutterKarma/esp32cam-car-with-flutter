import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Screen extends StatefulWidget {
  final bool _isScreenOn;
  Screen(this._isScreenOn);
  @override
  _ScreenState createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  @override
  Widget build(BuildContext context) {
    return Neumorphic(
        style: NeumorphicStyle(
            shape: NeumorphicShape.flat,
            depth: -3,
            surfaceIntensity: 10,
            shadowDarkColor: Colors.black,
            border: NeumorphicBorder(
              color: Color(0x33000000),
              width: 2,
            )),
        child: widget._isScreenOn
            ? Container(
                height: 240,
                width: 320,
                child: WebView(
                  initialUrl: "http://192.168.225.97",
                ))
            : Container(
                height: 240,
                width: 320,
              ));
  }
}
