
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Bloc/main_bloc.dart';
import 'package:tags/Models/post.dart';
import 'package:tags/Models/user.dart';
import 'package:tags/UI/clickable_text.dart';
import 'package:tags/UI/notif_icon.dart';
import 'package:tags/UI/stacked_notif.dart';

import 'package:tags/UI/user_circle_avatar.dart';
import 'package:tags/Utils/firebase_db.dart';

import 'package:tags/pages/comments_page.dart';

import 'package:tags/UI/postTileBottom.dart';
import 'package:tags/pages/like_page.dart';

  // Constante définissant le mode pour l'affichage du post
  // - GALLERY : défaut
  // - COMMENT : icone de comment non affiché
  // - EDIT : pas d'icone like, pas d'icone comment et textEdit en dessous de l'image 
  const int GALLERY=0;
  const int COMMENT=1;
  const int EDIT=2;

class PostTile extends StatefulWidget {


  int type;
  bool lastLikeSeen;
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
  final List<dynamic> _likers;
  final int _nbLikesNotSeen;
  final int _nbCommentsNotSeen;


  String get id => _id;
  String get tagsName => _tagsName;
  String get tagsId => _tagsId;
  String get ownerId => _ownerId;
  String get imageUrl => _imageUrl;
  int get nbCommentsNotSeen => _nbCommentsNotSeen;
  int get nbLikesNotSeen => _nbLikesNotSeen;
  List<dynamic> get likers => _likers;
  
  void setType(int type){
    this.type = type;
  }

  PostTile.fromDocumentSnaptshot(DocumentSnapshot snapshot,{this.lastLikeSeen,Key key}):
    _id=snapshot.documentID,
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
    _imageHeight=snapshot.data["imageHeight"],
    _likers = snapshot.data["likers"],
    _nbLikesNotSeen = snapshot.data["nbLikesNotSeen"],
    _nbCommentsNotSeen = snapshot.data["nbCommentsNotSeen"],
    super(key:key);


  PostTile.fromPost(Post post):
    _id=post.id,
    _timeStamp=post.timeStamp,
    _userNamePost=post.creator.userName,
    _tagsName=post.tagOwner.name,
    _tagsId=post.tagOwner.id,
    _imageUrl=post.imageUrl,
    _description=post.description,
    _nbComments=0,
    _ownerId=post.creator.id,
    _nbLikes= 0,
    _imageWidth=post.imageWidth,
    _imageHeight=post.imageHeight,
    _likers = [],
    _nbLikesNotSeen = 0,
    _nbCommentsNotSeen = 0;


  @override
  PostTileState createState() {
    return new PostTileState();
  }
}

class PostTileState extends State<PostTile> with AutomaticKeepAliveClientMixin  {
  bool _isLiked;
  UserCircleAvatar _userCircleAvatar;
  User currentUser;
  int nbLikes;



  @override
  void initState() {
    super.initState();
    _userCircleAvatar=UserCircleAvatar(widget._userNamePost,widget._ownerId,key: ValueKey(widget.id));
    final MainBloc _mainBloc = BlocProvider.of<MainBloc>(context);
    currentUser =_mainBloc.currentUser;
    _isLiked =getFavStatus(currentUser) || currentUser.id==widget._ownerId;
    nbLikes = widget._nbLikes;
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
                placeholder: (context,ur){
                  return Container(
                    child: CircularProgressIndicator(),
                  ); 
                },
                fit: BoxFit.fitWidth ,
                )
            ,)
          ),
        PostTileBottom(widget._description, widget._nbComments, _navigateCommentPage,widget.type),
        Divider(color: Colors.red,)
      ],
    );
  }

  void updateLikeCount() async {
    await db.updateLikesPost(widget.id, widget._tagsId,currentUser);
    await db.updateUserFavPost(currentUser, widget.id, 1);
    if(widget._nbLikesNotSeen==0) await db.updateLikeUserPost(widget._ownerId, widget._id,currentUser.userName,false);
    nbLikes = widget._nbLikes+1;
  }


  Widget _tileHeader(BuildContext context,User currentUser) {
    if(widget.lastLikeSeen==null) widget.lastLikeSeen=true; // On ne vient pas de la UserProfilePage
    DateTime date = DateTime.fromMillisecondsSinceEpoch(int.parse(widget._timeStamp));
    return ListTile(
      onTap:!_isLiked? _toggleFavIcon:null,
      subtitle: widget.type==COMMENT? Text(widget._tagsName) : Text("${formatDate(date,[dd, '-', mm, '-', yyyy ])}"),
      leading:_userCircleAvatar,
      title: ClickableWidget(
        Text(widget._userNamePost,style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold)), 
        widget._ownerId
        ),
      trailing: !(widget.type==EDIT)? Container(width: MediaQuery.of(context).size.width*0.30,
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Column(
              mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _isLiked?
                  Icon(Icons.favorite,size: 28.0,color: Colors.red,)
                  :
                  Icon(Icons.favorite_border,size: 28.0,color: Colors.black54),
                  Text("$nbLikes",style: TextStyle(fontSize: 13.0,fontWeight: FontWeight.bold,color: Colors.black54),)
                ],
              ),
              SizedBox(width: 30.0,),
              PopupMenuButton<String>(
                onSelected: (String choice){
                  switch(choice){
                    case "supprimer":
                      db.deletePostFireStore(this.widget);
                      break;
                    case "like":
                      _navigateLikePage();
                  }
                },
                itemBuilder: (BuildContext context){
                  if(currentUser.id==widget._ownerId){
                  return [
                    /*PopupMenuItem(
                      child: Text("signaler"),
                      value: "signaler" ,
                    ),*/
                    PopupMenuItem(
                      child: widget.lastLikeSeen?
                      Text("aimer par")
                      :
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("aimer par"),
                          NotifIcon(18.0,9.0)
                        ],
                      ),
                      value: "like" ,
                    ),
                    /*PopupMenuItem(
                      value: "supprimer",
                      child: Text("supprimer"),
                    )*/
                    ];
                  }
                  return [
                    /*PopupMenuItem(
                      child: Text("signaler"),
                      value: "signaler" ,
                    ),*/
                    PopupMenuItem(
                      child: Text("aimer par"),
                      value: "like" ,
                    ),
                  ];
                },
                child: widget.lastLikeSeen? Icon(Icons.more_vert,size: 35.0,) : StackedNotifWidget(Icon(Icons.more_vert,size: 35.0,),17.0,8.5),
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

  void _navigateCommentPage(){
    Navigator.of(context).push(
      MaterialPageRoute(builder:(BuildContext context) {
        this.widget.setType(COMMENT);
        return CommentsPage(this.widget);
      })
    );
  }

  void _navigateLikePage(){
    Navigator.of(context).push(
      MaterialPageRoute(builder:(BuildContext context) {
        return LikePage(this.widget,widget.lastLikeSeen==true);
      })
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}