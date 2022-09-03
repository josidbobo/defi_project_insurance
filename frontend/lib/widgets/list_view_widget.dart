import 'package:flutter/material.dart';

class ScrollableW extends StatelessWidget {
  final String mainText;
  final String subText;
  final Widget iconImage;

  ScrollableW({
    Key? key, 
    required this.mainText, 
    required this.subText, 
    required this.iconImage}) : super(key: key);
  

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 350,
      width: 350,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 187, width: 180,
                child: ClipRRect(clipBehavior: Clip.hardEdge ,child: iconImage)),
            ],
          ),
          const SizedBox(height: 13,),
          Text(mainText, style: Theme.of(context).textTheme.headline2!.copyWith(fontSize: 19),),
          const SizedBox(height: 8,),
          Text(subText, style: TextStyle(color: Colors.grey[600],), textAlign: TextAlign.center)
        ]
      ),
    );
  }
}
