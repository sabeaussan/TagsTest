
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Bloc/main_bloc.dart';
import 'package:tags/Models/user.dart';

import 'package:tags/UI/user_circle_avatar.dart';
import 'package:tags/Utils/firebase_db.dart';

import 'package:tags/pages/comments_page.dart';

  const int GALLERY=0;
  const int COMMENT=1;
  const int FAVORITE=2;
  const int EDIT=3;

class PostTile extends StatefulWidget {


  int _type;
  final String _id;
  final String _userNamePost;
  final String _tagsName;
  final String _tagsId;
  final String _ownerId;
  final String _description;
  final String _timeStamp;
  final int _nbComments;
  final int _nbLikes;
  final int _imageWidth;
  final int _imageHeight;
  final String _imageUrl;


  String get id => _id;
  String get tagsName => _tagsName;
  String get tagsId => _tagsId;
  String get ownerId => _ownerId;
  String get imageUrl => _imageUrl;
  
  void setType(int postType){
    this._type=postType;
  }

  PostTile.fromDocumentSnaptshot(DocumentSnapshot snapshot):
    _id=snapshot.documentID,
    _type=snapshot.data["type"],
    _timeStamp=snapshot.data["timeStamp"],
    _userNamePost=snapshot.data["userName"],
    _tagsName=snapshot.data["tagsName"],
    _tagsId=snapshot.data["tagsId"],
    _imageUrl=snapshot.data["imageUrl"],
    _description=snapshot.data["description"],
    _nbComments=snapshot.data["nbComments"],
    _ownerId=snapshot.data["ownerId"],
    _nbLikes=snapshot.data["nbLikes"],
    _imageWidth=snapshot.data["imageWidth"],
    _imageHeight=snapshot.data["imageHeight"];
  


  @override
  PostTileState createState() {
    return new PostTileState();
  }
}

class PostTileState extends State<PostTile> with AutomaticKeepAliveClientMixin  {
  bool _isLiked;
  UserCircleAvatar _userCircleAvatar;
  User currentUser;



  @override
  void initState() {
    super.initState();
    _userCircleAvatar=UserCircleAvatar(widget._userNamePost,widget._ownerId);
    final MainBloc _mainBloc = BlocProvider.of<MainBloc>(context);
    currentUser =_mainBloc.currentUser;
    _isLiked =getFavStatus(currentUser);
  }

  bool getFavStatus(User user){
    if(user.favPostId!=null) return user.favPostId.contains(widget.id);
     return false;
  }
  


  @override
  Widget build(BuildContext context) {
    final double aspectRatio =widget._imageWidth/widget._imageHeight;
    return Column(
      children: <Widget>[
        _tileHeader(context,currentUser),
        AspectRatio(
          aspectRatio:aspectRatio>0.83? aspectRatio: 0.83,
            child:Center(
              child:CachedNetworkImage(
                width:MediaQuery.of(context).size.width ,
                alignment:FractionalOffset.topCenter,
                imageUrl: widget._imageUrl,
                placeholder:Container(
                        child: CircularProgressIndicator(),
                    ),
                fit: BoxFit.fitWidth ,
                )
            ,)
          ),
        _tileBottom(),
        Divider(color: Colors.deepOrange,)
      ],
    );
  }

  void updateLikeCount(){
    final MainBloc _mainBloc = BlocProvider.of<MainBloc>(context);
    final User currentUser =_mainBloc.currentUser;
    if(_isLiked){
      db.updateOldPost(widget.id, widget._tagsId, "nbLikes", 1);
      db.updateOldUserFav(currentUser, widget.id, 1);
    }
    else{
      db.updateOldPost(widget.id, widget._tagsId, "nbLikes", -1);
      db.updateOldUserFav(currentUser, widget.id, -1);
    }
  }


  Widget _tileHeader(BuildContext context,User currentUser) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(int.parse(widget._timeStamp));
    return ListTile(
      onTap:_toggleFavIcon,
      subtitle: widget._type==COMMENT? Text(widget._tagsName) : Text("${formatDate(date,[dd, '-', mm, '-', yyyy ])}"),
      leading:_userCircleAvatar,
      title: Text(widget._userNamePost,style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold)),
      trailing: !(widget._type==EDIT)? Container(width: MediaQuery.of(context).size.width*0.30,
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Column(
              mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _isLiked?
                  Icon(Icons.favorite,size: 28.0,color: Colors.deepOrange,)
                  :
                  Icon(Icons.favorite_border,size: 28.0,color: Colors.black54),
                  Text("${widget._nbLikes}",style: TextStyle(fontSize: 13.0,fontWeight: FontWeight.bold,color: Colors.black54),)
                ],
              ),
              SizedBox(width: 30.0,),
              PopupMenuButton<String>(
                onSelected: (String choice){
                  if(choice=="supprimer"){
                    db.deletePostFireStore(this.widget);
                  }
                },
                itemBuilder: (BuildContext context){
                  if(currentUser.id==widget._ownerId){
                  return [
                    PopupMenuItem(
                      child: Text("signaler"),
                      value: "signaler" ,
                    ),
                    PopupMenuItem(
                      child: Text("partager"),
                      value: "partager" ,
                    ),
                    
                    PopupMenuItem(
                      value: "supprimer",
                      child: Text("supprimer"),
                    )
                    ];
                  }
                  return [
                    PopupMenuItem(
                      child: Text("signaler"),
                      value: "signaler" ,
                    ),
                    PopupMenuItem(
                      child: Text("partager"),
                      value: "partager" ,
                    ),
                  ];
                },
                child: Icon(Icons.more_vert),
              )
          ],) ,
    ):Container(height: 0.0,width: 0.0,));
  }

  void _toggleFavIcon(){
    setState(() {
      _isLiked=!_isLiked;
      updateLikeCount();
    });
  }

  ListTile _tileBottom(){
    return ListTile(
      title: Text(widget._description),
      trailing: widget._type==GALLERY? Column(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.comment,color: Colors.black,),
            onPressed: (){
              Navigator.of(context).push(
                MaterialPageRoute(builder:(BuildContext context) {
                  return CommentsPage(this.widget);
                })
              );
            },
            ),
          Text("${widget._nbComments}")
        ],
      ):Container(width: 0.0,height: 0.0,),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}