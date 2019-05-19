

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Event/events.dart';
import 'package:tags/Models/tags.dart';
import 'package:tags/pages/TagsPage/tags_chat.dart';
import 'package:tags/pages/TagsPage/tags_gallery.dart';

class BlocTagsPage extends  BlocBase {

  final Tags _tag;
  List<DocumentSnapshot> _snapshotTagMessageList=List<DocumentSnapshot>();
  List<DocumentSnapshot> _snapshotTagPostList=List<DocumentSnapshot>();
  DocumentSnapshot _lastMessageFetched;
  DocumentSnapshot _lastPostFetched;
  bool _messageEdgeReached=false;
  bool _fetchingMessage=false;

  bool _postEdgeReached=false;
  bool _fetchingPost=false;

  //liste contient les deux pages d'un tags
  List<Widget> _listPage;


  Tags get tags => _tag;
  List<DocumentSnapshot> get snapshotTagMessageList => _snapshotTagMessageList;
  List<DocumentSnapshot> get snapshotTagPostList => _snapshotTagPostList;



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

  //------------------------------------------Tag Message StreamControllers-----------------------------------------

  final StreamController<List<DocumentSnapshot>> _listTagMessageController = StreamController<List<DocumentSnapshot>>.broadcast();

  StreamSink<List<DocumentSnapshot>> get _listTagMessageControllerSink => _listTagMessageController.sink;
  Stream<List<DocumentSnapshot>> get listTagMessageControllerStream => _listTagMessageController.stream;

  final StreamController<FetchMoreTagMessageEvent> _fetchMoreMessageController = StreamController<FetchMoreTagMessageEvent>.broadcast();

  StreamSink<FetchMoreTagMessageEvent> get fetchMoreMessageControllerSink => _fetchMoreMessageController.sink;
  Stream<FetchMoreTagMessageEvent> get _fetchMoreMessageControllerStream => _fetchMoreMessageController.stream;


  final StreamController<bool> _loadingMessageController = StreamController<bool>.broadcast();

  StreamSink<bool> get _loadingMessageControllerSink => _loadingMessageController.sink;
  Stream<bool> get loadingMessageControllerStream => _loadingMessageController.stream;

  //-----------------------------------------------------------------------------------------------------------------


  //------------------------------------------Tag Post StreamController------------------------------------------------

  final StreamController<List<DocumentSnapshot>> _listTagPostController = StreamController<List<DocumentSnapshot>>.broadcast();

  StreamSink<List<DocumentSnapshot>> get _listTagPostControllerSink => _listTagPostController.sink;
  Stream<List<DocumentSnapshot>> get listTagPostControllerStream => _listTagPostController.stream;

  final StreamController<FetchMorePostEvent> _fetchMorePostController = StreamController<FetchMorePostEvent>.broadcast();

  StreamSink<FetchMorePostEvent> get fetchMorePostControllerSink => _fetchMorePostController.sink;
  Stream<FetchMorePostEvent> get _fetchMorePostControllerStream => _fetchMorePostController.stream;


  final StreamController<bool> _loadingPostController = StreamController<bool>.broadcast();

  StreamSink<bool> get _loadingPostControllerSink => _loadingPostController.sink;
  Stream<bool> get loadingPostControllerStream => _loadingPostController.stream;



  void _fetchMoreMessage(FetchMoreTagMessageEvent event) async {
    if(_messageEdgeReached) return;
    print("-*-*-*-*-*-*-*-*-*-fetching more message-*-*-*-*-*-*-*-*-*-*-*-*-*");
    _fetchingMessage=true;
    _loadingPostControllerSink.add(_fetchingMessage);
    Firestore.instance.collection("Tags").document(_tag.id)
      .collection("TagsMessage").orderBy("id",descending:true)
      .startAfter([_lastMessageFetched.documentID]).limit(10).getDocuments().then((snap){
        if(snap.documents.length>0) _lastMessageFetched=snap.documents[snap.documents.length-1];
        if(snap.documents.length<10) _messageEdgeReached=true;
        _snapshotTagMessageList.addAll(snap.documents);
        _listTagMessageControllerSink.add(_snapshotTagMessageList);
        _fetchingMessage=false;
        _loadingPostControllerSink.add(_fetchingMessage);
      });
  }



