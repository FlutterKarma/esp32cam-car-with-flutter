import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

Widget fourbutton() {
  return Container(
    height: 150,
    width: 138,
    decoration: BoxDecoration(shape: BoxShape.circle),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Neumorphic(
          style: NeumorphicStyle(
              shape: NeumorphicShape.convex,
              boxShape: NeumorphicBoxShape.circle(),
              depth: 10,
              shadowLightColor: Colors.white,
              color: Colors.grey.withOpacity(0.7)),
          child: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(shape: BoxShape.circle),
            child: Icon(
              Icons.change_history,
              size: 45,
              color: Colors.lightGreen,
            ),
          ),
        ),
        Expanded(child: Container()),
        Row(
          children: <Widget>[
            Neumorphic(
              style: NeumorphicStyle(
                  shape: NeumorphicShape.convex,
                  boxShape: NeumorphicBoxShape.circle(),
                  depth: 10,
                  shadowLightColor: Colors.white,
                  color: Colors.grey.withOpacity(0.7)),
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(shape: BoxShape.circle),
                child: Icon(
                  Icons.crop_square,
                  size: 45,
                  color: Colors.purple,
                ),
              ),
            ),
            Expanded(child: Container()),
            Neumorphic(
              style: NeumorphicStyle(
                  shape: NeumorphicShape.convex,
                  boxShape: NeumorphicBoxShape.circle(),
                  depth: 10,
                  shadowLightColor: Colors.white,
                  color: Colors.grey.withOpacity(0.7)),
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(shape: BoxShape.circle),
                child: Icon(
                  Icons.panorama_fish_eye,
                  size: 45,
                  color: Colors.pinkAccent,
                ),
              ),
            )
          ],
        ),
        Expanded(child: Container()),
        Neumorphic(
          style: NeumorphicStyle(
              shape: NeumorphicShape.convex,
              boxShape: NeumorphicBoxShape.circle(),
              depth: 10,
              shadowLightColor: Colors.white,
              color: Colors.grey.withOpacity(0.7)),
          child: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(shape: BoxShape.circle),
            child: Icon(
              Icons.close,
              size: 45,
              color: Colors.blueAccent,
            ),
          ),
        )
      ],
    ),
  );
}
