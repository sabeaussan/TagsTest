import 'package:tags/Models/tags.dart';
import 'package:tags/Models/user.dart';
import 'package:tags/UI/post_tile.dart';

class Post {
  User _creator;    //TODO: faire comme ca pour le reste aussi
  Tags _tagOwner;
  String _id;
  String _imageUrl;
  String _description;
  String _timeStamp;
  int _nbComments;
  int _nbLikes;
  int _imageWidth;
  int _imageHeight;


  Post(
    this._id,
    this._creator,
    this._description,
    this._imageUrl,
    this._nbLikes,
    this._tagOwner,
    this._nbComments,
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
      "nbLikes"       : this._nbLikes,
      "nbComments"   : this._nbComments,
      "imageWidth"  : this._imageWidth,
      "imageHeight"   : this._imageHeight
    };
  }

  User get creator => _creator;
  Tags get tagOwner => _tagOwner;
  String get id =>_id;
  String get imageUrl => _imageUrl;
  String get description => _description;
  String get timeStamp =>_timeStamp;
  int get nbComments =>_nbComments;
  int get nbLikes =>_nbLikes;
  int get imageWidth =>_imageWidth;
  int get imageHeight =>_imageHeight;

  void setId(String postId){
    this._id = postId;
  }

  void setImageUrl(String imageUrl){
    this._imageUrl = imageUrl;
  }

}