import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  final int columns;

  Settings({this.columns});

  @override
  SettingsState createState() {
    return new SettingsState();
  }
}

class SettingsState extends State<Settings> {
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
                int columns = int.parse(_columnsController.text);
                print("Changing to $columns squares across");
                Navigator.of(context).pop(columns);
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
