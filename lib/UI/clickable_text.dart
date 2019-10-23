import 'package:flutter/material.dart';
import 'package:tags/Models/user.dart';
import 'package:tags/Utils/firebase_db.dart';
import 'package:tags/pages/other_user_profile_page.dart';

class ClickableWidget extends StatelessWidget {

  final Widget _child;
  final String _uid;

  ClickableWidget(this._child,this._uid);

  //TODO : faire un clickable widget plutot


  void _navigateOtherUserProfilePage(BuildContext context) async{
    final User user = await db.getUser(_uid);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context){
          return OtherUserProfilePage(user);
        }
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      child: _child,
      onTap: (){
        _navigateOtherUserProfilePage(context);
      },
    );
  }



}