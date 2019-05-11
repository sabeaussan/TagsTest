import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PostTileBottom extends StatelessWidget {

    final String _description;
    final int _nbComments;
		final Function _onPressed;

    const PostTileBottom(this._description,this._nbComments,this._onPressed);



  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
				SizedBox(width: 15.0,),
        Expanded(
          child: Text(_description,style: TextStyle(fontSize: 14.0),),
          flex: 6,
        ),
        Expanded(
					flex: 1,
          child: Column(
            children: <Widget>[
								IconButton(
									padding: EdgeInsets.all(1.0),
									icon: Icon(Icons.comment,color: Colors.black,),
									onPressed: _onPressed,
							),
							Text("$_nbComments")
            ],
          ),
        ),
				SizedBox(width: 10.0,),
      ],
    );
  }


}