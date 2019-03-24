class Message {
  String _id;
  String _content;
  String _userId;


  Message(this._id,this._userId,this._content,);

  void setId (String messageId){
    this._id = messageId;
  }

  toJson () {
    return {
      "id"   : this._id,
      "content"       : this._content,
      "userId"       : this._userId,
    };
  }

  String get id => _id;
  String get content =>_content;
  String get userId =>_userId;

}