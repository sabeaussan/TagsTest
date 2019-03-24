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
          Icon(Icons.person),
          Icon(Icons.new_releases,size: 19.0,color: numTab==4 ? CupertinoColors.inactiveGray: Colors.deepOrange)
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
              initialData: _mainBloc.newMessage||_mainBloc.newComment,
              builder: (BuildContext context, AsyncSnapshot<bool> snapshotNewMessage){
                  print("--------- mainNavBar check newEvent --------"+snapshotNewMessage.data.toString());
                  return CupertinoTabBar(
                    activeColor: Colors.deepOrange,
                    currentIndex: snapshotNumTab.data ,
                    items: <BottomNavigationBarItem>[
                      BottomNavigationBarItem(icon: Icon(Icons.explore,),title: Container()),
                      BottomNavigationBarItem(icon: Icon(Icons.location_on),title:Container()),
                      BottomNavigationBarItem(icon: IconButton(icon: Container(),onPressed: (){},),title:Container()),
                      BottomNavigationBarItem(icon: Icon(Icons.favorite),title:Container()),
                      BottomNavigationBarItem(icon: snapshotNewMessage.data? _buildNewMessageIcon(snapshotNumTab.data) : Icon(Icons.person),title:Container()),
                    ],
                    onTap:_onItemTapped,
                  );
                
              },
            );
          } 
    );
  }
}