import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Bloc/main_bloc.dart';
import 'package:tags/Models/user.dart';
import 'package:tags/UI/circle_avatar_initiales.dart';
import 'package:tags/Utils/firebase_db.dart';
import 'package:tags/pages/UserProfilPages/message_box_list.dart';
import 'package:tags/pages/UserProfilPages/modif_profile_page.dart';
import 'package:tags/pages/UserProfilPages/post_grid_view.dart';
import 'dart:async';


class UserProfilePage extends StatefulWidget {

  //TODO: utiliser un streamBuiilder pour séparer logic de UI

  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> with SingleTickerProviderStateMixin {

  CachedNetworkImageProvider _currentUserPhoto;
  TabController _userProfileTabController;
  MessageBoxList _messageBoxList;
  PostGrid _postGrid;
  User currentUser;
  MainBloc _mainBloc;
  Stream<User> stream;

  Widget _buildNewMessageIcon(IconData icon){
    return Stack(
        children: <Widget>[
          Icon(icon,size: 37.0,),
          //TODO: en faire un élément graphique
          //et gérer ici le snapshot pour savoir quoi renvoyer
          CircleAvatar(
            child: Center(child: Icon(Icons.error,size: 20.0,color:Colors.deepOrange),),
            backgroundColor: Color(0xFFF8F8F8),
            radius: 10.0,
          )
        ],
    );
  }
  
  


  Widget _buildTabs(User currentUser){
    const IconData telegram = const IconData(0xf474,
          fontFamily: CupertinoIcons.iconFont,
          fontPackage: CupertinoIcons.iconFontPackage);
    return Column(
          children: <Widget>[
            Divider(
              height: 1.0,
            ),
            SizedBox(height: 16.0,),   
            TabBar(
              labelPadding: EdgeInsets.only(bottom: 10.0),
              controller:_userProfileTabController,
              tabs: <Widget>[
                StreamBuilder<bool>(
                  stream: _mainBloc.newCommentControllerStream ,
                  initialData: _mainBloc.newComment ,
                  builder: (BuildContext context, AsyncSnapshot<bool> snapshotComment){
                    return snapshotComment.data? _buildNewMessageIcon(Icons.collections) :  Icon(Icons.collections,size: 32.0,);
                  },
                ),
                StreamBuilder<bool>(
                  stream:_mainBloc.newMessageControllerStream ,
                  initialData:  _mainBloc.newMessage ,
                  builder: (BuildContext context, AsyncSnapshot<bool> snapshotMessage){
                    return snapshotMessage.data? _buildNewMessageIcon(telegram):Icon(telegram,size: 40.0);
                  },
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
              children: <Widget>[
                _postGrid,
                _messageBoxList
              ],
              controller:_userProfileTabController ,
            ),
            )
          ],
    );
  }

 

  Future<void> _buildLogOutDialog(){
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context){
        return AlertDialog(
          content: Text("Etes-vous sur de vouloir vous déconnecter ?"),
          actions: <Widget>[
            FlatButton(
              child: Text("non",style: TextStyle(fontSize: 20.0),),
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("oui",style: TextStyle(fontSize: 20.0),),
              onPressed:() async{
                Navigator.of(context).pop();
                await db.signOutUser();
              } ,
            ),
          ],
        );
      }
    );
  }

  Future<void> _buildStopChatDialog(){
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context){
        return AlertDialog(
          content: Text("Les utlisateurs qui ne sont pas déjà en correspondance avec vous ne pourront plus vous envoyer de messages"),
          actions: <Widget>[
            FlatButton(
              child: Text("non",style: TextStyle(fontSize: 20.0),),
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("oui",style: TextStyle(fontSize: 20.0),),
              onPressed:() async{
                Navigator.of(context).pop();
                //await db.signOutUser();
              } ,
            ),
          ],
        );
      }
    );
  }

  Future<void> _buildPrivateDialog(){
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context){
        return AlertDialog(
          content: Text("Les utlisateurs qui ne sont pas déjà en correspondance avec vous n'auront plus accès à votre profile"),
          actions: <Widget>[
            FlatButton(
              child: Text("non",style: TextStyle(fontSize: 20.0),),
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("oui",style: TextStyle(fontSize: 20.0),),
              onPressed:() async{
                Navigator.of(context).pop();
                await db.signOutUser();
              } ,
            ),
          ],
        );
      }
    );
  }


  Widget _buildUserProfileColumn(User currentUser,BuildContext context){ 
    return Expanded(
      flex: 0,
      child: Center(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height*0.28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(bottom: Radius.elliptical(150.0,30.0)),
              color: Colors.red,
              shape: BoxShape.rectangle
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
              SizedBox(
                width: 10.0,
              ),
                GestureDetector(
              onTap: _currentUserPhoto!=null?
               (){}
              :
              null ,
              child:currentUser.photoUrl!=null ? 
              CircleAvatar(
                radius: MediaQuery.of(context).size.width*0.16,
                backgroundImage:  _currentUserPhoto,
              )
              :
              CircleAvatarInitiales(currentUser),
            ),
            SizedBox(
              width: 12.0,
            ),
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[

                       Text(currentUser.userName,style: TextStyle(fontSize: 25.0,fontWeight: FontWeight.bold,color: Colors.white),),
                    
          FlatButton(
            child: Text("Modifier profil",style: TextStyle(color: Colors.white),),
            onPressed: (){
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => ModifProfilePage(currentUser)
                  )
                );
            },
            color: Colors.transparent,          
          ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    PopupMenuButton<int>(
                    onSelected: (int choice)async {
                      switch(choice){
                        case 0:   //se déconnecter
                          await _buildLogOutDialog();
                          break;
                        case 1: //mode privé
                          await _buildPrivateDialog();
                          break;
                        case 2: //désactiver messages
                          await _buildStopChatDialog();
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context){
                      return [
                        PopupMenuItem(
                        child: Text("se déconnecter"),
                        value: 0 ,
                        ),
                        PopupMenuItem(
                        child: Text("rendre le profil privé"),
                        value: 1 ,
                        ),
                        PopupMenuItem(
                        child: Text("desactiver les nouveaux messages"),
                        value: 2 ,
                        ),
                      ];
                    },
                    icon: Icon(Icons.menu,size: 30.0,color: Colors.white,),
                    
                    ),
                  ],
                )
              ),
              ],
            ),
          ),
          ],
        ),
    ),
    );
  }

  

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("[initState userProfilePage]");
    _mainBloc = BlocProvider.of<MainBloc>(context);
    currentUser =_mainBloc.currentUser;
    _userProfileTabController =TabController(vsync: this,length: 2);
    _messageBoxList = const MessageBoxList();
    _postGrid=PostGrid(currentUser);
    stream =  _mainBloc.userUpdateControllerStream;
  }


  @override
  Widget build(BuildContext context) {
    return  StreamBuilder(
      stream: stream ,
      initialData: currentUser ,
      builder: (BuildContext context, AsyncSnapshot<User> snapshot){
        if(!snapshot.hasData){
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        _currentUserPhoto =_mainBloc.userPhoto;
        return Column(
          children: <Widget>[
          _buildUserProfileColumn(snapshot.data,context,),
            SizedBox(
              height: 10.0,
            ),
            Container(
              child: Text(currentUser.bio),
              margin: EdgeInsets.all(10.0),
            ),
            SizedBox(
              height: 20.0,
            ),
            Expanded(
              flex: 3,
              child: _buildTabs(snapshot.data),
            )
          ],
        );
      },
    );
  }
}