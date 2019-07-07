import 'dart:async';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Event/events.dart';
import 'package:tags/Models/tags.dart';
import 'package:tags/Models/user.dart';
import 'package:tags/Utils/firebase_db.dart';
import '../Utils/geolocalisation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';



class MainBloc extends BlocBase {
  //Mettre MainBloc dans HomeBlocPage et wrap HomePage dans un std qui prend en stream getUser
  //il faudra gérer les updates de User si par exemple il change de photo ou de UserName
  //avec un event updateUser qui modfie _currentUser avec les nouvelles données.

  StreamSubscription _firestoreSub;
  Location _userLocation= Location();
  //TODO : peut il y avoir un problème avec la pagination si
  //on fectMoreTags alors qu'on ne se trouve plus dans la zone

  
  bool _favTagsEdgeReached=false;

  void setFavTagsEdgeReached(bool favTagsEdgeReached){
    this._favTagsEdgeReached=favTagsEdgeReached;
  }

  bool _fetchingPost=false;
  int _lastIndexFetched;

  //TODO: mettre l'initialisation et l'actualisation de la position dans le MainBloc

  //-----------------------------------------ListTagsController--------------------------------------

  List<DocumentSnapshot> _snapshotTagsList=List<DocumentSnapshot>();
  List<Tags> _filteredTagsList=List<Tags>();
  List<DocumentSnapshot> get snapshotTagsList => _snapshotTagsList;
  List<Tags> get filteredSnapshotTagsList => _filteredTagsList;

  List<Tags> _mostPopularTags=List<Tags>();
  List<Tags> get mostPopularTags => _mostPopularTags;

  List<Tags> _listFavTags = List<Tags>();
  List<Tags> get listFavTags => _listFavTags;

  final StreamController<List<DocumentSnapshot>> _listMarkerTagsController = StreamController<List<DocumentSnapshot>>.broadcast();

  StreamSink<List<DocumentSnapshot>> get _listMarkerTagsControllerSink => _listMarkerTagsController.sink;
  Stream<List<DocumentSnapshot>> get listMarkerTagsControllerStream => _listMarkerTagsController.stream;

  final StreamController<List<Tags>> _listTagsController = StreamController<List<Tags>>.broadcast();

  StreamSink<List<Tags>> get _listTagsControllerSink => _listTagsController.sink;
  Stream<List<Tags>> get listTagsControllerStream => _listTagsController.stream;

  final StreamController<List<Tags>> _listPopularTagsController = StreamController<List<Tags>>.broadcast();

  StreamSink<List<Tags>> get _listPopularTagsControllerSink => _listPopularTagsController.sink;
  Stream<List<Tags>> get listPopularTagsControllerStream => _listPopularTagsController.stream;



  bool getFavStatus(String tagsId){
     if(_currentUser.favTagsId!=null) return _currentUser.favTagsId.contains(tagsId);
     return false;
  } 



  void _onNewTagsSnapshot(List<DocumentSnapshot> snapshot){
    _snapshotTagsList=snapshot;
    _tagsFilter(snapshot);
    _listMarkerTagsControllerSink.add(snapshot);
  }

  void _tagsFilter(List<DocumentSnapshot> snapshot){
    List<Tags> filteredList = List<Tags>();
    List<Tags> temp = List<Tags>();
    _mostPopularTags=[];
    int totalPopularity=0;
    int popularity;
    snapshot.forEach((DocumentSnapshot tags){
      //TODO : c'est de la merde comme solution
      //déplacer ça pour que la mapPage puisse aussi avoir accès 
      //à l'info isFav
      //TODO: calculer le distanceLabel ici
      final Tags tag = Tags.fromDocumentSnapshot(tags);
      final bool isFav = getFavStatus(tags.documentID);
      GeoFirePoint tagPosition = GeoFirePoint(tags.data["position"]["geopoint"].latitude, tags.data["position"]["geopoint"].longitude);
      final double distance=tagPosition.distance(lat: _userCurrentPosition.latitude,lng: _userCurrentPosition.longitude);
      tag.setDistance(distance);
      popularity=tags.data["nbFav"]+tags.data["nbPost"];
      tag.setPopularity(popularity);
      temp.add(tag);
      totalPopularity+=popularity;
      tag.setFavStatus(isFav);
      if(distance<=2 ){ 
        filteredList.add(tag);
      }
    });
    temp.forEach((Tags tag){
      print("tag name: "+tag.name+" tag pop : "+tag.popularity.toString());
      if(snapshot.length!=0){
        if(tag.popularity>=totalPopularity~/(snapshot.length)) mostPopularTags.add(tag);
      }
    });
    _listPopularTagsControllerSink.add(mostPopularTags);
    _filteredTagsList=filteredList;
    _listTagsControllerSink.add(filteredList);
  }

