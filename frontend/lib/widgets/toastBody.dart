import 'package:flutter/material.dart';

class ToastBody extends StatelessWidget {
  final IconData anyOther;
  final String msg;
  final bool error;

  const ToastBody(this.anyOther, this.msg, [this.error = false, Key? key]) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        color: error ? Colors.redAccent :Colors.greenAccent,
      ),
      child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [Icon(anyOther), const SizedBox(width: 6), Text(msg)]),
    );
  }
}
