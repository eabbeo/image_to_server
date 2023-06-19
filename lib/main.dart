// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';
//import 'dart:html';
import 'dart:io';
import 'package:flutter/foundation.dart';
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
  String domain = '192.168.56.1';
  String path = '/flutter_test/upload.php';
  Uint8List? byteImage;
  var imageBase;
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
              kIsWeb
                  ? Image.network(
                      imageFile!.path,
                      width: 300,
                      height: 300,
                      fit: BoxFit.fill,
                    )
                  : Image.file(
                      File(imageFile!.path),
                      width: 300,
                      height: 300,
                      fit: BoxFit.fill,
                    ),
            // Image.file(
            //   File(imageFile!.path),
            //   width: 300,
            //   height: 300,
            //   fit: BoxFit.fill,
            // ),
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
    byteImage = await pickImage!.readAsBytes();
    pickImage != null
        ? setState(() {
            imageFile = pickImage;
            File imgFile = File(imageFile!.path);
            tmpFile = imgFile;
            kIsWeb
                ? byteImage
                : base64Image = base64Encode(imgFile.readAsBytesSync());
            if (byteImage == null) {
              imageBase = base64Image;
            } else {
              imageBase = byteImage;
            }
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
  startUpload() async {
    print('Base 64 is $imageBase');

    setStatus('Uploading image');
    if (tmpFile == null) {
      setStatus(erroMessage);
      return;
    }
    String filename = tmpFile!.path.split('/').last;
    upload(filename);
  }

  upload(String filename) async {
    try {
      print('Filename is $filename');
      var response = await http.post(Uri.http(domain, path), body: {
        //
        "image": imageBase.toString(),
        "name": "$filename.jpg",
      });
      if (response.statusCode == 200) {
        status = 'Upload Successful';
      } else {
        status = 'Error uploading';
      }
    } catch (e) {
      status = e.toString();
    }
    // .catchError( setStatus(erroMessage));
  }
}
