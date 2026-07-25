class AppLanguage {
  final String code;
  final String name;
  final String nativeName;
  final bool isDownloaded;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    this.isDownloaded = false,
  });

  AppLanguage copyWith({bool? isDownloaded}) {
    return AppLanguage(
      code: code,
      name: name,
      nativeName: nativeName,
      isDownloaded: isDownloaded ?? this.isDownloaded,
    );
  }
}
