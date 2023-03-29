import 'package:flutter/material.dart';

SnackBar mySnackBar(String text) {
  return SnackBar(
    content: Text(
      text,
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 2),
    behavior: SnackBarBehavior.floating,margin: EdgeInsets.all(30),
  );
}

