import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Bloc/main_bloc.dart';
import 'package:tags/Models/user.dart';
import 'package:tags/UI/circle_avatar_initiales.dart';
import 'package:tags/pages/UserProfilPages/chat_page.dart';
import 'package:tags/pages/other_user_post_grid.dart';



class OtherUserProfilePage extends StatefulWidget {
  _OtherUserProfilePageState createState() => _OtherUserProfilePageState();

  final User _user;

  OtherUserProfilePage(this._user);

}

class _OtherUserProfilePageState extends State<OtherUserProfilePage> {

  bool _shouldDisplayOverlay=false;

  Widget _buildTabs(){
    return SliverFillRemaining(
        child :Column(
          children: <Widget>[
            Divider(
              height: 1.0,
            ),
            SizedBox(height: 16.0,),   
            Expanded(
              child: OtherUserPostGrid(widget._user),
            )
          ],
        )
    );
  }

  Widget _displayOverlayImage(){
    CachedNetworkImageProvider userImage = CachedNetworkImageProvider(widget._user.photoUrl);
    return Material(
      color: Colors.black54,
      child: InkWell(
        child: Center(
          child: Image(image: userImage),
        ),
        onTap: (){
          setState(() {
            _shouldDisplayOverlay=!_shouldDisplayOverlay; 
          });
        },
      )
    );
  }

  String retrieveDicussionId(String id1,String id2){
    return id1.compareTo(id2)<0?  "$id1+$id2" : "$id2+$id1";
  }

  void _navigateChatPage(BuildContext context,User currentUser,User partner){
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:(BuildContext context){
          final String discussionId=retrieveDicussionId(currentUser.id, partner.id);
          return ChatPage(partner,discussionId);
        }
      )
    );

  }
 

  Widget _buildUserProfileColumn(BuildContext context){
    final MainBloc _mainBloc = BlocProvider.of<MainBloc>(context);
    final User currentUser =_mainBloc.currentUser;
    return Center(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: widget._user.photoUrl!=null?
               (){
                setState(() {
                  _shouldDisplayOverlay=!_shouldDisplayOverlay; 
                });
              }
              :
              null ,
              child:widget._user.photoUrl!=null ? 
              CircleAvatar(
                radius: MediaQuery.of(context).size.width*0.16,
                backgroundImage:  CachedNetworkImageProvider(widget._user.photoUrl),
              )
              :
              CircleAvatarInitiales(widget._user),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(widget._user.userName,style: TextStyle(fontSize: 25.0,fontWeight: FontWeight.bold),),
              currentUser.id!=widget._user.id?
               IconButton(
                icon: Icon(Icons.chat),
                onPressed: (){
                  _navigateChatPage(context,currentUser,widget._user);
                },
              )
              :Container()
            ],
          ),
          Text(widget._user.nom + " "+widget._user.prenom),
          Divider()
          ],
        ),
    );
  }


  Widget _buildSliverAppBar(BuildContext context){
    return 
        SliverAppBar( 
          pinned: true,
          elevation: 0.0,
          automaticallyImplyLeading: true,
          expandedHeight: MediaQuery.of(context).size.height*0.40,
          flexibleSpace: FlexibleSpaceBar(  
            background: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildUserProfileColumn(context),
                Text(widget._user.bio),
                SizedBox(height: 15.0),
              ],
           ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {

    return  Stack(
      children: <Widget>[
        Scaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              _buildSliverAppBar(context),
              _buildTabs(),
            ],
          ),
        ),
        _shouldDisplayOverlay? _displayOverlayImage():Container(),
      ],
    );
  }
}