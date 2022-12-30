import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ikan_laut_skripsi_v2/components/prediksi.dart';
import 'package:ikan_laut_skripsi_v2/components/title_section.dart';
import 'package:ikan_laut_skripsi_v2/theme/colors.dart';

class DetailKlasifikasi extends StatefulWidget {
  final String id;
  const DetailKlasifikasi({super.key, required this.id});

  @override
  State<DetailKlasifikasi> createState() => _DetailKlasifikasiState();
}

class _DetailKlasifikasiState extends State<DetailKlasifikasi> {
  List<Color> warna = [sangatSegar, segar, busuk, sangatBusuk];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: white,
      child: SafeArea(
        child: Scaffold(
          body: FutureBuilder<Prediksi?>(
            future: readPrediksi(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final hasil = snapshot.data;
                return hasil == null
                    ? const Center(child: Text('Data tidak ada'))
                    : bodyHasil(hasil);
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Future<Prediksi?> readPrediksi() async {
    final docPrediksi =
        FirebaseFirestore.instance.collection('prediksi').doc(widget.id);
    final snapshot = await docPrediksi.get();
    if (snapshot.exists) {
      return Prediksi.fromJson(snapshot.data()!);
    }
    return null;
  }

  Widget bodyHasil(Prediksi prediksi) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          children: [
            const TitleSection(
              title: 'Detail Klasifikasi',
              subtitle: 'Berikut adalah detail identifikasi mata ikan.',
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
                  minWidth: 184,
                  minHeight: 184,
                  maxWidth: 204,
                  maxHeight: 204,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(prediksi.urlgambar, fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            Text(
              prediksi.prediksi[0]['label'].toString(),
              style: TextStyle(
                color: warna[prediksi.prediksi[0]['index']],
                fontWeight: FontWeight.w600,
                fontSize: 32,
              ),
            ),
            const SizedBox(
              height: 2,
            ),
            Text(
              '${prediksi.waktu} - ${prediksi.tanggal}',
              style: TextStyle(
                color: black.withOpacity(0.7),
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4), color: primary),
              child: Text(
                prediksi.prediksi[0]['jenis'].toString(),
                style: TextStyle(
                  color: white,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
            const Spacer(),
            Container(
              padding: EdgeInsets.zero,
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
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
            )
          ],
        ),
      ),
    );
  }
}
