import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final int columns;

  SettingsScreen({this.columns});

  @override
  SettingsScreenState createState() {
    return new SettingsScreenState();
  }
}

class SettingsScreenState extends State<SettingsScreen> {
  TextEditingController _columnsController;

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
  }

  _saveSettings() async {
    // Save to shared preferences
    final prefs = await SharedPreferences.getInstance();

    int columns = int.parse(_columnsController.text);

    await prefs.setInt("columns", columns);
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
                _saveSettings();

                Navigator.of(context).pop();
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
                  Text("Squares across:"),
                  Expanded(
                    child: TextFormField(
                      controller: _columnsController,
                      validator: (value) {
                        if (value.isEmpty) {
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
