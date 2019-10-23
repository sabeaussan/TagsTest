

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Event/events.dart';
import 'package:tags/Models/post.dart';
import 'package:tags/Models/publicmark.dart';
import 'package:tags/UI/post_tile.dart';
import 'package:tags/pages/TagsPage/tags_chat.dart';
import 'package:tags/pages/TagsPage/tags_gallery.dart';

class BlocTagsPage extends  BlocBase {

  

  static const int NB_MESSAGES_FETCHED = 15;
  static const int NB_POSTS_FETCHED = 10;

  final PublicMark _mark;
  
  //liste contient les deux pages d'une mark
  List<Widget> _listPage;
  PublicMark get mark => _mark;
  
  

  BlocTagsPage(this._mark,keyGallery,keyChat) {

    

    print("-------------create blotagPage------------");
    _listPage=[TagsGallery(this,key: keyGallery,),TagsChat(_mark,this,key:keyChat)];
    numTabStream.listen(_onTabChange);

    //---------------------Mark Message Stream---------------------------

    Firestore.instance.collection("Tags").document(_mark.id)
      .collection("TagsMessage").orderBy("timeStamp",descending:true).limit(NB_MESSAGES_FETCHED).snapshots().listen(_onNewMessageSnapshot);
    _fetchMoreMessageControllerStream.listen(_fetchMoreMessage);

    //-----------------------------------------------------------------

    //---------------------Mark Post Stream-----------------------------


    Firestore.instance.collection("Tags").document(_mark.id)
      .collection("TagsPost").orderBy("timeStamp",descending:true).limit(NB_POSTS_FETCHED).getDocuments()
      .then((QuerySnapshot snap){
        if(snap.documents.length<NB_POSTS_FETCHED) _postEdgeReached = true;
        else _lastPostFetched=snap.documents[snap.documents.length-1];
        _markPostsList=snap.documents.map((DocumentSnapshot doc){
          return PostTile.fromDocumentSnaptshot(doc,key: ValueKey(doc.documentID),);
        }).toList();
        _listMarkPostController.add(_markPostsList);
      });
    _newPostsControllerStream.listen(_onNewPost);
    _fetchMorePostControllerStream.listen(_fetchMorePost);

    //-----------------------------------------------------------------
  }



  //Sert à controller la page qui sera afficher, on reçoit l'int de la page à afficher
  final StreamController<int> _numTabController = StreamController<int>.broadcast();

  StreamSink<int> get numTabSink => _numTabController.sink;
  Stream<int> get numTabStream => _numTabController.stream;


  //Sert à renvoyer le widget à afficher entre TagsGallery et TagsChat
  final StreamController<Widget> _widgetPageController = StreamController<Widget>.broadcast();

  StreamSink <Widget> get _widgetPageSink => _widgetPageController.sink;
  Stream<Widget> get widgetPageStream => _widgetPageController.stream;

  final StreamController<QuerySnapshot> _listTagsPageController = StreamController<QuerySnapshot>.broadcast();

  StreamSink<QuerySnapshot> get _listTagsPageControllerSink => _listTagsPageController.sink;
  Stream<QuerySnapshot> get listTagsPageControllerStream => _listTagsPageController.stream;

  //------------------------------------------ Pagination des messages StreamController ------------------------------------------------

  List<DocumentSnapshot> _markMessagesList=List<DocumentSnapshot>();
  DocumentSnapshot _lastMessageFetched;
  bool _messageEdgeReached=false;
  bool _fetchingMessage=false;
  List<DocumentSnapshot> get markMessagesList => _markMessagesList;

  final StreamController<List<DocumentSnapshot>> _listTagMessageController = StreamController<List<DocumentSnapshot>>.broadcast();

  StreamSink<List<DocumentSnapshot>> get _listTagMessageControllerSink => _listTagMessageController.sink;
  Stream<List<DocumentSnapshot>> get listTagMessageControllerStream => _listTagMessageController.stream;

  final StreamController<FetchMoreTagMessageEvent> _fetchMoreMessageController = StreamController<FetchMoreTagMessageEvent>.broadcast();

  StreamSink<FetchMoreTagMessageEvent> get fetchMoreMessageControllerSink => _fetchMoreMessageController.sink;
  Stream<FetchMoreTagMessageEvent> get _fetchMoreMessageControllerStream => _fetchMoreMessageController.stream;


