import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Bloc/main_bloc.dart';
import 'package:tags/Models/user.dart';
import 'package:tags/UI/notif_icon.dart';
import 'package:tags/UI/post_tile.dart';
import 'package:tags/UI/user_circle_avatar.dart';
import 'package:tags/Utils/firebase_db.dart';

import 'other_user_profile_page.dart';

class LikePage extends StatefulWidget {

  final PostTile _likedPost;
  final bool _hideNotifs;

  LikePage(this._likedPost,this._hideNotifs);

  @override
  _LikePageState createState() => _LikePageState();
}

class _LikePageState extends State<LikePage> {

  User currentUser;

  void _navigateOtherUserProfilePage(BuildContext context,String likerId) async{
    final User user = await db.getUser(likerId);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context){
          return OtherUserProfilePage(user);
        }
      )
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final MainBloc _mainBloc = BlocProvider.of<MainBloc>(context);
    currentUser =_mainBloc.currentUser;
  }

  @override
  void dispose() {
    final String postOwnerId = widget._likedPost.ownerId;
    final int nbLikessNotSeen = widget._likedPost.nbLikesNotSeen;
    final String postId = widget._likedPost.id;
    final String markId =  widget._likedPost.tagsId;
    if(nbLikessNotSeen!=0 && postOwnerId==currentUser.id && !widget._hideNotifs){
      db.resetNbNotSeen(postId, markId,"nbLikesNotSeen");
      db.updateLikeUserPost(currentUser.id, postId, null, true);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(widget._hideNotifs);
    final List<dynamic> likers = widget._likedPost.likers;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Aimer par",)
      ),
      body: ListView.builder(
        itemCount: likers.length,
        itemBuilder: (BuildContext context, int index){
          dynamic info = likers[index];
          final String likerId = info.keys.single;
          final String likerUserName = info.values.single;
          return ListTile(
            onTap: (){
              _navigateOtherUserProfilePage(context,likerId);
            },
            trailing: index < widget._likedPost.nbLikesNotSeen && !widget._hideNotifs ? NotifIcon(19.0,9.5) : Container(width: 0.0,height: 0.0,),
            leading: UserCircleAvatar(likerUserName, likerId),
            title: Text(likerUserName),
          );
        },
      ),
    );
  }
}