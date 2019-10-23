import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  int _nbPosts;
  Future<QuerySnapshot> _futureUserPosts;

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
  
  


  Widget _buildTabs(User currentUser,QuerySnapshot userPosts){
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
                Icon(Icons.collections,size: 32.0,),
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
                PostGrid(),
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
                _mainBloc.dispose();
                Navigator.of(context).pop();
                await db.updateUserLastConnectionTime(currentUser.id);
                await db.signOutUser(currentUser.id);
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
                //await db.signOutUser(currentUser.id);
              } ,
            ),
          ],
        );
      }
    );
  }


  Widget _buildUserProfileColumn(User currentUser,BuildContext context){ 
    const IconData configuration = const IconData(0xf2f7,
          fontFamily: CupertinoIcons.iconFont,
          fontPackage: CupertinoIcons.iconFontPackage);
    //TODO: séparer en différent élément graphique
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
              SizedBox(
                width: 10.0,
              ),
              currentUser.photoUrl!=null ? 
              CircleAvatar(
                radius: MediaQuery.of(context).size.width*0.16,
                backgroundImage:  _currentUserPhoto,
              )
              :
              CircleAvatarInitiales(currentUser),
              SizedBox(
                width: 12.0,
              ),
              Expanded(
               flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 40.0,
                    ),
                    Text(currentUser.userName,style: TextStyle(fontSize: 25.0,fontWeight: FontWeight.bold,color: Colors.white),),
                    
          /*FlatButton(
            child: Text("Modifier profil",style: TextStyle(color: Colors.white),),
            onPressed: (){
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => ModifProfilePage(currentUser)
                  )
                );
            },
            color: Colors.transparent,          
          ),*/
          SizedBox(
            height: 15.0,
          ),
          Row(
            children: <Widget>[
              SizedBox(
                width: 20.0,
              ),
              Column(
                children: <Widget>[
                  Text(_nbPosts.toString(),style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.w500,color: Colors.white),),
                  Text("Posts",style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.w500,color: Colors.white),)
                ],
              ),
              SizedBox(
                width: 20.0,
              ),
              Column(
                children: <Widget>[
                  Text(currentUser.nbMarks.toString(),style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.w500,color: Colors.white),),
                  Text("Marks",style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.w500,color: Colors.white),)
                ],
              ),
              /*SizedBox(
                width: 9.0,
              ),
              IconButton(
                icon: Icon(Icons.edit,color: Colors.white,),
              )*/
            ],
          )
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    PopupMenuButton<int>(
                    onSelected: (int choice) async {
                      //TODO: réordonner les choix
                      switch(choice){
                        case 0:   //se déconnecter
                          await _buildLogOutDialog();
                          break;
                        /*case 1: //mode privé
                          await _buildPrivateDialog();
                          break;
                        case 2: //désactiver messages
                          await _buildStopChatDialog();
                          break;*/
                        case 3:
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) => ModifProfilePage(currentUser)
                            )
                          );
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context){
                      return [
                        PopupMenuItem(
                        child: Text("se déconnecter"),
                        value: 0 ,
                        ),
                        /*PopupMenuItem(
                        child: Text("rendre le profil privé"),
                        value: 1 ,
                        ),
                        PopupMenuItem(
                        child: Text("desactiver les nouveaux messages"),
                        value: 2 ,
                        ),*/
                        PopupMenuItem(
                        child: Text("Modifier le profil"),
                        value: 3 ,
                        ),
                      ];
                    },
                    icon: Icon(configuration,size: 27.0,color: Colors.white,),
                    
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
    super.initState();
    print("[initState userProfilePage]");
    _mainBloc = BlocProvider.of<MainBloc>(context);
    currentUser =_mainBloc.currentUser;
    _userProfileTabController =TabController(vsync: this,length: 2);
    _messageBoxList = const MessageBoxList();
    _futureUserPosts=_getUserPost();
    stream =  _mainBloc.userUpdateControllerStream;
  }

  Future<QuerySnapshot> _getUserPost() async {
    final QuerySnapshot userPosts = await Firestore.instance.collection("User").document(currentUser.id).collection("UserPost").orderBy("timeStamp",descending : true).getDocuments();
    _nbPosts=userPosts.documents.length;
    return userPosts;
  }

  @override
  Widget build(BuildContext context) {
    return  FutureBuilder(
      future: _futureUserPosts,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> userPostSnapshot){
        if(!userPostSnapshot.hasData){
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        _nbPosts=userPostSnapshot.data.documents.length;
        return StreamBuilder(
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
                  child: _buildTabs(snapshot.data,userPostSnapshot.data),
                )
              ],
            );
          },
        );
      }
    );
  }
}