  final StreamController<bool> _loadingMessageController = StreamController<bool>.broadcast();

  StreamSink<bool> get _loadingMessageControllerSink => _loadingMessageController.sink;
  Stream<bool> get loadingMessageControllerStream => _loadingMessageController.stream;

  

  



  void _fetchMoreMessage(FetchMoreTagMessageEvent event) async {
    // CallBack déclenché par le scroll controller
    // fetch d'autre commentaires

    // Si l'on a atteint la fin du nombre de doc
    if(_messageEdgeReached) return;
    print("-*-*-*-*-*-*-*-*-*-fetching more message-*-*-*-*-*-*-*-*-*-*-*-*-*");

    // On envoie un event pour afficher le widget de chargement dans la commentPage
    _fetchingMessage=true;
    _loadingMessageControllerSink.add(_fetchingMessage);

    // On fetch d'autre document en commençant par celui juste après le dernier reçu
    Firestore.instance.collection("Tags").document(_mark.id)
      .collection("TagsMessage").orderBy("timeStamp",descending:true)
      .startAfterDocument(_lastMessageFetched).limit(NB_MESSAGES_FETCHED).getDocuments().then((snap){

        // Si le nombre de doc est >0 alors on enregistre l'index du dernier
        // du dernier reçu dans _lastCommentsFetched pour le prochain fetch
        if(snap.documents.length>0) _lastMessageFetched=snap.documents[snap.documents.length-1];

        // Si le nombre de doc est < NB_MESSAGES_FETCHED alors on atteint la limite 
        // Il n'y a pas plus de doc à fetched => on met _messageEdgeReached=true
        if(snap.documents.length<NB_MESSAGES_FETCHED) _messageEdgeReached=true;

        // On rajoute dans la liste afficher par la listView de CommentPage 
        // les nouveaux doc fetched puis luis envoie
        _markMessagesList.addAll(snap.documents);
        _listTagMessageControllerSink.add(_markMessagesList);

        // On desactive le widget de chargement
        _fetchingMessage=false;
        _loadingMessageControllerSink.add(_fetchingMessage);
      });
  }



  void _onNewMessageSnapshot(QuerySnapshot snapshot){
    // CallBack appelé lors de l'ajout d'un commentaire par un utilisateur

    // Si la liste n'est pas vide il va falloir insérer au bon endroit le nouveaux doc
    // Il s'agit du plus récent donc l doit apparaitre au début
    if(_markMessagesList.length!=0){

      // On recoit tous les documents et pas juste celui qui a était ajouté
      snapshot.documentChanges.forEach((DocumentChange doc){
        // final int t1=int.parse(doc.document.data["timeStamp"]);
        // final int t2=int.parse(_markMessagesList.elementAt(0).data["timeStamp"]);
        // final String id1 = doc.document.documentID;
        // final String id2 = _markMessagesList.elementAt(0).documentID;
        // print("new doc : "+doc.document.data["content"]+t1.toString()+id1);
        // print("lastDoc : "+_markMessagesList.elementAt(0).data["content"]+t2.toString()+id2);
        if(doc.type==DocumentChangeType.added /*&&  t1 >= t2 && id1!=id2 */){
            _markMessagesList.insert(0,doc.document);
        }
      });
    }
    if(_markMessagesList.length==0 && snapshot.documents.length!=0) {
      // La liste est vide donc il s'agit de la première récupération de doc qu'on fait 
      // i.e premier fetching on ajoute donc tous les doc
      _markMessagesList.addAll(snapshot.documents);

      // On enregistre l'index du dernier doc récupérer pour le prochain fetching
      _lastMessageFetched=snapshot.documents[snapshot.documents.length-1];

      // Si le nombre de doc est < NB_MESSAGES_FETCHED alors on atteint la limite 
      // Il n'y a pas plus de doc à fetched => on met _messageEdgeReached=true
      if(snapshot.documents.length < NB_MESSAGES_FETCHED) _messageEdgeReached=true;
    }

    // On envoie les doc à la listView de la CommentPage
    _listTagMessageControllerSink.add(_markMessagesList);
  }

  //------------------------------------------ Pagination des posts StreamController ------------------------------------------------

  List<PostTile> _markPostsList=List<PostTile>();
  List<PostTile> get markPostsList => _markPostsList;
  DocumentSnapshot _lastPostFetched;
  bool _postEdgeReached=false;
  bool _fetchingPost=false;

