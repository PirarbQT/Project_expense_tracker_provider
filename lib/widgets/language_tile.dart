// lib/widgets/language_tile.dart
import 'package:flutter/material.dart';
import '../models/language.dart';

class LanguageTile extends StatelessWidget {
  final Language language;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete; //  เพิ่ม callback ลบ

  const LanguageTile({
    super.key,
    required this.language,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final subtitleParts = <String>[
      if ((language.nativeName ?? '').trim().isNotEmpty) language.nativeName!.trim(),
      if ((language.script ?? '').trim().isNotEmpty) language.script!.trim(),
    ];

    return ListTile(
      title: Text('${language.name} (${language.isoCode})'),
      subtitle: subtitleParts.isEmpty ? null : Text(subtitleParts.join(' • ')),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'แก้ไข',
            icon: const Icon(Icons.edit),
            onPressed: onEdit,
          ),
          IconButton(
            tooltip: 'ลบ',
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete, //  กดเพื่อลบ
          ),
        ],
      ),
    );
  }
}
