import 'dart:async';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Event/events.dart';
import 'package:tags/Models/publicmark.dart';
import 'package:tags/Models/user.dart';
import 'package:tags/Utils/firebase_db.dart';
import 'package:tags/Utils/local_notification_helper.dart';




class MainBloc extends BlocBase {
  //Mettre MainBloc dans HomeBlocPage et wrap HomePage dans un std qui prend en stream getUser
  //il faudra gérer les updates de User si par exemple il change de photo ou de UserName
  //avec un event updateUser qui modfie _currentUser avec les nouvelles données.

  StreamSubscription _userPostSub;
  StreamSubscription _userDiscussionSub;



  GeoFirePoint _userInitialFirePoint;

  static const int MAX_NB_MARK = 40;
  static const int MAX_NB_POPULAR_MARK = 15;

  //if nbMark*PROPORTION_POPULAR_MARK < MAX_NB_POPULAR_MARK alors ...
  //static const double PROPORTION_POPULAR_MARK = 0.2;

  static const int NEW_COMMENT_ID=0;
  static const int NEW_MESSAGE_ID=1;
  static const int NEW_LIKE_ID=2;
  static const int NEW_FAV_CONTENT_ID=3;

  static const double USER_RANGE=1;
  static const double QUERY_RANGE=10;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =  FlutterLocalNotificationsPlugin();

