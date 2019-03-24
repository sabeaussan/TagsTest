import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Bloc/main_bloc.dart';
import 'package:tags/Models/user.dart';
import 'package:tags/UI/circle_avatar_initiales.dart';
import 'package:tags/Utils/firebase_db.dart';



class ModifProfilePage extends StatefulWidget {
  //final NetworkImage _userPhoto;
  final User _oldUser;   //oldUser

  ModifProfilePage(this._oldUser);

  _ModifProfilePageState createState() => _ModifProfilePageState();
}

class _ModifProfilePageState extends State<ModifProfilePage> {

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _prenom;
  String _nom;
  String _nomUtilisateur;

//TODO: dispose les controller
  TextEditingController _nomController;
  TextEditingController _prenomController;
  TextEditingController _userNameController;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nomController=TextEditingController(text: widget._oldUser.nom);
    _prenomController=TextEditingController(text: widget._oldUser.prenom);
    _userNameController=TextEditingController(text:widget._oldUser.userName );
  }


  Widget _buildUserNameTextField() {
    return Center(
      child: Container(
        color: Colors.grey[50],
        width: MediaQuery.of(context).size.width - 80.0,
        child: TextFormField(
          controller: _userNameController,
          validator: (String input){
            if(input.length<2) return "Au moins 2 caractères recquis";
          },
          onSaved: (String val){
            _nomUtilisateur=val;
          },
          style: TextStyle(fontSize: 15.0, color: Colors.black),
          decoration: InputDecoration(
            labelText: "userName",
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.deepOrange)),
            border: UnderlineInputBorder(),
          ),
          maxLines: 1,
          keyboardType: TextInputType.text,
        ),
      ),
    );
  }

  Widget _buildPrenomTextField() {
    return Center(
      child: Container(
        color: Colors.grey[50],
        width: MediaQuery.of(context).size.width - 80.0,
        child: TextFormField(
          controller:_prenomController ,
          validator: (String input){
            if(input.length==0) return "Rentre un prenom valide";
          },
          onSaved: (String val){
            _prenom=val;
          },
          style: TextStyle(fontSize: 15.0, color: Colors.black),
          decoration: InputDecoration(
            labelText: "prenom",
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.deepOrange)),
            border: UnderlineInputBorder(),
          ),
          maxLines: 1,
          keyboardType: TextInputType.text,
        ),
      ),
    );
  }

  

  Widget _buildNameTextField() {
    return Center(
      child: Container(
        color: Colors.grey[50],
        width: MediaQuery.of(context).size.width - 80.0,
        child: TextFormField(
          controller: _nomController,
          validator: (String input){
            if(input.length==0) return "Rentre un nom valide";
          },
          onSaved: (String val){
            _nom=val;
          },
          style: TextStyle(fontSize: 15.0, color: Colors.black),
          decoration: InputDecoration(
            labelText: "nom",
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.deepOrange)),
            border: UnderlineInputBorder(),
          ),
          maxLines: 1,
          keyboardType: TextInputType.text,
        ),
      ),
    );
  }

  Widget _buildFormLogin() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          SizedBox(height: 17),
            _buildNameTextField(),
            SizedBox(height: 17),
            _buildPrenomTextField(),
            SizedBox(height: 17),
            _buildUserNameTextField(),
          SizedBox(height: 17),
        ],
      ),
    );
  }

  void _onConfirmRaisedButtonPressed(BuildContext context) {
    if(_formKey.currentState.validate()){
      _formKey.currentState.save();
      db.updateUser(widget._oldUser, _prenom, _nom, _nomUtilisateur);
      //print("2");     //s'execute avant la fin de db.updateUser pas bon 
      Navigator.of(context).pop();
    }
  }

  Widget _buildConfirmRaisedButton(BuildContext context) {
    return RaisedButton(
      color: Colors.deepOrange,
      onPressed: (){
        _onConfirmRaisedButtonPressed(context);
      },
      padding: EdgeInsets.all(15.0),
      elevation: 8.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Text(
        "Appliquer",
        style: TextStyle(
          fontSize: 17.0,
          color: Colors.white,
        )
      ),
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _userNameController.dispose();
    super.dispose();
  }

  /*----------------------------------A refactorer----------------------------------------------*/ 

  Future<void> takePicture(BuildContext context, ImageSource source) async {
    final File imageFile = await ImagePicker.pickImage(source: source, maxWidth: 800, maxHeight: 800);
    await db.updateUserPhoto(widget._oldUser,imageFile);
    return;
  }

  void openPicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 120.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FlatButton(
                  padding: EdgeInsets.all(20.0),
                  child: Icon(
                    Icons.camera_alt,
                    size: 40.0,
                  ),
                  onPressed: () {
                    takePicture(context, ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  padding: EdgeInsets.all(20.0),
                  child: Icon(
                    Icons.collections,
                    size: 40.0,
                  ),
                  onPressed: () {
                    takePicture(context, ImageSource.gallery);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }

  /*--------------------------------------------------------------------------------------------*/ 

  void _changeUserPhoto(BuildContext context){
    openPicker(context);
  }

  @override
  Widget build(BuildContext context) {
    final MainBloc _mainBloc = BlocProvider.of<MainBloc>(context);
    final User currentUser =_mainBloc.currentUser;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Modifier le profile",
          style: TextStyle(
              color: Colors.black,
              fontFamily:"Raleway",
              fontWeight: FontWeight.w500
            ),
          ),
        elevation: 0.0,
      ),
      body: StreamBuilder<User>(
        stream: _mainBloc.userUpdateControllerStream ,
        initialData: currentUser ,
        builder: (BuildContext context, AsyncSnapshot<User> snapshot){
          return SingleChildScrollView(
            padding: EdgeInsets.all(25.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _mainBloc.userPhoto!=null ? 
                  CircleAvatar(
                    radius: MediaQuery.of(context).size.width*0.16,
                    backgroundImage: _mainBloc.userPhoto
                  )
                  :
                  CircleAvatarInitiales(widget._oldUser),
                  FlatButton(
                    child: Text("Modifier photo",),
                    onPressed: (){
                      _changeUserPhoto(context);
                    },
                    color: Colors.transparent,          
                  ),
                  _buildFormLogin(),
                  _buildConfirmRaisedButton(context)
                ],
              ) ,
            ),
          );
        },
      ),
    );
  }
}