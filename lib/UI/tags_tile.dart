import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tags/Models/tags.dart';
import 'package:tags/pages/TagsPage/tags_page.dart';
import 'dart:async';

import 'leading_icon_tags_list.dart';


class TagsTile extends StatelessWidget {
  final Tags _tags;
  final String _distance;
  final bool _isNear;
  final bool _isFav;
  final GlobalKey<FormFieldState> _keyPassWord = GlobalKey<FormFieldState>();

  

  TagsTile(this._tags,this._distance,this._isNear,this._isFav);

  Widget _buildTextPassWordField(BuildContext context){
    return Center(
              child: Container(
              width: MediaQuery.of(context).size.width-80.0,
              child: TextFormField(     //TODO:Faire un formField pour le validator
                key: _keyPassWord,
                validator: (String input){
                  if(_tags.passWord!=input) return "mauvais mot de passe";
                },
                style: TextStyle(fontSize: 15.0,color: Colors.black),
                decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.deepOrange
                    )
                  ),
                  border: UnderlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.deepOrange),
                  labelText: "mot de passe"
                ),
                cursorColor: Colors.deepOrange,
                maxLength: 10,
                maxLengthEnforced: true,
                maxLines: 1,
                obscureText: true,
                keyboardType: TextInputType.text,
              ),
            ),
          );
  }

  Future<void> _buildPassWordDialog(BuildContext context,bool b){
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context){
        return AlertDialog(
            title: Text("entrez le mot de passe"),
            content: SizedBox(
              height: 50.0,
              child: _buildTextPassWordField(context),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("ok",style: TextStyle(fontSize: 20.0),),
                onPressed:() async{
                  if(_keyPassWord.currentState.validate()){
                    Navigator.of(context).pop();
                    _navigateTagsPage(context,b);
                  }
                } ,
              ),
            ],
        );
      }
    );
  }

  void _navigateTagsPage(BuildContext context,bool b){
      Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context){
                //TODO: on ouvre une boite de dialogue lorsque le tags n'est pas à porté
                return TagsPage(_tags,isFavAndNotNear: b);
              }
            )
          );
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:(){
        if(_tags.mode==PRIVATE_MODE && !_isFav){
                if(_isNear) _buildPassWordDialog(context, false);
                else {
                  if(_isFav) _buildPassWordDialog(context,true);
                  else return Container();
                }
              }
              else{
                if(_isNear) _navigateTagsPage(context,false);
                else {
                  if(_isFav) _navigateTagsPage(context,true);
                  else return Container();
                }
              }
      },
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
              child: LeadingIconTagsList(_isNear, _isFav, _distance),
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
            _tags.lastPostImageUrl==null?
            Expanded(
              child: Container(
                height:MediaQuery.of(context).size.width*0.2 ,
              ),
              flex: 1,
            )
            :
            Expanded(
              flex: 3,
              child: Container(
                width: MediaQuery.of(context).size.width*0.35,
                height: MediaQuery.of(context).size.width*0.35,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.horizontal(right: Radius.circular(15.0)),
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                    fit: _tags.lastPostImageWidth/_tags.lastPostImageHeight>=1.0 ? BoxFit.fitHeight:BoxFit.fitWidth,
                    image: CachedNetworkImageProvider(_tags.lastPostImageUrl)
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