

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Models/tags.dart';
import 'package:tags/pages/TagsPage/tags_chat.dart';
import 'package:tags/pages/TagsPage/tags_gallery.dart';

class BlocTagsPage extends  BlocBase {

  final Tags _tag;
  Tags get tags => _tag;

  //liste contient les deux pages d'un tags
  List<Widget> _listPage;

  //Sert à controller la page qui sera afficher, on reçoit l'int de la page à afficher
  final StreamController<int> _numTabController = StreamController<int>.broadcast();

  StreamSink<int> get numTabSink => _numTabController.sink;
  Stream<int> get numTabStream => _numTabController.stream;


  //Sert à renvoyer le widget à afficher entre TagsGallery et TagsChat
  final StreamController<Widget> _widgetPageController = StreamController<Widget>.broadcast();

  StreamSink <Widget> get _widgetPageSink => _widgetPageController.sink;
  Stream<Widget> get widgetPageStream => _widgetPageController.stream;

  final StreamController<QuerySnapshot> _listTagsPageController = StreamController<QuerySnapshot>.broadcast();

  StreamSink<QuerySnapshot> get _listTagsPageControllerSink => _listTagsPageController.sink;
  Stream<QuerySnapshot> get listTagsPageControllerStream => _listTagsPageController.stream;

  



  BlocTagsPage(this._tag,keyGallery,keyChat) {
    _listPage=[TagsGallery(_tag,key: keyGallery,),TagsChat(_tag,key:keyChat ,)];
    numTabStream.listen(_onTabChange);
  }

  void _onTabChange(int numTab){
    _widgetPageSink.add(_listPage[numTab]);
  }

  @override
  void dispose() {
    _numTabController.close();
    _widgetPageController.close();
    // TODO: implement dispose
  }



  



}