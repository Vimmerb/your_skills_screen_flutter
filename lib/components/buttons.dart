import 'package:flutter/material.dart';

class Buttons {
  //кнопка назад
  Widget back(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Image.asset("assets/images/buttons/back.png"),
    );
  }
}
