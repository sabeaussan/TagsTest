import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Bloc/main_bloc.dart';
import 'package:tags/Models/user.dart';
import 'package:tags/pages/home_page.dart';
import './pages/login_page.dart';
import 'dart:async';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_){
    runApp(MyApp());
  });
}


ThemeData _buildThemeData (){

   return ThemeData(
          primarySwatch: Colors.red,
          primaryIconTheme: IconThemeData(
            color: Colors.red,
            size: 30.0
          ),
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
  String uid;
  FirebaseUser fbU;
  

  @override
  Widget build(BuildContext context) {
        return  StreamBuilder(
          stream: FirebaseAuth.instance.onAuthStateChanged,
          builder: (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot){
            fbU=snapshot.data;
            
            if (snapshot.data!=null ){
              mainBloc = MainBloc();
            }
            print("******[stb onAuthStateChanged] trigered*********");
            print(fbU);
            return BlocProvider(
              bloc: snapshot.data!=null ? mainBloc : null,
              child: MaterialApp(
                title: 'Tags',
                theme: _buildThemeData(),
                home: snapshot.data!=null? FutureBuilder<int>(
                  future:mainBloc.provideCurrentUser(snapshot.data.uid),
                  builder:(BuildContext context, AsyncSnapshot<int> userSnapshot){
                    if(!userSnapshot.hasData){
                      return Material(
                        color: Colors.white,
                        child: Center(
                          child: CircularProgressIndicator(),
                        )
                      );
                    }
                    return Homepage();
                  },
                ): LoginPage(),
              ),
            );
          },
        );
  }
}
