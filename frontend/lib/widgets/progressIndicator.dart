import "package:flutter/material.dart";

class CircularProgress extends StatelessWidget {
  const CircularProgress({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 4,
      width: 5,
      child: const CircularProgressIndicator()
    );
  }
}