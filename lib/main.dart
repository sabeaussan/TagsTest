import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Bloc/main_bloc.dart';
import 'package:tags/Models/user.dart';
import 'package:tags/Utils/firebase_db.dart';
import 'package:tags/pages/home_page.dart';
import './pages/login_page.dart';
import 'dart:async';

void main() => runApp(MyApp());


ThemeData _buildThemeData (){

   return ThemeData(
          primarySwatch: Colors.red,
          //primaryColorLight: Colors.orange,
          primaryIconTheme: IconThemeData(
            color: Colors.red,
            size: 30.0
          ),
          //accentTextTheme: ,
          primaryTextTheme: TextTheme(
            title: TextStyle(color: Colors.red,
                  fontSize: 25.0,
                  fontFamily: "InkFree",
                  fontWeight: FontWeight.w900)),
          accentColor: Colors.red,
          primaryColor: Color(0xFFF8F8F8),
          tabBarTheme: TabBarTheme(
            labelColor: Colors.red,
            unselectedLabelColor: Colors.black45,
            indicatorSize: TabBarIndicatorSize.tab,
          ),
          
          
   );

}



  

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<User> getCurrentUser;
  MainBloc mainBloc;

  Future<User> _provideCurrentUser() async {
   print("******[_provideCurrentUser] trigered*********");
   final User  currentUser = await db.getCurrentUser();
   return currentUser;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser=_provideCurrentUser();
  }


  @override
  Widget build(BuildContext context) {
        return  StreamBuilder(
          stream: FirebaseAuth.instance.onAuthStateChanged,
          builder: (BuildContext context, AsyncSnapshot snapshot){
            mainBloc=MainBloc();
            print("******[stb onAuthStateChanged] trigered*********");
            return BlocProvider(
              bloc: snapshot.hasData? mainBloc : null,
              child: MaterialApp(
                title: 'Tags',
                theme: _buildThemeData(),
                home: snapshot.hasData? FutureBuilder<User>(
                  future:getCurrentUser,
                  builder:(BuildContext context, AsyncSnapshot<User> snapshot){
                    if(!snapshot.hasData){
                      return Material(
                        color: Colors.white,
                        child: Center(
                          child: CircularProgressIndicator(),
                        )
                      );
                    }
                    return Homepage();
                  } ,
                ): LoginPage(),
              ),
            );
          },
        );
  }
}
