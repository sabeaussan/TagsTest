import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:tags/Bloc/bloc_tags_page.dart';
import 'package:tags/Bloc/main_bloc.dart';
import 'package:tags/Models/publicmark.dart';
import 'package:tags/Models/user.dart';
import 'package:tags/UI/clickable_text.dart';
import 'package:tags/UI/send_message_tile.dart';
import 'package:tags/UI/tagsBottomNavBar.dart';
import 'package:tags/UI/user_circle_avatar.dart';
import 'package:tags/Utils/firebase_db.dart';
import 'package:tags/pages/TagsPage/tags_gallery.dart';


class TagsPage extends StatefulWidget {
  final PublicMark  _mark;
  bool isFavAndNotNear;

  TagsPage(this._mark,{this.isFavAndNotNear});

  _TagsPageState createState() => _TagsPageState();
}

class _TagsPageState extends State<TagsPage> {
  Key keyGallery;
  Key keyChat;
  BlocTagsPage _blocTagsPage;
  MainBloc _mainBloc; 
  User currentUser;

  

  Widget _buildListDisplayedAndInputTile(AsyncSnapshot<Widget> snapshot) {
    //construit l'UI de la page à afficher
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
          widget.isFavAndNotNear? Container() : SendMessageTile(_blocTagsPage,widget._mark),
              
        ]));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    db.updateMarksViews(widget._mark.id);
    keyGallery =PageStorageKey('TagsGallery');
    keyChat =PageStorageKey('TagsChat');
    _blocTagsPage = BlocTagsPage(widget._mark,keyGallery,keyChat);
    _mainBloc = BlocProvider.of<MainBloc>(context);
    currentUser =_mainBloc.currentUser;
  }

  void _toggleFavStatus(){
    final bool favStatus = widget._mark.isFav;
    final bool favStatusHasChanged = widget._mark.favStatusHasChanged;
    widget._mark.setFavStatusHasChanged(!favStatusHasChanged);
    setState(() {
      widget._mark.setFavStatus(!favStatus);
    });
  }

  void _updateUserFavMarks(){
    if(widget._mark.isFav) db.updateOldUserFavTags(currentUser, widget._mark.id, true);
    else db.updateOldUserFavTags(currentUser, widget._mark.id,false);
  }

  

  void _updateMarkNbFav() async {
    //remplacer arg par _isFav dans la fonctio d'update
    //ce sera plus lisible
    widget._mark.isFav?
      await db.updateMarkNbFav(widget._mark.id ,1)
      :
      await db.updateMarkNbFav(widget._mark.id,-1);
  }


  Widget _builInfoWidget(String userName, String userId){
    DateTime date = DateTime.fromMillisecondsSinceEpoch(int.parse(widget._mark.timeStamp));
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text("Tag créée le ${formatDate(date,[dd, '-', mm, '-', yyyy ])} par :"),
        SizedBox(
          height: 15.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
              UserCircleAvatar(userName,userId),
              SizedBox(width: 10.0,),
              ClickableWidget(
                Text("  "+userName,style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold)),
                userId
              )
          ],
        ),
        SizedBox(height: 15.0,),
        Text("Nombre de vues : "+widget._mark.nbViews.toString()),
      ],
    );
  }

  Future<void> _buildInfoDialog(){
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context){
            return AlertDialog(
                content: SizedBox(
                  height: 110.0,
                  child: _builInfoWidget(widget._mark.creatorName,widget._mark.creatorId) ,
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text("ok",style: TextStyle(fontSize: 20.0),),
                    onPressed:() {
                        Navigator.of(context).pop();
                    } ,
                  ),
                ],
            );
      }
    );
  }

  void _updateFavFields() async{
    _updateUserFavMarks();
    _updateMarkNbFav();
  }

  @override
  void dispose() {
    if(widget._mark.favStatusHasChanged){
      _updateFavFields();
    }
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    /*const IconData fire = const IconData(0xf42f,
          fontFamily: CupertinoIcons.iconFont,
          fontPackage: CupertinoIcons.iconFontPackage);*/
    return Scaffold(
        appBar: AppBar(
          title: Text(widget._mark.name,style: TextStyle(color: Colors.black,)),
          actions: <Widget>[
            IconButton(
              onPressed: (){
                //Ca bug si on appuie trop vite
                //TODO : mettre des await
                _toggleFavStatus();
              },
              icon: widget._mark.isFav ? Icon(Icons.star, color: Colors.red,size: 35.0,) : Icon(Icons.star_border,color: Colors.black45,size: 35.0),
            ),
            IconButton(
              onPressed:(){
                _buildInfoDialog();
              } ,
              icon: Icon(
                Icons.info_outline,size: 35.0,
              ),
            )
          ],
        ),
        body: StreamBuilder(
          //ce streamBuilder reçoit les pages à afficher entre gallery et chat
          //les snapshot sont eux même dans un streamBuilder qui construit la list via Firestore
          stream: _blocTagsPage.widgetPageStream,
          initialData: TagsGallery(_blocTagsPage,key: keyGallery,),
          builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
            return _buildListDisplayedAndInputTile(snapshot);
          },
        ),
        bottomNavigationBar:TagsBottomNavBar(_blocTagsPage));
  }
}
