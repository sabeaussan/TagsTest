




import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Event/events.dart';


class BlocCommentsPage implements BlocBase {
  StreamSubscription _firestoreSub;
  StreamSubscription _fetchMoreSub;

  final String _postId;

  BlocCommentsPage(this._postId){
    _firestoreSub = Firestore.instance.collection("PostComments").document(_postId)
      .collection("Comments").limit(15).orderBy("id",descending:true).snapshots().listen(_onNewMessageSnapshot);
    _fetchMoreSub = _fetchMoreCommentsControllerStream.listen(_fetchMoreComments);
  }

  @override
  void dispose() {
    _listPostCommentsController.close();
    _fetchMoreCommentsController.close();
    _loadingCommentsController.close();
    _firestoreSub.cancel();
    _fetchMoreSub.cancel();
    // TODO: implement dispose
  }


  //-----------------------------------------PostCommentsController--------------------------------------


  
  List<DocumentSnapshot> _snapshotPostCommentsList=List<DocumentSnapshot>();
  DocumentSnapshot _lastCommentsFetched;
  bool _commentsEdgeReached=false;
  bool _fetchingComments=false;

  List<DocumentSnapshot> get snapshotPostCommentsList => _snapshotPostCommentsList;
  

  final StreamController<List<DocumentSnapshot>> _listPostCommentsController = StreamController<List<DocumentSnapshot>>.broadcast();

  StreamSink<List<DocumentSnapshot>> get _listPostCommentsControllerSink => _listPostCommentsController.sink;
  Stream<List<DocumentSnapshot>> get listPostCommentsControllerStream => _listPostCommentsController.stream;

  final StreamController<FetchMoreCommentEvent> _fetchMoreCommentsController = StreamController<FetchMoreCommentEvent>.broadcast();

  StreamSink<FetchMoreCommentEvent> get fetchMoreCommentsControllerSink => _fetchMoreCommentsController.sink;
  Stream<FetchMoreCommentEvent> get _fetchMoreCommentsControllerStream => _fetchMoreCommentsController.stream;


  final StreamController<bool> _loadingCommentsController = StreamController<bool>.broadcast();

  StreamSink<bool> get _loadingCommentsControllerSink => _loadingCommentsController.sink;
  Stream<bool> get loadingCommentsControllerStream => _loadingCommentsController.stream;





  void _fetchMoreComments(FetchMoreCommentEvent event) async {
    if(_commentsEdgeReached) return;
    print("-*-*-*-*-*-*-*-*-*-fetching more comments-*-*-*-*-*-*-*-*-*-*-*-*-*");
    _fetchingComments=true;
    _loadingCommentsControllerSink.add(_fetchingComments);
    Firestore.instance.collection("PostComments").document(_postId)
      .collection("Comments").orderBy("id",descending:true)
      .startAfter([_lastCommentsFetched.documentID]).limit(15).getDocuments().then((snap){
        if(snap.documents.length>0) _lastCommentsFetched=snap.documents[snap.documents.length-1];
        if(snap.documents.length<15) _commentsEdgeReached=true;
        _snapshotPostCommentsList.addAll(snap.documents);
        _listPostCommentsControllerSink.add(_snapshotPostCommentsList);
        _fetchingComments=false;
        _loadingCommentsControllerSink.add(_fetchingComments);
      });
  }



  void _onNewMessageSnapshot(QuerySnapshot snapshot){
    if(_snapshotPostCommentsList.length!=0){
      snapshot.documentChanges.forEach((DocumentChange doc){
        final int t1=int.parse(doc.document.data["timeStamp"]);
        final int t2=int.parse(_snapshotPostCommentsList.elementAt(0).data["timeStamp"]);
        final String id1 = doc.document.documentID;
        final String id2 = _snapshotPostCommentsList.elementAt(0).documentID;
        print("new doc : "+doc.document.data["content"]+t1.toString()+id1);
        print("lastDoc : "+_snapshotPostCommentsList.elementAt(0).data["content"]+t2.toString()+id2);
        if(doc.type==DocumentChangeType.added &&  t1 >= t2 && id1!=id2 ){
            print("added!!!!!!!");
            _snapshotPostCommentsList.insert(0,doc.document);
        }
      });
    }
    if(_snapshotPostCommentsList.length==0) {
      _snapshotPostCommentsList.addAll(snapshot.documents);
      _lastCommentsFetched=snapshot.documents[snapshot.documents.length-1];
    }
    _listPostCommentsControllerSink.add(_snapshotPostCommentsList);
  }



}