


import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Models/discussion.dart';
import 'package:tags/Models/user.dart';

class BlocMessageBoxPage extends BlocBase{

  StreamController<QuerySnapshot> _discussionController = StreamController<QuerySnapshot>.broadcast();

  StreamSink get _discussionControllerSink => _discussionController.sink;
  Stream get discussionControllerStream => _discussionController.stream;

  BlocMessageBoxPage(User currentUser){
    Firestore.instance.collection("User").document(currentUser.id).collection("Discussion")
      .snapshots().listen(_onNewDiscussion);

  }

  void _onNewDiscussion(QuerySnapshot discussion){
    _discussionControllerSink.add(discussion);
  }

  @override
  void dispose() {
    _discussionController.close();
    // TODO: implement dispose
  }
  
}