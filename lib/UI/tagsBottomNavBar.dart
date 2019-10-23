import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_tags_page.dart';


class TagsBottomNavBar extends StatefulWidget {
  final BlocTagsPage _blocTagsPage;

  TagsBottomNavBar(this._blocTagsPage);

  _TagsBottomNavBarState createState() => _TagsBottomNavBarState();
}

class _TagsBottomNavBarState extends State<TagsBottomNavBar> {
  
  void _onItemTapped(int index){
    widget._blocTagsPage.numTabSink.add(index);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
          stream: widget._blocTagsPage.numTabStream,
          initialData: 0,
          builder: (BuildContext context, AsyncSnapshot<int> snapshot){
            return  CupertinoTabBar(
              iconSize: 35.0,
              activeColor: Colors.red,
              currentIndex: snapshot.data ,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(icon: Icon(Icons.mms,), title: Container()),
                BottomNavigationBarItem(icon: Icon(Icons.question_answer),title: Container()),
              ],
              //type: BottomNavigationBarType.fixed,
              onTap:_onItemTapped,
            );
          } 
    );
  }
}