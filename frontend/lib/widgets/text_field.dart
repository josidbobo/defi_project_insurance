import 'package:flutter/material.dart';

class TextView extends StatelessWidget {
  final TextEditingController controller;
  final String text;

  const TextView({
    Key? key,
    required this.text,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: TextField(
        decoration: InputDecoration(
            alignLabelWithHint: true,
            hintText: text,
            hintStyle: const TextStyle(fontSize: 15),
            border: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black54),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Colors.black54),
            )),
        autocorrect: true,
        controller: controller,
        showCursor: true,
        cursorWidth: 1,
        cursorColor: Colors.black,
      ),
    );
  }
}
