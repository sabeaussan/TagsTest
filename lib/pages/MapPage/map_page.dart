import 'package:flutter/material.dart';
import 'package:tags/Models/user.dart';


class MapPage extends StatefulWidget {


  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child:Image.asset("lib/assets/google_map_dummy.jpg",fit: BoxFit.fill,),
         ) //Text("map page")
      );
  }
}