import 'package:flutter/material.dart';
import 'package:tags/Models/publicmark.dart';


class LeadingIconTagsList extends StatelessWidget {
  final Color _iconColorPrimary;
  final Color _iconColorSecondary;
  final PublicMark _mark;

  LeadingIconTagsList(this._mark,this._iconColorPrimary,this._iconColorSecondary);

  @override
  Widget build(BuildContext context) {
    return _mark.isFav?
              Padding(
              child: Icon(Icons.star,size: 27.0, color: _iconColorPrimary),
              padding: EdgeInsets.only(right: 10.0)
              )
              :
            _mark.isNear? 
                Padding(
                  child: Icon(Icons.check_circle_outline,size: 27.0, color: _iconColorPrimary),
                  padding: EdgeInsets.only(right: 10.0)
                ):
                Column(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.near_me,size: 27.0,color: _iconColorSecondary),
                      onPressed: (){}
                    ),
                    Text(_mark.distanceLabel+" m",style: TextStyle(fontSize: 10.0,color: _iconColorSecondary),)
                  ],
                );
  }



}