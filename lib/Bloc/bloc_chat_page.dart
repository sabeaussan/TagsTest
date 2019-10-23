import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Event/events.dart';

class BlocChatPage implements BlocBase {
  StreamSubscription _firestoreSub;
  StreamSubscription _fetchMoreChatMessageSub;

  final String _discussionId;

  static const int NB_MESSAGES_FETCHED = 10;

  BlocChatPage(this._discussionId){
    _firestoreSub = Firestore.instance.collection("Discussions").document(_discussionId).collection("Message")
    .limit(NB_MESSAGES_FETCHED).orderBy("timeStamp",descending: true).snapshots().listen(_onNewChatMessageSnapshot);
    _fetchMoreChatMessageSub =_fetchMoreChatMessageControllerStream.listen(_fetchMoreChatMessage);


  }


  //-----------------------------------------ListChatMessageController--------------------------------------


  
  List<DocumentSnapshot> _chatMessageList=List<DocumentSnapshot>();
  DocumentSnapshot _lastChatMessageFetched;
  bool _chatMessageEdgeReached=false;
  bool _fetchingChatMessage=false;

  List<DocumentSnapshot> get chatMessageList => _chatMessageList;
  

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
    .startAfterDocument(_lastChatMessageFetched).limit(NB_MESSAGES_FETCHED).orderBy("timeStamp",descending: true).getDocuments().then((snap){
        if(snap.documents.length>0) _lastChatMessageFetched=snap.documents[snap.documents.length-1];
        if(snap.documents.length<NB_MESSAGES_FETCHED) _chatMessageEdgeReached=true;
        _chatMessageList.addAll(snap.documents);
        _listChatMessageControllerSink.add(_chatMessageList);
        _fetchingChatMessage=false;
        _loadingChatMessageControllerSink.add(_fetchingChatMessage);
      });
  }



  void _onNewChatMessageSnapshot(QuerySnapshot snapshot){
    if(_chatMessageList.length!=0){
      snapshot.documentChanges.forEach((DocumentChange doc){
        /*final int t1=int.parse(doc.document.data["timeStamp"]);
        final int t2=int.parse(_snapshotChatMessageList.elementAt(0).data["timeStamp"]);*/
        final String id1 = doc.document.documentID;
        final String id2 = _chatMessageList.elementAt(0).documentID;
        print("new doc : "+doc.document.data["content"]+id1);
        print("lastDoc : "+_chatMessageList.elementAt(0).data["content"]+id2);
        if(doc.type==DocumentChangeType.added &&  /*t1 >= t2 &&*/ id1!=id2 ){
            print("added!!!!!!!");
            _chatMessageList.insert(0,doc.document);
        }
      });
    }
    if(_chatMessageList.length==0 && snapshot.documents.length!=0) {
      _chatMessageList.addAll(snapshot.documents);
      print("first doc added!!!!!!!");
      _lastChatMessageFetched=snapshot.documents[snapshot.documents.length-1];
      if(snapshot.documents.length < NB_MESSAGES_FETCHED) _chatMessageEdgeReached=true;
    }
    _listChatMessageControllerSink.add(_chatMessageList);
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