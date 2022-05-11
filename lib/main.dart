import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ImagePicker _picker = ImagePicker();
  File? _pickedImage;
  Image? _predictedImage;
  bool isLoading = false;

  void startLoading() {
    setState(() {
      isLoading = true;
    });
  }

  void endLoading() {
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('機械学習'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _pickedImage == null
                ? Container(
                    width: 400,
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  )
                : Container(
                    width: 400,
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.asset(
                      _pickedImage!.path,
                    ),
                  ),
            const SizedBox(height: 10),
            _predictedImage == null
                ? Container(
                    width: 400,
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Center(child: SizedBox()),
                  )
                : Container(
                    width: 400,
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image(image: _predictedImage!.image),
                  ),
            ElevatedButton(
              onPressed: () async {
                final pickedFile =
                    await _picker.pickImage(source: ImageSource.gallery);
                if (pickedFile == null) {
                  return;
                }
                setState(() {
                  _pickedImage = File(pickedFile.path);
                });
              },
              child: const Text('選ぶ'),
            ),
            ElevatedButton(
              onPressed: () async {
                startLoading();
                //file -> base64
                List<int> imageBytes = _pickedImage!.readAsBytesSync();
                String base64Image = base64Encode(imageBytes);
                Uri url = Uri.parse('http://127.0.0.1:5000/trimming');
                String body = json.encode({
                  'post_img': base64Image,
                });

                //send to backend
                Response response = await http.post(url, body: body);

                //base64 -> file
                final data = json.decode(response.body);
                String imageBase64 = data['result'];
                Uint8List bytes = base64Decode(imageBase64);
                Image image = Image.memory(bytes);
                setState(() {
                  _predictedImage = image;
                });

                endLoading();
              },
              child: const Text('送る'),
            ),
          ],
        ),
      ),
    );
  }
}
