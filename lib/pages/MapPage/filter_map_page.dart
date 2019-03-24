import 'package:flutter/material.dart';


//TODO: rajouter filtre nom, max et distance à moi

class FilterMapDrawer extends StatefulWidget {
  _FilterMapDrawerState createState() => _FilterMapDrawerState();
}

class _FilterMapDrawerState extends State<FilterMapDrawer> {
  bool valueCheckBoxPublic = true;
  bool valueCheckBoxPrive = true;
  bool valueCheckBoxPersonnel = true;
  bool valueCheckBoxFavorite = true;
  double valueNbPostSlider=50;
  double valueNbMessageSlider=50;

  Widget _buildNbPostSlider(){
    String labelRange="${valueNbPostSlider.round()}";
    return(
      Container(
        padding: EdgeInsets.all(30.0),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Nombre de post minimum",style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold,color: Colors.black)),
          SizedBox(height: 10.0,),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Slider(
                    value:valueNbPostSlider,
                    max: 100.0,
                    min: 5.0,
                    inactiveColor: Colors.black12,
                    activeColor: Colors.deepOrange,
                    onChanged: (double value){
                      setState(() {
                        valueNbPostSlider=value;
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


  Widget _buildNbMessageSlider(){
    
    String labelRange="${valueNbMessageSlider.round()}";
    return(
      Container(
        padding: EdgeInsets.all(30.0),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Nombre de message minimum",style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold,color: Colors.black)),
          SizedBox(height: 10.0,),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Slider(
                    value:valueNbMessageSlider,
                    max: 100.0,
                    min: 5.0,
                    inactiveColor: Colors.black12,
                    activeColor: Colors.deepOrange,
                    onChanged: (double value){
                      setState(() {
                        valueNbMessageSlider=value;
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
         children: <Widget>[
           
             CheckboxListTile(
              value: valueCheckBoxPublic ,
              activeColor: Colors.deepOrange,
              onChanged: (bool val){
                setState(() {
                  valueCheckBoxPublic=val;
                });
              },
              title:Text("public"),
            ),
           
           
            CheckboxListTile(
              //Mettre tool Tip genre point d'intérogation
              //subtitle: Text("accessible à tout le monde",style:TextStyle(fontSize:13.0)),
              value: valueCheckBoxPrive ,
              activeColor: Colors.deepOrange,
              onChanged: (bool val){
                setState(() {
                  valueCheckBoxPrive=val;
                });
              },
              title:Text("privé"),
            ),
           
           CheckboxListTile(
               //Mettre tool Tip genre point d'intérogation
              //subtitle: Text("accessible à tout le monde",style:TextStyle(fontSize:13.0)),
              value: valueCheckBoxPersonnel ,
              activeColor: Colors.deepOrange,
              onChanged: (bool val){
                setState(() {
                  valueCheckBoxPersonnel=val;
                });
              },
              title:Text("personnel"),
            ),
            CheckboxListTile(
               //Mettre tool Tip genre point d'intérogation
              //subtitle: Text("accessible à tout le monde",style:TextStyle(fontSize:13.0)),
              value: valueCheckBoxFavorite ,
              activeColor: Colors.deepOrange,
              onChanged: (bool val){
                setState(() {
                  valueCheckBoxFavorite=val;
                });
              },
              title:Text("favoris"),
            ),
          
         ],
        ),
      )
    );
  }

  Widget _buildDrawerContent(){
    final drawerItems = Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text("Filtrer les Tags",style: TextStyle(color: Colors.black,
                  fontSize: 25.0,
                  fontFamily: "InkFree",
                  fontWeight: FontWeight.w900),),
          _buildNbPostSlider(),
          _buildNbMessageSlider(),
          _builRowRadio(),
          
          RaisedButton(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.4-80,vertical:MediaQuery.of(context).size.height*0.15*0.10),
            onPressed: (){
              
            },
            color: Colors.deepOrange,
            child: Text("Appliquer",style: TextStyle(color: Colors.white,fontSize: 27.0,fontWeight: FontWeight.bold),),
          )
        ],
      );
      return drawerItems;
  }


  @override
  Widget build(BuildContext context) {

    return Drawer(
      child: _buildDrawerContent(),
    );
  }
}