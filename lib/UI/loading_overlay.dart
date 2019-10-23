import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return  Material(
      color: Colors.black54,
      child: InkWell(
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 5.0,),
        ),
      )
    );
  }


}