import 'package:cached_network_image/cached_network_image.dart';
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
  
  


  Widget _buildTabs(User currentUser){
    return SliverFillRemaining(
        child :Column(
          children: <Widget>[
            Divider(
              height: 1.0,
            ),
            SizedBox(height: 16.0,),   
            TabBar(
              labelPadding: EdgeInsets.only(bottom: 10.0),
              controller:_userProfileTabController,
              tabs: <Widget>[
                Icon(Icons.image,size: 37.0,),
                Icon(Icons.mail,size: 37.0)
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
        )
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
    return Center(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AppBar(
              automaticallyImplyLeading: false,
              elevation: 0.0,
              actions: <Widget>[
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
                  icon: Icon(Icons.menu,size: 30.0,color: Colors.black87,),
                  
                  ),
                
              ],
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
          Text(currentUser.userName,style: TextStyle(fontSize: 25.0,fontWeight: FontWeight.bold),),
          FlatButton(
            child: Text("Modifier profil",),
            onPressed: (){
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) => ModifProfilePage(currentUser)
                )
              );
            },
            color: Colors.transparent,          
          ),
          Divider()
          ],
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

  Widget _buildSliverAppBar(User currentUser){
    return 
        SliverAppBar(
          snap: true,
          floating: true,
          elevation: 0.0,
          automaticallyImplyLeading: false,
          expandedHeight: MediaQuery.of(context).size.height*0.52,
          flexibleSpace: FlexibleSpaceBar(  
            background: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildUserProfileColumn(currentUser,context,),
                ListTile(                           //Utiliser une ExpansionListTile plus tard
                  dense: true,
                  title:  Text(currentUser.bio),
                ),
                //SizedBox(height: 15.0),
              ],
           ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    print(currentUser.id);
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
        return Container(
          child: Stack(
            children: <Widget>[
              CustomScrollView(
                slivers: <Widget>[
                  _buildSliverAppBar(snapshot.data),
                  _buildTabs(snapshot.data),
                ],
              ),

            ],
          ),
        );
      },
    );
  }
}