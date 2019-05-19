import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Event/events.dart';

class BlocChatPage implements BlocBase {
  StreamSubscription _firestoreSub;
  StreamSubscription _fetchMoreChatMessageSub;

  final String _discussionId;

  BlocChatPage(this._discussionId){
    _firestoreSub = Firestore.instance.collection("Discussions").document(_discussionId).collection("Message")
    .limit(10).orderBy("id",descending: true).snapshots().listen(_onNewChatMessageSnapshot);
    _fetchMoreChatMessageSub =_fetchMoreChatMessageControllerStream.listen(_fetchMoreChatMessage);


  }


  //-----------------------------------------ListChatMessageController--------------------------------------


  
  List<DocumentSnapshot> _snapshotChatMessageList=List<DocumentSnapshot>();
  DocumentSnapshot _lastChatMessageFetched;
  bool _chatMessageEdgeReached=false;
  bool _fetchingChatMessage=false;

  List<DocumentSnapshot> get snapshotChatMessageList => _snapshotChatMessageList;
  

  final StreamController<List<DocumentSnapshot>> _listChatMessageController = StreamController<List<DocumentSnapshot>>.broadcast();

  StreamSink<List<DocumentSnapshot>> get _listChatMessageControllerSink => _listChatMessageController.sink;
  Stream<List<DocumentSnapshot>> get listChatMessageControllerStream => _listChatMessageController.stream;

  final StreamController<FetchMoreChatMessageEvent> _fetchMoreChatMessageController = StreamController<FetchMoreChatMessageEvent>.broadcast();

  StreamSink<FetchMoreChatMessageEvent> get fetchMoreChatMessageControllerSink => _fetchMoreChatMessageController.sink;
  Stream<FetchMoreChatMessageEvent> get _fetchMoreChatMessageControllerStream => _fetchMoreChatMessageController.stream;


  final StreamController<bool> _loadingChatMessageController = StreamController<bool>.broadcast();

  StreamSink<bool> get _loadingChatMessageControllerSink => _loadingChatMessageController.sink;
  Stream<bool> get loadingChatMessageControllerStream => _loadingChatMessageController.stream;





  void _fetchMoreChatMessage(FetchMoreChatMessageEvent event) async {
    if(_chatMessageEdgeReached) return;
    print("-*-*-*-*-*-*-*-*-*-fetching more comments-*-*-*-*-*-*-*-*-*-*-*-*-*");
    _fetchingChatMessage=true;
    _loadingChatMessageControllerSink.add(_fetchingChatMessage);
    Firestore.instance.collection("Discussions").document(_discussionId).collection("Message")
    .startAfter([_lastChatMessageFetched.documentID]).limit(10).orderBy("id",descending: true).getDocuments().then((snap){
        if(snap.documents.length>0) _lastChatMessageFetched=snap.documents[snap.documents.length-1];
        if(snap.documents.length<10) _chatMessageEdgeReached=true;
        _snapshotChatMessageList.addAll(snap.documents);
        _listChatMessageControllerSink.add(_snapshotChatMessageList);
        _fetchingChatMessage=false;
        _loadingChatMessageControllerSink.add(_fetchingChatMessage);
      });
  }



  void _onNewChatMessageSnapshot(QuerySnapshot snapshot){
    if(_snapshotChatMessageList.length!=0){
      snapshot.documentChanges.forEach((DocumentChange doc){
        /*final int t1=int.parse(doc.document.data["timeStamp"]);
        final int t2=int.parse(_snapshotChatMessageList.elementAt(0).data["timeStamp"]);*/
        final String id1 = doc.document.documentID;
        final String id2 = _snapshotChatMessageList.elementAt(0).documentID;
        print("new doc : "+doc.document.data["content"]+id1);
        print("lastDoc : "+_snapshotChatMessageList.elementAt(0).data["content"]+id2);
        if(doc.type==DocumentChangeType.added &&  /*t1 >= t2 &&*/ id1!=id2 ){
            print("added!!!!!!!");
            _snapshotChatMessageList.insert(0,doc.document);
        }
      });
    }
    if(_snapshotChatMessageList.length==0) {
      _snapshotChatMessageList.addAll(snapshot.documents);
      _lastChatMessageFetched=snapshot.documents[snapshot.documents.length-1];
    }
    _listChatMessageControllerSink.add(_snapshotChatMessageList);
  }

  @override
  void dispose() {
    _listChatMessageController.close();
    _fetchMoreChatMessageController.close();
    _loadingChatMessageController.close();
    _firestoreSub.cancel();
    _fetchMoreChatMessageSub.cancel();
  }


  
  
}