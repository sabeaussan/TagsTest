import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;


import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tags/Bloc/bloc_provider.dart';
import 'package:tags/Bloc/main_bloc.dart';
import 'package:tags/Models/publicmark.dart';
import 'package:tags/pages/TagsPage/tags_page.dart';
import '../../Utils/geolocalisation.dart';


class MapPage extends StatefulWidget {

  MapPage({Key key}):super(key:key);

  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController gmController;
  MainBloc _mainBloc;




  Future<ui.Image> _getImageFromNetwork(PublicMark mark,BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    Completer<ui.Image> completer = new Completer<ui.Image>();
    final ImageConfiguration imageConfig = ImageConfiguration(devicePixelRatio: mediaQueryData.devicePixelRatio,size: Size(100, 100));
    CachedNetworkImageProvider(mark.lastPostImageUrl)
      .resolve(imageConfig)
      .addListener(ImageStreamListener(
        (ImageInfo info, bool _) => completer.complete(info.image)
      ));
    return completer.future;
  }

  Future<ui.Image> _getImageFromAssets(String path,BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    Completer<ui.Image> completer = new Completer<ui.Image>();
    final ImageConfiguration imageConfig = ImageConfiguration(devicePixelRatio: mediaQueryData.devicePixelRatio,size: Size(100, 100));
    AssetImage(path)
      .resolve(imageConfig)
      .addListener(ImageStreamListener(
        (ImageInfo info, bool _) => completer.complete(info.image)
      ));
    return completer.future;
  }


  Future<Uint8List> _buildCircleDefaultMarker(int width, int height,PublicMark mark,BuildContext context) async {
  final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);
  final Paint redCircle = Paint()
  ..strokeWidth=17.0
  ..style=PaintingStyle.stroke
  ..strokeCap=StrokeCap.round
  ..color = Colors.red.withOpacity(0.5);
  final Paint white = Paint()..color = Colors.white.withOpacity(0.5);
  canvas.drawCircle(
      Offset(97,97),
      30.0,
      white);
  canvas.drawCircle(
      Offset(97,97),
      35.0,
      redCircle);
  TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
  painter.text = TextSpan(
    text: '${mark.nbPost}',
    style: TextStyle(fontSize: 20.0, color: Colors.black,fontWeight: FontWeight.bold),
  );
  painter.layout();
  painter.paint(canvas, Offset((width * 0.49) - painter.width * 0.5, (height*0.49) - painter.height * 0.5));
  final img = await pictureRecorder.endRecording().toImage(width, height);
  final data = await img.toByteData(format: ui.ImageByteFormat.png);
  return data.buffer.asUint8List();
}

