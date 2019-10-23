import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_comment_page.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Bloc/main_bloc.dart';
import 'package:tags/Event/events.dart';
import 'package:tags/Models/comment.dart';
import 'package:tags/Models/user.dart';
import 'package:tags/Models/userPost.dart';
import 'package:tags/UI/comment_tile.dart';
import 'package:tags/UI/post_tile.dart';
import 'package:tags/Utils/firebase_db.dart';


class CommentsPage extends StatefulWidget {
  final PostTile _postTileToComment;
  final UserPost userPost;
  

  CommentsPage(this._postTileToComment,{this.userPost});

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
      if(lastExtent!=_scrollController.position.maxScrollExtent){
        lastExtent = _scrollController.position.maxScrollExtent;
        _blocCommentsPage.fetchMoreCommentsControllerSink.add(FetchMoreCommentEvent());
      }
        
    }
  }

  

  void _postComment(Comment comment,User currentUser) async {
    //Fonction éxecuté lors de la création d'un commentaire
    //Met à jour le nombre de commentaire non lu 
    //Met lastCommentSeen = false si nbCommentsNotSeen=0
    final String postId = widget._postTileToComment.id;
    final String markId =  widget._postTileToComment.tagsId;
    final String postOwnerId = widget._postTileToComment.ownerId;
    final int nbCommentsNotSeen = widget._postTileToComment.nbCommentsNotSeen;
    await db.createPostCommentFirestore(comment,markId,postId);
    if(postOwnerId!=currentUser.id){
      await db.updatePostNbComments(postId, markId,true);
      //await db.incrementNbCommentNotSeen(postId,markId);
      //On met le flag lastCommentSeen a 1 uniquement lorsque nbCommentsNotSeen passe de 0 à 1
      if(nbCommentsNotSeen==0) await db.updateCommentUserPost(postOwnerId, postId,comment,false);
    }
    else{
      //Sinon c'est l'utlisateur qui poste un commentaire donc 
      //On a pas besoin de lui notifier => on incrémente pas nbCommentsNotSeen
      await db.updatePostNbComments(postId, markId,false);
    }
    
  }

  Widget _buildMessageRow(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[ 
          SizedBox(width: 25.0,),
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
                hintText:"ajouter un commentaire ...",
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(10.0)),
              keyboardType: TextInputType.multiline,
              maxLines: null,
              cursorColor: Colors.red,
            ),
          ),
          IconButton(
                disabledColor: Colors.black12,
                icon: Icon(Icons.send, color: _focusNode.hasFocus? Colors.red:Color.fromARGB(150,182, 182, 182)),
                onPressed:
                () async {
                  _key.currentState.save();
                  if(message.trim().length!=0){
                    Comment commentTosend = Comment(null, currentUser.id,message, currentUser.photoUrl, currentUser.userName, widget._postTileToComment.id, widget._postTileToComment.tagsId,db.timeStamp());
                    _messageTextController.clear();
                    _blocCommentsPage.newCommentsControllerSink.add(commentTosend);
                    _postComment(commentTosend,currentUser);
                  }
                },
              )
        ],
      ),
      decoration: BoxDecoration(
        color: Color.fromARGB(40,182, 182, 182),
        border: Border.all(
          width: 2.0,
          color: _focusNode.hasFocus? Colors.red:Color.fromARGB(150,182, 182, 182),
          style: BorderStyle.solid
        ) ,
        borderRadius: const BorderRadius.all(Radius.circular(25.0)),
      ),
    );
  }



  Widget _buildListView(List<CommentTile> listCommentTile,bool isLoading) {
    return listCommentTile.length==0? 
    SingleChildScrollView(
        child:  widget._postTileToComment
      )
    : 
    ListView.builder(
      controller: _scrollController,
      itemCount: listCommentTile.length+1,
      reverse: false,
      itemBuilder: (BuildContext context, int index) {
        if(index==listCommentTile.length) return  _buildLoadingIndicator(isLoading);
          return Column(
            children: <Widget>[
              index == 0 ? widget._postTileToComment : Container(),
              listCommentTile[index],              
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
    final String postOwnerId = widget._postTileToComment.ownerId;
    final int nbCommentsNotSeen = widget._postTileToComment.nbCommentsNotSeen;
    final String postId = widget._postTileToComment.id;
    final String markId =  widget._postTileToComment.tagsId;
    if(widget.userPost!=null && nbCommentsNotSeen!=0 && postOwnerId==currentUser.id){
      print("####### COMMENT SEEN #######");
      //si le créateur du post n'as pas vu les derniers comm et que c'est bien lui qui a accéder à la page
      db.resetNbNotSeen(postId, markId,"nbCommentsNotSeen");  //TODO: faire un truc pour ne pas update pour rien
      db.updateCommentUserPost(postOwnerId, postId,null, true);
    }
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
    _blocCommentsPage = BlocCommentsPage(widget._postTileToComment,widget.userPost,currentUser);
    _scrollController = ScrollController();
    _scrollController.addListener(_fetchMoreComments);
  }

  @override
  Widget build(BuildContext context) {
    widget._postTileToComment.setType(COMMENT);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Commentaires",style: TextStyle(color: Colors.black),),
      ),
      //TODO : mettre StreamBuilder dans un Flexible et buildMessageRow en dehors du Stbd le tout dans une column
      body: StreamBuilder<List<CommentTile>>(
        initialData: _blocCommentsPage.snapshotPostCommentsList ,
        stream: _blocCommentsPage.listPostCommentsControllerStream,
        builder: (BuildContext context, AsyncSnapshot<List<CommentTile>> listSnapshot){
          if(!listSnapshot.hasData){
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                StreamBuilder(
                  stream: _blocCommentsPage.loadingCommentsControllerStream ,
                  initialData: false,
                  builder: (BuildContext context, AsyncSnapshot snapshot){
                    return Expanded(
                      child: _buildListView(listSnapshot.data,snapshot.data),
                      
                    );
                  },
                ),
                _buildMessageRow(context),
              ],
          );
        },
      ),
    );
  }
}