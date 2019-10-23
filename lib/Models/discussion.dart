

class Discussion {

  //On aura un id = ownerId+partnerId par ordre alphabétique pour une discussion 
  //Les messages seront enregistré dans une autre collection

  String _id;
  String _partnerImageUrl;
  String _partnerId;
  String _partnerUserName;
  String _lastMessage;
  bool _lastMessageSeen;
  String _timeStamp;
  int _notifId;

  Discussion(this._lastMessage,this._lastMessageSeen,this._partnerImageUrl,this._partnerUserName,this._partnerId,this._timeStamp);


  String get lastMessage => _lastMessage;
  bool get lastMessageSeen => _lastMessageSeen;
  String get partnerImageUrl => _partnerImageUrl;
  String get partnerUserName => _partnerUserName;
  String get partnerId => _partnerId;
  String get id => _id;

  toJson () {
    return {
      "id"   : this._id,
      "lastMessage" : this._lastMessage,
      "lastMessageSeen" : this._lastMessageSeen,
      "partnerId"   : this._partnerId,
      "partnerImageUrl"   : this._partnerImageUrl,
      "partnerUserName"       : this._partnerUserName,
      "timeStamp"       : this._timeStamp,
    };
  }

  void setId(String discId){
    this._id=discId;
  }

  void setNotifId(int id){
    this._notifId=id;
  }

  get notifId => _notifId;

}