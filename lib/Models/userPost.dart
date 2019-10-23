import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tags/Models/post.dart';


class UserPost {
  
  String _creatorId;
  String _tagOwnerId;
  String _id;
  String _imageUrl;
  String _timeStamp;
  int _imageWidth;
  int _imageHeight;
  bool _lastCommentSeen=true;
  bool _lastLikeSeen=true;
  //String _lastComment;
  //String _lastCommentUserName;
  //String _lastLikerUserName;


  UserPost(
    this._id,
    this._creatorId,
    this._imageUrl,
    this._tagOwnerId,
    this._timeStamp,
    this._imageHeight,
    this._imageWidth
  );

  UserPost.fromPost(Post post):
    _id=post.id,
    _tagOwnerId = post.tagOwner.id,
    _imageUrl = post.imageUrl,
    _creatorId = post.creator.id,
    _imageHeight=post.imageHeight,
    _imageWidth=post.imageWidth,
    _timeStamp = post.timeStamp;      //pose problème
  


    UserPost.fromDocumentSnaptshot(DocumentSnapshot snapshot):
    _id=snapshot.documentID,
    _imageHeight=snapshot.data["imageHeight"],
    _imageWidth=snapshot.data["imageWidth"],
    _imageUrl = snapshot.data["imageUrl"],
    _creatorId = snapshot.data["ownerId"],
    _tagOwnerId = snapshot.data["tagsId"],
    _lastCommentSeen = snapshot.data["lastCommentSeen"],
    _lastLikeSeen = snapshot.data["lastLikeSeen"],
    //_lastComment = snapshot.data["lastComment"],
    //_lastCommentUserName = snapshot.data["lastCommentUserName"],
    //_lastLikerUserName = snapshot.data["lastLikerUserName"],
    _timeStamp = snapshot.data["timeStamp"];


  toJson () {
    return {
      "id"  : this._id,
      "tagsId" : this._tagOwnerId,
      "imageUrl" : this._imageUrl,
      "ownerId"   : this._creatorId,
      "lastLikeSeen" : true,
      "lastCommentSeen" : true,
      "imageHeight" : this._imageHeight,
      "imageWidth" : this._imageWidth,
      "timeStamp"   : this._timeStamp
    };
  }

  String get creator => _creatorId;
  String get tagOwnerId => _tagOwnerId;
  String get id =>_id;
  String get imageUrl => _imageUrl;
  String get timeStamp => _timeStamp;
  int get imageWidth =>_imageWidth;
  int get imageHeight =>_imageHeight;
  bool get lastLikeSeen => _lastLikeSeen;
  bool get lastCommentSeen => _lastCommentSeen;

  void setId(String postId){
    this._id = postId;
  }

  void setImageUrl(String imageUrl){
    this._imageUrl = imageUrl;
  }

}