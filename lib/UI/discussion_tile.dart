import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Bloc/main_bloc.dart';
import 'package:tags/Models/user.dart';
import 'package:tags/UI/user_circle_avatar.dart';
import 'package:tags/Utils/firebase_db.dart';
import 'package:tags/pages/UserProfilPages/chat_page.dart';


class DiscussionTile extends StatefulWidget {

  final bool _lastMessageSeen;
  final String _lastMessage;
  final String _discussionId;
  final String _partnerName;
  final String _partnerId;
  final String _partnerPhotoUrl;



  DiscussionTile.fromDocumentSnapshot(DocumentSnapshot snapshot, {Key key}): 
    _discussionId=snapshot.documentID,
    _lastMessage=snapshot.data["lastMessage"],
    _lastMessageSeen=snapshot.data["lastMessageSeen"],
    _partnerName=snapshot.data["partnerUserName"],
    _partnerId=snapshot.data["partnerId"],
    _partnerPhotoUrl=snapshot.data["partnerImageUrl"],
    super(key:key);

  @override
  _DiscussionTileState createState() => _DiscussionTileState();
}

class _DiscussionTileState extends State<DiscussionTile> {
  UserCircleAvatar userCircleAvatar;

  void _navigateChatPage(BuildContext context){

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context){
          User partner = User.fromDiscussion(widget._partnerId,widget._partnerName,widget._partnerPhotoUrl);
          return ChatPage(partner,widget._discussionId);
        }
      )
    );
  }

  void deleteDiscussion(User currentUser){
    db.deleteDiscussionFireStore(widget._discussionId,currentUser.id);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("[initState discussion_Tile]");
    userCircleAvatar= UserCircleAvatar(widget._partnerName,widget._partnerId);
  }

  @override
  Widget build(BuildContext context) {
    final MainBloc _mainBloc = BlocProvider.of<MainBloc>(context);
    final User currentUser =_mainBloc.currentUser;
    return Container(
      child: ListTile(
        trailing: widget._lastMessageSeen? Container(width: 0.0,height: 0.0,)
        :CircleAvatar(
            child: Center(child: Icon(Icons.error,size: 20.0,color:Colors.red),),
            backgroundColor: Color(0xFFF8F8F8),
            radius: 10.0,
          ),
        onLongPress: (){
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[ 
                  Text("Voulez-vous supprimer cette discussion ?"),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: (){
                      deleteDiscussion(currentUser);
                    },
                  )
                ],
              ),
            )
          );
        },
        onTap:(){
          _navigateChatPage(context);
        },
        leading:userCircleAvatar,
        title: Text(widget._partnerName),
        subtitle: Text(widget._lastMessage),
      ),
    );
  }
}