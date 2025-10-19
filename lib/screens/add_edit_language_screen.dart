import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/language.dart';
import '../providers/language_provider.dart';
import '../utils/validators.dart';

class AddEditLanguageScreen extends StatefulWidget {
  final Language? language;
  const AddEditLanguageScreen({super.key, this.language});

  @override
  State<AddEditLanguageScreen> createState() => _AddEditLanguageScreenState();
}

class _AddEditLanguageScreenState extends State<AddEditLanguageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _iso = TextEditingController();
  final _native = TextEditingController();
  final _script = TextEditingController();

  @override
  void initState() {
    super.initState();
    final l = widget.language;
    if (l != null) {
      _name.text = l.name;
      _iso.text = l.isoCode;
      _native.text = l.nativeName ?? '';
      _script.text = l.script ?? '';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final prov = context.read<LanguageProvider>();

    final exists = await prov.existsNameOrIso(
      _name.text.trim(),
      _iso.text.trim(),
      excludeId: widget.language?.id,
    );
    if (exists) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('ชื่อหรือรหัส ISO ซ้ำ')));
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final lang = Language(
      id: widget.language?.id,
      name: _name.text.trim(),
      isoCode: _iso.text.trim(),
      nativeName:
          _native.text.trim().isEmpty ? null : _native.text.trim(),
      script: _script.text.trim().isEmpty ? null : _script.text.trim(),
      createdAt: widget.language?.createdAt ?? now,
    );

    if (widget.language == null) {
      await prov.add(lang);
    } else {
      await prov.edit(lang);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.language != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'แก้ไขภาษา' : 'เพิ่มภาษา')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _name,
                decoration:
                    const InputDecoration(labelText: 'ชื่อภาษา (name)'),
                validator: (v) =>
                    LangValidators.requiredText(v, label: 'ชื่อภาษา'),
              ),
              TextFormField(
                controller: _iso,
                decoration: const InputDecoration(
                    labelText: 'รหัส ISO (2–3 ตัวอักษร)'),
                validator: LangValidators.isoCode,
              ),
              TextFormField(
                controller: _native,
                decoration: const InputDecoration(
                    labelText: 'ชื่อภาษาแบบ native (optional)'),
              ),
              TextFormField(
                controller: _script,
                decoration:
                    const InputDecoration(labelText: 'ระบบอักษร (optional)'),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _save,
                child: Text(isEdit ? 'บันทึกการแก้ไข' : 'บันทึก'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
