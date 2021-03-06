import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Bloc/main_bloc.dart';
import 'package:tags/Models/user.dart';
import 'package:tags/UI/circle_avatar_initiales.dart';
import 'package:tags/UI/loading_overlay.dart';
import 'package:tags/Utils/firebase_db.dart';



class ModifProfilePage extends StatefulWidget {
  //final NetworkImage _userPhoto;
  final User _oldUser;   //oldUser

  ModifProfilePage(this._oldUser);

  _ModifProfilePageState createState() => _ModifProfilePageState();
}

class _ModifProfilePageState extends State<ModifProfilePage> {
  bool _isLoading=false;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _prenom;
  String _nom;
  String _nomUtilisateur;
  String _bio;
  File _tempUserImage;

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
          maxLength: 18,
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
                borderSide: BorderSide(color: Colors.red)),
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
          maxLength: 15,
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
                borderSide: BorderSide(color: Colors.red)),
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
          maxLength: 15,
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
                borderSide: BorderSide(color: Colors.red)),
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
            _buildBioTextFormField(widget._oldUser.bio),
            SizedBox(height: 17),
        ],
      ),
    );
  }

  void _onConfirmRaisedButtonPressed(BuildContext context) async {
    if(_formKey.currentState.validate()){
      _formKey.currentState.save();
      //print(_nomUtilisateur);
      setState(() {
        _isLoading=true;
      });
      db.updateUser(widget._oldUser, _prenom, _nom, _nomUtilisateur,_bio);
      if(_tempUserImage!=null) await db.updateUserPhoto(widget._oldUser, _tempUserImage);
      //print("2");     //s'execute avant la fin de db.updateUser pas bon 
      Navigator.of(context).pop();
    }
  }

  Widget _buildConfirmRaisedButton(BuildContext context) {
    return RaisedButton(
      color: Colors.red,
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

  Future<File> takePicture(BuildContext context, ImageSource source) async {
    final File imageFile = await ImagePicker.pickImage(source: source, maxWidth: 480, maxHeight: 480);
    return imageFile;
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
                    setState(() {
                      takePicture(context, ImageSource.camera).then((file){
                        setState(() {
                          _tempUserImage=file;
                        });
                      });
                    });
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
                    setState(() {
                      takePicture(context, ImageSource.gallery).then((file){
                        setState(() {
                          _tempUserImage=file;
                        });
                      });
                    });
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

  Widget _buildBioTextFormField(String currentBio){
    return Container(
      color: Colors.grey[50],
      width: MediaQuery.of(context).size.width-80.0,
      child: TextFormField(
              maxLength: 170,
              maxLengthEnforced: true ,
              initialValue: currentBio,
              onSaved: (String val){
                _bio=val;
              },
              decoration: InputDecoration(
              labelText: "bio",
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red)),
              border: UnderlineInputBorder(),
            ),
              keyboardType: TextInputType.multiline,
              maxLines: null,
              cursorColor: Colors.red,
            
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final MainBloc _mainBloc = BlocProvider.of<MainBloc>(context);
    final User currentUser =_mainBloc.currentUser;
    return Stack(
      children:<Widget>[ 
        Scaffold(
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
                    _mainBloc.userPhoto != null || _tempUserImage != null? 
                    CircleAvatar(
                      radius: MediaQuery.of(context).size.width*0.16,
                      backgroundImage: _tempUserImage==null? _mainBloc.userPhoto : FileImage(_tempUserImage),
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
      ),
        _isLoading?LoadingOverlay():Container(),
      ],
    );
  }
}