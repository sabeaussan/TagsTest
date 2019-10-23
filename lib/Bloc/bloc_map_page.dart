

import 'dart:async';

import 'package:tags/Bloc/bloc_provider.dart';

class BlocMapPage extends BlocBase {

  BlocMapPage(){
    _opacityCircleMarkerControllerStream.listen(onMarkerTapped);
  }

  final StreamController<String> _opacityCircleMarkerController = StreamController<String>.broadcast();

  StreamSink<String> get opacityCircleMarkerControllerSink => _opacityCircleMarkerController.sink;
  Stream<String> get _opacityCircleMarkerControllerStream => _opacityCircleMarkerController.stream;

  void onMarkerTapped(String markerId){

  }

  @override
  void dispose() {
    _opacityCircleMarkerController.close();
  }
  
}