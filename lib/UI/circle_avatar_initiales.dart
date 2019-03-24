
import 'package:flutter/material.dart';
import 'package:tags/Models/user.dart';


class CircleAvatarInitiales extends StatelessWidget {
  final User _user;

  CircleAvatarInitiales(this._user);

  String getInitiales(){
    String initiales = _user.prenom[0] + _user.nom[0];
    return initiales;
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: MediaQuery.of(context).size.width*0.16,
      backgroundColor: Colors.deepOrange[300],
      child: Text(getInitiales(),style: TextStyle(fontSize: 48.0,color: Colors.white),),
    );
  }
}