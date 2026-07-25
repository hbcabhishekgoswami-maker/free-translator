import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import '../models/language_model.dart';

class SupportedLanguages {
  static const List<AppLanguage> languages = [
    AppLanguage(code: 'af', name: 'Afrikaans', nativeName: 'Afrikaans'),
    AppLanguage(code: 'sq', name: 'Albanian', nativeName: 'Shqip'),
    AppLanguage(code: 'am', name: 'Amharic', nativeName: 'አማርኛ'),
    AppLanguage(code: 'ar', name: 'Arabic', nativeName: 'العربية'),
    AppLanguage(code: 'hy', name: 'Armenian', nativeName: 'Հայերեն'),
    AppLanguage(code: 'az', name: 'Azerbaijani', nativeName: 'Azərbaycan'),
    AppLanguage(code: 'eu', name: 'Basque', nativeName: 'Euskara'),
    AppLanguage(code: 'be', name: 'Belarusian', nativeName: 'Беларуская'),
    AppLanguage(code: 'bn', name: 'Bengali', nativeName: 'বাংলা'),
    AppLanguage(code: 'bg', name: 'Bulgarian', nativeName: 'Български'),
    AppLanguage(code: 'my', name: 'Burmese', nativeName: 'မြန်မာ'),
    AppLanguage(code: 'ca', name: 'Catalan', nativeName: 'Català'),
    AppLanguage(code: 'zh', name: 'Chinese', nativeName: '中文'),
    AppLanguage(code: 'hr', name: 'Croatian', nativeName: 'Hrvatski'),
    AppLanguage(code: 'cs', name: 'Czech', nativeName: 'Čeština'),
    AppLanguage(code: 'da', name: 'Danish', nativeName: 'Dansk'),
    AppLanguage(code: 'nl', name: 'Dutch', nativeName: 'Nederlands'),
    AppLanguage(code: 'en', name: 'English', nativeName: 'English'),
    AppLanguage(code: 'et', name: 'Estonian', nativeName: 'Eesti'),
    AppLanguage(code: 'fil', name: 'Filipino', nativeName: 'Filipino'),
    AppLanguage(code: 'fi', name: 'Finnish', nativeName: 'Suomi'),
    AppLanguage(code: 'fr', name: 'French', nativeName: 'Français'),
    AppLanguage(code: 'gl', name: 'Galician', nativeName: 'Galego'),
    AppLanguage(code: 'ka', name: 'Georgian', nativeName: 'ქართული'),
    AppLanguage(code: 'de', name: 'German', nativeName: 'Deutsch'),
    AppLanguage(code: 'el', name: 'Greek', nativeName: 'Ελληνικά'),
    AppLanguage(code: 'gu', name: 'Gujarati', nativeName: 'ગુજરાતી'),
    AppLanguage(code: 'he', name: 'Hebrew', nativeName: 'עברית'),
    AppLanguage(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी'),
    AppLanguage(code: 'hu', name: 'Hungarian', nativeName: 'Magyar'),
    AppLanguage(code: 'is', name: 'Icelandic', nativeName: 'Íslenska'),
    AppLanguage(code: 'id', name: 'Indonesian', nativeName: 'Bahasa Indonesia'),
    AppLanguage(code: 'ga', name: 'Irish', nativeName: 'Gaeilge'),
    AppLanguage(code: 'it', name: 'Italian', nativeName: 'Italiano'),
    AppLanguage(code: 'ja', name: 'Japanese', nativeName: '日本語'),
    AppLanguage(code: 'kn', name: 'Kannada', nativeName: 'ಕನ್ನಡ'),
    AppLanguage(code: 'kk', name: 'Kazakh', nativeName: 'Қазақ'),
    AppLanguage(code: 'km', name: 'Khmer', nativeName: 'ភាសាខ្មែរ'),
    AppLanguage(code: 'ko', name: 'Korean', nativeName: '한국어'),
    AppLanguage(code: 'ky', name: 'Kyrgyz', nativeName: 'Кыргызча'),
    AppLanguage(code: 'lo', name: 'Lao', nativeName: 'ລາວ'),
    AppLanguage(code: 'lv', name: 'Latvian', nativeName: 'Latviešu'),
    AppLanguage(code: 'lt', name: 'Lithuanian', nativeName: 'Lietuvių'),
    AppLanguage(code: 'mk', name: 'Macedonian', nativeName: 'Македонски'),
    AppLanguage(code: 'ms', name: 'Malay', nativeName: 'Bahasa Melayu'),
    AppLanguage(code: 'ml', name: 'Malayalam', nativeName: 'മലയാളം'),
    AppLanguage(code: 'mr', name: 'Marathi', nativeName: 'मराठी'),
    AppLanguage(code: 'mn', name: 'Mongolian', nativeName: 'Монгол'),
    AppLanguage(code: 'ne', name: 'Nepali', nativeName: 'नेपाली'),
    AppLanguage(code: 'no', name: 'Norwegian', nativeName: 'Norsk'),
    AppLanguage(code: 'fa', name: 'Persian', nativeName: 'فارسی'),
    AppLanguage(code: 'pl', name: 'Polish', nativeName: 'Polski'),
    AppLanguage(code: 'pt', name: 'Portuguese', nativeName: 'Português'),
    AppLanguage(code: 'pa', name: 'Punjabi', nativeName: 'ਪੰਜਾਬੀ'),
    AppLanguage(code: 'ro', name: 'Romanian', nativeName: 'Română'),
    AppLanguage(code: 'ru', name: 'Russian', nativeName: 'Русский'),
    AppLanguage(code: 'sr', name: 'Serbian', nativeName: 'Српски'),
    AppLanguage(code: 'si', name: 'Sinhala', nativeName: 'සිංහල'),
    AppLanguage(code: 'sk', name: 'Slovak', nativeName: 'Slovenčina'),
    AppLanguage(code: 'sl', name: 'Slovenian', nativeName: 'Slovenščina'),
    AppLanguage(code: 'es', name: 'Spanish', nativeName: 'Español'),
    AppLanguage(code: 'sw', name: 'Swahili', nativeName: 'Kiswahili'),
    AppLanguage(code: 'sv', name: 'Swedish', nativeName: 'Svenska'),
    AppLanguage(code: 'ta', name: 'Tamil', nativeName: 'தமிழ்'),
    AppLanguage(code: 'te', name: 'Telugu', nativeName: 'తెలుగు'),
    AppLanguage(code: 'th', name: 'Thai', nativeName: 'ไทย'),
    AppLanguage(code: 'tr', name: 'Turkish', nativeName: 'Türkçe'),
    AppLanguage(code: 'uk', name: 'Ukrainian', nativeName: 'Українська'),
    AppLanguage(code: 'ur', name: 'Urdu', nativeName: 'اردو'),
    AppLanguage(code: 'uz', name: 'Uzbek', nativeName: 'Oʻzbek'),
    AppLanguage(code: 'vi', name: 'Vietnamese', nativeName: 'Tiếng Việt'),
    AppLanguage(code: 'cy', name: 'Welsh', nativeName: 'Cymraeg'),
  ];

  static TranslateLanguage? getMlKitLanguage(String code) {
    try {
      return TranslateLanguage.values.firstWhere(
        (lang) => lang.bcpCode == code,
      );
    } catch (_) {
      return null;
    }
  }

  static List<AppLanguage> getAvailableLanguages() {
    final mlKitCodes = TranslateLanguage.values.map((e) => e.bcpCode).toList();
    return languages.where((lang) => mlKitCodes.contains(lang.code)).toList();
  }

  static String getLanguageName(String code) {
    try {
      return languages.firstWhere((lang) => lang.code == code).name;
    } catch (_) {
      return code.toUpperCase();
    }
  }
}
