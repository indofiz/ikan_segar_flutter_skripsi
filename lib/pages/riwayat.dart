import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ikan_laut_skripsi/components/prediksi.dart';
import 'package:ikan_laut_skripsi/components/title_section.dart';
import 'package:ikan_laut_skripsi/theme/colors.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ionicons/ionicons.dart';

class Riwayat extends StatefulWidget {
  final String email;
  const Riwayat({super.key, required this.email});

  @override
  State<Riwayat> createState() => _RiwayatState();
}

class _RiwayatState extends State<Riwayat> {
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
        Expanded(
          child: StreamBuilder<List<Prediksi>>(
              stream: readPrediksi(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Something wrong! ${snapshot.error}');
                } else if (snapshot.hasData) {
                  final prediks = snapshot.data!;
                  return SlidableAutoCloseBehavior(
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
    // print(emailAwait);
    return Slidable(
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
        ),
      ),
    );
  }
}
