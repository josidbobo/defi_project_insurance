import "package:flutter/material.dart";

class CircularProgress extends StatelessWidget {
  const CircularProgress(
      {Key? key, this.materialStrokeWidth = 3.5, this.height, this.color})
      : super(key: key);

  final double? height;
  final double materialStrokeWidth;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 8,
      width: 10,
      child: Center(
        child: AspectRatio(
            aspectRatio: 1.0,
            child: CircularProgressIndicator(
              color: color ?? Colors.white,
              strokeWidth: materialStrokeWidth,
            )),
      ),
    );
  }
}
