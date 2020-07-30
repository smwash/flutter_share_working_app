import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Container circularProgress() {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(
      top: 10.0,
    ),
    child: SpinKitFadingFour(
      color: Colors.purple,
      size: 50.0,
    ),
  );
}

Container linearProgress() {
  return Container(
    padding: EdgeInsets.only(
      bottom: 10.0,
    ),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(
        Colors.purple,
      ),
    ),
  );
}
