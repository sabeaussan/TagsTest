import 'package:tags/Models/publicmark.dart';
import 'package:tags/Models/user.dart';

class Post {
  User _creator;    //TODO: faire comme ca pour le reste aussi
  PublicMark _tagOwner;
  String _id;
  String _imageUrl;
  String _description;
  String _timeStamp;
  int _nbComments;
  int _nbLikes;
  int _imageWidth;
  int _imageHeight;
  List<dynamic> _likers;
  int _nbLikesNotSeen;
  int _nbCommentsNotSeen;

  Post(
    this._creator,
    this._description,
    this._tagOwner,
    this._imageHeight,
    this._imageWidth,
    this._timeStamp
  );


    

  toJson () {
    return {
      "id"  : this._id,
      "tagsId" : this._tagOwner.id,
      "tagsName"  : this._tagOwner.name,
      "timeStamp"   : this._timeStamp,
      "description"       : this._description,
      "imageUrl" : this._imageUrl,
      "userName"  : this._creator.userName,
      "ownerId"   : this._creator.id,
      "userPhotoUrl"   : this._creator.photoUrl,
      "nbLikes"       : 0,
      "nbComments"   : 0,
      "imageWidth"  : this._imageWidth,
      "imageHeight"   : this._imageHeight,
      "likers" : [],
      "nbCommentsNotSeen" : 0,
      "nbLikesNotSeen" : 0
    };
  }

  User get creator => _creator;
  PublicMark get tagOwner => _tagOwner;
  String get id =>_id;
  String get imageUrl => _imageUrl;
  String get description => _description;
  String get timeStamp =>_timeStamp;
  int get nbComments =>_nbComments;
  int get nbLikes =>_nbLikes;
  int get imageWidth =>_imageWidth;
  int get imageHeight =>_imageHeight;
  List<dynamic> get likers => _likers;
  int get nbCommentsNotSeen => _nbCommentsNotSeen;
  int get nbLikesNotSeen => _nbLikesNotSeen;

  void setId(String postId){
    this._id = postId;
  }

  void setImageUrl(String imageUrl){
    this._imageUrl = imageUrl;
  }

}