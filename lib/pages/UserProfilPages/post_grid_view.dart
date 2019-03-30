import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Bloc/main_bloc.dart';
import 'package:tags/Models/user.dart';
import 'package:tags/Models/userPost.dart';

import 'package:tags/UI/post_tile.dart';
import 'package:tags/pages/comments_page.dart';


class PostGrid extends StatelessWidget {

  //TODO: faire un futureBuilder ou stbld

  final User _user;

  PostGrid(this._user);

  void _navigateCommentsPage(BuildContext context,UserPost userPost) async {
    DocumentSnapshot postSnap = await Firestore.instance.collection("Tags").document(userPost.tagOwnerId).collection("TagsPost").document(userPost.id).get();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context)  {
          PostTile postFromTagsPost =  PostTile.fromDocumentSnaptshot(postSnap); 
          return CommentsPage(postFromTagsPost);
        }
      )
    );
  }

  Widget _buildNewCommentImage(UserPost postTileItems){
    return Stack(
        children: <Widget>[
          Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image:CachedNetworkImageProvider(postTileItems.imageUrl),
                    fit: BoxFit.fitWidth,
                    alignment: FractionalOffset.center,
                  )
                ),
              ),
          CircleAvatar(
            child: Center(child: Icon(Icons.error,size: 25.0,color:Colors.deepOrange),),
            backgroundColor: Color(0xFFF8F8F8),
            radius: 12.5,
          )
        ],
    );
  }




    List<Widget> _buildUserPostGrid(BuildContext context, QuerySnapshot snapshot) {
    final List<Widget> gridItems =snapshot.documents.map((DocumentSnapshot document){
      final UserPost userPostTileItems =  UserPost.fromDocumentSnaptshot(document);  
      return GestureDetector(
          onTap: (){
            _navigateCommentsPage(context,userPostTileItems);
          },
          child: GridTile(
           child: AspectRatio(
            aspectRatio: 1.0,
            child: userPostTileItems.lastCommentSeen?
             Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image:CachedNetworkImageProvider(userPostTileItems.imageUrl),
                    fit: BoxFit.fitWidth,
                    alignment: FractionalOffset.center,
                  )
                ),
              )
              :
              _buildNewCommentImage(userPostTileItems)
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