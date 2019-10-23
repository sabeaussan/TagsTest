import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tags/Utils/firebase_db.dart';





class LoginPage extends StatefulWidget {
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _logIn = true;
  String _email;
  String _prenom;
  String _nom;
  String _nomUtilisateur;
  String _passWord;
  bool _isLoading=false;
  GlobalKey<FormState> _formKey =GlobalKey<FormState>();

  Widget _buildTitle() {
    return Text("Tags",
        style: TextStyle(
            color: Colors.red,
            fontSize: 40.0,
            fontFamily: "InkFree",
            fontWeight: FontWeight.w900));
  }

  

  void _onLogButtonPressed(BuildContext context)  {
    //TODO: récupérer le currentUser depuis le type de retour de signInUser et createUser
    if(_formKey.currentState.validate()){
          setState(() {
          _isLoading=true; 
        });
      _formKey.currentState.save();
      if(_logIn){
        db.signInUser(_email, _passWord).then((FirebaseUser fbUser){
          if(fbUser!=null) print("utilisateur authentifié");     
        }).catchError((e) async{
          setState(() {
            _isLoading=false; 
          });  
          await _onLogErrorSignIn(e,context);
        });
         
      }
      else{
        db.createUser(_email, _passWord, _nom, _prenom, _nomUtilisateur).then((FirebaseUser fbUser){
           if(fbUser!=null)  print("utlisateur créé");
        }).catchError((e) async{
          setState(() {
            _isLoading=false; 
          });  
          await _onLogErrorCreateUser(e.toString(),context);
        });
      }
      
    }

  }

