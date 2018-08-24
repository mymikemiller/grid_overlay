import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'settings_screen.dart';
import 'grid_overlay_home.dart';

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

class CameraApp extends StatelessWidget {
  final CameraDescription camera;

  CameraApp({this.camera});

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new GridOverlayHome(camera: camera),
      routes: <String, WidgetBuilder>{
        'main': (BuildContext context) => new GridOverlayHome(camera: camera),
        'settings': (BuildContext context) => new SettingsScreen(),
      },
    );
  }
}

List<CameraDescription> cameras;

Future<Null> main() async {
  // Fetch the available cameras before initializing the app.
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    logError(e.code, e.description);
  }
  var camera = cameras.isEmpty ? null : cameras[0];
  runApp(new CameraApp(camera: camera));
}
