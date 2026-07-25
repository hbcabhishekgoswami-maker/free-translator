import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class SpeechService {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;
  bool _isInitialized = false;

  bool get isListening => _isListening;

  Future<bool> initialize() async {
    _isInitialized = await _speechToText.initialize(
      onError: (error) => print('Speech error: $error'),
      onStatus: (status) => print('Speech status: $status'),
    );
    return _isInitialized;
  }

  Future<void> startListening({
    required Function(String) onResult,
    String localeId = 'en_US',
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_isListening) {
      await stopListening();
    }

    _isListening = true;
    await _speechToText.listen(
      onResult: (result) {
        if (result.recognizedWords.isNotEmpty) {
          onResult(result.recognizedWords);
        }
      },
      localeId: localeId,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
    );
  }

  Future<void> stopListening() async {
    _isListening = false;
    await _speechToText.stop();
  }

  Future<void> speak(String text, {String localeId = 'en_US'}) async {
    await _flutterTts.setLanguage(localeId);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
  }

  String getLocaleId(String langCode) {
    final localeMap = {
      'en': 'en_US',
      'hi': 'hi_IN',
      'es': 'es_ES',
      'fr': 'fr_FR',
      'de': 'de_DE',
      'it': 'it_IT',
      'pt': 'pt_BR',
      'ru': 'ru_RU',
      'ja': 'ja_JP',
      'ko': 'ko_KR',
      'zh': 'zh_CN',
      'ar': 'ar_SA',
      'bn': 'bn_BD',
      'pa': 'pa_IN',
      'ta': 'ta_IN',
      'te': 'te_IN',
      'ml': 'ml_IN',
      'kn': 'kn_IN',
      'gu': 'gu_IN',
      'mr': 'mr_IN',
      'ur': 'ur_PK',
      'th': 'th_TH',
      'vi': 'vi_VN',
      'id': 'id_ID',
      'ms': 'ms_MY',
      'tr': 'tr_TR',
      'nl': 'nl_NL',
      'pl': 'pl_PL',
      'sv': 'sv_SE',
      'da': 'da_DK',
      'fi': 'fi_FI',
      'no': 'nb_NO',
      'uk': 'uk_UA',
      'cs': 'cs_CZ',
      'ro': 'ro_RO',
      'hu': 'hu_HU',
      'el': 'el_GR',
      'he': 'he_IL',
      'fa': 'fa_IR',
      'sw': 'sw_KE',
      'af': 'af_ZA',
      'ca': 'ca_ES',
      'hr': 'hr_HR',
      'sk': 'sk_SK',
      'sl': 'sl_SI',
      'bg': 'bg_BG',
      'et': 'et_EE',
      'lv': 'lv_LV',
      'lt': 'lt_LT',
    };
    return localeMap[langCode] ?? 'en_US';
  }

  void dispose() {
    _speechToText.cancel();
    _flutterTts.stop();
  }
}