  Future<void> _onLogErrorSignIn(dynamic e,BuildContext context){
    final PlatformException error=e;
    Text errorText;
    print("############ DEBUG ERROR SIGNIN ##########");
    print(error.message);
    switch(error.code){
      case "ERROR_INVALID_EMAIL":
        errorText=Text("L'email que vous avez rentré est invalide");
        break;
      case "ERROR_WRONG_PASSWORD":
        errorText=Text("Il semblerait que votre mot de passe soit erroné");
        break;
      case "ERROR_USER_NOT_FOUND":
        errorText=Text("Utilisateur inconnu, inscrivez-vous si ce n'est pas encore fait :)");
        break;
      case "ERROR_TOO_MANY_REQUESTS":
        errorText=Text("Trop d'utilisateur se connectent en même temps, réessayer dans quelques secondes :)");
        break;
      default:
        errorText=Text("Problème d'authentification...");
        break;
    }
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context){
        return AlertDialog(
          content: errorText,
          actions: <Widget>[
            FlatButton(
              child: Text("ok"),
              onPressed: (){
                Navigator.of(context).pop();
              },
            )
          ],
        );
      }
    );
  }

  Future<void> _onLogErrorCreateUser(String error,BuildContext context){
    Text errorText =Text(error);
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context){
        return AlertDialog(
          content: errorText,
          actions: <Widget>[
            FlatButton(
              child: Text("ok"),
              onPressed: (){
                Navigator.of(context).pop();
              },
            )
          ],
        );
      }
    );
  }

  Widget _buildRowSwitchLog(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(_logIn?
          "Pas encore inscrit ? " :
          "Deja inscrit ? "),
        FlatButton(
          color: Colors.transparent,
          textColor: Colors.red[300],
          child: Text( _logIn?
          "Inscris toi !" :
            "connecte toi !" 
          ),
          onPressed: (){
            setState(() {
              _logIn=!_logIn;
            });
          },
        )
      ],
    );
  }

  Widget _buildLogButton() {
    return RaisedButton(
      padding: EdgeInsets.all(15.0),
      elevation: 8.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text( _logIn?
              "se connecter" :
              "S'inscrire",
                style: TextStyle(
                  fontSize: 17.0,
                  color: Colors.white,
                )
              ),
              SizedBox(width: 10.0,),
              _isLoading?
              SizedBox(
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white)
                ),
                height: 20.0,
                width: 20.0,
              )
              :
              Container()
          ],
        ),
        color: Colors.red,
        onPressed: () {
          _onLogButtonPressed(context);
        });
  }

  Widget _buildFormLogin() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          SizedBox(height: 17),
          _buildEmailTextField("e-mail"),
          SizedBox(height: 17),
          _logIn? Container(): _buildNameTextField("Nom"),
          _logIn? Container(): SizedBox(height: 17),
          _logIn? Container(): _buildPrenomTextField("Prenom"),
         _logIn? Container():  SizedBox(height: 17),
          _logIn? Container(): _buildUserNameTextField("Nom d'utilisateur"),
         _logIn? Container():  SizedBox(height: 17),
          _buildPassWordTextField("Mot de passe"),
          //TODO: rajouter une confirlation de mot de passe
          SizedBox(height: 17),
        ],
      ),
    );
  }


  Widget _buildPassWordTextField(String hint) {
    return Center(
      child: Container(
        color: Colors.grey[50],
        width: MediaQuery.of(context).size.width - 80.0,
        child: TextFormField(
          obscureText: true,
          validator: (String input){
            if(input.length<6) return "Au moins 6 caractères recquis";
          },
          onSaved: (String val){
            _passWord=val.trim();
          },
          style: TextStyle(fontSize: 15.0, color: Colors.black),
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red)),
            border: OutlineInputBorder(),
            labelStyle: TextStyle(color: Colors.red[200]),
            labelText: hint,
          ),
          maxLines: 1,
          keyboardType: TextInputType.text,
        ),
      ),
    );
  }

  Widget _buildUserNameTextField(String hint) {
    return Center(
      child: Container(
        color: Colors.grey[50],
        width: MediaQuery.of(context).size.width - 80.0,
        child: TextFormField(
          validator: (String input){
            if(input.length<2) return "Au moins 2 caractères recquis";
          },
          onSaved: (String val){
            _nomUtilisateur=val.trim();
          },
          style: TextStyle(fontSize: 15.0, color: Colors.black),
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red)),
            border: OutlineInputBorder(),
            labelStyle: TextStyle(color: Colors.red[200]),
            labelText: hint,
          ),
          maxLines: 1,
          keyboardType: TextInputType.text,
        ),
      ),
    );
  }

            
  Widget _buildPrenomTextField(String hint) {
    return Center(
      child: Container(
        color: Colors.grey[50],
        width: MediaQuery.of(context).size.width - 80.0,
        child: TextFormField(
          validator: (String input){
            if(input.length==0) return "Rentre un prenom valide";
          },
          onSaved: (String val){
            _prenom=val.trim();
          },
          style: TextStyle(fontSize: 15.0, color: Colors.black),
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red)),
            border: OutlineInputBorder(),
            labelStyle: TextStyle(color: Colors.red[200]),
            labelText: hint,
          ),
          maxLines: 1,
          keyboardType: TextInputType.text,
        ),
      ),
    );
  }

  Widget _buildNameTextField(String hint) {
    return Center(
      child: Container(
        color: Colors.grey[50],
        width: MediaQuery.of(context).size.width - 80.0,
        child: TextFormField(
          validator: (String input){
            if(input.length==0) return "Rentre un nom valide";
          },
          onSaved: (String val){
            _nom=val.trim();
          },
          style: TextStyle(fontSize: 15.0, color: Colors.black),
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red)),
            border: OutlineInputBorder(),
            labelStyle: TextStyle(color: Colors.red[200]),
            labelText: hint,
          ),
          maxLines: 1,
          keyboardType: TextInputType.text,
        ),
      ),
    );
  }

  Widget _buildEmailTextField(String hint) {
    return Center(
      child: Container(
        color: Colors.grey[50],
        width: MediaQuery.of(context).size.width - 80.0,
        child: TextFormField(
          validator: (String input){
            if(input.length==0) return "Rentre une email valide";
          },
          onSaved: (String val){
            _email=val.trim();
          },
          style: TextStyle(fontSize: 15.0, color: Colors.black),
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red)),
            border: OutlineInputBorder(),
            labelStyle: TextStyle(color: Colors.red[200]),
            labelText: hint,
          ),
          maxLines: 1,
          keyboardType: TextInputType.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(25.0),
              child :Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                   Container(
                      width: MediaQuery.of(context).size.width - 50,
                      child : Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 8.5,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              _buildTitle(),
                              _buildFormLogin(),
                              _buildLogButton(),
                              _buildRowSwitchLog(),
                              SizedBox(height: 15),
                            ],
                        )),
                    ),
                ],
              ),
            )
          ),
    );
  }
}
