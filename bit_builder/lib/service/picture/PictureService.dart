import 'dart:typed_data';
import 'dart:io';
import 'dart:convert'; // <-- Import for jsonDecode
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late List<CameraDescription> cameras;
  bool isCameraInitialized = false;
  bool isFaceNew = false; // Track if face is new
  String userName = ''; // Track the user name
  String _faceRecognitionOutput =
      "Awaiting result..."; // For displaying results

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    if (await Permission.camera.request().isGranted) {
      cameras = await availableCameras();
      _controller = CameraController(cameras[0], ResolutionPreset.medium);
      await _controller.initialize();
      setState(() {
        isCameraInitialized = true;
      });
    } else {
      print('Camera permission denied');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _captureAndProcessPhoto() async {
    try {
      // Capture the photo
      XFile picture = await _controller.takePicture();
      File imageFile = File(picture.path);

      print("Image captured: ${imageFile.path}");

      // Convert the image to bytes
      Uint8List imageBytes = await imageFile.readAsBytes();

      // Step 1: Check the face
      bool faceValid = await _checkFace(imageBytes);

      if (faceValid) {
        if (isFaceNew) {
          // If face is new, prompt user for name
          _showNameDialog(imageBytes);
        } else {
          // If face is duplicate and we already displayed the name in _checkFace, no need to save
          // or prompt again.
          // The logic inside _checkFace will have already updated _faceRecognitionOutput accordingly.
        }
      } else {
        print("Face check failed. Not saving the image.");
      }
    } catch (e) {
      print("Error during face check or save: $e");
      setState(() {
        _faceRecognitionOutput = "Error during face check or save: $e";
      });
    }
  }

  Future<bool> _checkFace(Uint8List imageBytes) async {
    try {
      var uri = Uri.parse("http://192.168.203.26:8080/check-face/");
      var request = http.MultipartRequest('POST', uri)
        ..files.add(http.MultipartFile.fromBytes('file', imageBytes,
            filename: 'check_face.jpg'));

      var response = await request.send();
      if (response.statusCode == 200) {
        print("Face check successful!");
        final responseData = await response.stream.bytesToString();
        print("Check response: $responseData");

        // Decode the JSON response
        final Map<String, dynamic> decoded = jsonDecode(responseData);

        // Check status field in JSON
        if (decoded['status'] == 'unique') {
          // This is a new face
          setState(() {
            isFaceNew = true;
            _faceRecognitionOutput = "New face detected, please enter a name.";
          });
        } else if (decoded['status'] == 'duplicate') {
          // This is a duplicate face
          String existingName = decoded['existing_name'] ?? 'Unknown';
          setState(() {
            isFaceNew = false; // Face is not new
            _faceRecognitionOutput = "Face already exists as $existingName.";
          });
        } else {
          // Handle other statuses if any
          setState(() {
            _faceRecognitionOutput = "Unknown status returned.";
          });
        }

        return true;
      } else {
        print("Face check failed: ${response.statusCode}");
        setState(() {
          _faceRecognitionOutput = "Face check failed: ${response.statusCode}";
        });
        return false;
      }
    } catch (e) {
      print("Error during face check: $e");
      setState(() {
        _faceRecognitionOutput = "Error during face check: $e";
      });
      return false;
    }
  }

  Future<void> _saveFace(Uint8List imageBytes, String name) async {
    try {
      var uri = Uri.parse("http://192.168.203.26:8080/save-face/");
      var request = http.MultipartRequest('POST', uri)
        ..fields['name'] = name
        ..files.add(http.MultipartFile.fromBytes('file', imageBytes,
            filename: 'save_face.jpg'));

      var response = await request.send();
      if (response.statusCode == 200) {
        print("Face successfully saved!");
        final responseData = await response.stream.bytesToString();
        print("Save response: $responseData");

        setState(() {
          _faceRecognitionOutput = "Face Saved Successfully: $name";
        });
      } else {
        print("Failed to save face: ${response.statusCode}");
        setState(() {
          _faceRecognitionOutput =
              "Failed to save face: ${response.statusCode}";
        });
      }
    } catch (e) {
      print("Error during face save: $e");
      setState(() {
        _faceRecognitionOutput = "Error during face save: $e";
      });
    }
  }

  Future<void> _showNameDialog(Uint8List imageBytes) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Enter Your Name',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 15),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      userName = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Your name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (userName.isNotEmpty) {
                          _saveFace(imageBytes, userName);
                        } else {
                          print("Name cannot be empty");
                          setState(() {
                            _faceRecognitionOutput = "Name cannot be empty!";
                          });
                        }
                      },
                      child: Text('Save'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        print("Name entry canceled");
                      },
                      child: Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Check and Save Face'),
        backgroundColor: Color(0x1A237E),
        centerTitle: true,
        elevation: 5,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isCameraInitialized)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: CameraPreview(_controller),
              ),
            )
          else
            CircularProgressIndicator(),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _captureAndProcessPhoto,
            icon: Icon(Icons.camera_alt),
            label: Text('Capture and Process Photo'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Color(0x1A237E),
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              _faceRecognitionOutput,
              style: TextStyle(fontSize: 16, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
