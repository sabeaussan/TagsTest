import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';



class ChatBubble extends StatelessWidget {

  final bool _isPatner;
  final String _id;
  final String _timeStamp;
  final String _content;





  ChatBubble.fromDocumentSnapshot(DocumentSnapshot snapshot,bool isPartner):
    _id=snapshot.documentID,
    _isPatner = isPartner,
    _content=snapshot.data["content"],
    _timeStamp=snapshot.data["timeStamp"];





  void _navigateOtherUserProfilePage(BuildContext context){
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context){
          //return OtherUserProfilePage();
        }
      )
    );
  }


  Widget _buildChatBubble(BuildContext context){
    return Row(
      mainAxisAlignment: _isPatner? MainAxisAlignment.end: MainAxisAlignment.start,
      children: <Widget>[
        Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width*0.65),
            margin: EdgeInsets.only(right: 10.0),
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: _isPatner? Colors.orange[200] : Colors.deepOrange,
              border: Border.all(
                color:  _isPatner? Colors.orange[200] : Colors.deepOrange,
                width: 2.0,
                style: BorderStyle.solid
              ) ,
              borderRadius: const BorderRadius.all(Radius.circular(15.0)),
            ),
              child: Text(_content,style: TextStyle(color: _isPatner?  Colors.black : Colors.white,fontSize: 16.0),),
            
          ),
        
      ],
    );
  }



  @override
  Widget build(BuildContext context) {
    return _buildChatBubble(context);
  }
}