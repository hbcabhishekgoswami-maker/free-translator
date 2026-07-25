import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<String> recognizeTextFromFile(String filePath) async {
    final inputImage = InputImage.fromFilePath(filePath);
    final recognizedText = await _textRecognizer.processImage(inputImage);
    return recognizedText.text;
  }

  Future<String> recognizeTextFromImage(InputImage inputImage) async {
    final recognizedText = await _textRecognizer.processImage(inputImage);
    return recognizedText.text;
  }

  void close() {
    _textRecognizer.close();
  }
}
