import 'dart:async';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Models/user.dart';
import 'package:tags/Utils/firebase_db.dart';
import '../Utils/geolocalisation.dart';



class MainBloc extends BlocBase {
  //Mettre MainBloc dans HomeBlocPage et wrap HomePage dans un std qui prend en stream getUser
  //il faudra gérer les updates de User si par exemple il change de photo ou de UserName
  //avec un event updateUser qui modfie _currentUser avec les nouvelles données.

  StreamSubscription _firestoreSub;

  //TODO : peut il y avoir un problème avec la pagination si
  //on fectMoreTags alors qu'on ne se trouve plus dans la zone

  
  //TODO: mettre l'initialisation et l'actualisation de la position dans le MainBloc

  //-----------------------------------------ListTagsController--------------------------------------


  List<DocumentSnapshot> _snapshotTagsList=List<DocumentSnapshot>();
  List<DocumentSnapshot> get snapshotTagsList => _snapshotTagsList;
  

  final StreamController<List<DocumentSnapshot>> _listTagsController = StreamController<List<DocumentSnapshot>>.broadcast();

  StreamSink<List<DocumentSnapshot>> get _listTagsControllerSink => _listTagsController.sink;
  Stream<List<DocumentSnapshot>> get listTagsControllerStream => _listTagsController.stream;








  void _onNewTagsSnapshot(List<DocumentSnapshot> snapshot){
    _snapshotTagsList=snapshot;
    print("_onNewTagsSnapshot TRIGGERED *************"+snapshot.toString());
    _listTagsControllerSink.add(snapshot);
  }


  



  MainBloc(){
    Geolocalisation.getUserPosition().then((LocationData userLocation){
      userCurrentPosition=userLocation;
      _userPositionControllerSink.add(userCurrentPosition);
      print("latitude : "+ userCurrentPosition.latitude.toString());
      print("longitude : "+ userCurrentPosition.longitude.toString());
      GeoFirePoint center = db.geoflutterfire.point(latitude : userCurrentPosition.latitude, longitude : userCurrentPosition.longitude);
        Query init = Firestore.instance.collection("Tags");
        db.geoflutterfire.collection(collectionRef: init).within(
          strictMode: false,
          center: center,
          field: "position",
          radius: 10,
        ).listen(_onNewTagsSnapshot);
    });
    _provideCurrentUser();
    }
  
    @override
    void dispose() {
      _listTagsController.close();
      _firestoreSub.cancel();
      _userUpdateController.close();
      _listConvController.close();
      _userPositionController.close();
      _newMessageController.close();
      _listUserPostController.close();
      _newCommentController.close();
      _newEventController.close();
      // TODO: implement dispose
    }
  

  
  

  //TODO: Sert pour l'initial data des stb,
  //TODO:a changer car ca va poser problème si le serveur met trop de temps à répondre à la requête
  
  

  //-------------------------------------------User Controller-------------------------------------------
  static User _currentUser;
  CachedNetworkImageProvider _userPhoto;
  LocationData userCurrentPosition;
  User get currentUser => _currentUser;
  CachedNetworkImageProvider get userPhoto => _userPhoto;

    void setCurrentUser(User user){
        _currentUser=user;
    }


  final StreamController<User> _userUpdateController = StreamController<User>.broadcast();

  StreamSink<User> get _userUpdateControllerSink => _userUpdateController.sink;

  Stream<User> get userUpdateControllerStream => _userUpdateController.stream;

  final StreamController<LocationData> _userPositionController = StreamController<LocationData>.broadcast();

  StreamSink<LocationData> get _userPositionControllerSink => _userPositionController.sink;

  Stream<LocationData> get userPositionControllerStream => _userPositionController.stream;
  
  void _provideCurrentUser() async {
      _currentUser = await db.getCurrentUser();
      db.userRef.document(currentUser.id).snapshots().listen(onCurrentUserUpdate);
      Firestore.instance.collection("User").document(currentUser.id).collection("Discussion").orderBy("timeStamp",descending: true).snapshots().listen(_onNewMessage);
      Firestore.instance.collection("User").document(currentUser.id).collection("UserPost").orderBy("timeStamp",descending : true).snapshots().listen(_onNewComment);
    }

  
  
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


  //-----------------------------------------new Comment Event Controller--------------------------------------

  QuerySnapshot userPostSnapshot;
  bool newComment=false;

  StreamController<bool> _newCommentController = StreamController<bool>.broadcast();

  StreamSink<bool> get _newCommentControllerSink => _newCommentController.sink;
  Stream<bool> get newCommentControllerStream => _newCommentController.stream;



  StreamController<QuerySnapshot> _listUserPostController = StreamController<QuerySnapshot>.broadcast();

  StreamSink<QuerySnapshot> get _listUserPostControllerSink => _listUserPostController.sink;
  Stream<QuerySnapshot> get listUserPostControllerStream => _listUserPostController.stream;

  void _onNewComment(QuerySnapshot snapshot){
      newComment=false;
      userPostSnapshot=snapshot;
      snapshot.documents.forEach((DocumentSnapshot docSnap){
        if(docSnap.data["lastCommentSeen"]!=true) newComment =true;
      });
      _sendNewEvent();
      _newCommentControllerSink.add(newComment);
      _listUserPostControllerSink.add(snapshot);
    }

  //----------------------------------new Message Event Controller---------------------------------------

  QuerySnapshot userDiscussionSnapshot;
  bool newMessage=false;

  StreamController<QuerySnapshot> _listConvController = StreamController<QuerySnapshot>.broadcast();

  StreamSink<QuerySnapshot> get _listConvControllerSink => _listConvController.sink;
  Stream<QuerySnapshot> get listConvControllerStream => _listConvController.stream;



  StreamController<bool> _newMessageController = StreamController<bool>.broadcast();

  StreamSink<bool> get _newMessageControllerSink => _newMessageController.sink;
  Stream<bool> get newMessageControllerStream => _newMessageController.stream;

  void _onNewMessage(QuerySnapshot snapshot){
      newMessage=false;
      userDiscussionSnapshot=snapshot;
      snapshot.documents.forEach((DocumentSnapshot docSnap){
        if(docSnap.data["lastMessageSeen"]!=true) newMessage =true;
      });
      _sendNewEvent();
      _newMessageControllerSink.add(newMessage);
      _listConvControllerSink.add(snapshot);
    }
  
  
//----------------------------------- new Event Controller -------------------------------------------

    

    StreamController<bool> _newEventController = StreamController<bool>.broadcast();

    StreamSink<bool> get _newEventControllerSink => _newEventController.sink;
    Stream<bool> get newEventControllerStream => _newEventController.stream;

    void _sendNewEvent(){
      _newEventControllerSink.add(newComment||newMessage);
    }


    
  }