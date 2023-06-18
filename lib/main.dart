import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String status = 'Ready';
  XFile? imageFile;
  String? base64Image;
  File? tmpFile;
  String erroMessage = 'Error uploading image';
  String url = 'http://192.168.180.164/flutter_test/upload.php';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image to Server'),
      ),
      body: Center(
        child: Column(
          children: [
            OutlinedButton(
                onPressed: () {
                  chooseImage();
                },
                child: const Text('Choose image')),
            const SizedBox(
              height: 20,
            ),
            if (imageFile != null)
              Image.file(
                File(imageFile!.path),
                width: 300,
                height: 300,
                fit: BoxFit.fill,
              ),
            const SizedBox(
              height: 20,
            ),
            OutlinedButton(
                onPressed: () {
                  startUpload();
                },
                child: const Text('Upload image')),
            const SizedBox(
              height: 20,
            ),
            Text(
              status,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.green,
                  fontSize: 20,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  //choose image function
  chooseImage() async {
    final pickImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    pickImage != null
        ? setState(() {
            imageFile = pickImage;
            File imgFile = File(imageFile!.path);
            tmpFile = imgFile;
            base64Image = base64Encode(imgFile.readAsBytesSync());
          })
        : const Text('Error getting image');
  }

//status messgage
  setStatus(String messaage) {
    setState(() {
      status = messaage;
    });
  }

  //Start upload
  startUpload() {
    print('Base 64 is $base64Image');

    setStatus('Uploading image');
    if (tmpFile == null) {
      setStatus(erroMessage);
      return;
    }
    String filename = tmpFile!.path.split('/').last;
    upload(filename);
  }

  upload(String filename) {
    print('Filename is $filename');
    http.post(Uri.parse(url), body: {
      //

      "image": base64Image,
      "name": filename,
    }).then((value) {
      setStatus(
          value.statusCode == 200 ? value.body : value.statusCode.toString());
    });
    // .catchError( setStatus(erroMessage));
  }
}
