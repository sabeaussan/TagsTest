import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tags/Models/post.dart';


class UserPost {
  String _creatorId;    //TODO: faire comme ca pour le reste aussi
  String _tagOwnerId;
  String _id;
  String _imageUrl;
  bool _lastCommentSeen;


  UserPost(
    this._id,
    this._creatorId,
    this._imageUrl,
    this._tagOwnerId,
    this._lastCommentSeen
  );

  UserPost.fromPost(Post post):
    _id=post.id,
    _tagOwnerId = post.tagOwner.id,
    _imageUrl = post.imageUrl,
    _creatorId = post.creator.id,
    _lastCommentSeen = true;


    UserPost.fromDocumentSnaptshot(DocumentSnapshot snapshot):
    _id=snapshot.documentID,
    _imageUrl = snapshot.data["imageUrl"],
    _creatorId = snapshot.data["ownerId"],
    _tagOwnerId = snapshot.data["tagsId"],
    _lastCommentSeen = snapshot.data["lastCommentSeen"];


  toJson () {
    return {
      "id"  : this._id,
      "tagsId" : this._tagOwnerId,
      "imageUrl" : this._imageUrl,
      "ownerId"   : this._creatorId,
      "lastCommentSeen" : this._lastCommentSeen
    };
  }

  String get creator => _creatorId;
  String get tagOwnerId => _tagOwnerId;
  String get id =>_id;
  String get imageUrl => _imageUrl;
  bool get lastCommentSeen => _lastCommentSeen;

  void setId(String postId){
    this._id = postId;
  }

  void setImageUrl(String imageUrl){
    this._imageUrl = imageUrl;
  }

}