  final StreamController<List<PostTile>> _listMarkPostController = StreamController<List<PostTile>>.broadcast();

  StreamSink<List<PostTile>> get _listMarkPostControllerSink => _listMarkPostController.sink;
  Stream<List<PostTile>> get listMarkPostControllerStream => _listMarkPostController.stream;

  final StreamController<FetchMorePostEvent> _fetchMorePostController = StreamController<FetchMorePostEvent>.broadcast();

  StreamSink<FetchMorePostEvent> get fetchMorePostControllerSink => _fetchMorePostController.sink;
  Stream<FetchMorePostEvent> get _fetchMorePostControllerStream => _fetchMorePostController.stream;

  final StreamController<Post> _newPostsController = StreamController<Post>.broadcast();

  StreamSink<Post> get newPostsControllerSink => _newPostsController.sink;
  Stream<Post> get _newPostsControllerStream => _newPostsController.stream;


  final StreamController<bool> _loadingPostController = StreamController<bool>.broadcast();

  StreamSink<bool> get _loadingPostControllerSink => _loadingPostController.sink;
  Stream<bool> get loadingPostControllerStream => _loadingPostController.stream;

  void _onNewPost(Post post){
    // CallBack appelé lors de l'ajout d'un post par un utilisateur
    // Si la liste n'est pas vide il va falloir insérer au bon endroit le nouveaux doc
    // Il s'agit du plus récent donc l doit apparaitre au début
    if(_markPostsList.length!=0) _markPostsList.insert(0,PostTile.fromPost(post));

    // Sinon on se contente de l'ajouter car c'est le premier post
    else _markPostsList.add(PostTile.fromPost(post));

    // On envoie les doc à la listView de la MarkGallery
    _listMarkPostController.add(_markPostsList);
  }


  void _fetchMorePost(FetchMorePostEvent event) async {
    // CallBack déclenché par le scroll controller
    // fetch d'autre commentaires

    // Si l'on a atteint la fin du nombre de doc
    if(_postEdgeReached) return;
    print("-*-*-*-*-*-*-*-*-*-fetching more post-*-*-*-*-*-*-*-*-*-*-*-*-*");

    // On envoie un event pour afficher le widget de chargement dans la commentPage
    _fetchingPost=true;
    _loadingPostControllerSink.add(_fetchingPost);

    // On fetch d'autre document en commençant par celui juste après le dernier reçu
    Firestore.instance.collection("Tags").document(_mark.id)
      .collection("TagsPost").orderBy("timeStamp",descending:true)
      .startAfterDocument(_lastPostFetched).limit(NB_POSTS_FETCHED).getDocuments().then((snap){

        // Si le nombre de doc est >0 alors on enregistre l'index du dernier
        // du dernier reçu dans _lastCommentsFetched pour le prochain fetch
        if(snap.documents.length>0) _lastPostFetched=snap.documents[snap.documents.length-1];

        // Si le nombre de doc est < NB_POSTS_FETCHED alors on atteint la limite 
        // Il n'y a pas plus de doc à fetched => on met _postEdgeReached=true
        if(snap.documents.length<NB_POSTS_FETCHED) _postEdgeReached=true;

        // On rajoute dans la liste afficher par la listView de CommentPage 
        // les nouveaux doc fetched puis luis envoie
        _markPostsList.addAll(
          snap.documents.map((DocumentSnapshot doc){
            return PostTile.fromDocumentSnaptshot(doc);
          })
        );
        _listMarkPostControllerSink.add(_markPostsList);

        // On desactive le widget de chargement
        _fetchingPost=false;
        _loadingPostControllerSink.add(_fetchingPost);
      });
  }



  

  void _onTabChange(int numTab){
    _widgetPageSink.add(_listPage[numTab]);
  }

  @override
  void dispose() {
    print("-------------dispose blotagPage------------");
    _numTabController.close();
    _widgetPageController.close();
    _listTagsPageController.close();
    _listTagMessageController.close();
    _fetchMoreMessageController.close();
    _listTagsPageControllerSink.close();
    _loadingMessageController.close();
    _fetchMorePostController.close();
    _listMarkPostController.close();
    _loadingPostController.close();
    _newPostsController.close();
  }



  



}