import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Bloc/main_bloc.dart';
import 'package:tags/Models/tags.dart';
import 'package:tags/Models/user.dart';
import 'package:tags/Utils/firebase_db.dart';
import 'package:tags/pages/TagsPage/tags_page.dart';


class AddTagsPage extends StatefulWidget {
  _AddTagsPageState createState() => _AddTagsPageState();
}

class _AddTagsPageState extends State<AddTagsPage> {
  //TODO: ajouter un bloc pour gérer tous ça de manière plus propre ou tous metrre dans le MainBloc

  double valueC = 500.0;
  int groupValue=PUBLIC_MODE;
  bool switchValue=false;
  TextEditingController _tagsNameController;
  TextEditingController _tagsPassWordController;

  Widget _buildTextNameField(){
    return Center(
              child: Container(
              width: MediaQuery.of(context).size.width-80.0,
              child: TextField(     //TODO:Faire un formField 
                controller: _tagsNameController,
                style: TextStyle(fontSize: 20.0,color: Colors.black),
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.deepOrange
                    )
                  ),
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.deepOrange),
                  labelText: "Ajoute un nom"
                ),
                cursorColor: Colors.deepOrange,
                maxLength: 30,
                maxLengthEnforced: true,
                maxLines: 1,
                keyboardType: TextInputType.text,
              ),
            ),
          );
  }

  Widget _buildTextPassWordField(){
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
                  labelText: "Ajoute un mot de passe"
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


  Widget _buildRangeSlider(){
    String labelRange="${valueC.round()} m";
    return(
      Container(
        padding: EdgeInsets.all(30.0),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Portée du Tag",style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold,color: Colors.black)),
          SizedBox(height: 10.0,),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Slider(
                    value:valueC,
                    max: 1000.0,
                    min: 5.0,
                    inactiveColor: Colors.black12,
                    activeColor: Colors.deepOrange,
                    onChanged: (double value){
                      setState(() {
                        valueC=value;
                      });
                    },
                 )
                ),
                Text(labelRange)
              ],
            ),
        ],
      ),
      )
    );
  }

  Widget _builRowRadio(){
    return(
      Center(
        child: Row(
         children: <Widget>[
           Expanded(
             child: RadioListTile(
              subtitle: Text("accessible à tout le monde"),
              groupValue: groupValue,
              value: PUBLIC_MODE,
              activeColor: Colors.deepOrange,
              onChanged: (int value){
                setState(() {
                  groupValue=value;
                });
              },
              title:Text("public"),
            ),
           ),
           Expanded(
             child: RadioListTile(
              subtitle: Text("accessible avec un mot de passe",),
              groupValue: groupValue,
              value: PRIVATE_MODE,
              activeColor: Colors.deepOrange,
              onChanged: (int value){
                setState(() {
                  groupValue=value;
                });
              },
              title:Text("privé"),
            ),
           ),
         ],
        ),
      )
    );
  }

  Widget _builRowSwitch(){
    return Container(
      padding: EdgeInsets.all(30.0),
      child: Row(
        children: <Widget>[
          Text("personnel"),
          Switch( 
            value: switchValue ,
            onChanged: (bool value){
              setState(() {
                switchValue=value;
              });
            },
          )
        ],
      )
    );
  }

  @override
  void initState() {
    super.initState();
    _tagsNameController=TextEditingController();
    _tagsPassWordController=TextEditingController();
  }

  @override
  void dispose() {
    _tagsNameController.dispose();
    _tagsPassWordController.dispose();
    super.dispose();
  }

  void _onCreateTags(User user,BuildContext context)async {
    //TODO:gérer tous ça dans le bloc associé à cette page
    //TODO: faire un pushAndReplace par homePage
    if(_tagsNameController.text.trim().length!=null){
      print(_tagsNameController.text);
      print(_tagsPassWordController.text);
      Tags newTag;
      groupValue==PUBLIC_MODE?
      newTag = Tags(_tagsNameController.text, user.userName, null, 53.0, 80, 0, 0, 0,groupValue,switchValue,valueC,null)
      :
      newTag = Tags(_tagsNameController.text, user.userName, null, 53.0, 80, 0, 0, 0,groupValue,switchValue,valueC,_tagsPassWordController.text);
      newTag = await db.createTag(newTag, user);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context){
            return TagsPage(newTag);
          }
        )
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final MainBloc _mainBloc = BlocProvider.of<MainBloc>(context);
    final User currentUser =_mainBloc.currentUser;
    return Scaffold(
      //resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Créer un tag",style: TextStyle(color: Colors.black),),
        leading: IconButton(
          onPressed: (){
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.close),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(height: 25.0,),
            _buildTextNameField(),
            _buildRangeSlider(),
            _builRowRadio(),
            groupValue==PRIVATE_MODE? _buildTextPassWordField() :Container(),
            _builRowSwitch(),
            RaisedButton(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.4-20,vertical:MediaQuery.of(context).size.height*0.350*0.10),
              onPressed: (){
                _onCreateTags(currentUser,context);
              },
              color: Colors.deepOrange,
              child: Text("Créer",style: TextStyle(color: Colors.white,fontSize: 27.0,fontWeight: FontWeight.bold),),
            )
          ],
        ),
      )
    );
  }
}