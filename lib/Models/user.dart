import 'package:cloud_firestore/cloud_firestore.dart';

class User {

  String _mail;
  String _passWord;
  String _prenom;
  String _nom;
  String _photoUrl;
  String _userName;
  String _id;
  String _bio;
  List<dynamic> _favPostId;
  List<dynamic> _favTagsId;
  List<dynamic> _favCommId;


  User(
    this._mail,
    this._passWord,
    this._nom,
    this._prenom,
    this._id,
    this._userName,
    this._bio,
    this._photoUrl,
    this._favCommId,
    this._favPostId,
    this._favTagsId
  );


  User.fromDocumentSnapshot(DocumentSnapshot snapshot):
    _id=snapshot.documentID,
    _mail=snapshot.data["mail"],
    _passWord=snapshot.data["password"],
    _nom=snapshot.data["nom"],
    _prenom=snapshot.data["prenom"],
    _bio =snapshot.data["bio"],
    _userName=snapshot.data["userName"],
    _favCommId=snapshot.data["favCommId"],
    _favPostId=snapshot.data["favPostId"],
    _favTagsId=snapshot.data["favTagsId"],
    _photoUrl=snapshot.data["photoUrl"];

    User.fromDiscussion(String partnerId,String partnerUserName,String partnerPhotoUrl):
    _id=partnerId,
    _userName=partnerUserName,
    _photoUrl=partnerPhotoUrl;

  toJson () {
    return {
      "id"   : this._id,
      "mail" : this._mail,
      "passWord"  : this._passWord,
      "nom"   : this._nom,
      "prenom"       : this._prenom,
      "userName"   : this._userName,
      "bio" : this._bio,
      "photoUrl"   : this._photoUrl,
      "favCommId"       : this._favCommId,
      "favPostId"   : this._favPostId,
      "favTagsId"   : this._favTagsId,
    };
  }

  String get id => _id;
  String get mail => _mail;
  String get nom => _nom;
  String get prenom => _prenom;
  String get userName => _userName;
  String get bio => _bio;
  String get photoUrl => _photoUrl;
  List<dynamic> get favPostId => _favPostId;
  List<dynamic> get favTagsId => _favTagsId;
  List<dynamic> get favCommId => _favCommId;
}