  void _onLocationChanged(LocationData updatedLocation){
    print("************* LOCATION CHANGED BY 5 M ******************");
    if(Geolocalisation.gmController!=null){
      Geolocalisation.gmController.moveCamera(
      CameraUpdate.newCameraPosition(CameraPosition(
        zoom: 14.0,
        target: LatLng(updatedLocation.latitude, updatedLocation.longitude)
      ))
      );
    }
    _userCurrentPosition=updatedLocation;
    _tagsFilter(_snapshotTagsList);
  }

  //------------------------------------------FavTag StreamControllers-----------------------------------------

  final StreamController<List<Tags>> _listFavTagController = StreamController<List<Tags>>.broadcast();

  StreamSink<List<Tags>> get _listFavTagControllerSink => _listFavTagController.sink;
  Stream<List<Tags>> get listFavTagControllerStream => _listFavTagController.stream;

  final StreamController<FetchMoreFavTagsEvent> _fetchMoreFavTagController = StreamController<FetchMoreFavTagsEvent>.broadcast();

  StreamSink<FetchMoreFavTagsEvent> get fetchMoreFavTagControllerSink => _fetchMoreFavTagController.sink;
  Stream<FetchMoreFavTagsEvent> get _fetchMoreFavTagControllerStream => _fetchMoreFavTagController.stream;


  final StreamController<bool> _loadingFavTagsController = StreamController<bool>.broadcast();

  StreamSink<bool> get _loadingFavTagsControllerSink => _loadingFavTagsController.sink;
  Stream<bool> get loadingFavTagsControllerStream => _loadingFavTagsController.stream;
  

  void _fetchMoreFavTags(FetchMoreFavTagsEvent e) async {
    int i;
    int edge;
    _listFavTags=[];
    if(_favTagsEdgeReached) return;
    if(e.fetchedIndex+2<=_currentUser.favTagsId.length){
      edge=2;
      if(e.fetchedIndex+2==_currentUser.favTagsId.length)_favTagsEdgeReached=true;
    }
    else {
      if(_currentUser.favTagsId.length==0){
        edge=0;
      }
      else edge=e.fetchedIndex+2-currentUser.favTagsId.length;
      _favTagsEdgeReached=true;
    }
    _fetchingPost=true;
    _loadingFavTagsControllerSink.add(_fetchingPost);
    await Future(() async{
      for(i=e.fetchedIndex;i<e.fetchedIndex+edge;i++){
      final String markId = _currentUser.favTagsId[i];
      print("first");
      var doc = await Firestore.instance.collection("Tags").document(markId).get();
        if(doc.exists){
          final Tags favMark = Tags.fromDocumentSnapshot(doc);
          favMark.setFavStatus(true);
          _listFavTags.add(favMark);
        }
        print(_listFavTags);
    }
    });
    _fetchingPost=false;
    _loadingFavTagsControllerSink.add(_fetchingPost);
    print(_listFavTags);
    _listFavTagControllerSink.add(_listFavTags);
  }

  MainBloc(){
    /*********************FavTags  *************************/
    _fetchMoreFavTagControllerStream.listen(_fetchMoreFavTags);    

    /*****************************************************/
    _userLocation.getLocation().then((LocationData loc){
      _userCurrentPosition=loc;
      _userPositionControllerSink.add(_userCurrentPosition);
      GeoFirePoint center = db.geoflutterfire.point(latitude : _userCurrentPosition.latitude, longitude : _userCurrentPosition.longitude);
        Query init = Firestore.instance.collection("Tags");
        db.geoflutterfire.collection(collectionRef: init).within(
          strictMode: false,
          center: center,
          field: "position",
          radius: 10,
        ).listen(_onNewTagsSnapshot);
    });
    _userLocation.changeSettings(distanceFilter: 10);
    _userLocation.onLocationChanged().listen(_onLocationChanged);
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
  LocationData _userCurrentPosition;
  LocationData get userCurrentPosition => _userCurrentPosition;
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
      //print("***********[User updated] *************");
      _currentUser=User.fromDocumentSnapshot(snapshot);
      //TODO : changer ca car s active a chaque changement 
      if(currentUser.photoUrl!=null){
        _userPhoto=CachedNetworkImageProvider(_currentUser.photoUrl);
        //print("[onCurrentUserUpdate] getting photo");
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