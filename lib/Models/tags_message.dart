class TagsMessage {
  String _id;
  String _content;
  String _userId;
  String _userPhotoUrl;
  String _tagOwnerId;
  String _userName;
  String _timeStamp;


  TagsMessage(this._id,this._userId,this._content,this._userName,this._userPhotoUrl,this._tagOwnerId,this._timeStamp);

  void setId (String messageId){
    this._id = messageId;
  }

  toJson () {
    return {
      "id"   : this._id,
      "content"       : this._content,
      "userId"       : this._userId,
      "userName"   : this._userName,
      "userPhotoUrl"       : this._userPhotoUrl,
      "tagOwnerId"   : this._tagOwnerId,
      "timeStamp" : this._timeStamp
    };
  }

  String get id => _id;
  String get content =>_content;
  String get userId =>_userId;
  String get userName =>_userName;
  String get userPhotoUrl =>_userPhotoUrl;
  String get tagOwnerId => _tagOwnerId;

}