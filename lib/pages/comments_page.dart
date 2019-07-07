import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_comment_page.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Bloc/main_bloc.dart';
import 'package:tags/Event/events.dart';
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
  BlocCommentsPage  _blocCommentsPage;
  ScrollController _scrollController;
  double lastExtent=0.0;

  void _fetchMoreComments() async {
    if(_scrollController.position.pixels==_scrollController.position.maxScrollExtent){
      print("--------------------FetchMoreMessageEvent triggered----------------");
      if(lastExtent!=_scrollController.position.maxScrollExtent){
        print("position : "+_scrollController.position.pixels.toString());
        print("maxExtent : "+_scrollController.position.pixels.toString());
        print("lastExtent : "+lastExtent.toString());
        lastExtent = _scrollController.position.maxScrollExtent;
        _blocCommentsPage.fetchMoreCommentsControllerSink.add(FetchMoreCommentEvent());
      }
        
    }
  }

  

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
                    Comment messageTosend = Comment(null, currentUser.id,message, currentUser.photoUrl, currentUser.userName, widget._postTileToComment.id, widget._postTileToComment.tagsId,db.timeStamp());
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



  Widget _buildListView(List<DocumentSnapshot> snapshot,bool isLoading) {
    return 
    snapshot.length==0? SingleChildScrollView(
        child:  widget._postTileToComment
      )
    : 
    ListView.builder(
                controller: _scrollController,
                itemCount: snapshot.length+1,
                itemBuilder: (BuildContext context, int index) {
                  if(index==snapshot.length) return  _buildLoadingIndicator(isLoading);
                  return Column(
                    children: <Widget>[
                      index == 0 ? widget._postTileToComment : Container(),
                      CommentTile.fromDocumentSnapshot(snapshot[index]),
                      Divider()
                    ],
                  );
                }
            );
  }

  Widget _buildLoadingIndicator(bool isLoading){
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Center(
        child: Opacity(
          opacity: isLoading ? 1.0 : 0.0,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    db.updateOldUserPost(widget._postTileToComment.id, currentUser.id,true);  //TODO: faire un truc pour ne pas update pour rien
    _scrollController.removeListener(_fetchMoreComments);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _messageTextController =TextEditingController();
    _focusNode=FocusNode();
    _mainBloc = BlocProvider.of<MainBloc>(context);
    currentUser =_mainBloc.currentUser;
    _blocCommentsPage = BlocCommentsPage(widget._postTileToComment.id);
    _scrollController = ScrollController();
    _scrollController.addListener(_fetchMoreComments);
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
      //TODO : mettre StreamBuilder dans un Flexible et buildMessageRow en dehors du Stbd le tout dans une column
      body: StreamBuilder<List<DocumentSnapshot>>(
        initialData: _blocCommentsPage.snapshotPostCommentsList ,
        stream: _blocCommentsPage.listPostCommentsControllerStream,
        builder: (BuildContext context, AsyncSnapshot<List<DocumentSnapshot>> listSnapshot){
          if(!listSnapshot.hasData){
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          print("******[stb CommentsPage] trigered********* "+listSnapshot.data.length.toString());
          return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                  Expanded(
                  child: Scrollbar(
                    child: Container(
                      child: StreamBuilder(
                        stream: _blocCommentsPage.loadingCommentsControllerStream ,
                        initialData: false ,
                        builder: (BuildContext context, AsyncSnapshot snapshot){
                          return Container(
                            child: _buildListView(listSnapshot.data,snapshot.data),
                          );
                        },
                      ),
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