import 'package:flutter/material.dart';


class NotifIcon extends StatelessWidget{

  final double _iconSize;
  final double _radius;

  NotifIcon(this._iconSize,this._radius);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return CircleAvatar(
      child: Center(child: Icon(Icons.error,size: _iconSize,color:Colors.red),),
      backgroundColor: Color(0xFFF8F8F8),
      radius: _radius,
    );
  }


}