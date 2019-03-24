import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Bloc/main_bloc.dart';
import 'package:tags/Models/comments.dart';
import 'package:tags/Models/user.dart';
import 'package:tags/UI/comment_tile.dart';
import 'package:tags/UI/post_tile.dart';
import 'package:tags/Utils/firebase_db.dart';


class CommentsPage extends StatefulWidget {
  final PostTile _postTileToComment;

  CommentsPage(this._postTileToComment);

  _CommentsPageState createState() => _CommentsPageState();
}



class _CommentsPageState extends State<CommentsPage> {
  TextEditingController _messageTextController;
  FocusNode _focusNode;
  GlobalKey<FormFieldState> _key = GlobalKey<FormFieldState>();
  String message;
  MainBloc _mainBloc;
  User currentUser;

  //TODO: utiliser des textFormField pour pouvoir avoir accés a onSaved

  void _postComment(Comment comment,User currentUser) async {
    await db.createPostCommentFirestore(comment,widget._postTileToComment.tagsId,widget._postTileToComment.id);
    if(widget._postTileToComment.ownerId!=currentUser.id) db.updateOldUserPost(widget._postTileToComment.id, widget._postTileToComment.ownerId,false);
  }

  Widget _buildMessageRow(BuildContext context) {
    
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[ 
          FloatingActionButton(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            onPressed:null,
            mini: true,
          ),

          Expanded(
            child: TextFormField(
              key: _key,
              controller: _messageTextController,
              focusNode: _focusNode,
              onSaved: (String val){
                message=val;
              },
              decoration: InputDecoration(
                filled: false,
                hintText:"message...",
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(10.0)),
              keyboardType: TextInputType.multiline,
              maxLines: null,
              cursorColor: Colors.deepOrange,
            ),
          ),
          IconButton(
                disabledColor: Colors.black12,
                icon: Icon(Icons.send, color: _focusNode.hasFocus? Colors.deepOrange:Color.fromARGB(150,182, 182, 182)),
                onPressed:
                () async {
                  _key.currentState.save();
                  if(message.trim().length!=0){
                    Comment messageTosend = Comment(null, currentUser.id,message, currentUser.photoUrl, currentUser.userName, widget._postTileToComment.id, widget._postTileToComment.tagsId);
                    _messageTextController.clear();
                    _postComment(messageTosend,currentUser);
                  }
                },
              )
        ],
      ),
      decoration: BoxDecoration(
        color: Color.fromARGB(40,182, 182, 182),
        border: Border.all(
          width: 2.0,
          color: _focusNode.hasFocus? Colors.deepOrange:Color.fromARGB(150,182, 182, 182),
          style: BorderStyle.solid
        ) ,
        borderRadius: const BorderRadius.all(Radius.circular(25.0)),
      ),
    );
  }



  Widget _buildListView(QuerySnapshot snapshot) {
    return 
    snapshot.documents.length==0? SingleChildScrollView(
        child:  widget._postTileToComment
      )
    : 
    ListView.builder(
                itemCount: snapshot.documents.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: <Widget>[
                      index == 0 ? widget._postTileToComment : Container(),
                      CommentTile.fromDocumentSnapshot(snapshot.documents[index]),
                      Divider()
                    ],
                  );
                }
            );
  }

  @override
  void dispose() {
    db.updateOldUserPost(widget._postTileToComment.id, currentUser.id,true);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _messageTextController =TextEditingController();
    _focusNode=FocusNode();
    _mainBloc = BlocProvider.of<MainBloc>(context);
    currentUser =_mainBloc.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    print("[build commentPage]");
    widget._postTileToComment.setType(COMMENT);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Commentaires",style: TextStyle(color: Colors.black),),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection("PostComments").document(widget._postTileToComment.id).collection("Comments").snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
          if(!snapshot.hasData){
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return Column(
              children: <Widget>[
                Flexible(
                  child: Scrollbar(
                    child: Container(
                      child: _buildListView(snapshot.data),
                    ),
                  ),
                ),
                _buildMessageRow(context),
              ],
          );
        },
      ),
    );
  }
}
