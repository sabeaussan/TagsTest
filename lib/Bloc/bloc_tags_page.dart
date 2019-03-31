

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
  DocumentSnapshot _lastDocFetched;
  bool _edgeReached=false;
  bool _fetching=false;

  //liste contient les deux pages d'un tags
  List<Widget> _listPage;


  Tags get tags => _tag;
  List<DocumentSnapshot> get snapshotTagMessageList => _snapshotTagMessageList;



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

  final StreamController<List<DocumentSnapshot>> _listTagMessageController = StreamController<List<DocumentSnapshot>>.broadcast();

  StreamSink<List<DocumentSnapshot>> get _listTagMessageControllerSink => _listTagMessageController.sink;
  Stream<List<DocumentSnapshot>> get listTagMessageControllerStream => _listTagMessageController.stream;

  final StreamController<FetchMoreEvent> _fetchMoreContentController = StreamController<FetchMoreEvent>.broadcast();

  StreamSink<FetchMoreEvent> get fetchMoreContentControllerSink => _fetchMoreContentController.sink;
  Stream<FetchMoreEvent> get _fetchMoreContentControllerStream => _fetchMoreContentController.stream;


  final StreamController<bool> _loadindController = StreamController<bool>.broadcast();

  StreamSink<bool> get _loadindControllerSink => _loadindController.sink;
  Stream<bool> get loadindControllerStream => _loadindController.stream;




  void _fetchMoreMessage(FetchMoreEvent event) async {
    if(_edgeReached) return;
    _fetching=true;
    _loadindControllerSink.add(_fetching);
    Firestore.instance.collection("Tags").document(_tag.id)
      .collection("TagsMessage").orderBy("id",descending:true)
      .startAfter([_lastDocFetched.documentID]).limit(10).getDocuments().then((snap){
        print("-*-*-*-*-*-*-*-*-*-fetching more message-*-*-*-*-*-*-*-*-*-*-*-*-*");
        if(snap.documents.length>0) _lastDocFetched=snap.documents[snap.documents.length-1];
        if(snap.documents.length<10) _edgeReached=true;
        _snapshotTagMessageList.addAll(snap.documents);
        _listTagMessageControllerSink.add(_snapshotTagMessageList);
        _fetching=false;
        _loadindControllerSink.add(_fetching);
      });
  }



  void _onNewSnapshot(QuerySnapshot snapshot){
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
    if(_snapshotTagMessageList.length==0) {
      _snapshotTagMessageList.addAll(snapshot.documents);
      _lastDocFetched=snapshot.documents[snapshot.documents.length-1];
    }
    _listTagMessageControllerSink.add(_snapshotTagMessageList);
  }



  BlocTagsPage(this._tag,keyGallery,keyChat) {
    _listPage=[TagsGallery(_tag,key: keyGallery,),TagsChat(_tag,this,key:keyChat)];
    numTabStream.listen(_onTabChange);
    Firestore.instance.collection("Tags").document(_tag.id)
      .collection("TagsMessage").orderBy("id",descending:true).limit(10).snapshots().listen(_onNewSnapshot);
    _fetchMoreContentControllerStream.listen(_fetchMoreMessage);
  }

  void _onTabChange(int numTab){
    _widgetPageSink.add(_listPage[numTab]);
  }

  @override
  void dispose() {
    _numTabController.close();
    _widgetPageController.close();
    _listTagsPageController.close();
    _listTagMessageController.close();
    _fetchMoreContentController.close();
    _listTagsPageControllerSink.close();
    _loadindController.close();
    // TODO: implement dispose
  }



  



}