import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final int columns;
  final int lineWidth;

  SettingsScreen({this.columns, this.lineWidth});

  @override
  SettingsScreenState createState() {
    return new SettingsScreenState();
  }
}

class SettingsScreenState extends State<SettingsScreen> {
  TextEditingController _columnsController;
  TextEditingController _lineWidthController;

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
  }

  _saveSettings() async {
    // Save to shared preferences
    final prefs = await SharedPreferences.getInstance();

    int columns = int.parse(_columnsController.text);
    await prefs.setInt("columns", columns);

    int lineWidth = int.parse(_lineWidthController.text);
    await prefs.setInt("lineWidth", lineWidth);
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
              )
            ],
          )),
    );
  }
}
