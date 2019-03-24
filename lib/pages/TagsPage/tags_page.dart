import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_provider.dart';


import 'package:tags/Bloc/bloc_tags_page.dart';
import 'package:tags/Bloc/main_bloc.dart';
import 'package:tags/Models/tags.dart';
import 'package:tags/Models/user.dart';
import 'package:tags/UI/send_message_tile.dart';
import 'package:tags/UI/tagsBottomNavBar.dart';
import 'package:tags/Utils/firebase_db.dart';
import 'package:tags/pages/TagsPage/tags_gallery.dart';

class TagsPage extends StatefulWidget {
  final Tags  _tags;
  bool isFavAndNotNear;

  TagsPage(this._tags,{this.isFavAndNotNear});

  _TagsPageState createState() => _TagsPageState();
}

class _TagsPageState extends State<TagsPage> {
  Key keyGallery;
  Key keyChat;
  bool _isFav;
  BlocTagsPage _blocTagsPage;
  User currentUser;

  

  Widget _buildListDisplayedAndInputTile(AsyncSnapshot<Widget> snapshot) {
    //construit l'UI de la pgae à afficher
    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
          Flexible(
              child: Scrollbar(
            child: Container(
              child: snapshot.data,
              ),
            ),
          ),
          SendMessageTile(false,bloc:_blocTagsPage,tagOwnerId:widget._tags.id),
              
        ]));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    keyGallery =PageStorageKey('TagsGallery');
    keyChat =PageStorageKey('TagsChat');
    _blocTagsPage = BlocTagsPage(widget._tags,keyGallery,keyChat);
    final MainBloc _mainBloc = BlocProvider.of<MainBloc>(context);
    currentUser =_mainBloc.currentUser;
    _isFav =getFavStatus(currentUser);
  }

  bool getFavStatus(User user){
    if(user.favTagsId!=null) return user.favTagsId.contains(widget._tags.id);
     return false;
  }



  void _updateFavTags(User user){
    setState(() {
      _isFav?
        db.updateOldUserFavTags(user, widget._tags.id, -1)
        :
        db.updateOldUserFavTags(user, widget._tags.id, 1);
        _isFav=!_isFav;
    });
  }



  @override
  Widget build(BuildContext context) {
    print(_isFav);
    return Scaffold(
        appBar: AppBar(
          title: Text(widget._tags.name,style: TextStyle(color: Colors.black,)),
          actions: <Widget>[
            IconButton(
              onPressed: (){
                _updateFavTags(currentUser);
              },
              icon: _isFav ? Icon(Icons.star, color: Colors.deepOrange,size: 35.0,) : Icon(Icons.star_border,size: 35.0),
            ),
            IconButton(
              icon: Icon(
                Icons.info,
                color: Colors.deepOrange,
              ),
            )
          ],
        ),
        body: StreamBuilder(
          //ce streamBuilder reçoit les pages à afficher entre gallery et chat
          //les snapshot sont eux même dans un streamBuilder qui construit la list via Firestore
          stream: _blocTagsPage.widgetPageStream,
          initialData: TagsGallery(widget._tags,key: keyGallery,),
          builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
            return _buildListDisplayedAndInputTile(snapshot);
          },
        ),
        bottomNavigationBar: TagsBottomNavBar(_blocTagsPage));
  }
}
