import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tags/Models/userPost.dart';

import 'package:tags/UI/post_tile.dart';
import 'package:tags/pages/comments_page.dart';


class OtherUserPostGrid extends StatelessWidget {


  final List<DocumentSnapshot> _userPosts;

  OtherUserPostGrid(this._userPosts);

  void _navigateCommentsPage(BuildContext context,UserPost userPost) async {
    DocumentSnapshot postSnap = await Firestore.instance.collection("Tags").document(userPost.tagOwnerId).collection("TagsPost").document(userPost.id).get();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context)  {
          PostTile postFromTagsPost =  PostTile.fromDocumentSnaptshot(postSnap); 
          return CommentsPage(postFromTagsPost,userPost: userPost);
        }
      )
    );
  }

  

    List<Widget> _buildUserPostGrid(BuildContext context, List<DocumentSnapshot> userPosts) {
    final List<Widget> gridItems =userPosts.map((DocumentSnapshot document){
    final UserPost userPostTileItems = UserPost.fromDocumentSnaptshot(document);  
      return GestureDetector(
          onTap: (){
            _navigateCommentsPage(context,userPostTileItems);
          },
          child: GridTile(
           child: AspectRatio(
            aspectRatio: 1.0,
            child: 
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
                    image:CachedNetworkImageProvider(userPostTileItems.imageUrl),
                      fit: userPostTileItems.imageWidth/userPostTileItems.imageHeight>=1.0 ? BoxFit.fitHeight:BoxFit.fitWidth,
                      alignment: FractionalOffset.center,
                ),
              )
              )
              )

            ),
          ),
        );
    }).toList();
    return gridItems;
  }

  @override
  Widget build(BuildContext context) {
        if (_userPosts.length==0) {
            return Center(
              child: Text("Aucun post"),
            );
          }
        return GridView.count(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          children: _buildUserPostGrid(context,_userPosts),
          mainAxisSpacing: 5.0,
          crossAxisSpacing: 5.0,
          shrinkWrap: true,
        );
  }
}