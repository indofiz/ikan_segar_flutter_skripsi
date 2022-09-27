import 'package:flutter/material.dart';
import 'package:ikan_laut_skripsi/theme/colors.dart';
import 'package:ikan_laut_skripsi/theme/text.dart';

class IkanKembung extends StatelessWidget {
  const IkanKembung({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: white,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_ios),
            ),
            title: const Text('Ikan Kembung'),
          ),
          body: bodyMakan(),
        ),
      ),
    );
  }

  Widget bodyMakan() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              width: double.infinity,
              child: Image.asset('assets/ikan/kembung.jpeg'),
            ),
            const SizedBox(
              height: 28,
            ),
            Text(
              'Secara Umum',
              textAlign: TextAlign.start,
              style: title,
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
              textAlign: TextAlign.justify,
              style: paragraf,
            ),
            const SizedBox(
              height: 32,
            ),
            Text(
              'Morpologi',
              textAlign: TextAlign.start,
              style: title,
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
              textAlign: TextAlign.justify,
              style: paragraf,
            )
          ],
        ),
      ),
    );
  }
}
