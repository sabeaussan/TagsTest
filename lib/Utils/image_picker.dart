import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tags/Bloc/bloc_tags_page.dart';
import 'package:tags/Models/tags.dart';
import 'package:tags/pages/create_post_page.dart';

class ImagePickerUtils extends StatefulWidget {
  final FocusNode _focusNode;
  final BlocTagsPage _blocTagsPage;

  ImagePickerUtils(this._focusNode,this._blocTagsPage);

  _ImagePickerUtilsState createState() => _ImagePickerUtilsState();
}

class _ImagePickerUtilsState extends State<ImagePickerUtils> {
  //C'est nul remplacer le FloatingActionButton par un widget classique pour benef imagePicker partout

  static final  int GALLERY_PAGE = 0;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      elevation: 0.0,
      onPressed: () {
        widget._focusNode.unfocus();
        widget._blocTagsPage.numTabSink.add(GALLERY_PAGE);
        openPicker(context);
      },
      mini: true,
      child: Icon(
        Icons.add_a_photo,
        size: 21.0,
      ),
      backgroundColor: Colors.deepOrange,
    );
  }

  void openPicker(BuildContext context) {
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
                  onPressed: () {
                    takePicture(context, ImageSource.camera);
                    //Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  padding: EdgeInsets.all(20.0),
                  child: Icon(
                    Icons.collections,
                    size: 40.0,
                  ),
                  onPressed: () {
                    takePicture(context, ImageSource.gallery);
                    //Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }

  Future<void> takePicture(BuildContext context, ImageSource source) async {
    final Tags tag = widget._blocTagsPage.tags;
    final File imageFile = await ImagePicker.pickImage(
        source: source, maxWidth: 1200, maxHeight: 1600);
    Navigator.of(context).push(MaterialPageRoute(
        builder: ((BuildContext context) => CreatePostPage(imageFile,tag))));
    return;
  }
}
