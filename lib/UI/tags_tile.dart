import 'package:flutter/material.dart';
import 'package:tags/Models/tags.dart';
import 'package:tags/pages/TagsPage/tags_page.dart';


class TagsTile extends StatelessWidget {
  final Tags _tags;
  final String _distance;
  final bool _isNear;
  final bool _isFav;
  TextEditingController _tagsPassWordController=TextEditingController();

  

  TagsTile(this._tags,this._distance,this._isNear,this._isFav);

  Widget _buildTextPassWordField(BuildContext context){
    return Center(
              child: Container(
              width: MediaQuery.of(context).size.width-80.0,
              child: TextField(     //TODO:Faire un formField pour le validator
                controller: _tagsPassWordController,
                style: TextStyle(fontSize: 15.0,color: Colors.black),
                decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.deepOrange
                    )
                  ),
                  border: UnderlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.deepOrange),
                  labelText: "mot de passe"
                ),
                cursorColor: Colors.deepOrange,
                maxLength: 10,
                maxLengthEnforced: true,
                maxLines: 1,
                obscureText: true,
                keyboardType: TextInputType.text,
              ),
            ),
          );
  }

  Future<void> _buildPassWordDialog(BuildContext context,bool b){
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context){
        return AlertDialog(
            title: Text("entrez le mot de passe"),
            content: SizedBox(
              height: 50.0,
              child: _buildTextPassWordField(context),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("ok",style: TextStyle(fontSize: 20.0),),
                onPressed:() async{
                  if(_tags.passWord==_tagsPassWordController.text){
                    Navigator.of(context).pop();
                    _navigateTagsPage(context,b);
                  }
                } ,
              ),
            ],
        );
      }
    );
  }

  void _navigateTagsPage(BuildContext context,bool b){
      Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context){
                //TODO: on ouvre une boite de dialogue lorsque le tags n'est pas à porté
                return TagsPage(_tags,isFavAndNotNear: b);
              }
            )
          );
  }

  @override
  Widget build(BuildContext context) {
    return (
      ListTile(
        onTap: (){
          if(_tags.mode==PRIVATE_MODE){
            if(_isNear) _buildPassWordDialog(context, false);
            else {
              if(_isFav) _buildPassWordDialog(context,true);
              else return Container();
            }
          }
          else{
            if(_isNear) _navigateTagsPage(context,false);
            else {
              if(_isFav) _navigateTagsPage(context,true);
              else return Container();
            }
          }
        },
        trailing:_isFav?
          Padding(
          child: Icon(Icons.star,size: 32.0, color: Colors.deepOrange),
          padding: EdgeInsets.only(right: 10.0)
          )
          :
         _isNear? 
            Padding(
              child: Icon(Icons.check_circle_outline,size: 32.0, color: Colors.deepOrange),
              padding: EdgeInsets.only(right: 10.0)
            ):
            Column(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.near_me,size: 32.0,color: Colors.black),
                  onPressed: (){}
                ),
                Text(_distance)
              ],
            ),
        title: Row(
          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(_tags.name,style: TextStyle(fontWeight: FontWeight.bold),),
            SizedBox(width: 15.0,),
            //TODO : en fonction du tags (bar,cinema,etc mettre un icône approprié)
            _tags.mode==PRIVATE_MODE ? Icon(Icons.lock,color: Colors.black87,)
            :
            Container()
          ],
        ),
        subtitle: Text("${_tags.nbPost} posts et ${_tags.nbMessage} messages"),
      )
    );
  }
}