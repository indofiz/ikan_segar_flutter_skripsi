import 'package:flutter/cupertino.dart';
import 'package:ikan_laut_skripsi/components/card_ciri.dart';
import 'package:ikan_laut_skripsi/components/title_section.dart';
import 'package:ikan_laut_skripsi/theme/colors.dart';

class PageHome extends StatefulWidget {
  const PageHome({super.key});

  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        welcomePage(),
        ciriIkan(),
      ],
    );
  }

  Widget ciriIkan() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
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
      ),
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
}
