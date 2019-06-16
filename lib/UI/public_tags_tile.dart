import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tags/Models/tags.dart';
import 'package:tags/UI/leading_icon_tags_list.dart';



class PublicTagsTile extends StatelessWidget {

  final Tags _tags;
  final String _distance;
  final bool _isNear;
  final bool _isFav;
  final Function _onTagsTap;

  PublicTagsTile(this._tags,this._distance,this._isFav,this._isNear,this._onTagsTap);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTap: _onTagsTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0)
        ),
        elevation: 5.0,
        margin: EdgeInsets.symmetric(horizontal: 8.5,vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(
              width: 10.0,
            ),
            Expanded(
              flex: 1,
              child: Container(),
            ),
            Expanded(
              flex: 4,
              child: Column(
                children: <Widget>[
                  Text(_tags.name,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17.0),),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text("${_tags.nbPost} posts et ${_tags.nbMessage} messages",style: TextStyle(fontSize: 12.0),),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                width: MediaQuery.of(context).size.width*0.35,
                height: MediaQuery.of(context).size.width*0.35,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.horizontal(right: Radius.circular(15.0)),
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                    fit: BoxFit.fitHeight,
                    image: AssetImage("lib/assets/selfie_dummy.jpg")
                  )
                ),
              )
            )
          ],
        ),
      ),
    );
  }

}