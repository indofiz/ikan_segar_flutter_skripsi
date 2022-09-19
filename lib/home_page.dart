import 'dart:io';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ikan_laut_skripsi/pages/home.dart';
import 'package:ikan_laut_skripsi/theme/colors.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int pageIndex = 0;
  final ImagePicker _picker = ImagePicker();
  UploadTask? uploadTask;

  late File _image;
  late List _results;
  bool imageSelect = false;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future loadModel() async {
    Tflite.close();
    (await Tflite.loadModel(
        model: "assets/model/model_unquant.tflite",
        labels: 'assets/model/labels.txt'))!;
  }

  Future clasification(File image) async {
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 4,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _results = recognitions!;
      _image = image;
      imageSelect = true;
    });
    uploadImage(image, recognitions!);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: bgColor,
        body: getBody(),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primary,
          onPressed: pickImage,
          tooltip: 'Ambil Gambar',
          child: const Icon(Icons.camera_alt),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: getFooter(),
      ),
    );
  }

  Widget getBody() {
    return IndexedStack(
      index: pageIndex,
      children: const [
        Center(
          child: PageHome(),
        ),
        Center(
          child: Text('bbbb'),
        )
      ],
    );
  }

  Widget getFooter() {
    List<IconData> iconItems = [Ionicons.home, Ionicons.time];
    return AnimatedBottomNavigationBar(
        height: 64,
        icons: iconItems,
        activeColor: primary,
        splashColor: white,
        inactiveColor: black.withOpacity(0.5),
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.defaultEdge,
        rightCornerRadius: 8,
        leftCornerRadius: 8,
        iconSize: 24,
        activeIndex: pageIndex,
        onTap: (index) {
          setTabs(index);
        });
  }

  setTabs(index) {
    setState(() {
      pageIndex = index;
    });
  }

  Future pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    File image = File(pickedFile!.path);

    clasification(image);
  }

  Future uploadImage(File image, List predictions) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString('email');
    String tanggal = DateFormat("yyyy-MM-dd").format(DateTime.now());
    String waktu = DateFormat("HH:mm:ss").format(DateTime.now());
    String fileName = image.path.split('/').last;
    final path = 'files/$fileName';
    final ref = FirebaseStorage.instance.ref().child(path);
    uploadTask = ref.putFile(image);
    final snapshot = await uploadTask!.whenComplete(() => {});
    final urlDownload = await snapshot.ref.getDownloadURL();

    // SIMPAN DATA
    final docPrediksi = FirebaseFirestore.instance.collection('prediksi').doc();

    final json = {
      'id': docPrediksi.id,
      'email': email,
      'tanggal': tanggal,
      'waktu': waktu,
      'prediksi': predictions,
      'urlgambar': urlDownload
    };
    await docPrediksi.set(json);
    // buildProgress();
  }

  // Widget buildProgress() => StreamBuilder<TaskSnapshot>(
  //     stream: uploadTask?.snapshotEvents,
  //     builder: (context, snapshot) {
  //       if (snapshot.hasData) {
  //         final data = snapshot.data!;
  //         double progress = data.bytesTransferred / data.totalBytes;
  //         return SizedBox(
  //           height: 50,
  //           child: Stack(
  //             fit: StackFit.expand,
  //             children: [
  //               LinearProgressIndicator(
  //                 value: progress,
  //                 backgroundColor: border,
  //                 color: primary,
  //               ),
  //               Center(
  //                 child: Text(
  //                   '${(100 * progress).roundToDouble()}%',
  //                   style: TextStyle(color: white),
  //                 ),
  //               )
  //             ],
  //           ),
  //         );
  //       } else {
  //         return const SizedBox(
  //           height: 50,
  //         );
  //       }
  //     });
}

class Prediksi {
  String id;
  final String email;
  final String tanggal;
  final String waktu;
  final List prediksi;
  final String urlgambar;

  Prediksi(
      {this.id = '',
      required this.email,
      required this.tanggal,
      required this.waktu,
      required this.prediksi,
      required this.urlgambar});

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'tanggal': tanggal,
        'waktu': waktu,
        'prediction': prediksi,
        'urlgambar': prediksi
      };

  static Prediksi fromJson(Map<String, dynamic> json) => Prediksi(
      id: json['id'],
      email: json['email'],
      tanggal: json['tanggal'],
      waktu: json['waktu'],
      prediksi: json['prediksi'],
      urlgambar: json['urlgambar']);
}
