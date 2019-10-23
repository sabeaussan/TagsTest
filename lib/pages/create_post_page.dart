import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Bloc/bloc_tags_page.dart';
import 'package:tags/Bloc/main_bloc.dart';
import 'package:tags/Models/post.dart';
import 'dart:ui' as ui;
import 'dart:io';

import 'package:tags/Models/user.dart';
import 'package:tags/UI/loading_overlay.dart';
import 'package:tags/Utils/firebase_db.dart';


class CreatePostPage extends StatefulWidget {
  final File _imageFile;
  final BlocTagsPage _blocTagsPage;
  

  CreatePostPage(this._imageFile,this._blocTagsPage);

  @override
  CreatePostPageState createState() {
    return new CreatePostPageState();
  }
}

class CreatePostPageState extends State<CreatePostPage> {
  bool _isLoading=false;
  int _imageWidth;
  int _imageHeight;
  FocusNode _focusNode;


  Future<ui.Image> _getImage() {
    Completer<ui.Image> completer = new Completer<ui.Image>();
    new FileImage(widget._imageFile)
      .resolve(new ImageConfiguration())
      .addListener(ImageStreamListener(
        (ImageInfo info, bool _) => completer.complete(info.image)
      ));
    return completer.future;
  }


  TextEditingController _postDescriptionController;

  

  Widget _buildImageContainer(){
    return FutureBuilder(
      future: _getImage(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if(!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        ui.Image image = snapshot.data;
        _imageWidth =image.width;
        _imageHeight=image.height;
        return 
        AspectRatio(
            aspectRatio:_imageWidth/_imageHeight>0.83 ? _imageWidth/_imageHeight : 0.83,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: FileImage(widget._imageFile),
                    fit: BoxFit.fitWidth,
                    alignment: FractionalOffset.topCenter
                  )
                ),
            )
          );
      },
    );
  }

  String timeStamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void _createPost(User currentUser,BuildContext context) async{
      setState(() {
        _isLoading=true;
        _focusNode.unfocus(); 
      });
      final Post newPost = Post(currentUser, _postDescriptionController.text, widget._blocTagsPage.mark, _imageHeight,_imageWidth ,timeStamp());
      await db.createPostFirestore(newPost,widget._imageFile).then((Post post){
        widget._blocTagsPage.newPostsControllerSink.add(newPost);
        _isLoading=false;
      });
      Navigator.of(context).pop();
    
    
  }

  Widget _buildTextDescriptionField(BuildContext context){
    return Container(
      width: MediaQuery.of(context).size.width-40.0,
        child: TextField(
          focusNode: _focusNode,
          controller: _postDescriptionController,
          style: TextStyle(fontSize: 16.0,color: Colors.black),
          decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            width: 3.0,
            color: Colors.red
            )
          ),
          hintStyle: TextStyle(color: Colors.black12),
          hintText: "Ajoute une description"
          ),
          cursorColor: Colors.red,
          maxLines: null,
          keyboardType: TextInputType.multiline,
        ),
      );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _focusNode = FocusNode();
    _postDescriptionController =TextEditingController();
  }

  @override
  void dispose() {
    _postDescriptionController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MainBloc _mainBloc = BlocProvider.of<MainBloc>(context);
    final User currentUser =_mainBloc.currentUser;
    return Stack(
      children: <Widget>[
        Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              "Edite ton post",
              style: TextStyle(fontSize: 30.0, color: Colors.black),
            ),
            actions: <Widget>[
                IconButton(
                onPressed: (){
                    _createPost(currentUser,context);
                },
                iconSize: 40.0,
                icon: Icon(Icons.check_circle,color:Colors.red),
              )
            ],
          ),
          body: SingleChildScrollView(
            child: Center(
              child: 
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _buildImageContainer(),
                      _buildTextDescriptionField(context),
                    ],
                  ),
            
            )
          )
        ),
        _isLoading?LoadingOverlay():Container(),
      ],
    );
  }
}
