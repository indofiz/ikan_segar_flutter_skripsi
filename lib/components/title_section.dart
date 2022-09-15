import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ikan_laut_skripsi/theme/colors.dart';

class TitleSection extends StatelessWidget {
  final String title;
  final String subtitle;
  const TitleSection({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
              textStyle: TextStyle(
                  color: black, fontSize: 18, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          subtitle,
          style: GoogleFonts.poppins(
              textStyle: TextStyle(
                  color: textFieldColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w300)),
        ),
      ],
    );
  }
}