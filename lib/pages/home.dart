import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ikan_laut_skripsi/components/card_ciri.dart';
import 'package:ikan_laut_skripsi/components/prediksi.dart';
import 'package:ikan_laut_skripsi/components/title_section.dart';
import 'package:ikan_laut_skripsi/theme/colors.dart';

class PageHome extends StatefulWidget {
  final String email;
  const PageHome({super.key, required this.email});

  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  Stream<List<Prediksi>> readPrediksi() => FirebaseFirestore.instance
      .collection('prediksi')
      .where('email', isEqualTo: widget.email)
      .orderBy('createdAt', descending: true)
      .limit(5)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Prediksi.fromJson(doc.data())).toList());

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        welcomePage(),
        ciriIkan(),
        Expanded(
          child: StreamBuilder<List<Prediksi>>(
            stream: readPrediksi(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Something wrong! ${snapshot.error}');
              } else if (snapshot.hasData) {
                final prediks = snapshot.data!;
                return ListView(
                  physics: const BouncingScrollPhysics(),
                  children: prediks.map(buildPrediksi).toList(),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget ciriIkan() {
    return Column(
      children: [
        const SizedBox(
          height: 24,
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: TitleSection(
            title: 'Ketahui Ciri Ikan?',
            subtitle: 'Hanya jenis berikut yang bisa diidentifikasi',
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            CardCiri(
              image: 'assets/images/kembung.png',
              title: 'Selar Como',
            ),
            CardCiri(
              image: 'assets/images/selar_como.png',
              title: 'Kembung',
            ),
          ],
        ),
        const SizedBox(
          height: 32,
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: TitleSection(
            title: 'Riwayat Identifikasi',
            subtitle:
                'Berikut riwayat ikan diidentifikasi yang pernah dilakukan',
          ),
        ),
      ],
    );
  }

  Widget welcomePage() {
    return Container(
        decoration: BoxDecoration(
            color: primary, borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat Datang',
              style: TextStyle(
                  color: white, fontWeight: FontWeight.w600, fontSize: 18),
            ),
            Text(
              widget.email,
              style: TextStyle(
                  color: white, fontWeight: FontWeight.w400, fontSize: 12),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              'Aplikasi bisa digunakan untuk mendeteksi kesegaran ikan laut selar como (hapau) dan kembung.',
              style: TextStyle(color: white.withOpacity(0.8)),
            )
          ],
        ));
  }

  Widget buildPrediksi(Prediksi prediksi) {
    // print(emailAwait);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
          border: Border.all(color: border, width: 1),
          color: white,
          borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 44,
            maxWidth: 64,
            maxHeight: 64,
          ),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(prediksi.urlgambar, fit: BoxFit.cover)),
        ),
        title: Text(
          prediksi.prediksi[0]['label'].toString(),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text('${prediksi.tanggal} - ${prediksi.waktu}'),
      ),
    );
  }
}
