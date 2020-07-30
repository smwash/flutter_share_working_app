import 'package:flutter/material.dart';

AppBar header(context,
    {bool isTitle = false, String titleText, removeBackButton = false}) {
  return AppBar(
    automaticallyImplyLeading: removeBackButton ? false : true,
    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,
    title: Text(
      isTitle ? 'FlutterShare' : titleText,
      style: TextStyle(
        color: Colors.white,
        fontFamily: isTitle ? 'Signatra' : '',
        fontSize: isTitle ? 50.0 : 22,
      ),
    ),
  );
}
