import 'package:flutter/material.dart';

class TextView extends StatefulWidget {
  final TextEditingController controller;
  final String text;
  
  TextView({Key? key,
    required this.text,
    required this.controller,}) : super(key: key);

  @override
  State<TextView> createState() => _TextViewState();
}

class _TextViewState extends State<TextView> {

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: TextField(
        onSubmitted: (_) => widget.controller.clear(),
        decoration: InputDecoration(
            alignLabelWithHint: true,
            hintText: widget.text,
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
        controller: widget.controller,
        showCursor: true,
        cursorWidth: 1,
        cursorColor: Colors.black,
      ),
    );
  }
}
