import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ikan_laut_skripsi_v2/components/prediksi.dart';
import 'package:ikan_laut_skripsi_v2/components/title_section.dart';
import 'package:ikan_laut_skripsi_v2/theme/colors.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:tflite/tflite.dart';

class HasilKlasifikasi extends StatefulWidget {
  final File image;
  final List prediksi;
  const HasilKlasifikasi(
      {super.key, required this.image, required this.prediksi});

  @override
  State<HasilKlasifikasi> createState() => _HasilKlasifikasiState();
}

class _HasilKlasifikasiState extends State<HasilKlasifikasi> {
  UploadTask? uploadTask;

  List<Color> warna = [
    busuk,
    sangatBusuk,
    sangatSegar,
    segar,
    busuk,
    sangatBusuk,
    sangatSegar,
    segar
  ];

  var ikanSegar =
      'Ikan memilki banyak kandungan gizi esensial yang sangat bermanfaat bagi kesehatan dan kecerdasan. Ikan mengandung protein, karbohidrat, vitamin, mineral, asam lemak Omega 3, 6, 9 yang baik manfaat nya untuk tubuh manusia.';

  var ikanBusuk =
      'Ikan yang tidak segar atau membusuk berisiko membawa penyakit dan bisa membuat seseorang keracunan makanan. Sebabnya, daging ikan yang membusuk bisa jadi tempat berkembang biak bakteri.';

  List<Color> warnaCon = [
    busuk,
    sangatBusuk,
    sangatSegar,
    segar,
    busuk,
    sangatBusuk,
    sangatSegar,
    segar
  ];

  @override
  void initState() {
    super.initState();
    uploadImage(widget.image, widget.prediksi);
    print(widget.prediksi);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: white,
      child: SafeArea(
        child: Scaffold(
          body: bodyHasil(),
        ),
      ),
    );
  }

  Widget bodyHasil() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          children: [
            const TitleSection(
              title: 'Hasil Klasifikasi',
              subtitle:
                  'Berikut adalah hasil identifikasi mata ikan yang berdasarkan foto.',
            ),
            const SizedBox(
              height: 24,
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  border: Border.all(color: black.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(18)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 240,
                  minHeight: 240,
                  maxWidth: 260,
                  maxHeight: 260,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(widget.image, fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            Text(
              widget.prediksi[0]['label'],
              style: TextStyle(
                color: warna[widget.prediksi[0]['index']],
                fontWeight: FontWeight.w600,
                fontSize: 40,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              "Jenis Ikan ${widget.prediksi[0]['jenis']}",
              style: TextStyle(
                color: black.withOpacity(0.8),
                fontWeight: FontWeight.w500,
                fontSize: 24,
              ),
            ),
            const SizedBox(
              height: 32,
            ),
            Container(
              decoration: BoxDecoration(
                  color: warnaCon[widget.prediksi[0]['index']].withOpacity(0.4),
                  borderRadius: const BorderRadius.all(Radius.circular(12))),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_rounded,
                          color: black,
                          size: 20,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          "Sekilas Info",
                          style: TextStyle(
                            color: black,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      widget.prediksi[0]['label']
                              .toLowerCase()
                              .contains('segar')
                          ? ikanSegar
                          : ikanBusuk,
                      style: TextStyle(
                          color: black.withOpacity(0.8), fontSize: 13),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Container(
              padding: EdgeInsets.zero,
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(0))),
                  backgroundColor: primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  alignment: Alignment.center,
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Kembali',
                  style: TextStyle(color: white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            buildProgress()
          ],
        ),
      ),
    );
  }

  Widget buildProgress() => StreamBuilder<TaskSnapshot>(
        stream: uploadTask?.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!;
            double progress = data.bytesTransferred / data.totalBytes;
            return SizedBox(
              height: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: primary.withOpacity(0.3),
                    color: secondary,
                  ),
                ],
              ),
            );
          } else {
            return const SizedBox(
              height: 0,
            );
          }
        },
      );

  Future uploadImage(File image, List prediksi) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString('email');
    String tanggal = DateFormat("yyyy-MM-dd").format(DateTime.now());
    String waktu = DateFormat("HH:mm:ss").format(DateTime.now());
    DateTime createdAt = DateTime.now();
    String fileName = image.path.split('/').last;
    final path = 'files/$fileName';
    final ref = FirebaseStorage.instance.ref().child(path);
    setState(() {
      uploadTask = ref.putFile(image);
    });
    final snapshot = await uploadTask!.whenComplete(() => {});
    final urlDownload = await snapshot.ref.getDownloadURL();

    // SIMPAN DATA
    final docPrediksi = FirebaseFirestore.instance.collection('prediksi').doc();

    final prediksiKirim = Prediksi(
        id: docPrediksi.id,
        email: email!,
        tanggal: tanggal,
        waktu: waktu,
        prediksi: prediksi,
        urlgambar: urlDownload,
        createdAt: createdAt);
    final json = prediksiKirim.toJson();

    await docPrediksi.set(json);
    setState(() {
      uploadTask = null;
    });
  }
}
