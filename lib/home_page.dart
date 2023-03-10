import 'dart:io';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:ikan_laut_skripsi_v2/classifier/classifier.dart';
import 'package:ikan_laut_skripsi_v2/classifier/classifier_quant.dart';
import 'package:ikan_laut_skripsi_v2/pages/hasil_klasifikasi.dart';
import 'package:ikan_laut_skripsi_v2/pages/home.dart';
import 'package:ikan_laut_skripsi_v2/pages/riwayat.dart';
import 'package:ikan_laut_skripsi_v2/theme/colors.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:ionicons/ionicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class HomePage extends StatefulWidget {
  final String email;
  const HomePage({Key? key, required this.email}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int pageIndex = 0;
  final ImagePicker _picker = ImagePicker();
  UploadTask? uploadTask;
  late Classifier _classifier;

  var logger = Logger();

  File? _image;
  File? _imageCropped;

  img.Image? fox;

  Category? category;

  bool imageSelect = false;

  @override
  void initState() {
    super.initState();
    _classifier = ClassifierQuant();
  }

  Future<void> pickImage(ImageSource type) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: type,
      );
      File image = File(pickedFile!.path);
      _cropImage(image);
    } catch (error) {
      // ignore: avoid_print
      print("error: $error");
    }
  }

  Future<void> _cropImage(File pickedFile) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      // aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      aspectRatioPresets: [CropAspectRatioPreset.square],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: primary,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: true,
        )
      ],
    );

    if (croppedFile != null) {
      String fileName = croppedFile.path.split('/').last;

      setState(() {
        _image = File(croppedFile.path);
        print(_image);
        _predict();
      });
    }
  }

  void _predict() async {
    img.Image imageInput = img.decodeImage(_image!.readAsBytesSync())!;
    var pred = _classifier.predict(imageInput);
    var labelRaw = pred.label;
    final info = labelRaw.split('-');
    Map<String, dynamic> predik = {
      'index': int.parse(info[0]),
      'jenis': info[1],
      'label': info[2],
      'confidence': pred.score
    };
    List<Map> hasilPrediksi = [predik];
    // print(hasilPrediksi);
    setState(() {
      imageSelect = true;
    });
    await Future.delayed(
      const Duration(milliseconds: 300),
      () => {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                HasilKlasifikasi(image: _image!, prediksi: hasilPrediksi),
          ),
        )
      },
    );
    // uploadImage(image, recognitions!);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: white,
      child: SafeArea(
        child: WillPopScope(
          onWillPop: _onWillPop,
          child: Scaffold(
            backgroundColor: bgColor,
            body: getBody(),
            floatingActionButton: FloatingActionButton(
              backgroundColor: primary,
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      height: 200,
                      color: white,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              'Ambil Gambar:',
                              style: TextStyle(
                                  color: black,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 40),
                              width: double.infinity,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: primary,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 16),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  alignment: Alignment.centerLeft,
                                ),
                                onPressed: (() {
                                  pickImage(ImageSource.camera);
                                  Navigator.pop(context);
                                }),
                                child: Row(
                                  children: [
                                    Icon(
                                      Ionicons.camera,
                                      color: white,
                                      size: 18,
                                    ),
                                    const SizedBox(
                                      width: 14,
                                    ),
                                    Text(
                                      'Kamera Handphone',
                                      style: TextStyle(
                                          color: white,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 40),
                              width: double.infinity,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: primary,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 16),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  alignment: Alignment.centerLeft,
                                ),
                                onPressed: (() {
                                  pickImage(ImageSource.gallery);
                                  Navigator.pop(context);
                                }),
                                child: Row(
                                  children: [
                                    Icon(
                                      Ionicons.images,
                                      color: white,
                                      size: 18,
                                    ),
                                    const SizedBox(
                                      width: 14,
                                    ),
                                    Text(
                                      'Galeri Handphone',
                                      style: TextStyle(
                                          color: white,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              tooltip: 'Ambil Gambar',
              child: const Icon(Icons.camera_alt),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: getFooter(),
          ),
        ),
      ),
    );
  }

  Widget getBody() {
    return IndexedStack(
      index: pageIndex,
      children: [
        Center(
          child: PageHome(email: widget.email),
        ),
        Center(
          child: Riwayat(email: widget.email),
        )
      ],
    );
  }

  Widget getFooter() {
    List<IconData> iconItems = [Ionicons.home, Ionicons.time];
    return AnimatedBottomNavigationBar(
      height: 54,
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
      },
    );
  }

  setTabs(index) {
    setState(() {
      pageIndex = index;
    });
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Anda yakin?'),
            content: const Text('Ingin keuar dari aplikasi'),
            actions: <Widget>[
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(false), //<-- SEE HERE
                child: const Text('Tidak'),
              ),
              TextButton(
                onPressed: () => SystemNavigator.pop(), // <-- SEE HERE
                child: const Text('Keluar'),
              ),
            ],
          ),
        )) ??
        false;
  }
}
