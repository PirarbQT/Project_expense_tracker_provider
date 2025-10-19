import 'package:flutter/foundation.dart';
import '../db/language_dao.dart';
import '../models/language.dart';

class LanguageProvider extends ChangeNotifier {
  final _dao = LanguageDao();
  List<Language> _items = [];
  String _search = '';
  String _sortBy = 'name';
  bool _asc = true;

  List<Language> get items => _items;
  String get search => _search;
  String get sortBy => _sortBy;
  bool get asc => _asc;

  Future<void> load() async {
    _items = await _dao.getAll(search: _search, sortBy: _sortBy, asc: _asc);
    notifyListeners();
  }

  void updateQuery({String? search, String? sortBy, bool? asc}) {
    if (search != null) _search = search;
    if (sortBy != null) _sortBy = sortBy;
    if (asc != null) _asc = asc;
    load();
  }

  Future<void> add(Language lang) async {
    await _dao.insert(lang);
    await load();
  }

  Future<void> edit(Language lang) async {
    await _dao.update(lang);
    await load();
  }

  Future<void> remove(Language lang) async {
    if (lang.id == null) return;
    await _dao.delete(lang.id!);
    await load();
  }

  Future<bool> existsNameOrIso(String name, String iso, {int? excludeId}) =>
      _dao.existsByNameOrIso(name, iso, excludeId: excludeId);
}
