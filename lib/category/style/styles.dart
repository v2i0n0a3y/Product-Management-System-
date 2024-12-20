import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppStyle {
  static TextStyle m12b = GoogleFonts.beVietnamPro(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );

  static TextStyle m12bt = GoogleFonts.beVietnamPro(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: Colors.black.withOpacity(0.65));

  static TextStyle m12w = GoogleFonts.beVietnamPro(
      fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white);

  static TextStyle r12w = GoogleFonts.beVietnamPro(
      fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white);

  static TextStyle r10wt = GoogleFonts.beVietnamPro(
      fontSize: 10,
      fontWeight: FontWeight.w400,
      color: Colors.white.withOpacity(0.75));

  static TextStyle b32w = GoogleFonts.beVietnamPro(
      fontSize: 32, fontWeight: FontWeight.w600, color: Colors.white);
}
