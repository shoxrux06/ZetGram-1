import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/word.dart';
import '../data/words.dart';

enum CardStatus {
  fresh('Yangi'),
  learning('Takrorlash'),
  known('Bilaman');

  const CardStatus(this.label);

  final String label;
}

enum StatusFilter {
  all('Hammasi'),
  fresh('Yangi'),
  learning('Takrorlash'),
  known('Bilaman');

  const StatusFilter(this.label);

  final String label;
}

enum StudyMode { enToUz, uzToEn }

/// Holds the deck, the current card and the learner's progress.
/// Everything is kept on the device with SharedPreferences.
class StudyStore extends ChangeNotifier {
  StudyStore(this._prefs) {
    _load();
    _resolve();
  }

  static const _statusKey = 'devlugat.status.v1';
  static const _uiKey = 'devlugat.ui.v1';

  final SharedPreferences _prefs;
  final Map<String, Word> _byId = {for (final w in kWords) w.id: w};
  final Map<String, CardStatus> _status = {};

  String _category = 'all';
  StatusFilter _filter = StatusFilter.all;
  StudyMode _mode = StudyMode.enToUz;
  bool _shuffle = false;
  ThemeMode _themeMode = ThemeMode.system;
  List<String>? _order;
  String _currentId = kWords.first.id;

  List<Word> _deck = const [];
  int _index = 0;
  bool _flipped = false;

  /// -1 when the last move went backwards, 1 when forwards. Drives the slide direction.
  int lastDirection = 1;

  String get category => _category;
  StatusFilter get filter => _filter;
  StudyMode get mode => _mode;
  bool get shuffle => _shuffle;
  ThemeMode get themeMode => _themeMode;
  bool get flipped => _flipped;
  List<Word> get deck => _deck;
  int get index => _index;
  Word? get current => _deck.isEmpty ? null : _deck[_index];
  String get currentId => _currentId;

  CardStatus statusOf(String id) => _status[id] ?? CardStatus.fresh;

  int countOf(CardStatus s, {String? category}) => kWords
      .where((w) => (category == null || w.category == category) && statusOf(w.id) == s)
      .length;

  int totalIn(String? category) =>
      category == null ? kWords.length : kWords.where((w) => w.category == category).length;

  List<Word> wordsInCategory() =>
      _category == 'all' ? kWords : kWords.where((w) => w.category == _category).toList();

  // ---------- actions ----------

  void flip() {
    if (_deck.isEmpty) return;
    _flipped = !_flipped;
    notifyListeners();
  }

  void go(int dir) {
    if (_deck.isEmpty) return;
    _index = (_index + dir + _deck.length) % _deck.length;
    _currentId = _deck[_index].id;
    lastDirection = dir;
    _flipped = false;
    _saveUi();
    notifyListeners();
  }

  /// Marks the current card and moves on. Returns a short message to show, if any.
  String? mark(CardStatus status) {
    final word = current;
    if (word == null) return null;
    final before = _index;
    if (status == CardStatus.fresh) {
      _status.remove(word.id);
    } else {
      _status[word.id] = status;
    }
    _saveStatus();

    final after = _buildDeck();
    String? message;
    if (after.isEmpty) {
      message = 'Bu filtrdagi barcha so‘zlar belgilandi';
    } else {
      final j = after.indexWhere((w) => w.id == word.id);
      if (j >= 0) {
        if (j + 1 >= after.length) message = 'Bo‘lim oxiriga yetdingiz — boshidan davom etamiz';
        _currentId = after[(j + 1) % after.length].id;
      } else {
        _currentId = after[min(before, after.length - 1)].id;
      }
    }
    lastDirection = 1;
    _flipped = false;
    _resolve();
    _saveUi();
    notifyListeners();
    return message;
  }

  void setCategory(String id) {
    if (id == _category) return;
    _category = id;
    _index = 0;
    _afterFilterChange();
  }

  void setFilter(StatusFilter f) {
    if (f == _filter) return;
    _filter = f;
    _index = 0;
    _afterFilterChange();
  }

  void setMode(StudyMode m) {
    if (m == _mode) return;
    _mode = m;
    _flipped = false;
    _saveUi();
    notifyListeners();
  }

