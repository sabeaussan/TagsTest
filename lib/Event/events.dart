abstract class Event {

}

class FetchMoreTagMessageEvent extends Event {


    FetchMoreTagMessageEvent();
}

class FetchMorePostEvent extends Event {
  

    FetchMorePostEvent();
}


class FetchMoreCommentEvent extends Event {
  

    FetchMoreCommentEvent();
}

class FetchMoreTagsEvent extends Event {
  

    FetchMoreTagsEvent();
}

class FetchMoreChatMessageEvent extends Event {
  

    FetchMoreChatMessageEvent();
}


class FetchMoreFavTagsEvent extends Event {
  
  int _fetchedIndex;

    FetchMoreFavTagsEvent(this._fetchedIndex);

  int get fetchedIndex => _fetchedIndex;
}


class NotificationEvent extends Event{

  final bool _newFavContentEvent;
  final bool _newMessageEvent;
  final bool _newCommentEvent;

  bool get newFavContentEvent => _newFavContentEvent;
  bool get newMessageEvent => _newMessageEvent;
  bool get newCommentEvent => _newCommentEvent;

  NotificationEvent(this._newFavContentEvent,this._newMessageEvent,this._newCommentEvent);

}