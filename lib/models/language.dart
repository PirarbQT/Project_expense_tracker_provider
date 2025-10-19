class Language {
  final int? id;
  final String name;
  final String isoCode;
  final String? nativeName;
  final String? script;
  final int createdAt;

  Language({
    this.id,
    required this.name,
    required this.isoCode,
    this.nativeName,
    this.script,
    required this.createdAt,
  });

  Language copyWith({
    int? id,
    String? name,
    String? isoCode,
    String? nativeName,
    String? script,
    int? createdAt,
  }) {
    return Language(
      id: id ?? this.id,
      name: name ?? this.name,
      isoCode: isoCode ?? this.isoCode,
      nativeName: nativeName ?? this.nativeName,
      script: script ?? this.script,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Language.fromMap(Map<String, dynamic> map) => Language(
        id: map['id'] as int?,
        name: map['name'] as String,
        isoCode: map['isoCode'] as String,
        nativeName: map['nativeName'] as String?,
        script: map['script'] as String?,
        createdAt: map['createdAt'] as int,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'isoCode': isoCode,
        'nativeName': nativeName,
        'script': script,
        'createdAt': createdAt,
      };
}
