import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Bloc/main_bloc.dart';
import 'package:tags/Models/userPost.dart';
import 'package:tags/UI/notif_icon.dart';

import 'package:tags/UI/post_tile.dart';
import 'package:tags/pages/comments_page.dart';


class PostGrid extends StatelessWidget {

  //TODO: faire un futureBuilder ou stbld



  PostGrid();

  void _navigateCommentsPage(BuildContext context,UserPost userPost) async {
    DocumentSnapshot postSnap = await Firestore.instance.collection("Tags").document(userPost.tagOwnerId).collection("TagsPost").document(userPost.id).get();
    print(" ######## DEBUG _navigateCommentsPage ########");
    print(postSnap.documentID);
    print(postSnap.data["userName"]);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context)  {
          PostTile postFromTagsPost =  PostTile.fromDocumentSnaptshot(postSnap,lastLikeSeen: userPost.lastLikeSeen); 
          return CommentsPage(postFromTagsPost,userPost: userPost,);
        }
      )
    );
  }

  Widget _buildNewCommentImage(UserPost userPostItems){
    return Stack(
        children: <Widget>[
          Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)
                ),
                margin: EdgeInsets.symmetric(horizontal : 1.5,vertical: 5.0),
                child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                    image:CachedNetworkImageProvider(userPostItems.imageUrl),
                      fit: userPostItems.imageWidth/userPostItems.imageHeight>=1.0 ? BoxFit.fitHeight:BoxFit.fitWidth,
                      alignment: FractionalOffset.center,
                ),
              )
              )
              ),
          Positioned(
            child: NotifIcon(22.0,11.0),
            top: 10.0,
            right: 10.0,
          )
        ],
    );
  }




    List<Widget> _buildUserPostGrid(BuildContext context, QuerySnapshot snapshot) {
    final List<Widget> gridItems =snapshot.documents.map((DocumentSnapshot document){
      final UserPost userPostItems =  UserPost.fromDocumentSnaptshot(document);  
      return GestureDetector(
          onTap: (){
            _navigateCommentsPage(context,userPostItems);
          },
          child: GridTile(
           child: AspectRatio(
            aspectRatio: 1.0,
            child: userPostItems.lastCommentSeen && userPostItems.lastLikeSeen?
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)
                ),
                margin: EdgeInsets.symmetric(horizontal : 1.5,vertical: 5.0),
                child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                    image:CachedNetworkImageProvider(userPostItems.imageUrl),
                      fit: userPostItems.imageWidth/userPostItems.imageHeight>=1.0 ? BoxFit.fitHeight:BoxFit.fitWidth,
                      alignment: FractionalOffset.center,
                ),
              )
              )
              )
              :
              _buildNewCommentImage(userPostItems),
            ),
          ),
        );
    }).toList();
    return gridItems;
  }

  @override
  Widget build(BuildContext context) {
    MainBloc _mainBloc = BlocProvider.of<MainBloc>(context);
    return
     StreamBuilder(
       stream: _mainBloc.listUserPostControllerStream,
       initialData: _mainBloc.userPostSnapshot,
       builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
         print(" ################### STB USERPOST TRIGGERED ################# ");
        if(!snapshot.hasData){
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.data.documents.length==0) {
          return Center(
            child: Text("Aucun post"),
          );
        }
        return GridView.count(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          children: _buildUserPostGrid(context,snapshot.data),
          mainAxisSpacing: 5.0,
          crossAxisSpacing: 5.0,
          shrinkWrap: true,
        );
       }
     );
  }
}