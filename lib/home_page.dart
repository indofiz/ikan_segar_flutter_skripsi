import 'dart:io';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ikan_laut_skripsi/components/prediksi.dart';
import 'package:ikan_laut_skripsi/pages/home.dart';
import 'package:ikan_laut_skripsi/pages/riwayat.dart';
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
          child: Riwayat(),
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

  Future uploadImage(File image, List prediksi) async {
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

    final prediksiKirim = Prediksi(
      id: docPrediksi.id,
      email: email!,
      tanggal: tanggal,
      waktu: waktu,
      prediksi: prediksi,
      urlgambar: urlDownload,
    );
    final json = prediksiKirim.toJson();

    await docPrediksi.set(json);
  }
}
