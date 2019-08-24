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

  
  /*bool _favTagsEdgeReached=false;

  void setFavTagsEdgeReached(bool favTagsEdgeReached){
    this._favTagsEdgeReached=favTagsEdgeReached;
  }

  bool _fetchingPost=false;*/


  //TODO: mettre l'initialisation et l'actualisation de la position dans le MainBloc

  //-----------------------------------------ListTagsController--------------------------------------

  List<DocumentSnapshot> _snapshotTagsList=List<DocumentSnapshot>();

  List<Tags> _filteredTagsList=List<Tags>();
  List<Tags> get filteredSnapshotTagsList => _filteredTagsList;
 
  List<Tags> _marksList=List<Tags>();
  List<Tags> get marksList => _marksList;

  List<Tags> _mostPopularTags=List<Tags>();
  List<Tags> get mostPopularTags => _mostPopularTags;

  List<Tags> listFavTags = List<Tags>();
  



  /************************************* StreamController des marker de map_page ***************************/

  final StreamController<List<Tags>> _listMarkerTagsController = StreamController<List<Tags>>.broadcast();

  StreamSink<List<Tags>> get _listMarkerTagsControllerSink => _listMarkerTagsController.sink;
  Stream<List<Tags>> get listMarkerTagsControllerStream => _listMarkerTagsController.stream;


  /************************************* StreamController des marks de list_marks_page ***************************/

  final StreamController<List<Tags>> _listTagsPageController = StreamController<List<Tags>>.broadcast();

  StreamSink<List<Tags>> get _listTagsPageControllerSink => _listTagsPageController.sink;
  Stream<List<Tags>> get listTagsPageControllerStream => _listTagsPageController.stream;

  /************************************* StreamController des marks de popular_fav_page ***************************/

  final StreamController<List<Tags>> _listPopularTagsController = StreamController<List<Tags>>.broadcast();

  StreamSink<List<Tags>> get _listPopularTagsControllerSink => _listPopularTagsController.sink;
  Stream<List<Tags>> get listPopularTagsControllerStream => _listPopularTagsController.stream;



  bool getFavStatus(String tagsId){
     if(_currentUser.favTagsId!=null) return _currentUser.favTagsId.contains(tagsId);
  } 



  void _onNewTagsSnapshot(List<DocumentSnapshot> snapshot){
    //TODO: est triggered 2 fois a chaque fois !!
    _snapshotTagsList=snapshot;
    _tagsFilter(snapshot);
  }

  void _tagsFilter(List<DocumentSnapshot> snapshot){
    /**Cette fonction permet de filtrer les marks qui doivent
     * aller dans la favPage (most Popular), liste des marks a proximité et marker sur googleMap 
     */
        
    _mostPopularTags=[];                    //liste des marks populaire pour popular_fav_page
    _filteredTagsList=[];                   //liste des marks pour list_marks_page
    _marksList=[];                          //liste des marks, utile pour map_page
    int totalPopularity=0;
    int popularity;
    snapshot.forEach((DocumentSnapshot tags){
      final Tags tag = Tags.fromDocumentSnapshot(tags);
      final bool isFav = getFavStatus(tags.documentID);
      GeoFirePoint tagPosition = GeoFirePoint(tag.lat, tag.long);
      final double distance=tagPosition.distance(lat: _userCurrentPosition.latitude,lng: _userCurrentPosition.longitude);
      tag.setDistance(distance);
      popularity=tag.nbFav+tag.nbPost;
      tag.setPopularity(popularity);
      totalPopularity+=popularity;
      tag.setFavStatus(isFav);
      _marksList.add(tag);
      if(distance<=1){
        //Si la mark est dans un rayon de 1km autour de l'utilisateur
        //alors on l'affiche dans la list_marks_page
        _filteredTagsList.add(tag);
      }
    });
    //print("############ AVERAGE POPULARITY : "+(totalPopularity~/(snapshot.length)).toString());
    _marksList.forEach((Tags tag){
      //print("############ NAME : "+tag.name);
      //print("############  POPULARITY : "+tag.popularity.toString());
      if(snapshot.length!=0){
        if(tag.popularity>=totalPopularity~/(snapshot.length)) {
          tag.setIsPopular(true);
          _mostPopularTags.add(tag);
        }
      }
    });
    _listPopularTagsControllerSink.add(_mostPopularTags);    //on ajoute au stream de popular_fav_page
    _listTagsPageControllerSink.add(_filteredTagsList);              //on ajoute au stream de list_marks_page 
    _listMarkerTagsControllerSink.add(_marksList);           //on ajoute au stream de la map_page           
  }

  void _onLocationChanged(LocationData updatedLocation){
    //print("************* LOCATION CHANGED BY 5 M ******************");
    /*if(Geolocalisation.gmController!=null){
      Geolocalisation.gmController.moveCamera(
      CameraUpdate.newCameraPosition(CameraPosition(
        zoom: Geolocalisation.gmController.,
        target: LatLng(updatedLocation.latitude, updatedLocation.longitude)
      ))
      );
    }*/
    _userCurrentPosition=updatedLocation;
    _userPositionControllerSink.add(_userCurrentPosition);
    _tagsFilter(_snapshotTagsList);
  }


  //------------------------------------------FavTag StreamControllers-----------------------------------------

  final StreamController<List<Tags>> _listFavTagController = StreamController<List<Tags>>.broadcast();

  StreamSink<List<Tags>> get _listFavTagControllerSink => _listFavTagController.sink;
  Stream<List<Tags>> get listFavTagControllerStream => _listFavTagController.stream;

  /*final StreamController<FetchMoreFavTagsEvent> _fetchMoreFavTagController = StreamController<FetchMoreFavTagsEvent>.broadcast();

  StreamSink<FetchMoreFavTagsEvent> get fetchMoreFavTagControllerSink => _fetchMoreFavTagController.sink;
  Stream<FetchMoreFavTagsEvent> get _fetchMoreFavTagControllerStream => _fetchMoreFavTagController.stream;


  final StreamController<bool> _loadingFavTagsController = StreamController<bool>.broadcast();

  StreamSink<bool> get _loadingFavTagsControllerSink => _loadingFavTagsController.sink;
  Stream<bool> get loadingFavTagsControllerStream => _loadingFavTagsController.stream;
  */

 /* void _fetchMoreFavTags(FetchMoreFavTagsEvent e) async {
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
  */

  MainBloc(){
    /*********************FavTags  *************************/
    //_fetchMoreFavTagControllerStream.listen(_fetchMoreFavTags);    

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
    //_newFavContentControllerStream.listen(_onNewFavContent);
    }
  
    @override
    void dispose() {
      _listPopularTagsController.close();
      _listTagsPageController.close();
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
  String _lastFavTagsPostIdSeen;
  String _lastConnectionTimeStamp="0";
  bool newFavContent=false;

    void setCurrentUser(User user){
        _currentUser=user;
    }


  String get lastFavTagsPostIdSeen => _lastFavTagsPostIdSeen;

  void setLastFavTagsPostIdSeen(String arg){
    _lastFavTagsPostIdSeen=arg;
  }

  final StreamController<User> _userUpdateController = StreamController<User>.broadcast();

  StreamSink<User> get _userUpdateControllerSink => _userUpdateController.sink;

  Stream<User> get userUpdateControllerStream => _userUpdateController.stream;

  final StreamController<LocationData> _userPositionController = StreamController<LocationData>.broadcast();

  StreamSink<LocationData> get _userPositionControllerSink => _userPositionController.sink;

  Stream<LocationData> get userPositionControllerStream => _userPositionController.stream;
  
  void _provideCurrentUser() async {
      _currentUser = await db.getCurrentUser();
      _lastConnectionTimeStamp=currentUser.lastConnectionTime;
      print("########### DEBUG PROVIDE CURRENT USER ############  : "+ _currentUser.lastConnectionTime);
      db.userRef.document(currentUser.id).snapshots().listen(onCurrentUserUpdate);
      listFavTags =  await getUserFavMarks();
      newFavContent=hasChangedSinceLastConnection(listFavTags);
      Firestore.instance.collection("User").document(currentUser.id).collection("Discussion").orderBy("timeStamp",descending: true).snapshots().listen(_onNewMessage);
      Firestore.instance.collection("User").document(currentUser.id).collection("UserPost").orderBy("timeStamp",descending : true).snapshots().listen(_onNewComment);
    }

    Future<List<Tags>> getUserFavMarks() async {
      List<Tags> favMarks=[];
      if(!newFavContent){
        //Si on a l'icon de notif activé alors on vient de resume l'app
        //et donc d'appeler getUserFavMarks
        //donc pas besoin d'un double appel lorsque l'on accède a favPage
        await Future(() async{
          //récupère tous les favoris d'un utilisateur

          for(int i=0;i<_currentUser.favTagsId.length;i++){
            final String markId = _currentUser.favTagsId[i];
            DocumentSnapshot doc = await Firestore.instance.collection("Tags").document(markId).get();
            if(doc.exists){
              final Tags favMark = Tags.fromDocumentSnapshot(doc);
              favMark.setFavStatus(true);
              favMarks.add(favMark);
            }
          }
        });
      }
      return favMarks;
    }

    bool hasChangedSinceLastConnection(List<Tags> favMarks){
      print("############# DEBUGGING hasChangedSinceLastConnection ##############");
      print(_lastConnectionTimeStamp);
      int lastConnectionTime = int.parse(_lastConnectionTimeStamp);
      bool b = false;
      favMarks.forEach((Tags mark){
        int lastPostTime = int.parse(mark.lastPostTimeStamp);
        print("lastConnectionTime : " + lastConnectionTime.toString());
        print("lastPostTime : "+lastPostTime.toString());
        if(lastPostTime>lastConnectionTime){
          b=true;
        }
      });
      print(b);
      return b;
    }


  
  
    void onCurrentUserUpdate (DocumentSnapshot snapshot){
      //print("***********[User updated] *************");
      _currentUser=User.fromDocumentSnapshot(snapshot);
      _lastConnectionTimeStamp=_currentUser.lastConnectionTime;
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
      sendNewEvent();
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
        if(docSnap.data["lastMessageSeen"]!=true) newMessage = true;
      });
      sendNewEvent();
      _newMessageControllerSink.add(newMessage);
      _listConvControllerSink.add(snapshot);
    }
  
  
//----------------------------------- new Event Controller -------------------------------------------

    

    StreamController<NotificationEvent> _newEventController = StreamController<NotificationEvent>.broadcast();

    StreamSink<NotificationEvent> get _newEventControllerSink => _newEventController.sink;
    Stream<NotificationEvent> get newEventControllerStream => _newEventController.stream;

    void sendNewEvent(){
      print("############### DEBUG NEW FAV CONTENT ############ : "+newFavContent.toString());
      final NotificationEvent notif = NotificationEvent(newFavContent, newMessage, newComment);
      _newEventControllerSink.add(notif);
    }


//------------------------------------ new Fav Content Event Controller --------------------------------

  /*StreamController<bool> _newFavContentController = StreamController<bool>.broadcast();

  StreamSink<bool> get newFavContentControllerSink => _newFavContentController.sink;
  Stream<bool> get _newFavContentControllerStream => _newFavContentController.stream;

  void _onNewFavContent(){

  }*/
  
}