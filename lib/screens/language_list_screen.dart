import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../widgets/language_tile.dart';
import '../models/language.dart'; // ใช้สำหรับ seed ตัวอย่าง
import 'add_edit_language_screen.dart';

class LanguageListScreen extends StatefulWidget {
  const LanguageListScreen({super.key});

  @override
  State<LanguageListScreen> createState() => _LanguageListScreenState();
}

class _LanguageListScreenState extends State<LanguageListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // โหลดข้อมูลเมื่อเปิดหน้าจอครั้งแรก
    Future.microtask(() => context.read<LanguageProvider>().load());
  }

  // ฟังก์ชันเพิ่มข้อมูลตัวอย่าง (กันซ้ำให้อัตโนมัติ)
  Future<void> _seedSamples(BuildContext context) async {
    final prov = context.read<LanguageProvider>();
    final now = DateTime.now().millisecondsSinceEpoch;
    final samples = <Language>[
      Language(name: 'Thai',     isoCode: 'th', nativeName: 'ไทย',    script: 'Thai',       createdAt: now),
      Language(name: 'English',  isoCode: 'en', nativeName: 'English', script: 'Latin',      createdAt: now + 1),
      Language(name: 'Japanese', isoCode: 'ja', nativeName: '日本語',    script: 'Kanji/Kana', createdAt: now + 2),
      Language(name: 'Korean',   isoCode: 'ko', nativeName: '한국어',    script: 'Hangul',     createdAt: now + 3),
      Language(name: 'Chinese',  isoCode: 'zh', nativeName: '中文',     script: 'Han',        createdAt: now + 4),
    ];

    for (final s in samples) {
      final exists = await prov.existsNameOrIso(s.name, s.isoCode);
      if (!exists) {
        await prov.add(s);
      }
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ใส่ข้อมูลตัวอย่างเรียบร้อย')),
    );
  }

  Future<void> _confirmAndDelete(Language lang) async {
    final prov = context.read<LanguageProvider>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('ต้องการลบ "${lang.name} (${lang.isoCode})" ใช่ไหม?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ยกเลิก')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('ลบ')),
        ],
      ),
    );
    if (ok == true) {
      await prov.remove(lang);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('ลบแล้ว'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () async {
              await prov.add(lang.copyWith(id: null));
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<LanguageProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Languages'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'name' || v == 'createdAt') {
                prov.updateQuery(sortBy: v);
              } else if (v == 'toggle') {
                prov.updateQuery(asc: !prov.asc); // ใช้ getter asc
              } else if (v == 'seed') {
                _seedSamples(context); // เพิ่มข้อมูลตัวอย่าง
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'name', child: Text('Sort by Name')),
              PopupMenuItem(value: 'createdAt', child: Text('Sort by CreatedAt')),
              PopupMenuItem(value: 'toggle', child: Text('Toggle ASC/DESC')),
              PopupMenuItem(value: 'seed', child: Text('Insert Sample Data')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // ช่องค้นหา
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'ค้นหา name / iso / native',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchCtrl.clear();
                    prov.updateQuery(search: '');
                  },
                ),
              ),
              onChanged: (v) => prov.updateQuery(search: v),
            ),
          ),
          // แสดงรายการภาษา
          Expanded(
            child: ListView.builder(
              itemCount: prov.items.length,
              itemBuilder: (context, i) {
                final lang = prov.items[i];
                return Dismissible(
                  key: ValueKey(lang.id ?? lang.name),
                  background: Container(
                    color: Colors.redAccent,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) async {
                    await prov.remove(lang);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('ลบแล้ว'),
                        action: SnackBarAction(
                          label: 'UNDO',
                          onPressed: () async {
                            await prov.add(lang.copyWith(id: null));
                          },
                        ),
                      ),
                    );
                  },
                  child: LanguageTile(
                    language: lang,
                    onEdit: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddEditLanguageScreen(language: lang),
                        ),
                      );
                    },
                    onDelete: () => _confirmAndDelete(lang), // ปุ่มลบแบบกด + dialog ยืนยัน
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddEditLanguageScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