Future<Uint8List> _buildCircleFavMarker(int width, int height,PublicMark mark,BuildContext context) async {
  final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);
  final Paint redCircle = Paint()
  ..strokeWidth=17.0
  ..style=PaintingStyle.stroke
  ..strokeCap=StrokeCap.round
  ..color = Colors.red;
  final Paint white = Paint()..color = Colors.white;
  final Radius radius = Radius.circular(100.0);
  canvas.drawCircle(
      Offset(97,97),
      45.0,
      white);
  canvas.drawCircle(
      Offset(97,97),
      50.0,
      redCircle);
  final ui.Image favIcon = await _getImageFromAssets("lib/assets/star_icon.png", context);
  canvas.drawImageRect(
    favIcon,
    Rect.fromLTRB(
        0.0, 0.0, favIcon.width.toDouble(), favIcon.height.toDouble()),
    Rect.fromLTWH(56.0, 55.0, width.toDouble()*0.42, height.toDouble()*0.42),
    new Paint(),
  );
  canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(25.5, 35.5, width.toDouble()*0.30, height.toDouble()*0.16),
        topLeft: radius*0.4,
        topRight: radius*0.4,
        bottomLeft: radius*0.4,
        bottomRight: radius*0.4,
      ),
      white);
  TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
  painter.text = TextSpan(
    text: '${mark.nbPost}',
    style: TextStyle(fontSize: 20.0, color: Colors.black,fontWeight: FontWeight.bold),
  );
  painter.layout();
  painter.paint(canvas, Offset((width * 0.28) - painter.width * 0.5, (height*0.26) - painter.height * 0.5));
  final img = await pictureRecorder.endRecording().toImage(width, height);
  final data = await img.toByteData(format: ui.ImageByteFormat.png);
  return data.buffer.asUint8List();
}

  Future<Uint8List> _buildCircleMarkerWithImage(int width, int height,PublicMark mark,BuildContext context) async {
  final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);
  final Paint whiteCircle = Paint()
  ..strokeWidth=10.7
  ..style=PaintingStyle.stroke
  ..strokeCap=StrokeCap.round
  ..color = Colors.white;
  final Paint redCircle = Paint()
  ..strokeWidth=17.0
  ..style=PaintingStyle.stroke
  ..strokeCap=StrokeCap.round
  ..color = Colors.red;
  final Paint white = Paint()..color = Colors.white;
  final Radius radius = Radius.circular(100.0);
  final ui.Image image = await _getImageFromNetwork(mark,context);
  
  canvas.drawImageRect(
      image,
      Rect.fromLTRB(
          0.0, 0.0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(30.0, 27.8, width.toDouble()*0.67, height.toDouble()*0.67),
      new Paint(),
    );
  canvas.drawCircle(
      Offset(97,97),
      70.0,
      whiteCircle);
  canvas.drawCircle(
      Offset(97,97),
      84.0,
      redCircle);
  canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(0.5, 0.5, width.toDouble()*0.45, height.toDouble()*0.23),
        topLeft: radius*0.4,
        topRight: radius*0.4,
        bottomLeft: radius*0.4,
        bottomRight: radius*0.4,
      ),
      white);
  if(mark.isFav){
    final ui.Image favIcon = await _getImageFromAssets("lib/assets/star_icon.png", context);
    canvas.drawCircle(
      Offset(40,150),
      35.0,
      white);
    canvas.drawImageRect(
      favIcon,
      Rect.fromLTRB(
          0.0, 0.0, favIcon.width.toDouble(), favIcon.height.toDouble()),
      Rect.fromLTWH(10.0, 117.8, width.toDouble()*0.30, height.toDouble()*0.30),
      new Paint(),
    );
  }
  TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
  painter.text = TextSpan(
    text: '${mark.nbPost}',
    style: TextStyle(fontSize: 25.0, color: Colors.black,fontWeight: FontWeight.bold),
  );
  painter.layout();
  painter.paint(canvas, Offset((width * 0.22) - painter.width * 0.5, (height*0.12) - painter.height * 0.6));
  final img = await pictureRecorder.endRecording().toImage(width, height);
  final data = await img.toByteData(format: ui.ImageByteFormat.png);
  return data.buffer.asUint8List();
}


  @override
  void initState() {
    super.initState();
    _mainBloc = BlocProvider.of<MainBloc>(context);
    
  }

  void _navigateMarksPage(BuildContext context,bool b,PublicMark mark){
    Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context){
      //TODO: on ouvre une boite de dialogue lorsque le tags n'est pas à porté
        return TagsPage(mark,isFavAndNotNear: b);
      }
    ));
  }

  
  
  Future<Marker> _buildMarker(PublicMark mark) async {
    Uint8List icon;
    Completer<Marker> completer =  Completer<Marker>();
    if(mark.lastPostImageUrl!=null && mark.isPopular){
      icon = await _buildCircleMarkerWithImage(200,200,mark,context);
    }
    else{
      if(mark.isFav) icon = await _buildCircleFavMarker(200,200,mark,context);
      else icon = await _buildCircleDefaultMarker(200,200,mark,context);
    }
    Marker marker = Marker(
      markerId: MarkerId(mark.id),
      infoWindow: InfoWindow(
        onTap: (){
          if(mark.isPopular||mark.isFav) _navigateMarksPage(context,true,mark);
        },
        title: mark.name,
        snippet: mark.description
      ),
      alpha: 1.0,
      anchor: Offset(0.49, 0.49),
      icon: BitmapDescriptor.fromBytes(icon),
      position: LatLng(mark.lat,mark.long)
      );
      completer.complete(marker);
      return completer.future;
  }


  Future<Set<Marker>> _buildSetMarkers(List<PublicMark> listMarks,BuildContext context) async {
    //TODO: opacité du marker doit être proportioonel a sa popularité
    List<Marker> listMarker=List<Marker>();
    Completer<Set<Marker>> completer =  Completer<Set<Marker>>();
    await Future.wait(listMarks.map(_buildMarker)).then((List<Marker> markers){
      listMarker.addAll(markers);
    });
    final Set<Marker> setMarker = listMarker.toSet();
    completer.complete(setMarker);
    return completer.future;
  }


  @override
  void dispose() {
    Geolocalisation.gmController=null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
        return FutureBuilder<List<PublicMark>>(
          future : _mainBloc.filterMarksForMapPage(),
          builder: (BuildContext context, AsyncSnapshot<List<PublicMark>> listDocSnapshot){
                  return Center(
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    width: double.infinity,
                    child: FutureBuilder<Set<Marker>>(
                      future: _buildSetMarkers(listDocSnapshot.data,context),
                      builder: (context, markerSnapshot) {
                            return GoogleMap(
                              markers: markerSnapshot.data,
                              myLocationEnabled: true,
                              myLocationButtonEnabled: true,
                              rotateGesturesEnabled: false,
                              compassEnabled: true,
                              initialCameraPosition: CameraPosition(
                                target: LatLng(_mainBloc.userCurrentPosition.latitude, _mainBloc.userCurrentPosition.longitude),
                                zoom: 16.0,
                              ),
                              
                              onMapCreated: (GoogleMapController controller){
                                  setState(() {
                                    Geolocalisation.gmController=controller;
                                    //controller.getVisibleRegion()
                                  });
                              },
                            );
                          }
                    ),
                  )
                );
              },
            );
  }
}