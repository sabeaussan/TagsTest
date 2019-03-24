import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Bloc/main_bloc.dart';
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
  Stream _stream;
  bool convExist=false;   //convHasChanged
  int numMessageIni;

  //TODO: lle setState de onChanged nique la masse de read en avec le StreamBuilder
  //TODO: mettre le last message dans disucssion pour eviter d'écrire deux fois la même chose.

  

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
    _stream = Firestore.instance.collection("Discussions").document(widget._discussionId).collection("Message").orderBy("id",descending: true).snapshots();
    final MainBloc _mainBloc = BlocProvider.of<MainBloc>(context);
    currentUser =_mainBloc.currentUser;
  }

  Future<void> _sendMessages(Message message) async {
    print("[_sendMessages ]"+widget._discussionId);
    db.sendMessageFirestore(widget._discussionId,message,currentUser,widget._partner);
  }



  @override
  void dispose() async {
    //met à jour le champ lastMessageSeen pour que les nouveaux 
    //messages non lus soient notifiées
    //TODO: checker si il y a eu des changements avant d'utiliser update
    db.updateDiscussion(currentUser.id,widget._discussionId);
    print("dispose");
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
      body: StreamBuilder<QuerySnapshot>(
        stream: _stream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
          if(!snapshot.hasData) return Container();
          convExist=true;
          return Column(
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  itemCount: snapshot.hasData? snapshot.data.documents.length : 0,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: <Widget>[
                        widget._partner.id==snapshot.data.documents[index]["userId"]?
                        ChatBubble.fromDocumentSnapshot(snapshot.data.documents[index],true)
                        :
                        ChatBubble.fromDocumentSnapshot(snapshot.data.documents[index],false),
                        SizedBox(height: 10.0,) 
                      ],
                    );
                  }
                ),
              ),
              _buildMessageRow(context)
            ],
          );
          },
        ),
    );
  }
}
