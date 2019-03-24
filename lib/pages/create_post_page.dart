import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Bloc/main_bloc.dart';
import 'package:tags/Models/post.dart';
import 'dart:io';

import 'package:tags/Models/tags.dart';
import 'package:tags/Models/user.dart';
import 'package:tags/Utils/firebase_db.dart';


class CreatePostPage extends StatefulWidget {
  final File _imageFile;
  final Tags _tags;
  

  CreatePostPage(this._imageFile,this._tags);

  @override
  CreatePostPageState createState() {
    return new CreatePostPageState();
  }
}

class CreatePostPageState extends State<CreatePostPage> {
  bool _isLoading=false;
  TextEditingController _postDescriptionController;

  Widget _buildImageContainer(){
    return AspectRatio(
            aspectRatio: 0.83,
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
  }

  String timeStamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void _createPost(User currentUser,BuildContext context) async{
    if(_postDescriptionController.text.trim().length!=0){
      setState(() {
        _isLoading=true; 
      });
      final Post newPost = Post(null, currentUser, _postDescriptionController.text, null, 0, widget._tags, 0, timeStamp());
      await db.createPostFirestore(newPost,widget._imageFile).then((_){
        _isLoading=false;
      });
      Navigator.of(context).pop();
    }
    
  }

  Widget _buildTextDescriptionField(BuildContext context){
    return Container(
      width: MediaQuery.of(context).size.width-40.0,
        child: TextField(
          controller: _postDescriptionController,
          style: TextStyle(fontSize: 16.0,color: Colors.black),
          decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            width: 3.0,
            color: Colors.deepOrange
            )
          ),
          hintStyle: TextStyle(color: Colors.black12),
          hintText: "Ajoute une description"
          ),
          cursorColor: Colors.deepOrange,
          maxLines: null,
          keyboardType: TextInputType.multiline,
        ),
      );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _postDescriptionController =TextEditingController();
  }

  @override
  void dispose() {
    _postDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MainBloc _mainBloc = BlocProvider.of<MainBloc>(context);
    final User currentUser =_mainBloc.currentUser;
    return Scaffold(
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
             icon:_isLoading? 
             CircularProgressIndicator(strokeWidth: 5.0): Icon(Icons.check_circle,color:Colors.deepOrange),
           )
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildImageContainer(),
              _buildTextDescriptionField(context)
            ],
          ),
        )
      )
    );
  }
}
