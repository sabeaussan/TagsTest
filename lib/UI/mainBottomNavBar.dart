import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_home_page.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Bloc/main_bloc.dart';



class BottomNavBar extends StatefulWidget {
//TODO: mettre en stateful pour pouvoir avoir des icones grisé quand non sélectionné
  final BlocHomePage _blocHomePage;

  BottomNavBar(this._blocHomePage);

  @override
  BottomNavBarState createState() {
    return new BottomNavBarState();
  }
}

class BottomNavBarState extends State<BottomNavBar> {

  void _onItemTapped(int index){
    widget._blocHomePage.numTabSink.add(index);
  }

  Widget _buildNewMessageIcon(int numTab){
    return Stack(
        children: <Widget>[
          Icon(numTab==3?CupertinoIcons.person_solid:CupertinoIcons.person),
          //TODO: en faire un élément graphique
          CircleAvatar(
            child: Center(child: Icon(Icons.error,size: 18.0,color:Colors.red),),
            backgroundColor: Color(0xFFF8F8F8),
            radius: 9,
          )
        ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final MainBloc _mainBloc = BlocProvider.of<MainBloc>(context);
    return StreamBuilder<int>(
          stream: widget._blocHomePage.numTabStream,
          initialData: 0,
          builder: (BuildContext context, AsyncSnapshot<int> snapshotNumTab){
            return  StreamBuilder<bool>(
              stream: _mainBloc.newEventControllerStream,
              initialData: _mainBloc.newMessage || _mainBloc.newComment,
              builder: (BuildContext context, AsyncSnapshot<bool> snapshotNewMessage){
                  return CupertinoTabBar(
                    backgroundColor: Color(0xFFF8F8F8),
                    activeColor: Colors.red,
                    inactiveColor: Colors.black38,
                    border: const Border(top: BorderSide(color: Colors.black12,width: 1)),
                    currentIndex: snapshotNumTab.data ,
                    items: <BottomNavigationBarItem>[
                      BottomNavigationBarItem(icon: Icon(snapshotNumTab.data==0?Icons.explore:IconData(0xe900, fontFamily: 'CompassOutline')),title: Container()),
                      BottomNavigationBarItem(icon: Padding(
                        child: Icon(snapshotNumTab.data==1? Icons.location_on:IconData(0xe900, fontFamily: 'CustomIcons')),
                        padding: EdgeInsets.only(right: 38.0),
                      ),title:Container()),
                      //BottomNavigationBarItem(icon: ),
                      BottomNavigationBarItem(icon: Padding(
                        child: Icon(snapshotNumTab.data==2?Icons.favorite:Icons.favorite_border),
                        padding: EdgeInsets.only(left: 38.0),
                      ),title:Container()),
                      BottomNavigationBarItem(icon: snapshotNewMessage.data? _buildNewMessageIcon(snapshotNumTab.data) : Icon(snapshotNumTab.data==3?Icons.person:Icons.person_outline),title:Container()),
                    ],
                    onTap:_onItemTapped,
                  );
                
              },
            );
          } 
    );
  }
}