import 'package:flutter/material.dart';
import 'package:ikan_laut_skripsi/theme/colors.dart';

class CardCiri extends StatelessWidget {
  final String image;
  final String title;
  const CardCiri({super.key, required this.image, required this.title});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            color: white,
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 24),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        child: Center(
            child: Column(
          children: [
            Image.asset(image),
            Text(
              title,
              style: TextStyle(color: black, fontWeight: FontWeight.w400),
            )
          ],
        )),
      ),
    );
  }
}
