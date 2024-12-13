import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechToTextExample extends StatefulWidget {
  @override
  _SpeechToTextExampleState createState() => _SpeechToTextExampleState();
}

class _SpeechToTextExampleState extends State<SpeechToTextExample> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'برای ضبط بر روی میکروفون ضربه بزنید';
  double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('Status: $status'),
      onError: (error) => print('Error: $error'),
    );
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            _text = result.recognizedWords;
            if (result.hasConfidenceRating && result.confidence > 0) {
              _confidence = result.confidence;
            }
          });
        },
        localeId: 'fa-IR', // Persian locale
      );
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ذخیره صدا'),
        backgroundColor: Color(0x1A237E),
        centerTitle: true,
        elevation: 5,
      ),
      body: Column(
        children: [
          // Header with confidence and status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            decoration: BoxDecoration(
              color: Color(0x1A237E),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                Text(
                  "Confidence: ${(_confidence * 100).toStringAsFixed(1)}%",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                IconButton(
                  onPressed: _isListening ? _stopListening : _startListening,
                  icon: Icon(
                    _isListening ? Icons.stop : Icons.mic,
                    size: 50,
                    color: Colors.blue,
                  ),
                  tooltip: _isListening ? 'Stop Listening' : 'Start Listening',
                ),
              ],
            ),
          ),
          // Text display container
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20.0),
              margin: const EdgeInsets.all(36.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Text(
                  _text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 18.0,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
