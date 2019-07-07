import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tags/Models/tags.dart';
import 'package:tags/pages/TagsPage/tags_page.dart';
import 'dart:async';

import 'leading_icon_tags_list.dart';


class TagsTile extends StatefulWidget {
  final Tags _tags;
  final String _distance;



  final bool _isFavPage;

  TagsTile(this._tags,this._distance,this._isFavPage);

  @override
  _TagsTileState createState() => _TagsTileState();
}

class _TagsTileState extends State<TagsTile> {
  final GlobalKey<FormFieldState> _keyPassWord = GlobalKey<FormFieldState>();
  bool _isNear=true;

  Widget _buildTextPassWordField(BuildContext context){
    return Center(
              child: Container(
              width: MediaQuery.of(context).size.width-80.0,
              child: TextFormField(     //TODO:Faire un formField pour le validator
                key: _keyPassWord,
                validator: (String input){
                  if(widget._tags.passWord!=input) return "mauvais mot de passe";
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
    print(b);
      Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context){
                //TODO: on ouvre une boite de dialogue lorsque le tags n'est pas à porté
                return TagsPage(widget._tags,isFavAndNotNear: b);
              }
            )
          );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void _isMarkNear(){
    if(widget._tags.distance<0){
      _isNear=true;
    }
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      //TODO: a revoir il y a clairement un problème!!!!
      onTap:(){
        if(widget._isFavPage) _navigateTagsPage(context,true);
        else{
          if(widget._tags.mode==PRIVATE_MODE){
                if(_isNear) _buildPassWordDialog(context, false);
                else {
                  if(widget._tags.favStatus) _buildPassWordDialog(context,true);
                  else return Container();
                }
        }
          else{
            if(_isNear) _navigateTagsPage(context,false);
            else {
              if(widget._tags.favStatus) _navigateTagsPage(context,true);
              else return Container();
            }
          }
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0)
        ),
        elevation: 20.0,
        margin: EdgeInsets.symmetric(horizontal: 25,vertical: 12.0),
        child: widget._tags.lastPostImageUrl==null? 
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            //Expanded(
              //flex: 2,
               LeadingIconTagsList(_isNear, widget._tags.favStatus, widget._distance,Colors.red,Colors.black),
            //),
            //Expanded(
              //flex: 2,
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(widget._tags.name,style: TextStyle(fontWeight: FontWeight.w600,fontSize: 20.0,color: Colors.black)),
                  SizedBox(
                    height: 13.0,
                  ),
                  Text("${widget._tags.nbPost} posts et ${widget._tags.nbMessage} messages",style: TextStyle(fontSize: 13.0,color:Colors.black),),
                  SizedBox(
                    height: 10.0,
                  ),
                ],
              ),
            //),
            SizedBox(
                    width: MediaQuery.of(context).size.width*0.13,
                  ),
          ],
        )
        :
        Stack(
          children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width-40,
                height: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                    fit: widget._tags.lastPostImageWidth/widget._tags.lastPostImageHeight>=1.0 ? BoxFit.fitHeight:BoxFit.fitWidth,
                    image: CachedNetworkImageProvider(widget._tags.lastPostImageUrl)
                  )
                ),
              ),
              Positioned(
                child: LeadingIconTagsList(_isNear, widget._tags.favStatus, widget._distance,Colors.white70,Colors.white70),
                right: 15.0,
                top: 10.0,
              ),
              Positioned(
                child: Text(widget._tags.name,style: TextStyle(fontWeight: FontWeight.w600,fontSize: 22.0,color: Colors.white)),
                bottom: 25.0,
                left: 25.0,
              ),
              Positioned(
                top: 15.0,
                left: 15.0,
                child: Text("${widget._tags.nbPost} posts et ${widget._tags.nbMessage} messages",style: TextStyle(fontSize: 15.0,color:Colors.white),),
              )
                ],
              ),
      ),
    );
  }
}