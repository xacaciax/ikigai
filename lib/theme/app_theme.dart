import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildThemeData() {
  return ThemeData(
    primaryColor: Colors.white,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      color: Colors.lightBlue,
      toolbarTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: TextTheme(
      bodySmall: GoogleFonts.roboto(
        color: Colors.black,
        fontSize: 14.0,
      ),
      bodyMedium: GoogleFonts.roboto(
        color: Colors.black,
        fontSize: 16.0,
      ),
      headlineSmall: GoogleFonts.roboto(
        color: Colors.black,
        fontSize: 24.0,
      ),
      titleLarge: GoogleFonts.roboto(
        color: Colors.black,
        fontSize: 22.0,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        primary: Colors.lightBlue,
        onPrimary: Colors.white,
        textStyle: TextStyle(
          color: Colors.orange,
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: Color.fromARGB(255, 6, 88, 155), // Bright blue
      textTheme: ButtonTextTheme.normal,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Color(0xFF90CAF9)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Color(0xFF90CAF9)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Color(0xFF2196F3)),
      ),
      labelStyle: TextStyle(
        color: Color(
            0xFFB3E5FC), // Very light blue, consider contrast for readability
      ),
    ),
  );
}
