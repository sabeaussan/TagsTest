import 'package:flutter/material.dart';


class LeadingIconTagsList extends StatelessWidget {
  final bool _isNear;
  final bool _isFav;
  final String _distance;
  final Color _iconColorPrimary;
  final Color _iconColorSecondary;

  LeadingIconTagsList(this._isNear,this._isFav,this._distance,this._iconColorPrimary,this._iconColorSecondary);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return _isFav?
              Padding(
              child: Icon(Icons.star,size: 27.0, color: _iconColorPrimary),
              padding: EdgeInsets.only(right: 10.0)
              )
              :
            _isNear? 
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
                    Text(_distance+" m",style: TextStyle(fontSize: 10.0,color: _iconColorSecondary),)
                  ],
                );
  }



}