import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Bloc/main_bloc.dart';
import 'package:tags/Models/publicmark.dart';
import 'package:tags/Models/user.dart';
import 'package:tags/UI/loading_overlay.dart';
import 'package:tags/Utils/firebase_db.dart';
import 'package:tags/pages/TagsPage/tags_page.dart';
import 'package:location/location.dart';


class AddTagsPage extends StatefulWidget {
  _AddTagsPageState createState() => _AddTagsPageState();
}

class _AddTagsPageState extends State<AddTagsPage> {
  //TODO: ajouter un bloc pour gérer tous ça de manière plus propre ou tous metrre dans le MainBloc
  //TODO : ajouter un overlay de chargement

  double valueC = 50.0;
  int groupValue=PUBLIC_MODE;
  bool switchValuePersonnal=false;
  bool switchValuePhotoOnly=false;
  TextEditingController _tagsNameController;
  TextEditingController _tagsPassWordController;
  GlobalKey<FormFieldState> _keyTitle = GlobalKey<FormFieldState>();
  GlobalKey<FormFieldState> _keyDescription = GlobalKey<FormFieldState>();
  String _markDescription;

  Location location = new Location();
  LocationData pos;

  bool _isLoading=false;

  Widget _buildTextNameField(){
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width-80.0,
        child: TextFormField(     //TODO:Faire un formField 
        key: _keyTitle,
        validator: (String input){
          if(input.trim().length<2) return("Nom trop court, au moins 2 caractère recquis");
        },
        controller: _tagsNameController,
        style: TextStyle(fontSize: 20.0,color: Colors.black),
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.red
            )
          ),
          border: OutlineInputBorder(),
          labelStyle: TextStyle(color: Colors.red),
          labelText: "Ajoute un nom"
        ),
        cursorColor: Colors.red,
        maxLength: 30,
        maxLengthEnforced: true,
        maxLines: 1,
        keyboardType: TextInputType.text,
        ),
      ),
    );
  }

  Widget _buildMarkDescriptionFormField(){
    return Container(
      color: Colors.grey[50],
      width: MediaQuery.of(context).size.width-80.0,
      child: TextFormField(
        key: _keyDescription,
        maxLength: 120,
        maxLengthEnforced: true ,
        onSaved: (String val){
          print("############### DEBUG _buildMarkDescriptionFormField ############# : "+val);
          _markDescription=val;
        },
        decoration: InputDecoration(
        labelText: "Description",
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red)),
          border: UnderlineInputBorder(),
        ),
        keyboardType: TextInputType.multiline,
        maxLines: null,
        cursorColor: Colors.red,    
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
          Text("Portée de la mark",style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold,color: Colors.black)),
          SizedBox(height: 10.0,),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Slider(
                    value:valueC,
                    max: 250.0,
                    min: 15.0,
                    inactiveColor: Colors.black12,
                    activeColor: Colors.red,
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

  /*Widget _builRowRadio(){
    return(
      Center(
        child: Row(
         children: <Widget>[
           Expanded(
             child: RadioListTile(
              subtitle: Text("accessible à tout le monde"),
              groupValue: groupValue,
              value: PUBLIC_MODE,
              activeColor: Colors.red,
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
              subtitle: Text("accessible à vos contact",),
              groupValue: groupValue,
              value: PRIVATE_MODE,
              activeColor: Colors.red,
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
  }*/

  Widget _builRowSwitchPerso(){
    return Container(
      padding: EdgeInsets.only(top: 15.0,left: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text("personnel"),
          Switch( 
            value: switchValuePersonnal ,
            onChanged: (bool value){
              setState(() {
                switchValuePersonnal=value;
              });
            },
          ),
          Expanded(
            flex: 1,
            child: Text("(Vous serez le seul à pouvoir poster dessus)",style: TextStyle(fontSize: 12.0),)
          )
        ],
      )
    );
  }

  Widget _builRowSwitchPhotoOnly(){
    return Container(
      padding: EdgeInsets.only(top: 15.0,left: 30.0),
      //width: MediaQuery.of(context).size.width-10.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text("photo uniquement"),
          Switch( 
            value: switchValuePhotoOnly ,
            onChanged: (bool value){
              setState(() {
                switchValuePhotoOnly=value;
              });
            },
          ),
          Expanded(
            flex: 1,
            child: Text("(On ne peut pas poster des images prises dans la gallerie)",style: TextStyle(fontSize: 12.0),)
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
    location.getLocation().then((LocationData loc){
      setState(() {
        pos=loc;
      });
    });
  }

  @override
  void dispose() {
    //TODO : il y en a surement d'autre à dispose
    _tagsNameController.dispose();
    _tagsPassWordController.dispose();
    super.dispose();
  }

  void _onCreateTags(User user,BuildContext context) async {
    //TODO:gérer tous ça dans le bloc associé à cette page
    //TODO : ajouter la gestion du PRVATE_MODE
    if(!_keyTitle.currentState.validate()) return;
    setState(() {
      _isLoading=true;
    });
    _keyDescription.currentState.save();
    if(groupValue==PUBLIC_MODE){
      PublicMark newTag;
      newTag = PublicMark(_tagsNameController.text, user.userName, user.id,db.timeStamp(), pos.latitude, pos.longitude,switchValuePersonnal,switchValuePhotoOnly,valueC,_markDescription);
      newTag = await db.createTag(newTag);
      await db.updateUserNbMarks(user);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context){
            newTag.setFavStatus(false);
          return TagsPage(newTag,isFavAndNotNear: false);
        }
        )
      );
    }
    
    
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
          title: Text("Créer une mark",style: TextStyle(color: Colors.black),),
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
              SizedBox(height: 25.0),
              _buildTextNameField(),
              _buildRangeSlider(),
              //_builRowRadio(),
              _builRowSwitchPerso(),
              _builRowSwitchPhotoOnly(),
              _buildMarkDescriptionFormField(),
              SizedBox(height: 25.0),
              RaisedButton(
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.4-20,vertical:MediaQuery.of(context).size.height*0.350*0.10),
                onPressed: (){
                  _onCreateTags(currentUser,context);
                },
                color: Colors.red,
                child: Text("Créer",style: TextStyle(color: Colors.white,fontSize: 27.0,fontWeight: FontWeight.bold),),
              )
            ],
          ),
        )
      ),
      _isLoading?LoadingOverlay():Container(),
      ]
    );
  }
}