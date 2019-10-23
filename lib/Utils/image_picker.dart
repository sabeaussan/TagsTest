import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tags/Bloc/bloc_tags_page.dart';
import 'package:tags/pages/create_post_page.dart';

const int GALLERY_PAGE = 0;

class ImagePickerUtils extends StatelessWidget {
  final FocusNode _focusNode;
  final BlocTagsPage _blocTagsPage;
  final bool _photoOnly;

  ImagePickerUtils(this._focusNode,this._blocTagsPage,this._photoOnly);

  

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      elevation: 0.0,
      onPressed: () async{
        _focusNode.unfocus();
        _blocTagsPage.numTabSink.add(GALLERY_PAGE);
        _photoOnly? 
          await takePicture(context, ImageSource.camera)
          :
          openPicker(context);
      },
      mini: true,
      child: Icon(
        Icons.add_a_photo,
        size: 21.0,
      ),
      backgroundColor: Colors.red,
    );
  }

  void openPicker(BuildContext context){
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 120.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FlatButton(
                  padding: EdgeInsets.all(20.0),
                  child: Icon(
                    Icons.camera_alt,
                    size: 40.0,
                  ),
                  onPressed: () async {
                    await takePicture(context, ImageSource.camera);
                    //Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  padding: EdgeInsets.all(20.0),
                  child: Icon(
                    Icons.collections,
                    size: 40.0,
                  ),
                  onPressed: () async {
                    await takePicture(context, ImageSource.gallery);
                    //Navigator.of(context).pop();
                  },
                )
              ],
            ),
          );
        });
  }

  Future<void> takePicture(BuildContext context, ImageSource source) async {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;
    final File imageFile = await ImagePicker.pickImage(source: source, maxWidth:deviceWidth*4 , maxHeight: deviceHeight*4);
    if(imageFile==null) return;
    Navigator.of(context).push(MaterialPageRoute(
        builder: ((BuildContext context) => CreatePostPage(imageFile,_blocTagsPage))));
    return;
  }
}
