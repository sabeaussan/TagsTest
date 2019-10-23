import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Bloc/main_bloc.dart';
import 'package:tags/Models/user.dart';
import 'package:tags/UI/circle_avatar_initiales.dart';
import 'package:tags/pages/UserProfilPages/chat_page.dart';
import 'package:tags/pages/other_user_post_grid.dart';



class OtherUserProfilePage extends StatelessWidget {

  final User _user;

  OtherUserProfilePage(this._user);


  Widget _buildTabs(List<DocumentSnapshot> userPosts){
    return OtherUserPostGrid(userPosts);
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

  Widget _buildUserProfileColumn(BuildContext context,int nbPosts){
     const IconData chat = const IconData(0xf38d,
          fontFamily: CupertinoIcons.iconFont,
          fontPackage: CupertinoIcons.iconFontPackage); 
    final MainBloc _mainBloc = BlocProvider.of<MainBloc>(context);
    final User currentUser =_mainBloc.currentUser;
    return Expanded(
      flex: 0,
      child: Center(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height*0.28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(bottom: Radius.elliptical(150.0,30.0)),
              color: Colors.red,
              shape: BoxShape.rectangle
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
              SizedBox(
                width: 10.0,
              ),
              Expanded(
                flex: 1,
                child: _user.photoUrl!=null ? 
                CircleAvatar(
                  radius: MediaQuery.of(context).size.width*0.16,
                  backgroundImage:  CachedNetworkImageProvider(_user.photoUrl),
                )
                :
                CircleAvatarInitiales(_user),
              ),
            
            SizedBox(
              width: 12.0,
            ),
              Expanded(
                flex:2,
                child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      textBaseline: TextBaseline.alphabetic,
                      children: <Widget>[
                        Flex(
                          direction: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                          Flexible(
                            flex: 4,
                            child: Text(_user.userName,style: TextStyle(fontSize: 25.0,fontWeight: FontWeight.bold,color: Colors.white),),
                           ),
                          Flexible(
                            fit: FlexFit.loose,
                            flex: 0,
                            child: currentUser.id!=_user.id?
                              IconButton(
                                icon: Icon(chat,color: Colors.white,),
                                onPressed: (){
                                  _navigateChatPage(context,currentUser,_user);
                                },
                              )
                              :Container(),
                         ),
                        ],),
                        Text(_user.nom + " "+_user.prenom,style: TextStyle(color: Colors.white),),
                        SizedBox(
            height: 15.0,
          ),
          Row(
            children: <Widget>[
              SizedBox(
                width: 20.0,
              ),
              Column(
                children: <Widget>[
                  Text(nbPosts.toString(),style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.w500,color: Colors.white),),
                  Text("Posts",style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.w500,color: Colors.white),)
                ],
              ),
              SizedBox(
                width: 20.0,
              ),
              Column(
                children: <Widget>[
                  Text(currentUser.nbMarks.toString(),style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.w500,color: Colors.white),),
                  Text("Marks",style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.w500,color: Colors.white),)
                ],
              ),
              /*SizedBox(
                width: 9.0,
              ),
              IconButton(
                icon: Icon(Icons.edit,color: Colors.white,),
              )*/
            ],
          )
                      ],
                    ),
              ),  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<QuerySnapshot>(
        future: Firestore.instance.collection("User").document(_user.id).collection("UserPost").getDocuments(),
        builder: (context, userPostSnapshot) {
          if(userPostSnapshot.data==null){
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final int nbPosts = userPostSnapshot.data.documents.length;
          return Column(
              children: <Widget>[
                _buildUserProfileColumn(context,nbPosts),
                SizedBox(
                  height: 10.0,
                ),
                Container(
                  child: Text(_user.bio),
                  margin: EdgeInsets.all(10.0),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Expanded(
                  flex: 3,
                  child: _buildTabs(userPostSnapshot.data.documents),
                )
              ],
            );
        }
      )
    );
  }
}