  MainBloc(){

    var initializationSettingsAndroid =  AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS =  IOSInitializationSettings(
      onDidReceiveLocalNotification: (id,title,body, payload) => onSelectNotification(payload)
    );
    var initializationSettings =  InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings,onSelectNotification: onSelectNotification);
    _appResumedControllerStream.listen(_onAppResumed);
    _newFavContentSeenNotificationControllerStream.listen(_onNewFavContentNotificationSeen);
  }

    Future onSelectNotification(String payload) async {
      print("notif tapped");
      return;
    }

  StreamSubscription _firestoreSub;
  Location _userLocation= Location();
  //TODO : peut il y avoir un problème avec la pagination si
  //on fectMoreTags alors qu'on ne se trouve plus dans la zone


  //-----------------------------------------ListTagsController--------------------------------------

  List<DocumentSnapshot> _snapshotMarksList=List<DocumentSnapshot>();
  List<PublicMark> listFavMarks = List<PublicMark>();
  

  /************************************* StreamController des marker de map_page ***************************/

  /*final StreamController<List<PublicMark>> _listMarkerTagsController = StreamController<List<PublicMark>>.broadcast();

  StreamSink<List<PublicMark>> get _listMarkerTagsControllerSink => _listMarkerTagsController.sink;
  Stream<List<PublicMark>> get listMarkerTagsControllerStream => _listMarkerTagsController.stream;*/





  bool getFavStatus(String tagsId){
     if(_currentUser!=null) return _currentUser.favTagsId.contains(tagsId);
  } 

  void _onLocationChanged(LocationData updatedLocation){
    _userCurrentPosition=updatedLocation;
  }

  void _onNewMarkSnapshot(List<DocumentSnapshot> snapshot){
    //TODO: est triggered 2 fois a chaque fois !!
    _snapshotMarksList=snapshot;
    //_filterMarksInit(_snapshotMarksList);
  }

  //TODO : faire en sorte de ne pas tout refiltrer a chaque fois qu'on appel locationChanged

  Future<List<PublicMark>> filterMarksForListMarkPage() async {
    print(" ############### FILTERING FOR LIST MARK PAGE ############ ");
    //_userCurrentPosition = await _userLocation.getLocation();
    //filtre les marks qui seront afficher sur la markPage
    List<PublicMark> listMarksPage=List<PublicMark>();  //liste des marks pour list_marks_page
    _snapshotMarksList.forEach((DocumentSnapshot doc){
      final PublicMark mark = PublicMark.fromDocumentSnapshot(doc);
      final bool isFav = getFavStatus(mark.id);
      mark.setFavStatus(isFav);
      GeoFirePoint markPosition = GeoFirePoint(mark.lat, mark.long);
      final double distance=markPosition.distance(lat: _userCurrentPosition.latitude,lng:_userCurrentPosition.longitude);
      //TODO: remplacer les valeurs en dur du nombre de mark afficher sur la map
      if(distance<=1){
        //Si la mark est dans un rayon de 1km autour de l'utilisateur
        //alors on l'affiche dans la list_marks_page
         mark.setDistance(distance);
        setDistanceLabelAndOnRange(mark);
        listMarksPage.add(mark);
      }
    });
    return listMarksPage;
  }

  

  Future<List<PublicMark>> filterMarksForMapPage() async {

    List<PublicMark> listMapPage=List<PublicMark>();      //liste des marks, utile pour map_page
    int nbMark=_snapshotMarksList.length;
    int nbPopularMark=0;
    _snapshotMarksList.sort((a,b){
      final int popA = a.data["popularity"];
      final int popB = b.data["popularity"];
      return popB.compareTo(popA);
    });
    if(nbMark>MAX_NB_MARK) nbMark=MAX_NB_MARK;
    for(int i=0;i<nbMark;i++){
      DocumentSnapshot doc = _snapshotMarksList[i];
      final PublicMark mark = PublicMark.fromDocumentSnapshot(doc);
      final bool isFav = getFavStatus(doc.documentID);
      mark.setFavStatus(isFav);
      if(nbPopularMark <MAX_NB_POPULAR_MARK ){
        mark.setIsPopular(true);
        nbPopularMark++;
      } 
      listMapPage.add(mark); 
    }
    return listMapPage;
  }

  Future<List<PublicMark>>  filterMarksForPopularPage() async{
    
    List<PublicMark> listPopularMark=List<PublicMark>();     //liste des marks populaire pour popular_fav_page
    int nbMark=_snapshotMarksList.length;
    int nbPopularMark=0;
    _snapshotMarksList.sort((a,b){
      final int popA = a.data["popularity"];
      final int popB = b.data["popularity"];
      return popB.compareTo(popA);
    });

    if(nbMark>MAX_NB_MARK) nbMark=MAX_NB_MARK;
    for(int i=0;i<nbMark;i++){
      DocumentSnapshot doc = _snapshotMarksList[i];
      final PublicMark mark = PublicMark.fromDocumentSnapshot(doc);
      if(nbPopularMark <MAX_NB_POPULAR_MARK && mark.lastPostImageUrl!=null){

        GeoFirePoint markPosition = GeoFirePoint(mark.lat, mark.long);
        final double distance=markPosition.distance(lat: _userCurrentPosition.latitude,lng: _userCurrentPosition.longitude);
        mark.setDistance(distance);
        setDistanceLabelAndOnRange(mark);

        final bool isFav = getFavStatus(doc.documentID);
        mark.setFavStatus(isFav);

        print(mark.name);
        print(mark.lastPostImageUrl);
        mark.setIsPopular(true);
        listPopularMark.add(mark); 
        nbPopularMark++;
      } 
      
    }

    return listPopularMark;
  }

  /*void _updateMarksDistance(List<DocumentSnapshot> snapshot){
    _filteredTagsList=[]; 
    snapshot.forEach((DocumentSnapshot tags){
      final PublicMark tag = PublicMark.fromDocumentSnapshot(tags);
      final bool isFav = getFavStatus(tags.documentID);
      tag.setFavStatus(isFav);
      GeoFirePoint tagPosition = GeoFirePoint(tag.lat, tag.long);
      //Distance entre la range et le user
      final double distance=tagPosition.distance(lat: _userCurrentPosition.latitude,lng: _userCurrentPosition.longitude);
      tag.setDistance(distance);
      setDistanceLabelAndOnRange(tag);
      if(distance<=1){
        //Si la mark est dans un rayon de 1km autour de l'utilisateur
        //alors on l'affiche dans la list_marks_page
        _filteredTagsList.add(tag);
      }
    });
    _listTagsPageControllerSink.add(_filteredTagsList);              //on ajoute au stream de list_marks_page 
  }*/

  /*void _onLocationChanged(LocationData updatedLocation){
    _userCurrentPosition=updatedLocation;
    double dist = _userInitialFirePoint.distance(lat: _userCurrentPosition.latitude,lng:_userCurrentPosition.longitude);
    if(dist>USER_RANGE){
      //On doit refiltrer les mark afficher dans la MarkPage
      _filterMarks(_snapshotMarksList);
    }
    //_userPositionControllerSink.add(_userCurrentPosition);
    _updateMarksDistance(_snapshotMarksList);
  }*/

  void setDistanceLabelAndOnRange(PublicMark mark){
    int dist = (mark.distance*1000).toInt();
    if(dist <= mark.tagRange) mark.setIsNear(true);
    else mark.setIsNear(false);
    dist = dist - mark.tagRange.toInt() ;
    mark.setDistanceLabel(dist.toString());
  }


  
  
    @override
    void dispose() {
      print("########## Disposing MAINBLOC ########");
      _firestoreSub.cancel();
      _userPostSub.cancel();
      _userDiscussionSub.cancel();
      _appResumedController.close();
      _newFavContentNotificationSeenController.close();
      _userUpdateController.close();
      _listConvController.close();
      //_userPositionController.close();
      _newMessageController.close();
      _listUserPostController.close();
      _newUserPostEventController.close();
      _newEventController.close();
      // TODO: implement dispose
    }
  

  
  

  //TODO: Sert pour l'initial data des stb,
  //TODO:a changer car ca va poser problème si le serveur met trop de temps à répondre à la requête
  
  

  //-------------------------------------------User Controller-------------------------------------------
  static User _currentUser;
  CachedNetworkImageProvider _userPhoto;
  LocationData _userCurrentPosition;
  LocationData _userInitialPosition;
  LocationData get userCurrentPosition => _userCurrentPosition;
  LocationData get userInitialPosition => _userInitialPosition;
  User get currentUser => _currentUser;
  CachedNetworkImageProvider get userPhoto => _userPhoto;

  String _lastConnectionTimeStamp;
  bool _newFavContent=false;


    void setCurrentUser(User user){
        _currentUser=user;
    }
  bool get newFavContent => _newFavContent;


  final StreamController<User> _userUpdateController = StreamController<User>.broadcast();

  StreamSink<User> get _userUpdateControllerSink => _userUpdateController.sink;

  Stream<User> get userUpdateControllerStream => _userUpdateController.stream;

  /*final StreamController<LocationData> _userPositionController = StreamController<LocationData>.broadcast();

  StreamSink<LocationData> get _userPositionControllerSink => _userPositionController.sink;

  Stream<LocationData> get userPositionControllerStream => _userPositionController.stream;*/


  final StreamController<ResumeAppEvent> _appResumedController = StreamController<ResumeAppEvent>.broadcast();

  StreamSink<ResumeAppEvent> get appResumedControllerSink => _appResumedController.sink;

  Stream<ResumeAppEvent> get _appResumedControllerStream => _appResumedController.stream;

  final StreamController<NewFavContentSeen> _newFavContentNotificationSeenController = StreamController<NewFavContentSeen>.broadcast();

  StreamSink<NewFavContentSeen> get newFavContentNotificationSeenControllerSink => _newFavContentNotificationSeenController.sink;

  Stream<NewFavContentSeen> get _newFavContentSeenNotificationControllerStream => _newFavContentNotificationSeenController.stream;

  void _onAppResumed(ResumeAppEvent e) async{
    listFavMarks = await getUserFavMarks();
    if(_newFavContent){
      final String title = "Du nouveau contenu a était posté !";
      showOngoingNotification(
        flutterLocalNotificationsPlugin,
        title : title,
        body :"",
        id: NEW_FAV_CONTENT_ID,
      );
      sendNewEvent();
    }
  }

  void _onNewFavContentNotificationSeen(NewFavContentSeen e){
    _newFavContent=false;
    sendNewEvent();
  }

  
  Future<int> provideCurrentUser(String uid) async {

    _currentUser = await db.getCurrentUser(uid);

    _userInitialPosition = await _userLocation.getLocation();
    _userCurrentPosition=_userInitialPosition;
    _userInitialFirePoint = db.geoflutterfire.point(latitude : _userInitialPosition.latitude, longitude : _userInitialPosition.longitude);
    Query markQuery = Firestore.instance.collection("Tags");
    db.geoflutterfire.collection(collectionRef: markQuery).within(
      strictMode: false,
      center: _userInitialFirePoint,
      field: "position",
      radius: QUERY_RANGE,
    ).listen(_onNewMarkSnapshot);
    _userLocation.changeSettings(distanceFilter: 10);
    _userLocation.onLocationChanged().listen(_onLocationChanged);

    _lastConnectionTimeStamp=currentUser.lastConnectionTime;
    db.userRef.document(_currentUser.id).snapshots().listen(onCurrentUserUpdate);
    listFavMarks =  await getUserFavMarks();
    _userPostSub =Firestore.instance.collection("User").document(_currentUser.id).
      collection("Discussion").orderBy("timeStamp",descending: true).snapshots().listen(_onNewMessage);
    _userDiscussionSub = Firestore.instance.collection("User").document(_currentUser.id).
      collection("UserPost").orderBy("timeStamp",descending : true).snapshots().listen(_onNewUserPostEvent);
    return 0;
  }

    Future<List<PublicMark>> getUserFavMarks() async {

      if(_newFavContent || _lastConnectionTimeStamp==null) return Future((){
        return listFavMarks;
      });
      else{
        List<PublicMark> favMarks=[];
        int lastConnectionTime = int.parse(_lastConnectionTimeStamp);
        _newFavContent=false;
        //Si on a l'icon de notif activé alors on vient de resume l'app
        //et donc d'appeler getUserFavMarks
        //donc pas besoin d'un double appel lorsque l'on accède a favPage
        await Future(() async{
          //récupère tous les favoris d'un utilisateur
          for(int i=0;i<_currentUser.favTagsId.length;i++){
            final String markId = _currentUser.favTagsId[i];
            DocumentSnapshot doc = await Firestore.instance.collection("Tags").document(markId).get();
            if(doc.exists){
              final PublicMark favMark = PublicMark.fromDocumentSnapshot(doc);
              int lastPostTime = int.parse(favMark.lastPostTimeStamp);
              // On regarde si la mark a était maj pendant que l'app était en backGround
              if(lastPostTime>lastConnectionTime){
                _newFavContent=true;
                // On veut les mark notifié en premier
                if(favMarks.length!=0) favMarks.insert(0, favMark);
                else favMarks.add(favMark);
              }
              else{
                favMarks.add(favMark);
              }
              favMark.setFavStatus(true);
            }
          }
        });
        return favMarks;
      }
      
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


  //-----------------------------------------new UserPost Event Controller--------------------------------------

  QuerySnapshot userPostSnapshot;
  bool _newUserPostEvent =false;
  bool get newUserPostEvent => _newUserPostEvent;

  StreamController<bool> _newUserPostEventController = StreamController<bool>.broadcast();

  StreamSink<bool> get _newUserPostEventControllerSink => _newUserPostEventController.sink;
  Stream<bool> get newUserPostEventControllerStream => _newUserPostEventController.stream;



  StreamController<QuerySnapshot> _listUserPostController = StreamController<QuerySnapshot>.broadcast();

  StreamSink<QuerySnapshot> get _listUserPostControllerSink => _listUserPostController.sink;
  Stream<QuerySnapshot> get listUserPostControllerStream => _listUserPostController.stream;

  void _onNewUserPostEvent(QuerySnapshot snapshot){
      _newUserPostEvent =false;
      userPostSnapshot=snapshot;
      snapshot.documents.forEach((DocumentSnapshot docSnap){
        if(docSnap.data["lastCommentSeen"]==false){
          _newUserPostEvent=true;
          final String title = docSnap.data["lastCommentUserName"]+" a commenté";
          final String body = docSnap.data["lastComment"];
          showOngoingNotification(
            flutterLocalNotificationsPlugin,
            title : title,
            body :body,
            id: NEW_COMMENT_ID,
          );
        }
        if(docSnap.data["lastLikeSeen"]==false){
          _newUserPostEvent=true;
          final String title = docSnap.data["lastLikerUserName"]+" a liké un de vos postes !";
          //final String body = docSnap.data["lastComment"];
          showOngoingNotification(
            flutterLocalNotificationsPlugin,
            title : title,
            body :"",
            id: NEW_LIKE_ID,
          );
        }
      });
      sendNewEvent();
      _newUserPostEventControllerSink.add(_newUserPostEvent);
      _listUserPostControllerSink.add(snapshot);
    }

  //----------------------------------new Message Event Controller---------------------------------------

  QuerySnapshot userDiscussionSnapshot;
  bool _newMessage=false;
  bool get newMessage => _newMessage;

  StreamController<QuerySnapshot> _listConvController = StreamController<QuerySnapshot>.broadcast();

  StreamSink<QuerySnapshot> get _listConvControllerSink => _listConvController.sink;
  Stream<QuerySnapshot> get listConvControllerStream => _listConvController.stream;



  StreamController<bool> _newMessageController = StreamController<bool>.broadcast();

  StreamSink<bool> get _newMessageControllerSink => _newMessageController.sink;
  Stream<bool> get newMessageControllerStream => _newMessageController.stream;

  void _onNewMessage(QuerySnapshot snapshot){
      _newMessage=false;
      userDiscussionSnapshot=snapshot;
      snapshot.documents.forEach((DocumentSnapshot docSnap){
        if(docSnap.data["lastMessageSeen"]!=true){
          _newMessage = true;
          if(docSnap.data["partnerId"]!=_currentUser.id){
            final String title = docSnap.data["partnerUserName"];
            final String body = docSnap.data["lastMessage"];
            showOngoingNotification(
              flutterLocalNotificationsPlugin,
              title : title,
              body :body,
              id: NEW_MESSAGE_ID,
            );
          }
        } 

      });
      sendNewEvent();
      _newMessageControllerSink.add(_newMessage);
      _listConvControllerSink.add(snapshot);
    }
  
  
//----------------------------------- new Event Controller -------------------------------------------

    

    StreamController<NotificationEvent> _newEventController = StreamController<NotificationEvent>.broadcast();

    StreamSink<NotificationEvent> get _newEventControllerSink => _newEventController.sink;
    Stream<NotificationEvent> get newEventControllerStream => _newEventController.stream;

    void sendNewEvent(){
      // print("############### DEBUG NEW FAV CONTENT ############ : "+newFavContent.toString());
      final NotificationEvent notif = NotificationEvent(_newFavContent, _newMessage, _newUserPostEvent);
      _newEventControllerSink.add(notif);
    }

  //------------------------------- Local Push Notification ------------------------------------------

  
  
}