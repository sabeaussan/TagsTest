import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_chat_page.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Bloc/main_bloc.dart';
import 'package:tags/Event/events.dart';
import 'package:tags/Models/message.dart';
import 'package:tags/Models/user.dart';
import 'package:tags/UI/chat_bubble.dart';
import 'package:tags/UI/user_circle_avatar.dart';
import 'package:tags/Utils/firebase_db.dart';
import 'dart:async';


class ChatPage extends StatefulWidget {

  final User _partner;
  final String _discussionId;

  ChatPage(this._partner,this._discussionId);


  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController _messageTextController;
  FocusNode _focusNode;
  GlobalKey<FormFieldState> _key = GlobalKey<FormFieldState>();
  String message;
  User currentUser;
  UserCircleAvatar _userCircleAvatar;
  bool convExist=false;   //convHasChanged
  int numMessageIni;
  ScrollController _scrollController;
  double lastExtent=0.0;
  BlocChatPage _blocListChatMessage;

  //TODO: lle setState de onChanged nique la masse de read en avec le StreamBuilder
  //TODO: mettre le last message dans disucssion pour eviter d'écrire deux fois la même chose.

  

  void _fetchMoreTags() async {
    if(_scrollController.position.pixels==_scrollController.position.maxScrollExtent){
      if(lastExtent!=_scrollController.position.maxScrollExtent){
        print("--------------------FetchMoreMessageEvent triggered----------------");
        print("position : "+_scrollController.position.pixels.toString());
        print("maxExtent : "+_scrollController.position.pixels.toString());
        print("lastExtent : "+lastExtent.toString());
        lastExtent = _scrollController.position.maxScrollExtent;
        _blocListChatMessage.fetchMoreChatMessageControllerSink.add(FetchMoreChatMessageEvent());
      }
        
    }
  }

  

  Widget _buildMessageRow(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          FloatingActionButton(
            child: Icon(Icons.camera_alt,color: Colors.white),
            backgroundColor: Colors.deepOrange,
            onPressed: (){

            },
            mini: true,
          ),
          Expanded(
            child: TextFormField(
              key: _key,
              controller: _messageTextController,
              focusNode: _focusNode,
              onSaved: (String val){
                message=val;
              },
              decoration: InputDecoration(
                filled: false,
                hintText:"message...",
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(10.0)),
              keyboardType: TextInputType.multiline,
              maxLines: null,
              cursorColor: Colors.deepOrange,
            ),
          ),
          IconButton(
                disabledColor: Colors.black12,
                icon: Icon(Icons.send, color: _focusNode.hasFocus? Colors.deepOrange:Color.fromARGB(150,182, 182, 182)),
                onPressed: 
                () async {
                  _key.currentState.save();
                  if(message.trim().length!=0){
                    Message messageTosend =Message(null,currentUser.id,_messageTextController.text,);
                    _messageTextController.clear();
                    await  _sendMessages(messageTosend);
                  }
                },
              )
        ],
      ),
      decoration: BoxDecoration(
        color: Color.fromARGB(40,182, 182, 182),
        border: Border.all(
          width: 2.0,
          color: _focusNode.hasFocus? Colors.deepOrange:Color.fromARGB(150,182, 182, 182),
          style: BorderStyle.solid
        ) ,
        borderRadius: const BorderRadius.all(Radius.circular(25.0)),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _focusNode =FocusNode();
    _messageTextController=TextEditingController();
    _userCircleAvatar=UserCircleAvatar(widget._partner.userName,widget._partner.id);
    print("[initState ]"+widget._discussionId);
    final MainBloc _mainBloc = BlocProvider.of<MainBloc>(context);
    currentUser =_mainBloc.currentUser;
    _scrollController = ScrollController();
    _scrollController.addListener(_fetchMoreTags);
    _blocListChatMessage=BlocChatPage(widget._discussionId);
  }

  Future<void> _sendMessages(Message message) async {
    print("[_sendMessages ]"+widget._discussionId);
    db.sendMessageFirestore(widget._discussionId,message,currentUser,widget._partner);
  }

  Widget _buildLoadingIndicator(bool isLoading){
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Center(
        child: Opacity(
          opacity: isLoading ? 1.0 : 0.0,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  @override
  void dispose() async {
    //met à jour le champ lastMessageSeen pour que les nouveaux 
    //messages non lus soient notifiées
    //TODO: checker si il y a eu des changements avant d'utiliser update
    db.updateDiscussion(currentUser.id,widget._discussionId);
    //TODO : faire ici aussi la mis a jour des derniers messages affiché dans la conv 
    print("dispose");
    _scrollController.removeListener(_fetchMoreTags);
    _scrollController.dispose();
    super.dispose();
  }
  

  @override
  Widget build(BuildContext context) {
    print("[build ]"+widget._discussionId);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          children: <Widget>[
            _userCircleAvatar,
            SizedBox(width: 18.0),
            Text(widget._partner.userName ,style: TextStyle(color: Colors.black),),
          ],
        )
      ),
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: _blocListChatMessage.listChatMessageControllerStream,
        initialData: _blocListChatMessage.snapshotChatMessageList,
        builder: (BuildContext context, AsyncSnapshot<List<DocumentSnapshot>> listSnapshot){
          if(!listSnapshot.hasData) return Container();
          convExist=true;
          return Column(
            children: <Widget>[
              StreamBuilder(
                stream: _blocListChatMessage.loadingChatMessageControllerStream ,
                initialData: false ,
                builder: (BuildContext context, AsyncSnapshot snapshot){
                  return Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      itemCount: listSnapshot.hasData? listSnapshot.data.length+1 : 0,
                      itemBuilder: (BuildContext context, int index) {
                        if(index==listSnapshot.data.length){
                          return  Center(
                            child: _buildLoadingIndicator(snapshot.data)
                          );
                        }
                        return Column(
                          children: <Widget>[
                            widget._partner.id==listSnapshot.data[index]["userId"]?
                            ChatBubble.fromDocumentSnapshot(listSnapshot.data[index],true)
                            :
                            ChatBubble.fromDocumentSnapshot(listSnapshot.data[index],false),
                            SizedBox(height: 10.0,) 
                          ],
                        );
                      }
                    ),
                  );
                },
              ),
              _buildMessageRow(context)
            ],
          );
          },
        ),
    );
  }
}