import 'package:flutter/material.dart';

class MyTheme {
  static ThemeData lightTheme(BuildContext context) => ThemeData(
      scaffoldBackgroundColor: Colors.pink[100],
      // primaryTextTheme: GoogleFonts.latoTextTheme()
      cardColor: Colors.white,
      canvasColor: creamColor,
      appBarTheme: AppBarTheme(
        color: Colors.deepPurple,
        elevation: 0.0,
        iconTheme: const IconThemeData(color: Colors.black),
        toolbarTextStyle: Theme.of(context).textTheme.bodyText2,
        titleTextStyle: Theme.of(context).textTheme.headline6,
        // textTheme: Theme.of(context).textTheme,
      ),
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple)
          .copyWith(secondary: darkBluishColor));
  static ThemeData darkTheme(BuildContext context) => ThemeData(
      scaffoldBackgroundColor: Colors.grey[850],
      // primaryTextTheme: GoogleFonts.latoTextTheme()
      // brightness: Brightness.dark,
      cardColor: Colors.black,
      canvasColor: darkCreamColor,
      appBarTheme: const AppBarTheme(
        color: Colors.black,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.redAccent),
      ),
      colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.pink, brightness: Brightness.dark)
          .copyWith(secondary: Colors.white));

  static Color creamColor = const Color(0xfff5f5f5);
  // static Color darkCreamColor = Vx.gray800;
  static Color darkCreamColor = Colors.grey[800]!;
  static Color darkBluishColor = const Color(0xff403b58);
  static Color lightBluishColor = Colors.indigo[500]!;
}
