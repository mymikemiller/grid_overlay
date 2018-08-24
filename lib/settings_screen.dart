import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class SettingsScreen extends StatefulWidget {
  final int columns;
  final int lineWidth;
  final Color lineColor;

  SettingsScreen({this.columns, this.lineWidth, this.lineColor});

  @override
  SettingsScreenState createState() {
    return new SettingsScreenState();
  }
}

class SettingsScreenState extends State<SettingsScreen> {
  TextEditingController _columnsController;
  TextEditingController _lineWidthController;

  Color pickerColor = new Color(0xff443a49);
  Color currentColor = new Color(0xff443a49);
  ValueChanged<Color> onColorChanged;

  // bind some values with [ValueChanged<Color>] callback
  changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  // Create a global key that will uniquely identify the Form widget and allow
  // us to validate the form
  //
  // Note: This is a `GlobalKey<FormState>`, not a GlobalKey<Settings>!
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _columnsController =
        new TextEditingController(text: widget.columns.toString());

    _lineWidthController =
        new TextEditingController(text: widget.lineWidth.toString());

    currentColor = widget.lineColor;
  }

  _saveSettings() async {
    // Save to shared preferences
    final prefs = await SharedPreferences.getInstance();

    int columns = int.parse(_columnsController.text);
    await prefs.setInt("columns", columns);

    int lineWidth = int.parse(_lineWidthController.text);
    await prefs.setInt("lineWidth", lineWidth);

    await prefs.setInt("lineColor", currentColor.value);
  }

  bool _validateNumber(String value) {
    int parsed = int.tryParse(value);
    return parsed != null && value.isNotEmpty;
  }

  void _saveAndClose() async {
    await _saveSettings();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Settings"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _saveAndClose();
                }
              },
            ),
          ],
        ),
        body: new Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text("Squares Across:"),
                  Expanded(
                    child: TextFormField(
                      controller: _columnsController,
                      validator: (value) {
                        if (!_validateNumber(value)) {
                          return 'Please enter a number';
                        }
                      },
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Text("Line Width:"),
                  Expanded(
                    child: TextFormField(
                      controller: _lineWidthController,
                      validator: (value) {
                        if (!_validateNumber(value)) {
                          return 'Please enter a number';
                        }
                      },
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              Center(
                child: RaisedButton(
                    child: Text("Line Color"),
                    elevation: 3.0,
                    onPressed: () {
                      pickerColor = currentColor;
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Pick a color!'),
                            content: SingleChildScrollView(
                              child: ColorPicker(
                                pickerColor: pickerColor,
                                onColorChanged: changeColor,
                                colorPickerWidth: 1000.0,
                                pickerAreaHeightPercent: 0.7,
                              ),
                            ),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('Got it'),
                                onPressed: () {
                                  setState(() => currentColor = pickerColor);
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    color: currentColor,
                    textColor: Colors.white),
              )
            ],
          ),
        ));
  }
}
