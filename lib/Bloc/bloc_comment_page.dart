




import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Event/events.dart';
import 'package:tags/Models/comment.dart';
import 'package:tags/Models/user.dart';
import 'package:tags/Models/userPost.dart';
import 'package:tags/UI/comment_tile.dart';
import 'package:tags/UI/post_tile.dart';


class BlocCommentsPage implements BlocBase {
  StreamSubscription _newCommentSub;
  StreamSubscription _fetchMoreSub;
  static const int NB_COMMENT_FETCHED = 15;
  // Liste contenant les documents afficher par la ListView de CommentPage
  List<CommentTile> _commentsList=List<CommentTile>();
  List<CommentTile> get snapshotPostCommentsList => _commentsList;
  DocumentSnapshot _lastCommentsFetched;
  bool _commentsEdgeReached=false;
  bool _fetchingComments=false;

  final PostTile _commentedPost;
  final UserPost _userPost;
  final User _currentUser;

  BlocCommentsPage(this._commentedPost,this._userPost,this._currentUser){
    int index=0;
    final String postOwnerId = _commentedPost.ownerId;
    final int nbCommentsNotSeen = _commentedPost.nbCommentsNotSeen;
    Firestore.instance.collection("PostComments").document(_commentedPost.id)
      .collection("Comments").limit(NB_COMMENT_FETCHED).orderBy("timeStamp",descending:true).getDocuments()
      .then((QuerySnapshot snap){
        if(snap.documents.length<NB_COMMENT_FETCHED) _commentsEdgeReached = true;
        else _lastCommentsFetched=snap.documents[snap.documents.length-1];
        _commentsList=snap.documents.map((DocumentSnapshot doc){
          bool needToBeNotify = false;
          if(index<nbCommentsNotSeen && postOwnerId==_currentUser.id && _userPost!=null) needToBeNotify=true;
          index++;
          return CommentTile.fromDocumentSnapshot(doc,needToBeNotify);
        }).toList();
        _listPostCommentsControllerSink.add(_commentsList);
      });
    _newCommentSub = _newCommentsControllerStream.listen(_onNewComment);
    _fetchMoreSub = _fetchMoreCommentsControllerStream.listen(_fetchMoreComments);
    
  }

  @override
  void dispose() {
    _listPostCommentsController.close();
    _fetchMoreCommentsController.close();
    _loadingCommentsController.close();
    _newCommentsController.close();
    _newCommentSub.cancel();
    _fetchMoreSub.cancel();
  }


  //-----------------------------------------PostCommentsController--------------------------------------

  //Pagination de la collection Comments

  


  
  

  
  
  // StreamController qui contient les comment à donner à la CommentPage
  final StreamController<List<CommentTile>> _listPostCommentsController = StreamController<List<CommentTile>>.broadcast();

  StreamSink<List<CommentTile>> get _listPostCommentsControllerSink => _listPostCommentsController.sink;
  Stream<List<CommentTile>> get listPostCommentsControllerStream => _listPostCommentsController.stream;


  // StreamController qui contient l'évènement fetchMoreComment
  final StreamController<FetchMoreCommentEvent> _fetchMoreCommentsController = StreamController<FetchMoreCommentEvent>.broadcast();

  StreamSink<FetchMoreCommentEvent> get fetchMoreCommentsControllerSink => _fetchMoreCommentsController.sink;
  Stream<FetchMoreCommentEvent> get _fetchMoreCommentsControllerStream => _fetchMoreCommentsController.stream;

  // StreamController qui contient les comment reçu depuis la commentPage et écris par User
  final StreamController<Comment> _newCommentsController = StreamController<Comment>.broadcast();

  StreamSink<Comment> get newCommentsControllerSink => _newCommentsController.sink;
  Stream<Comment> get _newCommentsControllerStream => _newCommentsController.stream;


  final StreamController<bool> _loadingCommentsController = StreamController<bool>.broadcast();

  StreamSink<bool> get _loadingCommentsControllerSink => _loadingCommentsController.sink;
  Stream<bool> get loadingCommentsControllerStream => _loadingCommentsController.stream;





  void _fetchMoreComments(FetchMoreCommentEvent event) async {
    // CallBack déclenché par le scroll controller
    // fetch d'autre commentaires

    // Si l'on a atteint la fin du nombre de doc
    if(_commentsEdgeReached) return;

    print(" ################ FETCHING COMMENT ############### ");
    int index=0;
    final String postOwnerId = _commentedPost.ownerId;
    final int nbCommentsNotSeen = _commentedPost.nbCommentsNotSeen;

    // Sinon on fetch d'autre document
    // On envoie un event pour afficher le widget de chargement dans la commentPage
    _fetchingComments=true;
    _loadingCommentsControllerSink.add(_fetchingComments);

    // On fetch d'autre document en commençant par celui juste après le dernier reçu
    Firestore.instance.collection("PostComments").document(_commentedPost.id)
      .collection("Comments").startAfterDocument(_lastCommentsFetched)
      .orderBy("timeStamp",descending:true).limit(NB_COMMENT_FETCHED).getDocuments().then((snap){

        // Si le nombre de doc est >0 alors on enregistre l'index du dernier
        // du dernier reçu dans _lastCommentsFetched pour le prochain fetch
        if(snap.documents.length>0) _lastCommentsFetched=snap.documents[snap.documents.length-1];

        // Si le nombre de doc est < NB_COMMENT_FETCHED alors on atteint la limite 
        // Il n'y a pas plus de doc à fetched => on met _commentsEdgeReached=true
        if(snap.documents.length<NB_COMMENT_FETCHED) _commentsEdgeReached=true;

        // On rajoute dans la liste afficher par la listView de CommentPage 
        // les nouveaux doc fetched puis luis envoie
        _commentsList.addAll(
          snap.documents.map((DocumentSnapshot doc){
            bool needToBeNotify = false;
            if(index<nbCommentsNotSeen && postOwnerId==_currentUser.id && _userPost!=null) needToBeNotify=true;
            index++;
            return CommentTile.fromDocumentSnapshot(doc,needToBeNotify);
          }).toList()
        );
        _listPostCommentsControllerSink.add(_commentsList);

        // On desactive le widget de chargement
        _fetchingComments=false;
        _loadingCommentsControllerSink.add(_fetchingComments);
      });
  }



  void _onNewComment(Comment com){
    // CallBack appelé lors de l'ajout d'un commentaire par un utilisateur

    // Si la liste n'est pas vide il va falloir insérer au bon endroit le nouveaux doc
    // Il s'agit du plus récent donc l doit apparaitre au début
    if(_commentsList.length!=0) _commentsList.insert(0,CommentTile.fromComment(com));

    // Sinon on se contente de l'ajouter car c'est le premier commentaire
    else _commentsList.add(CommentTile.fromComment(com));

    // On envoie les doc à la listView de la CommentPage
    _listPostCommentsControllerSink.add(_commentsList);
  }



}