  void toggleShuffle() {
    _shuffle = !_shuffle;
    if (_shuffle) {
      _order = kWords.map((w) => w.id).toList()..shuffle(Random());
      final d = _buildDeck();
      if (d.isNotEmpty) _currentId = d.first.id;
      _index = 0;
    }
    _afterFilterChange();
  }

  void setThemeMode(ThemeMode m) {
    _themeMode = m;
    _saveUi();
    notifyListeners();
  }

  void jumpTo(String id) {
    if (!_byId.containsKey(id)) return;
    if (!_buildDeck().any((w) => w.id == id)) _filter = StatusFilter.all;
    if (_category != 'all' && _byId[id]!.category != _category) _category = 'all';
    _currentId = id;
    lastDirection = 1;
    _afterFilterChange();
  }

  void resetProgress() {
    _status.clear();
    _saveStatus();
    _afterFilterChange();
  }

  // ---------- internals ----------

  void _afterFilterChange() {
    lastDirection = 1;
    _flipped = false;
    _resolve();
    _saveUi();
    notifyListeners();
  }

  List<Word> _buildDeck() {
    var list = kWords.where((w) {
      final inCat = _category == 'all' || w.category == _category;
      final inFilter = switch (_filter) {
        StatusFilter.all => true,
        StatusFilter.fresh => statusOf(w.id) == CardStatus.fresh,
        StatusFilter.learning => statusOf(w.id) == CardStatus.learning,
        StatusFilter.known => statusOf(w.id) == CardStatus.known,
      };
      return inCat && inFilter;
    }).toList();
    final order = _order;
    if (_shuffle && order != null) {
      final pos = {for (var i = 0; i < order.length; i++) order[i]: i};
      list.sort((a, b) => (pos[a.id] ?? 0).compareTo(pos[b.id] ?? 0));
    }
    return list;
  }

  void _resolve() {
    _deck = _buildDeck();
    if (_deck.isEmpty) {
      _index = 0;
      return;
    }
    final i = _deck.indexWhere((w) => w.id == _currentId);
    if (i >= 0) {
      _index = i;
    } else {
      _index = min(_index, _deck.length - 1);
      _currentId = _deck[_index].id;
    }
  }

  void _load() {
    try {
      final raw = _prefs.getString(_statusKey);
      if (raw != null) {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        map.forEach((id, v) {
          if (!_byId.containsKey(id)) return;
          if (v == 'known') _status[id] = CardStatus.known;
          if (v == 'learning') _status[id] = CardStatus.learning;
        });
      }
    } catch (_) {
      // Corrupt data: start fresh rather than crash.
    }
    try {
      final raw = _prefs.getString(_uiKey);
      if (raw == null) return;
      final m = jsonDecode(raw) as Map<String, dynamic>;
      final cat = m['category'];
      if (cat == 'all' || kCategories.any((c) => c.id == cat)) _category = cat as String;
      _filter = StatusFilter.values.firstWhere((f) => f.name == m['filter'], orElse: () => StatusFilter.all);
      _mode = m['mode'] == 'uzToEn' ? StudyMode.uzToEn : StudyMode.enToUz;
      _themeMode = ThemeMode.values.firstWhere((t) => t.name == m['theme'], orElse: () => ThemeMode.system);
      final order = (m['order'] as List?)?.cast<String>();
      if (order != null && order.length == kWords.length && order.every(_byId.containsKey)) {
        _order = order;
        _shuffle = m['shuffle'] == true;
      }
      final id = m['current'];
      if (id is String && _byId.containsKey(id)) _currentId = id;
    } catch (_) {
      // Ignore bad preferences.
    }
  }

  void _saveStatus() {
    _prefs.setString(
      _statusKey,
      jsonEncode({for (final e in _status.entries) e.key: e.value.name}),
    );
  }

  void _saveUi() {
    _prefs.setString(
      _uiKey,
      jsonEncode({
        'category': _category,
        'filter': _filter.name,
        'mode': _mode.name,
        'theme': _themeMode.name,
        'shuffle': _shuffle,
        'order': _order,
        'current': _currentId,
      }),
    );
  }
}
