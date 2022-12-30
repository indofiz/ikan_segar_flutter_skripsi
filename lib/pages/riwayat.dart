import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ikan_laut_skripsi_v2/components/no_data.dart';
import 'package:ikan_laut_skripsi_v2/components/prediksi.dart';
import 'package:ikan_laut_skripsi_v2/components/shimmer.dart';
import 'package:ikan_laut_skripsi_v2/components/title_section.dart';
import 'package:ikan_laut_skripsi_v2/pages/detail_klasifikasi.dart';
import 'package:ikan_laut_skripsi_v2/theme/colors.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ionicons/ionicons.dart';

class Riwayat extends StatefulWidget {
  final String email;
  const Riwayat({super.key, required this.email});

  @override
  State<Riwayat> createState() => _RiwayatState();
}

class _RiwayatState extends State<Riwayat> {
  late bool _isLoading;
  bool hasInternet = false;

  @override
  void initState() {
    _isLoading = true;
    Future.delayed(
      const Duration(seconds: 4),
      () => {
        setState(() {
          _isLoading = false;
        })
      },
    );
    super.initState();
    // InternetConnectionChecker().onStatusChange.listen((status) {
    //   final hasInternet = status == InternetConnectionStatus.connected;
    //   setState(() => this.hasInternet = hasInternet);
    // });
  }

  Stream<List<Prediksi>> readPrediksi() => FirebaseFirestore.instance
      .collection('prediksi')
      .where('email', isEqualTo: widget.email)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Prediksi.fromJson(doc.data())).toList());

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          height: 24,
        ),
        const TitleSection(
          title: 'Riwayat Klasifikasi',
          subtitle: 'Berikut riwayat ikan diidentifikasi yang pernah dilakukan',
        ),
        const SizedBox(
          height: 24,
        ),
        _isLoading
            ? Expanded(
                child: ListView.separated(
                    itemBuilder: (context, index) => const ShimmerCard(),
                    separatorBuilder: (context, index) => const SizedBox(
                          height: 12,
                        ),
                    itemCount: 10),
              )
            : Expanded(
                child: StreamBuilder<List<Prediksi>>(
                    stream: readPrediksi(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Something wrong! ${snapshot.error}');
                      } else if (snapshot.hasData) {
                        final prediks = snapshot.data;
                        return prediks == null || prediks.isEmpty
                            ? const NoData()
                            : SlidableAutoCloseBehavior(
                                closeWhenOpened: true,
                                child: ListView(
                                  children: prediks.map(buildPrediksi).toList(),
                                ),
                              );
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    }),
              ),
      ],
    );
  }

  Widget buildPrediksi(Prediksi prediksi) {
    return Slidable(
      closeOnScroll: true,
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              final docPrediksi = FirebaseFirestore.instance
                  .collection('prediksi')
                  .doc(prediksi.id);
              FirebaseStorage.instance.refFromURL(prediksi.urlgambar).delete();
              docPrediksi.delete();
            },
            backgroundColor: Colors.red,
            icon: Ionicons.trash,
            label: 'Hapus',
          )
        ],
      ),
      child: Container(
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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DetailKlasifikasi(id: prediksi.id)),
            );
          },
        ),
      ),
    );
  }
}
