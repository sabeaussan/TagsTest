import 'package:flutter/material.dart';

import 'notif_icon.dart';


class StackedNotifWidget extends StatelessWidget {

  final Widget _child;
  final double _iconSize;
  final double _radius;

  StackedNotifWidget(this._child,this._iconSize,this._radius);

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: <Widget>[
        _child,
        NotifIcon(_iconSize,_radius),
      ],
    );
  }


}