  void _onNewMessageSnapshot(QuerySnapshot snapshot){
    if(_snapshotTagMessageList.length!=0){
      snapshot.documentChanges.forEach((DocumentChange doc){
        final int t1=int.parse(doc.document.data["timeStamp"]);
        final int t2=int.parse(_snapshotTagMessageList.elementAt(0).data["timeStamp"]);
        final String id1 = doc.document.documentID;
        final String id2 = _snapshotTagMessageList.elementAt(0).documentID;
        print("new doc : "+doc.document.data["content"]+t1.toString()+id1);
        print("lastDoc : "+_snapshotTagMessageList.elementAt(0).data["content"]+t2.toString()+id2);
        if(doc.type==DocumentChangeType.added &&  t1 >= t2 && id1!=id2 ){
            print("added!!!!!!!");
            _snapshotTagMessageList.insert(0,doc.document);
        }
      });
    }
    if(_snapshotTagMessageList.length==0 && snapshot.documents.length!=0) {
      _snapshotTagMessageList.addAll(snapshot.documents);
      _lastMessageFetched=snapshot.documents[snapshot.documents.length-1];
    }
    _listTagMessageControllerSink.add(_snapshotTagMessageList);
  }

  void _onNewPostSnapshot(QuerySnapshot snapshot){
    if(_snapshotTagPostList.length!=0){
      snapshot.documentChanges.forEach((DocumentChange doc){
        final int t1=int.parse(doc.document.data["timeStamp"]);
        final int t2=int.parse(_snapshotTagPostList.elementAt(0).data["timeStamp"]);
        final String id1 = doc.document.documentID;
        final String id2 = _snapshotTagPostList.elementAt(0).documentID;
        print("new doc : "+doc.document.data["description"]+t1.toString()+id1);
        print("lastDoc : "+_snapshotTagPostList.elementAt(0).data["description"]+t2.toString()+id2);
        if(doc.type==DocumentChangeType.added &&  t1 >= t2 && id1!=id2 ){
            print("added!!!!!!!");
            _snapshotTagPostList.insert(0,doc.document);
        }
      });
    }
    if(_snapshotTagPostList.length==0 && snapshot.documents.length!=0) {
      _snapshotTagPostList.addAll(snapshot.documents);
      _lastPostFetched=snapshot.documents[snapshot.documents.length-1];
    }
    _listTagPostControllerSink.add(_snapshotTagPostList);
  }

  void _fetchMorePost(FetchMorePostEvent event) async {
    if(_postEdgeReached) return;
    print("-*-*-*-*-*-*-*-*-*-fetching more post-*-*-*-*-*-*-*-*-*-*-*-*-*");
    _fetchingPost=true;
    _loadingPostControllerSink.add(_fetchingPost);
    Firestore.instance.collection("Tags").document(_tag.id)
      .collection("TagsPost").orderBy("id",descending:true)
      .startAfter([_lastPostFetched.documentID]).limit(2).getDocuments().then((snap){
        if(snap.documents.length>0) _lastPostFetched=snap.documents[snap.documents.length-1];
        if(snap.documents.length<2) _postEdgeReached=true;
        _snapshotTagPostList.addAll(snap.documents);
        _listTagPostControllerSink.add(_snapshotTagPostList);
        _fetchingPost=false;
        _loadingPostControllerSink.add(_fetchingPost);
      });
  }



  BlocTagsPage(this._tag,keyGallery,keyChat) {
    print("-------------create blotagPage------------");
    _listPage=[TagsGallery(_tag,this,key: keyGallery,),TagsChat(_tag,this,key:keyChat)];
    numTabStream.listen(_onTabChange);

    //---------------------Tag Message Stream---------------------------

    Firestore.instance.collection("Tags").document(_tag.id)
      .collection("TagsMessage").orderBy("id",descending:true).limit(10).snapshots().listen(_onNewMessageSnapshot);
    _fetchMoreMessageControllerStream.listen(_fetchMoreMessage);

    //-----------------------------------------------------------------

    //---------------------Tag Post Stream-----------------------------


    Firestore.instance.collection("Tags").document(_tag.id)
      .collection("TagsPost").orderBy("id",descending:true).limit(2).snapshots().listen(_onNewPostSnapshot);
    _fetchMorePostControllerStream.listen(_fetchMorePost);

    //-----------------------------------------------------------------
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
    _listTagPostController.close();
    _loadingPostController.close();

    // TODO: implement dispose
  }



  



}