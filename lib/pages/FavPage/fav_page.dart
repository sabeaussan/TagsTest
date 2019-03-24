
import 'package:flutter/material.dart';
import 'package:tags/pages/FavPage/private_fav_page.dart';
import 'package:tags/pages/FavPage/public_fav_page.dart';


import '../home_page.dart';

class FavPage extends StatefulWidget {
  

  FavPageState createState() => FavPageState();
}

class FavPageState extends State<FavPage> {
  //Page qui contient les onglets


  TabController _tabController;
  //TODO: implémenter le dispose()

  

  @override
  void initState() {
    // On instancie HomePageState pour récupérer le _tabcontroller
    super.initState();
    _tabController=HomepageState().favTabController ;
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: <Widget>[
        PrivateFavPage(),
        PublicFavPage(),
      ],
      controller: _tabController,
    );
  }
}