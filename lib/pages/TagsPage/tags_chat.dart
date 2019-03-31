import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tags/Models/tags.dart';
import 'package:tags/UI/message_tile.dart';

class TagsChat extends StatefulWidget {
  //Contient le chat associé à un tags
  //TODO: va peut être falloir le transformer en stful

  final Tags tag;
  final Set<DocumentSnapshot> _snapshotList;

  TagsChat(this.tag,this._snapshotList,{Key key}):super(key:key);

  @override
  TagsChatState createState() {
    return new TagsChatState();
  }
}

class TagsChatState extends State<TagsChat>{

  ScrollController _scrollController;
  DocumentSnapshot _lastDocFetched;
  Stream<QuerySnapshot> _paginatedQuery;
  List<DocumentSnapshot> _snapshotTagMessageList=List<DocumentSnapshot>();
  List<DocumentSnapshot> temp=List<DocumentSnapshot>();
  bool _edgeReached=false;
  bool _fetching=false;
  

  //TODO: faire un cache pour ne pas recharger les info déja afficher 

  void _fetchMoreMessage() async {
    if(_edgeReached) return;
    if(_scrollController.position.pixels==_scrollController.position.maxScrollExtent){
        Firestore.instance.collection("Tags").document(widget.tag.id)
          .collection("TagsMessage").orderBy("id",descending:true)
          .startAfter([_lastDocFetched.documentID]).limit(10).getDocuments().then((snap){
              
              setState(() {
                _fetching=true;
                print("-*-*-*-*-*-*-*-*-*-limit de document atteinte-*-*-*-*-*-*-*-*-*-*-*-*-*");
                if(snap.documents.length>0) _lastDocFetched=snap.documents[snap.documents.length-1];
                if(snap.documents.length<10) _edgeReached=true;
                _snapshotTagMessageList.addAll(snap.documents);
            });
          });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("---------[initState tagsChat]-----------");
    _paginatedQuery = Firestore.instance.collection("Tags").document(widget.tag.id)
      .collection("TagsMessage").orderBy("id",descending:true).limit(10).snapshots();
    _scrollController = ScrollController();
    _scrollController.addListener(_fetchMoreMessage);
  }
  
  
  @override
  Widget build(BuildContext context) {
    String blabla="3";
    
    return StreamBuilder(
      stream: _paginatedQuery ,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
        if(!snapshot.hasData){
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.data.documents.length==0) {
            return Center(
              child: Text("ajoute un premier message !"),
            );
          }
          
          if(_snapshotTagMessageList.length!=0){
              snapshot.data.documentChanges.forEach((DocumentChange doc){
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
          if(_snapshotTagMessageList.length==0 /*&& !_fetching*/) {
            _snapshotTagMessageList.addAll(snapshot.data.documents);
            _lastDocFetched=snapshot.data.documents[snapshot.data.documents.length-1];
          }
          print(_snapshotTagMessageList);
          
        print("******[stb tagsChat] trigered********* "+snapshot.data.documents.length.toString());
        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          itemCount: _snapshotTagMessageList.length,
          addAutomaticKeepAlives: true,
          itemBuilder: (BuildContext context, int index) {
            _fetching=false;
            return Column(
              children: <Widget>[
                MessageTile.fromDocumentSnapshot(_snapshotTagMessageList[index]),
                Divider()
              ],
            );
          }
        );
      }
    );
  }

 
}
