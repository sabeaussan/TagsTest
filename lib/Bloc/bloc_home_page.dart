import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_favorite_page.dart';
import 'package:tags/Bloc/bloc_map_page.dart';


import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Bloc/bloc_user_profile.dart';
import 'package:tags/pages/FavPage/fav_page.dart';
import 'package:tags/pages/TagsPage/list_tags_page.dart';
import 'package:tags/pages/home_page.dart';
import 'package:tags/pages/MapPage/map_page.dart';
import 'package:tags/pages/UserProfilPages/user_profile_page.dart';





class BlocHomePage extends BlocBase{

  static PageStorageKey keyMap;
  //Liste des configurations de widgets pour la homePage
  //On fournit à toutes les pages le User
  
  final List<Map<Widget,AppBarHomePage>> _listWidgetHomePage = [
    {_provideBloc(MapPage(key: keyMap,), BlocMapPage()) : AppBarHomePage.mapBar},
    {ListTagsPage() :AppBarHomePage.listBar },
    {null : null},
    {_provideBloc(FavPage(), BlocFavoritePage()) : AppBarHomePage.favBar},
    {_provideBloc(UserProfilePage(), BlocUserProfilePage()) : AppBarHomePage.userProfileBar}
  ];


  static Widget _provideBloc(Widget child,BlocBase bloc){
    return BlocProvider(
      bloc: bloc,
      child: child,
    );
  }


  //On utilise ce streamController pour récupérer un le numéro sélectionner par le tab
  //On le renvoie a la navBar pour currentIndex

  final StreamController<int> _numTabController = StreamController<int>.broadcast();

  StreamSink<int> get numTabSink => _numTabController.sink;
  Stream<int> get numTabStream => _numTabController.stream;

  //On utilise ce StreamController pour renvoyer la tabPage[_currentTabIndex]
  //On le renvoie a la homePage
  final StreamController<Map<Widget,AppBarHomePage>> _widgetPageController = StreamController<Map<Widget,AppBarHomePage>>.broadcast();

  StreamSink <Map<Widget,AppBarHomePage>> get _widgetPageSink => _widgetPageController.sink;
  Stream<Map<Widget,AppBarHomePage>> get widgetPageStream => _widgetPageController.stream;

  BlocHomePage(){
    keyMap =PageStorageKey('MapPage');
    _numTabController.stream.listen(_onTabChange);
  }


  void _onTabChange(int numTab){
    _widgetPageSink.add(
      _listWidgetHomePage[numTab]
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _widgetPageController.close();
    _numTabController.close();
  }

    

}