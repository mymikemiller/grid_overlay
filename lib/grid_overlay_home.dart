import 'grid_painter.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

class GridOverlayHome extends StatefulWidget {
  final CameraDescription camera;

  GridOverlayHome({this.camera}) {
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
  int lineWidth = 2;
  Color lineColor = new Color(0xFFFFFFFF);

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  initState() {
    super.initState();
    _applyPrefs();
  }

  void _applyPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    // Read the settings ;from shared preferences
    final newColumns = prefs.getInt('columns') ?? null;
    final newLineWidth = prefs.getInt('lineWidth') ?? null;
    final newLineColorValue = prefs.getInt('lineColor') ?? null;

    if (newColumns != null &&
        newLineWidth != null &&
        newLineColorValue != null) {
      setState(() {
        this.columns = newColumns;
        this.lineWidth = newLineWidth;

        final newLineColor = Color(newLineColorValue);
        this.lineColor = newLineColor;
      });
    }
  }

  _GridOverlayHomeState(CameraDescription camera) {
    if (camera != null) {
      onNewCameraSelected(camera);
    }
  }

  // Launch the Settings screen and awaits the result from Navigator.pop
  _showSettings(BuildContext context) async {
    // Navigator.push returns a Future that will complete after we call
    // Navigator.pop on the Settings Screen
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => new SettingsScreen(
              columns: this.columns,
              lineWidth: this.lineWidth,
              lineColor: this.lineColor,
            )));

    _applyPrefs();
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'No camera found',
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
                gridColor: lineColor,
                strokeWidth: lineWidth.toDouble(),
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
      body: new Stack(
        children: <Widget>[
          // Stock photo widget (For taking screenshots)
          Positioned.fill(
            child: new DecoratedBox(
              decoration: new BoxDecoration(
                image: new DecorationImage(
                    image: new AssetImage('images/sculpture1.jpg'),
                    fit: BoxFit.cover),
              ),
            ),
          ),

          // Grid widget
          new Positioned.fill(
            child: new CustomPaint(
              painter: new GridPainter(
                columns: columns,
                gridColor: lineColor,
                strokeWidth: lineWidth.toDouble(),
              ),
            ),
          ),

          //Camera widget
          // new Container(
          //   child: new Padding(
          //     padding: const EdgeInsets.all(1.0),
          //     child: new Center(
          //       child: _cameraPreviewWidget(),
          //     ),
          //   ),
          //   decoration: new BoxDecoration(
          //     color: Colors.black,
          //     border: new Border.all(
          //       color: controller != null && controller.value.isRecordingVideo
          //           ? Colors.redAccent
          //           : Colors.grey,
          //       width: 3.0,
          //     ),
          //   ),
          // ),
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
