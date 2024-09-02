import 'package:flutter/material.dart';

import 'light_color.dart';

class AppTheme {
  const AppTheme();

  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.light(
      primary: LightColor.primaryColor,
      background: LightColor.background,
      onPrimary: LightColor.iconColor,
      surface: LightColor.lightGrey,
      onBackground: LightColor.black,
    ),
    cardTheme: CardTheme(color: LightColor.background),
    textTheme: TextTheme(bodyLarge: TextStyle(color: LightColor.black)),
    iconTheme: IconThemeData(color: LightColor.iconColor),
    dividerColor: LightColor.lightGrey,
    primaryTextTheme: TextTheme(bodyLarge: TextStyle(color: LightColor.titleTextColor)),
    appBarTheme: AppBarTheme(
      backgroundColor: LightColor.background, // Use this to set AppBar background color
      elevation: 0,
      iconTheme: IconThemeData(color: LightColor.iconColor),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: LightColor.background, // Set the bottom app bar color here
      selectedItemColor: LightColor.primaryColor,
      unselectedItemColor: LightColor.iconColor,
    ),
  );

  static TextStyle titleStyle =
      const TextStyle(color: LightColor.titleTextColor, fontSize: 16);
  static TextStyle subTitleStyle =
      const TextStyle(color: LightColor.subTitleTextColor, fontSize: 12);

  static TextStyle h1Style =
      const TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
  static TextStyle h2Style = const TextStyle(fontSize: 22);
  static TextStyle h3Style = const TextStyle(fontSize: 20);
  static TextStyle h4Style = const TextStyle(fontSize: 18);
  static TextStyle h5Style = const TextStyle(fontSize: 16);
  static TextStyle h6Style = const TextStyle(fontSize: 14);

  static List<BoxShadow> shadow = <BoxShadow>[
    BoxShadow(color: Color(0xfff8f8f8), blurRadius: 10, spreadRadius: 15),
  ];

  static EdgeInsets padding =
      const EdgeInsets.symmetric(horizontal: 20, vertical: 10);
  static EdgeInsets hPadding = const EdgeInsets.symmetric(
    horizontal: 10,
  );

  static double fullWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double fullHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
}
