import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tags/Models/publicmark.dart';
import 'package:tags/pages/TagsPage/tags_page.dart';

import 'leading_icon_tags_list.dart';


class TagsTile extends StatelessWidget {
  final PublicMark _mark;
  TagsTile(this._mark);

  void _navigateTagsPage(BuildContext context,bool b){
    Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context){
        //TODO: on ouvre une boite de dialogue lorsque le tags n'est pas à porté
        return TagsPage(_mark,isFavAndNotNear: b);
        }
    ));
  }

  void _navigation(BuildContext context){
    final PublicMark mark = _mark;
    if(mark.isNear)_navigateTagsPage(context, false);
    else{
      if(mark.isFav || mark.isPopular) _navigateTagsPage(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:(){
        _navigation(context);
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0)
        ),
        elevation: 20.0,
        margin: EdgeInsets.symmetric(horizontal: 25,vertical: 12.0),
        child: _mark.lastPostImageUrl==null? 
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
              LeadingIconTagsList(_mark,Colors.red,Colors.black),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(_mark.name,style: TextStyle(fontWeight: FontWeight.w600,fontSize: 20.0,color: Colors.black)),
                  SizedBox(
                    height: 13.0,
                  ),
                  Text("${_mark.nbPost} posts et ${_mark.nbMessage} messages",style: TextStyle(fontSize: 13.0,color:Colors.black),),
                  SizedBox(
                    height: 10.0,
                  ),
                ],
              ),
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
                    fit: _mark.lastPostImageWidth/_mark.lastPostImageHeight>=1.0 ? BoxFit.fitHeight:BoxFit.fitWidth,
                    image: CachedNetworkImageProvider(_mark.lastPostImageUrl)
                  )
                ),
              ),
              Positioned(
                child: LeadingIconTagsList(_mark,Colors.white70,Colors.white70),
                right: 15.0,
                top: 10.0,
              ),
              Positioned(
                child: Text(_mark.name,style: TextStyle(fontWeight: FontWeight.w800,fontSize: 25.0,color: Colors.white)),
                top: 40.0,
                left: 15.0,
              ),
              Positioned(
                child: Container(
                  width: MediaQuery.of(context).size.width-60,
                  child: Text(_mark.description,style: TextStyle(fontWeight: FontWeight.w600,fontSize: 17.0,color: Colors.white.withOpacity(0.9))),
                ),
                bottom: 35.0,
                left: 25.0,
              ),
              Positioned(
                top: 15.0,
                left: 15.0,
                child: Text("${_mark.nbPost} posts et ${_mark.nbMessage} messages",style: TextStyle(fontSize: 15.0,color:Colors.white),),
              )
                ],
              ),
      ),
    );
  }
}