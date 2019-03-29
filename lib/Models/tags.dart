import 'package:cloud_firestore/cloud_firestore.dart';

const int PUBLIC_MODE = 0;
const int PRIVATE_MODE=1;



class Tags {

  String _name;
  String _creatorName;
  String _creatorId;
  String _timeStamp;
  String _id;
  double _lat;
  double _long;
  int _nbFav;
  int _nbPost;
  int _nbMessage;
  int _mode;
  bool _isPersonnal;
  double _tagRange;
  String _passWord;



  Tags(
    this._name,
    this._creatorName,
    this._creatorId,
    this._timeStamp,
    this._lat,
    this._long,
    this._nbFav,
    this._nbMessage,
    this._nbPost,
    this._mode,
    this._isPersonnal,
    this._tagRange,
    this._passWord
    );

    toJson () {
    return {
      "id"  : this._id,
      "name" : this._name,
      "creatorName"  : this._creatorName,
      "creatorId"  : this._creatorId,
      "timeStamp"   : this._timeStamp,
      "lat"       : this._lat,
      "long" : this._long,
      "nbFav"  : this._nbFav,
      "nbMessage"   : this._nbMessage,
      "nbPost"       : this._nbPost,
      "mode"   : this._mode,
      "tagRange" : this._tagRange,
      "isPersonnal"       : this._isPersonnal,
      "passWord"       : this._passWord,
    };
  }

  String get name => _name;
  String get creatorName => _creatorName;
  String get creatorId => _creatorId;
  String get timeStamp =>_timeStamp;
  String get id => _id;
  double get lat => _lat;
  double get long => _long;
  int get nbFav =>_nbFav;
  int get nbPost => _nbPost;
  int get nbMessage =>_nbMessage;
  int get mode => _mode;
  bool get isPersonnal =>_isPersonnal;
  double get tagRange=> _tagRange;
  String get passWord => _passWord;
    
  void setId(String id){
    this._id=id;
  }

  Tags.fromDocumentSnapshot(DocumentSnapshot snapshot):
    _id=snapshot.documentID,
    _name=snapshot.data["name"],
    _timeStamp=snapshot.data["timeStamp"],
    _creatorName=snapshot.data["creatorName"],
    _creatorId=snapshot.data["creatorId"],
    _lat=snapshot.data["lat"],
    _long=snapshot.data["long"],
    _nbFav=snapshot.data["nbFav"],
    _nbMessage=snapshot.data["nbMessage"],
    _nbPost=snapshot.data["nbPost"],
    _mode=snapshot.data["mode"],
    _isPersonnal=snapshot.data["isPersonnal"],
    _tagRange=snapshot.data["tagRange"],
    _passWord=snapshot.data["passWord"];

}