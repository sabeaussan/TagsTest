
import 'dart:async';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Models/user.dart';
import 'package:tags/Utils/firebase_db.dart';



class MainBloc extends BlocBase {
  //Mettre MainBloc dans HomeBlocPage et wrap HomePage dans un std qui prend en stream getUser
  //il faudra gérer les updates de User si par exemple il change de photo ou de UserName
  //avec un event updateUser qui modfie _currentUser avec les nouvelles données.

  static User _currentUser;

  CachedNetworkImageProvider _userPhoto;

  bool newMessage=false;
  bool newComment=false;

  //TODO: Sert pour l'initial data des stb,
  //TODO:a changer car ca va poser problème si le serveur met trop de temps à répondre à la requête
  QuerySnapshot userPostSnapshot;
  QuerySnapshot userDiscussionSnapshot;



  final StreamController<User> _userUpdateController = StreamController<User>.broadcast();

  StreamSink<User> get _userUpdateControllerSink => _userUpdateController.sink;

  Stream<User> get userUpdateControllerStream => _userUpdateController.stream;
  
  
  /*StreamController<QuerySnapshot> _listTagsPageController = StreamController<QuerySnapshot>.broadcast();

  StreamSink<QuerySnapshot> get _listTagsPageControllerSink => _listTagsPageController.sink;
  Stream<QuerySnapshot> get listTagsPageControllerStream => _listTagsPageController.stream;*/

  StreamController<QuerySnapshot> _listConvController = StreamController<QuerySnapshot>.broadcast();

  StreamSink<QuerySnapshot> get _listConvControllerSink => _listConvController.sink;
  Stream<QuerySnapshot> get listConvControllerStream => _listConvController.stream;


  StreamController<bool> _newEventController = StreamController<bool>.broadcast();

  StreamSink<bool> get _newEventControllerSink => _newEventController.sink;
  Stream<bool> get newEventControllerStream => _newEventController.stream;


  StreamController<bool> _newMessageController = StreamController<bool>.broadcast();

  StreamSink<bool> get _newMessageControllerSink => _newMessageController.sink;
  Stream<bool> get newMessageControllerStream => _newMessageController.stream;

  StreamController<bool> _newCommentController = StreamController<bool>.broadcast();

  StreamSink<bool> get _newCommentControllerSink => _newCommentController.sink;
  Stream<bool> get newCommentControllerStream => _newCommentController.stream;



  StreamController<QuerySnapshot> _listUserPostController = StreamController<QuerySnapshot>.broadcast();

  StreamSink<QuerySnapshot> get _listUserPostControllerSink => _listUserPostController.sink;
  Stream<QuerySnapshot> get listUserPostControllerStream => _listUserPostController.stream;
  
  
    void _provideCurrentUser() async {
      _currentUser = await db.getCurrentUser();
      db.userRef.document(currentUser.id).snapshots().listen(onCurrentUserUpdate);
      Firestore.instance.collection("User").document(currentUser.id).collection("Discussion").orderBy("timeStamp",descending: true).snapshots().listen(_onNewMessage);
      Firestore.instance.collection("User").document(currentUser.id).collection("UserPost").snapshots().listen(_onNewComment);
    }

    void _onNewComment(QuerySnapshot snapshot){
      newComment=false;
      userPostSnapshot=snapshot;
      print("----------[_onNewComment] triggered-------------");
      snapshot.documents.forEach((DocumentSnapshot docSnap){
        print(docSnap.documentID);
        print(docSnap.data["lastCommentSeen"]);
        if(docSnap.data["lastCommentSeen"]!=true) newComment =true;
      });
      print("--------- after check newComment --------"+newComment.toString());
      _sendNewEvent();
      _newCommentControllerSink.add(newComment);
      print("new userPostSnapshot" + snapshot.toString());
      _listUserPostControllerSink.add(snapshot);
    }

    void _sendNewEvent(){
      _newEventControllerSink.add(newComment||newMessage);
    }

    

    void _onNewMessage(QuerySnapshot snapshot){
      newMessage=false;
      userDiscussionSnapshot=snapshot;
      print("----------[_onNewMessage] triggered-------------");
      snapshot.documents.forEach((DocumentSnapshot docSnap){
        print(docSnap.documentID);
        print(docSnap.data["lastMessageSeen"]);
        if(docSnap.data["lastMessageSeen"]!=true) newMessage =true;
      });
      print("--------- after check newMessage --------"+newMessage.toString());
      _sendNewEvent();
      _newMessageControllerSink.add(newMessage);
      _listConvControllerSink.add(snapshot);
    }

    MainBloc(){
      print("***********[MainBloc créé]***********");
      _provideCurrentUser();
      
    }
  
    User get currentUser => _currentUser;

    void setCurrentUser(User user){
        _currentUser=user;
    }
    CachedNetworkImageProvider get userPhoto => _userPhoto;
  
    void onCurrentUserUpdate (DocumentSnapshot snapshot){
      print("***********[User updated] *************");
      _currentUser=User.fromDocumentSnapshot(snapshot);
      //TODO : changer ca car s active a chaque changement 
      if(currentUser.photoUrl!=null){
        _userPhoto=CachedNetworkImageProvider(_currentUser.photoUrl);
        print("[onCurrentUserUpdate] getting photo");
      }
      _userUpdateControllerSink.add(currentUser);
    }
       
  
  
  
    @override
    void dispose() {
      _userUpdateController.close();
      //_listTagsPageController.close();
      _listConvController.close();
      _newMessageController.close();
      _listUserPostController.close();
      _newCommentController.close();
      // TODO: implement dispose
    }
    
  }