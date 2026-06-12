import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'voice_page7.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:record/record.dart';
import 'package:dio/dio.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CucumberScreen extends StatefulWidget {
  const CucumberScreen({super.key});

  @override
  State<CucumberScreen> createState() => _CucumberScreenState();
}

class _CucumberScreenState extends State<CucumberScreen> {
  final FlutterTts tts = FlutterTts();
  final AudioRecorder recorder = AudioRecorder();

  StreamSubscription<Uint8List>? recordingSubscription;

  final List<int> pcmAudioBytes = [];

  Uint8List? recordedWavBytes;

  bool isRecording = false;
  bool isUploading = false;

  String statusText = "Press Play Sound";

  static const int apiChildId = 4;

  // غيّري الرقم لو Cucumber في Swagger له ID مختلف
  static const int apiContentItemId = 10;

  Future<void> speakCucumber() async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.5);
    await tts.setPitch(1.0);
    await tts.speak("Cucumber");
  }

  Future<void> startRecording() async {
    final hasPermission = await recorder.hasPermission();

    if (!hasPermission) {
      showMessage("Microphone permission denied");
      return;
    }

    pcmAudioBytes.clear();
    recordedWavBytes = null;

    final stream = await recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
        autoGain: true,
        echoCancel: true,
        noiseSuppress: true,
      ),
    );

    recordingSubscription = stream.listen((data) {
      pcmAudioBytes.addAll(data);
    });

    setState(() {
      isRecording = true;
      statusText = "Recording... say Cucumber";
    });

    debugPrint("Recording Started");
  }

  Future<void> stopRecording() async {
    if (!isRecording) return;

    await recorder.stop();
    await recordingSubscription?.cancel();
    recordingSubscription = null;

    if (pcmAudioBytes.isEmpty) {
      setState(() {
        isRecording = false;
        statusText = "No audio recorded";
      });

      showMessage("No audio recorded");
      return;
    }

    recordedWavBytes = buildWavFile(
      pcmData: Uint8List.fromList(pcmAudioBytes),
      sampleRate: 16000,
      numChannels: 1,
      bitsPerSample: 16,
    );

    setState(() {
      isRecording = false;
      statusText = "Recording saved. Ready to upload.";
    });

    debugPrint("Recording Stopped");
    debugPrint("WAV bytes length: ${recordedWavBytes!.length}");
  }

  Future<void> uploadAudio() async {
    if (recordedWavBytes == null) {
      showMessage("Please record audio first");
      return;
    }

    try {
      setState(() {
        isUploading = true;
        statusText = "Uploading to API...";
      });

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("No logged-in user found");
      }

      final dio = Dio();

      final formData = FormData.fromMap({
        "ChildId": apiChildId,
        "ContentItemId": apiContentItemId,
        "File": MultipartFile.fromBytes(
          recordedWavBytes!,
          filename: "cucumber.wav",
        ),
      });

      final response = await dio.post(
        "http://localhost:5210/api/Attempts",
        data: formData,
      );

      debugPrint("API Response: ${response.data}");

      final dynamic responseData = response.data;

      Map<String, dynamic> data;

      if (responseData is String) {
        data = jsonDecode(responseData) as Map<String, dynamic>;
      } else {
        data = Map<String, dynamic>.from(responseData as Map);
      }

      final num similarityValue = data["similarity"] ?? 0;
      final int accuracy = similarityValue.round();

      final bool success = data["success"] == true;
      final String recognizedText = data["recognizedText"]?.toString() ?? "";

      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        "pronunciationAccuracy": accuracy,
      }, SetOptions(merge: true));

      if (!mounted) return;

      setState(() {
        statusText = "Recognized: $recognizedText\nAccuracy: $accuracy%";
      });

      showMessage(
        success ? "Good pronunciation: $accuracy%" : "Try again: $accuracy%",
      );
    } catch (e) {
      debugPrint("Upload Error: $e");

      if (!mounted) return;

      setState(() {
        statusText = "Upload failed";
      });

      showMessage("Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  Uint8List buildWavFile({
    required Uint8List pcmData,
    required int sampleRate,
    required int numChannels,
    required int bitsPerSample,
  }) {
    final int byteRate = sampleRate * numChannels * bitsPerSample ~/ 8;
    final int blockAlign = numChannels * bitsPerSample ~/ 8;
    final int dataSize = pcmData.length;
    final int chunkSize = 36 + dataSize;

    final bytes = BytesBuilder();

    void writeString(String value) {
      bytes.add(ascii.encode(value));
    }

    void writeUint16(int value) {
      final data = ByteData(2);
      data.setUint16(0, value, Endian.little);
      bytes.add(data.buffer.asUint8List());
    }

    void writeUint32(int value) {
      final data = ByteData(4);
      data.setUint32(0, value, Endian.little);
      bytes.add(data.buffer.asUint8List());
    }

    writeString("RIFF");
    writeUint32(chunkSize);
    writeString("WAVE");

    writeString("fmt ");
    writeUint32(16);
    writeUint16(1);
    writeUint16(numChannels);
    writeUint32(sampleRate);
    writeUint32(byteRate);
    writeUint16(blockAlign);
    writeUint16(bitsPerSample);

    writeString("data");
    writeUint32(dataSize);
    bytes.add(pcmData);

    return bytes.toBytes();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  void dispose() {
    tts.stop();
    recorder.dispose();
    recordingSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // صورة الخيار
                ElevatedButton(
                  onPressed: () {
                    // لو عايزة الصورة كمان تنطق Cucumber اكتبي هنا:
                    // speakCucumber();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/cucumber.jpg',
                      width: 280,
                      height: 280,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 280,
                          height: 280,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 80),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // اسم العنصر
                TextButton(
                  onPressed: () {
                    // لو عايزة الكلمة كمان تنطق Cucumber اكتبي هنا:
                    // speakCucumber();
                  },
                  child: const Text(
                    'The Cucumber',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  statusText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),

                const SizedBox(height: 20),

                // زرار Play sound ينطق Cucumber
                SizedBox(
                  width: 250,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: speakCucumber,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6FB8C7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Play sound',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                SizedBox(
                  width: 250,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: isRecording ? null : startRecording,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E9CCA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Start Recording',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                SizedBox(
                  width: 250,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: isRecording ? stopRecording : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Stop Recording',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                SizedBox(
                  width: 250,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: isUploading ? null : uploadAudio,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      isUploading ? 'Uploading...' : 'Upload To API',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // زر Back
                    SizedBox(
                      width: 100,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E9CCA),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Back',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),

                    // زر Next
                    SizedBox(
                      width: 100,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FishScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E9CCA),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Next',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
