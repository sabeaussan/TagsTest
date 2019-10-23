import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Bloc/bloc_tags_page.dart';
import 'package:tags/Bloc/main_bloc.dart';
import 'package:tags/Models/publicmark.dart';
import 'package:tags/Models/tags_message.dart';
import 'package:tags/Models/user.dart';
import 'package:tags/Utils/firebase_db.dart';
import 'package:tags/Utils/image_picker.dart';

const int CHAT_PAGE = 1;

class SendMessageTile extends StatefulWidget {
  
  //TODO: passer une void call back a éxecuter quand ont appuie sur envoie
  final PublicMark _mark;
  final BlocTagsPage _bloc;


  SendMessageTile(this._bloc,this._mark);

  _SendMessageTileState createState() => _SendMessageTileState();
}

class _SendMessageTileState extends State<SendMessageTile> {
  
  FocusNode _focusNode;
  TextEditingController _messageTextController;
  GlobalKey<FormFieldState> _key = GlobalKey<FormFieldState>();
  String message;

  String timeStamp() => DateTime.now().millisecondsSinceEpoch.toString();


  void _sendTagMessages(TagsMessage message) async  {
    await db.sendTagMessageFirestore(message);
  }
  

  Widget _buildMessageRow(User currentUser) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          currentUser.id!=widget._mark.creatorId && widget._mark.isPersonnal? 
            Container()
            :
            ImagePickerUtils(_focusNode, widget._bloc,widget._mark.photoOnly),
          Expanded(
              child: TextFormField(
                key: _key,
                onTap: (){
                  widget._bloc.numTabSink.add(CHAT_PAGE);
                },
                onSaved: (String val){
                  message=val;
                },
                controller: _messageTextController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  filled: false,
                  hintText: "message...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(10.0)), 
                keyboardType: TextInputType.multiline,
                maxLines: null,
                cursorColor: Colors.red,
              ),
          ),
          IconButton(
                disabledColor: Colors.black12,
                icon: Icon(Icons.send, color: _focusNode.hasFocus? Colors.red:Color.fromARGB(150,182, 182, 182)),
                onPressed:
                ()async {
                  _key.currentState.save();
                  if(message.trim().length!=0){
                    TagsMessage messageTosend =TagsMessage(null, currentUser.id,_messageTextController.text,currentUser.userName,currentUser.photoUrl,widget._mark.id,timeStamp());
                    _messageTextController.clear();
                    _sendTagMessages(messageTosend);
                  }
                },
              )
        ],
      ),
      decoration: BoxDecoration(
        color: Color.fromARGB(40,182, 182, 182),
        border: Border.all(
          width: 2.0,
          color: _focusNode.hasFocus? Colors.red:Color.fromARGB(150,182, 182, 182),
          style: BorderStyle.solid
        ) ,
        borderRadius: const BorderRadius.all(Radius.circular(25.0)),
      ),
    );
  }

  

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    _messageTextController=TextEditingController();
  }

  @override
  void dispose() {
    /*_focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _messageTextController.dispose();*/
    super.dispose();
  }

  void _onFocusChange(){
    setState(() {  
    });
  }

  @override
  Widget build(BuildContext context) {
    final MainBloc _mainBloc = BlocProvider.of<MainBloc>(context);
    final User currentUser =_mainBloc.currentUser;
    return _buildMessageRow(currentUser);
  }
}