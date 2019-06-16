import 'package:flutter/material.dart';


import 'package:tags/Bloc/bloc_home_page.dart';
import 'package:tags/UI/mainBottomNavBar.dart';
import 'package:tags/Utils/firebase_db.dart';
import 'package:tags/pages/MapPage/filter_map_page.dart';
import 'package:tags/pages/add_tags_page.dart';
import 'package:tags/pages/MapPage/map_page.dart';



enum AppBarHomePage {
  mapBar,
  favBar,
  userProfileBar,
  listBar
}


class Homepage extends StatefulWidget {

  //TODO: faire une Map ou une class qui contient page et appBar et wrap
  HomepageState createState() => HomepageState();
  
}

class HomepageState extends State<Homepage> with SingleTickerProviderStateMixin {
  final BlocHomePage _blocHomePage = BlocHomePage();
  int index=0;
  static TabController _favTabController;   //déclarer en static pour y avoir accès depuis une instance dans favPage

  TabController get favTabController=> _favTabController;  

  Widget _buildAppBar(AppBarHomePage appBarPage){

    //Cette fonction fournit l'appBar de la page affiché sur la HomePage
    if(appBarPage==AppBarHomePage.mapBar){
      return AppBar(
        title: Text("Tags" ),
      );
    }
    if(appBarPage==AppBarHomePage.favBar){
        return AppBar(
          automaticallyImplyLeading: false,
          elevation: 5.0,
          titleSpacing: 0.0,
          actions: <Widget>[
            IconButton(
              onPressed: (){},
              padding: EdgeInsets.only(bottom: 5.0),
              icon: Icon(Icons.star,color: Colors.deepOrange,size: 30.0,),
            ),
          ], 
          title: TabBar(
            labelPadding: EdgeInsets.only(top: 10.0,bottom: 10.0),
            labelStyle: TextStyle(fontSize: 23.0,fontFamily: "InkFree",fontWeight: FontWeight.w800) ,
            controller: favTabController,
            tabs: <Widget>[
              Tab(text: "A proximité",),
              Tab(text: "Les plus aimés"),
            ],
          )
        );
    }
    if(appBarPage==AppBarHomePage.userProfileBar){
        return PreferredSize(
          preferredSize: Size.fromHeight(0.0),
          child: Container(),
        );
    }
    if(appBarPage==AppBarHomePage.listBar){
      return AppBar(
        leading: Icon(Icons.search),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: (){
              db.signOutUser();
            },
            iconSize: 30.0,
          )
        ],
        title: Text("Tags à proximité" ),
      );
    }
  }

  void _navigateAddTagsPage(BuildContext context){
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context)=>AddTagsPage())
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _favTabController = TabController(vsync:this,length: 2);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    print("[dispose HomePage]");
    //_favTabController.dispose();
  }
  

  @override
  Widget build(BuildContext context) {
    return (
      StreamBuilder(
        stream: _blocHomePage.widgetPageStream,
        builder: (BuildContext context, AsyncSnapshot<Map<Widget,AppBarHomePage>> snapshot) {
          return Scaffold(
            appBar: snapshot.data==null?
            _buildAppBar(AppBarHomePage.mapBar):_buildAppBar(snapshot.data.values.single),
            body:snapshot.data==null? MapPage():snapshot.data.keys.single,           
            bottomNavigationBar: BottomNavBar(_blocHomePage),
            
            floatingActionButton: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFFF8F8F8),width: 4.5),
                shape: BoxShape.circle
              ),
              child: FloatingActionButton(
                mini : false,
                backgroundColor: Colors.red[600],
                elevation: 8.0,
                child: Icon(Icons.add_location,size: 32.0,color: Colors.white,),
                onPressed:(){
                  _navigateAddTagsPage(context);
                },
            ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            drawer: snapshot.data==null?FilterMapDrawer():
            snapshot.data.values.single==AppBarHomePage.mapBar  ? FilterMapDrawer():Container(),
                      );
                    },
                  )
                );
              }
            }
            
          