import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:url_launcher/url_launcher.dart';

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

  void _sendSupportEmail() async {
    const url = 'mailto:mikem.exe@gmail.com?subject=Grid%20Overlay';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _numericalField(
      {String title, Icon icon, TextEditingController controller}) {
    return ListTile(
      leading: icon,
      title: Row(
        children: <Widget>[
          Text(title),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: TextFormField(
                controller: controller,
                validator: (value) {
                  if (!_validateNumber(value)) {
                    return 'Please enter a number';
                  }
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: title,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _lineColorField() {
    return ListTile(
      leading: Icon(Icons.format_color_fill),
      title: Row(
        children: <Widget>[
          Text("Line Color:"),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: _lineColorButton(),
            ),
          ),
        ],
      ),
    );
  }

  RaisedButton _lineColorButton() {
    return RaisedButton(
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
                    child: Text('Choose'),
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
        textColor: Colors.white);
  }

  Widget _contactSupport() {
    return ListTile(
      leading: Icon(Icons.contact_mail),
      title: Row(
        children: <Widget>[
          Text("Contact Support:"),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: new InkWell(
                child: new Text(
                  "Send an Email",
                  style: new TextStyle(color: Colors.blue),
                ),
                onTap: _sendSupportEmail,
              ),
            ),
          ),
        ],
      ),
    );
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
          child: Column(
            children: <Widget>[
              _numericalField(
                  title: "Squares Across:",
                  icon: Icon(Icons.grid_on),
                  controller: _columnsController),
              _numericalField(
                  title: "Line Width:",
                  icon: Icon(Icons.line_weight),
                  controller: _lineWidthController),
              _lineColorField(),
              _contactSupport(),
            ],
          ),
        ));
  }
}
