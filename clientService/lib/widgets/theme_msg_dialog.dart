import 'package:flutter/material.dart';

class ThemeMsgDialog extends StatelessWidget {
  final _textFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Theme of your request'),
      content: TextField(
        controller: _textFieldController,
        decoration: InputDecoration(hintText: "Theme name"),
      ),
      actions: <Widget>[
        ElevatedButton(
          style: const ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(
              Color(0xFFe41f26),
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          style: const ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(
              Color(0xFFe41f26),
            ),
          ),
          onPressed: () {
            Navigator.pop(context, _textFieldController.text);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
