import 'grid_painter.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'settings.dart';

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

class GridOverlayHome extends StatefulWidget {
  final int columns;
  final CameraDescription camera;

  GridOverlayHome({this.camera, this.columns}) {
    print("Setting camera");
  }

  @override
  _GridOverlayHomeState createState() {
    return new _GridOverlayHomeState(this.camera);
  }
}

/// Returns a suitable camera icon for [direction].
IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
  }
  throw new ArgumentError('Unknown lens direction');
}

class _GridOverlayHomeState extends State<GridOverlayHome> {
  CameraController controller;
  int columns = 3;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  _GridOverlayHomeState(CameraDescription camera) {
    //print("constructing. camera: ${widget.camera}");
    if (camera != null) {
      onNewCameraSelected(camera);
    }
  }

  // Launch the Settings screen and awaits the result from Navigator.pop
  _showSettings(BuildContext context) async {
    // Navigator.push returns a Future that will complete after we call
    // Navigator.pop on the Settings Screen!
    final newColumns = await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => new Settings(
              columns: this.columns,
            )));

    print("columns: $newColumns");
    if (newColumns != null) {
      setState(() {
        this.columns = newColumns;
      });
    }
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return new Stack(
        alignment: FractionalOffset.center,
        children: <Widget>[
          new Positioned.fill(
            child: new AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: new CameraPreview(controller)),
          ),
          new Positioned.fill(
            child: new CustomPaint(
              painter: new GridPainter(
                columns: columns,
                gridColor: Colors.white,
                strokeWidth: 5.0,
              ),
            ),
          ),
        ],
      );
    }
  }

  void showInSnackBar(String message) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(message)));
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = new CameraController(cameraDescription, ResolutionPreset.high);

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        showInSnackBar('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: null,
      body: new Column(
        children: <Widget>[
          new Expanded(
            child: new Container(
              child: new Padding(
                padding: const EdgeInsets.all(1.0),
                child: new Center(
                  child: _cameraPreviewWidget(),
                ),
              ),
              decoration: new BoxDecoration(
                color: Colors.black,
                border: new Border.all(
                  color: controller != null && controller.value.isRecordingVideo
                      ? Colors.redAccent
                      : Colors.grey,
                  width: 3.0,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showSettings(context);
        },
        tooltip: 'Settings',
        child: new Icon(Icons.settings),
      ),
    );
  }
}
