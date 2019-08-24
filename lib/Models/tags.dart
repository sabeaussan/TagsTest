import 'package:cloud_firestore/cloud_firestore.dart';

const int PUBLIC_MODE = 0;
const int PRIVATE_MODE=1;



class Tags {

  String _name;
  String _creatorName;
  String _creatorId;
  String _timeStamp;
  String _id;
  String _lastPostImageUrl;
  int _lastPostImageWidth;
  int _lastPostImageHeight;
  double _lat;
  double _long;
  int _nbFav;
  int _nbPost;
  int _nbMessage;
  int _mode;
  bool _isPersonnal;
  double _tagRange;
  String _passWord;
  bool _favStatus;
  bool _favStatusHasChanged=false;
  int _popularity;
  bool _isPopular=false; //TODO:faire getter et setter pour que les popular aient une image sur map page
  double _distance;
  //String _lastPostIdSeen;
  String _lastPostTimeStamp;
  bool _hasBeenUpdated=false;


  Tags(
    this._name,
    this._creatorName,
    this._creatorId,
    this._timeStamp,
    this._lat,
    this._long,
    this._lastPostImageUrl,
    this._lastPostImageWidth,
    this._lastPostImageHeight,
    this._nbFav,
    this._nbMessage,
    this._nbPost,
    this._mode,
    this._isPersonnal,
    this._tagRange,
    this._passWord
    );

    toJson (dynamic position) {
    return {
      "id"  : this._id,
      "name" : this._name,
      "creatorName"  : this._creatorName,
      "creatorId"  : this._creatorId,
      "timeStamp"   : this._timeStamp,
      "position"   : position,
      "lastPostImageUrl" : this._lastPostImageUrl,
      "lastPostImageWidth" : this._lastPostImageWidth,
      "lastPostImageHeight" : this._lastPostImageHeight,
      "nbFav"  : this._nbFav,
      "nbMessage"   : this._nbMessage,
      "nbPost"       : this._nbPost,
      "mode"   : this._mode,
      "tagRange" : this._tagRange,
      "isPersonnal"       : this._isPersonnal,
      "lastPostTimeStamp" : this._lastPostTimeStamp,
      "passWord"       : this._passWord,
    };
  }

  String get name => _name;
  String get creatorName => _creatorName;
  String get creatorId => _creatorId;
  String get timeStamp =>_timeStamp;
  String get id => _id;
  String get lastPostImageUrl => _lastPostImageUrl;
  double get lat => _lat;
  double get long => _long;
  int get nbFav =>_nbFav;
  int get nbPost => _nbPost;
  int get nbMessage =>_nbMessage;
  int get mode => _mode;
  int get popularity => _popularity;
  double get distance => _distance;
  bool get isPersonnal =>_isPersonnal;
  int get lastPostImageWidth => _lastPostImageWidth;
  int get lastPostImageHeight => _lastPostImageHeight;
  double get tagRange=> _tagRange;
  String get passWord => _passWord;
  bool get favStatus => _favStatus;
  bool get favStatusHasChanged => _favStatusHasChanged;
  bool get isPopular => _isPopular;
  //String get lastPostIdSeen => _lastPostIdSeen;
  String get lastPostTimeStamp => _lastPostTimeStamp;
  bool get hasBeenUpdated => _hasBeenUpdated;

  void setId(String id){
    this._id=id;
  }

  void setFavStatus(bool favStatus){
    this._favStatus=favStatus;
  }

  void setFavStatusHasChanged(bool favStatusHasChanged){
    this._favStatusHasChanged=favStatusHasChanged;
  }

  void setPopularity(int popularity){
    this._popularity=popularity;
  }

  void setDistance(double distance){
    this._distance=distance;
  }
  
  void setIsPopular(bool isPopular){
    this._isPopular=isPopular;
  }

  void setLastPostTimeStamp(String time){
    this._lastPostTimeStamp=time;
  }

  void setHasBeenUpdated(bool b){
    this._hasBeenUpdated=b;
  }

  /*void setLastPostIdSeen(String lastPostIdSeen){
    this._lastPostIdSeen=lastPostIdSeen;
  }*/
  

  Tags.fromDocumentSnapshot(DocumentSnapshot snapshot):
    _id=snapshot.documentID,
    _name=snapshot.data["name"],
    _timeStamp=snapshot.data["timeStamp"],
    _creatorName=snapshot.data["creatorName"],
    _creatorId=snapshot.data["creatorId"],
    _lat=snapshot.data["position"]["geopoint"].latitude,
    _long=snapshot.data["position"]["geopoint"].longitude,
    _lastPostImageUrl=snapshot.data["lastPostImageUrl"],
    _lastPostImageWidth = snapshot.data["lastPostImageWidth"],
    _lastPostImageHeight = snapshot.data["lastPostImageHeight"],
    _nbFav=snapshot.data["nbFav"],
    _nbMessage=snapshot.data["nbMessage"],
    _nbPost=snapshot.data["nbPost"],
    _mode=snapshot.data["mode"],
    _isPersonnal=snapshot.data["isPersonnal"],
    _tagRange=snapshot.data["tagRange"],
    _lastPostTimeStamp=snapshot.data["lastPostTimeStamp"],
    _passWord=snapshot.data["passWord"];

}