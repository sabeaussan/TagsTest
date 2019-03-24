class Comment {
  String _id;
  String _postId;
  String _tagsOwnerId;
  String _userName;
  String _userPhotoUrl;
  String _content;
  String _userId;


  Comment(this._id,this._userId,this._content,this._userPhotoUrl,this._userName,this._postId,this._tagsOwnerId); 


  String get id  => _id;
  String get postId =>_postId;
  String get tagOwnerId =>_tagsOwnerId;
  String get username => _userName;
  String get userPhotoUrl =>_userPhotoUrl;
  String get content => _content;
  String get userId => _userId;

  

  void setId(String postCommentId){
    this._id =postCommentId;
  }

  toJson () {
    return {
      "id"   : this._id,
      "content"       : this._content,
      "userId"       : this._userId,
      "userName"   : this._userName,
      "userPhotoUrl"       : this._userPhotoUrl,
      "postId"       : this._postId,
      "tagsOwnerId"   : this._tagsOwnerId,
    };
  }
  
  
}