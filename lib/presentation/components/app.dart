import 'package:flutter/material.dart';

import '../pages/pages.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final primaryColor = Color.fromRGBO(136, 14, 79, 1);
    final primaryColorDark = Color.fromRGBO(96, 0, 39, 1);
    final primaryColorLight = Color.fromRGBO(188, 71, 123, 1);

    return Container(
      child: MaterialApp(
      title: '4Dev',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryColor,
        primaryColorDark: primaryColorDark,
        primaryColorLight: primaryColorLight,
        accentColor: primaryColor,
        backgroundColor: Colors.white,
        textTheme: TextTheme(
          headline1: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: primaryColorDark,
          )
        ),
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: primaryColorLight)
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: primaryColor)
          ),
          alignLabelWithHint: true,
        ),
        buttonTheme: ButtonThemeData(
          colorScheme: ColorScheme.light(primary: primaryColor),
          buttonColor: primaryColor,
          splashColor: primaryColorLight,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          textTheme: ButtonTextTheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        )
      ),
      home: LoginPage(),
    ));
  }
}
