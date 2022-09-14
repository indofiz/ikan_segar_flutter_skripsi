import 'dart:io';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:ikan_laut_skripsi/theme/colors.dart';
import 'package:ionicons/ionicons.dart';
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
    String res;
    res = (await Tflite.loadModel(
        model: "assets/model/model_unquant.tflite",
        labels: 'assets/model/labels.txt'))!;
    print('model loaded');
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
    print(recognitions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('aaaaaa'),
      ),
      body: getBody(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        onPressed: pickImage,
        tooltip: 'Pick Image',
        child: const Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: getFooter(),
    );
  }

  Widget getBody() {
    return IndexedStack(
      index: pageIndex,
      children: const [
        Center(
          child: Text('Sekarang di'),
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
}
