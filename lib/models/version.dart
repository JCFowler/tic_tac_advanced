class Version {
  String version;
  String link;

  Version(this.version, this.link);

  static Version toObject(Map<String, dynamic> map) {
    return (Version(map['version'], map['link']));
  }

  bool isVersionNumberGreater(String version2) {
    final v1 = int.parse(version.replaceAll('.', ''));
    final v2 = int.parse(version2.replaceAll('.', ''));

    return v1 > v2;
  }
}
