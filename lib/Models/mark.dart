/*import 'package:cloud_firestore/cloud_firestore.dart';

const int PUBLIC_MODE = 0;
const int PRIVATE_MODE=1;



abstract class Mark {

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
  bool _isPersonnal;
  bool _photoOnly;
  double _tagRange;
  bool _isFav=false;
  bool _favStatusHasChanged=false;
  double _distance;
  String _distanceLabel;
  String _description;
  String _lastPostTimeStamp;
  bool _hasBeenUpdated=false;
  bool _isNear=false;
  int _nbViews;


  Mark(
    this._name,
    this._creatorName,
    this._creatorId,
    this._timeStamp,
    this._lat,
    this._long,
    this._isPersonnal,
    this._photoOnly,
    this._tagRange,
    this._description,
    );

  Mark.empty();

  toJson (dynamic position) {
    return {
      "id"  : this._id,
      "name" : this._name,
      "creatorName"  : this._creatorName,
      "creatorId"  : this._creatorId,
      "timeStamp"   : this._timeStamp,
      "position"   : position,
      "lastPostImageUrl" : null,    //TODO: voir si c'est vraiment nécéssaire
      "lastPostImageWidth" : null,  
      "lastPostImageHeight" : null,
      "nbFav"  : 0,
      "nbMessage"   : 0,
      "nbPost"       : 0,
      "tagRange" : this._tagRange,
      "isPersonnal"       : this._isPersonnal,
      "photoOnly" : this._photoOnly,
      "lastPostTimeStamp" : this._lastPostTimeStamp,
      "description" : this._description,
      "nbViews" : 1
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
  double get distance => _distance;
  String get distanceLabel => _distanceLabel;
  bool get isPersonnal =>_isPersonnal;
  bool get photoOnly => _photoOnly;
  int get lastPostImageWidth => _lastPostImageWidth;
  int get lastPostImageHeight => _lastPostImageHeight;
  double get tagRange=> _tagRange;
  bool get isFav => _isFav;
  bool get favStatusHasChanged => _favStatusHasChanged;
  String get lastPostTimeStamp => _lastPostTimeStamp;
  bool get hasBeenUpdated => _hasBeenUpdated;
  bool get isNear => _isNear;
  String get description => _description;
  int get nbViews => _nbViews;

  void setId(String id){
    this._id=id;
  }

  void setFavStatus(bool favStatus){
    this._isFav=favStatus;
  }

  void setFavStatusHasChanged(bool favStatusHasChanged){
    this._favStatusHasChanged=favStatusHasChanged;
  }


  void setDistance(double distance){
    this._distance=distance;
  }
  

  void setLastPostTimeStamp(String time){
    this._lastPostTimeStamp=time;
  }

  void setHasBeenUpdated(bool b){
    this._hasBeenUpdated=b;
  }

  void setIsNear(bool b){
    this._isNear=b;
  }

  void setDistanceLabel(String d){
    this._distanceLabel=d;
  }

  


}*/

