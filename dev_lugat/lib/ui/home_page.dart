import 'package:flutter/cupertino.dart' show CupertinoDialogAction;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/word.dart';
import '../data/words.dart';
import '../services/speech.dart';
import '../state/study_store.dart';
import 'flash_card.dart';
import 'palette.dart';
import 'word_list_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.store, required this.speech});

  final StudyStore store;
  final Speech speech;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StudyStore get store => widget.store;

  void _toast(String? message) {
    if (message == null || !mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), duration: const Duration(milliseconds: 1800)));
  }

  Future<void> _speak(String text, {bool slow = false}) async {
    final ok = await widget.speech.say(text, slow: slow);
    if (!ok) _toast('Ovozni ijro etib bo‘lmadi. Telefon ovozini tekshiring.');
  }

  void _mark(CardStatus status) {
    HapticFeedback.selectionClick();
    _toast(store.mark(status));
  }

  Future<void> _confirmReset() async {
    final ok = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text('Progressni tozalash'),
        content: const Text('Barcha “Bilaman” va “Takrorlash” belgilari o‘chiriladi.'),
        actions: [
          adaptiveAction(context, 'Bekor qilish', () => Navigator.pop(context, false)),
          adaptiveAction(context, 'Tozalash', () => Navigator.pop(context, true), destructive: true),
        ],
      ),
    );
    if (ok == true) {
      store.resetProgress();
      _toast('Progress tozalandi');
    }
  }

  void _openList() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => WordListSheet(store: store),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _Header(onList: _openList, onReset: _confirmReset, store: store),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _Summary(store: store),
                ),
                const SizedBox(height: 12),
                _CategoryRow(store: store),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _FilterRow(store: store),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _CardArea(store: store, onSpeak: _speak),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.paddingOf(context).bottom + 10),
                  child: Column(
                    children: [
                      _Controls(store: store, onMark: _mark),
                      const SizedBox(height: 8),
                      Text(
                        'Bosing — ag‘darish · chapga/o‘ngga suring — o‘tish',
                        style: TextStyle(fontFamily: kMono, fontSize: 10.5, color: p.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget adaptiveAction(BuildContext context, String label, VoidCallback onPressed, {bool destructive = false}) {
  final platform = Theme.of(context).platform;
  if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
    return CupertinoDialogAction(isDestructiveAction: destructive, onPressed: onPressed, child: Text(label));
  }
  return TextButton(
    onPressed: onPressed,
    child: Text(label, style: destructive ? TextStyle(color: context.palette.learn) : null),
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.onList, required this.onReset, required this.store});

  final VoidCallback onList;
  final VoidCallback onReset;
  final StudyStore store;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 4, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: 'Dev ', style: TextStyle(color: p.accent)),
                      TextSpan(text: 'Lug‘at', style: TextStyle(color: p.ink)),
                    ],
                  ),
                  style: const TextStyle(fontFamily: kMono, fontWeight: FontWeight.w600, fontSize: 25, letterSpacing: -0.8),
                ),
                const SizedBox(height: 2),
                Text('IT inglizchasi · B1–B2 · ${kWords.length} so‘z', style: TextStyle(fontSize: 13, color: p.muted)),
              ],
            ),
          ),
          _ModeToggle(store: store),
          IconButton(
            tooltip: 'So‘zlar ro‘yxati',
            onPressed: onList,
            icon: Icon(Icons.format_list_bulleted_rounded, color: p.ink),
          ),
          PopupMenuButton<String>(
            tooltip: 'Sozlamalar',
            icon: Icon(Icons.more_horiz_rounded, color: p.ink),
            onSelected: (v) {
              switch (v) {
                case 'system':
                  store.setThemeMode(ThemeMode.system);
                case 'light':
                  store.setThemeMode(ThemeMode.light);
                case 'dark':
                  store.setThemeMode(ThemeMode.dark);
                case 'reset':
                  onReset();
              }
            },
            itemBuilder: (_) => [
              _themeItem('system', 'Avto mavzu', Icons.brightness_auto_rounded, store.themeMode == ThemeMode.system, p),
              _themeItem('light', 'Yorug‘ mavzu', Icons.light_mode_rounded, store.themeMode == ThemeMode.light, p),
              _themeItem('dark', 'Tungi mavzu', Icons.dark_mode_rounded, store.themeMode == ThemeMode.dark, p),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.restart_alt_rounded, size: 20, color: p.learn),
                    const SizedBox(width: 12),
                    Text('Progressni tozalash', style: TextStyle(color: p.learn)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _themeItem(String value, String label, IconData icon, bool selected, Palette p) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: selected ? p.accent : p.muted),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(color: p.ink))),
          if (selected) Icon(Icons.check_rounded, size: 18, color: p.accent),
        ],
      ),
    );
  }
}

/// Switches between EN → UZ and UZ → EN study directions.
class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.store});

  final StudyStore store;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final enFirst = store.mode == StudyMode.enToUz;
    return Tooltip(
      message: 'Yo‘nalishni almashtirish',
      child: Material(
        color: p.surface,
        shape: StadiumBorder(side: BorderSide(color: p.line)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: () => store.setMode(enFirst ? StudyMode.uzToEn : StudyMode.enToUz),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(enFirst ? 'EN' : 'UZ',
                    style: TextStyle(fontFamily: kMono, fontSize: 12.5, fontWeight: FontWeight.w600, color: p.accent)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Icon(Icons.arrow_forward_rounded, size: 13, color: p.muted),
                ),
                Text(enFirst ? 'UZ' : 'EN',
                    style: TextStyle(fontFamily: kMono, fontSize: 12.5, fontWeight: FontWeight.w600, color: p.ink)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.store});

  final StudyStore store;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final total = kWords.length;
    final k = store.countOf(CardStatus.known);
    final l = store.countOf(CardStatus.learning);
    final n = total - k - l;
    final numStyle = TextStyle(
      fontFamily: kMono,
      fontWeight: FontWeight.w600,
      color: p.ink,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    Widget legend(Widget dot, String label, int value) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            dot,
            const SizedBox(width: 6),
            Text('$label ', style: TextStyle(fontSize: 12.5, color: p.muted)),
            Text('$value', style: numStyle.copyWith(fontSize: 12.5)),
          ],
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: SizedBox(
            height: 7,
            child: LayoutBuilder(
              builder: (context, c) {
                final dur = MediaQuery.of(context).disableAnimations ? Duration.zero : const Duration(milliseconds: 420);
                return Stack(
                  children: [
                    Container(color: p.line),
                    AnimatedContainer(duration: dur, curve: Curves.easeOutCubic, width: c.maxWidth * (k + l) / total, color: p.learn),
                    AnimatedContainer(duration: dur, curve: Curves.easeOutCubic, width: c.maxWidth * k / total, color: p.known),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.start,
          spacing: 16,
          runSpacing: 4,
          children: [
            legend(StatusDot(color: p.known), 'Bilaman', k),
            legend(StatusDot(color: p.learn), 'Takrorlash', l),
            legend(StatusDot(color: p.muted, hollow: true), 'Yangi', n),
          ],
        ),
      ],
    );
  }
}

class StatusDot extends StatelessWidget {
  const StatusDot({super.key, required this.color, this.hollow = false});

  final Color color;
  final bool hollow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: hollow ? Colors.transparent : color,
        border: hollow ? Border.all(color: color, width: 1.5) : null,
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.store});

  final StudyStore store;

  @override
  Widget build(BuildContext context) {
    final items = <(String, String)>[('all', 'Hammasi'), ...kCategories.map((c) => (c.id, c.name))];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final (id, name) = items[i];
          final cat = id == 'all' ? null : id;
          return _CategoryChip(
            label: name,
            count: '${store.countOf(CardStatus.known, category: cat)}/${store.totalIn(cat)}',
            selected: store.category == id,
            onTap: () => store.setCategory(id),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.count, required this.selected, required this.onTap});

  final String label;
  final String count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final fg = selected ? p.accentInk : p.ink;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? p.accent : p.surface,
        shape: StadiumBorder(side: BorderSide(color: selected ? p.accent : p.line)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: TextStyle(fontSize: 13.5, color: fg)),
                const SizedBox(width: 7),
                Text(
                  count,
                  style: TextStyle(
                    fontFamily: kMono,
                    fontSize: 11.5,
                    color: selected ? fg.withValues(alpha: 0.85) : p.muted,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.store});

  final StudyStore store;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        Expanded(
          child: _Segmented<StatusFilter>(
            values: StatusFilter.values,
            selected: store.filter,
            label: (f) => f.label,
            onChanged: store.setFilter,
          ),
        ),
        const SizedBox(width: 8),
        Tooltip(
          message: store.shuffle ? 'Asl tartib' : 'Aralashtirish',
          child: Material(
            color: store.shuffle ? p.accentSoft : p.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9),
              side: BorderSide(color: store.shuffle ? p.accent : p.line),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(9),
              onTap: () {
                store.toggleShuffle();
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                    content: Text(store.shuffle ? 'So‘zlar aralashtirildi' : 'Asl tartib tiklandi'),
                    duration: const Duration(milliseconds: 1400),
                  ));
              },
              child: SizedBox(
                width: 40,
                height: 34,
                child: Icon(Icons.shuffle_rounded, size: 18, color: store.shuffle ? p.accent : p.muted),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Segmented<T> extends StatelessWidget {
  const _Segmented({
    required this.values,
    required this.selected,
    required this.label,
    required this.onChanged,
  });

  final List<T> values;
  final T selected;
  final String Function(T) label;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final children = values.map((v) {
      final on = v == selected;
      final child = Semantics(
        selected: on,
        button: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: on ? p.ink : Colors.transparent, borderRadius: BorderRadius.circular(7)),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label(v),
                maxLines: 1,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: on ? p.bg : p.muted,
                ),
              ),
            ),
          ),
        ),
      );
      // Width follows label length so every label keeps the same text size.
      return Expanded(flex: label(v).length + 4, child: child);
    }).toList();
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: p.line),
      ),
      child: Row(children: children),
    );
  }
}

class _CardArea extends StatelessWidget {
  const _CardArea({required this.store, required this.onSpeak});

  final StudyStore store;
  final SpeakCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    final word = store.current;
    if (word == null) {
      return EmptyDeck(filter: store.filter, onShowAll: () => store.setFilter(StatusFilter.all));
    }
    final status = store.statusOf(word.id);
    final position = '${store.index + 1} / ${store.deck.length}';
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final dir = store.lastDirection.toDouble();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: store.flip,
      onHorizontalDragEnd: (d) {
        final v = d.primaryVelocity ?? 0;
        if (v < -250) store.go(1);
        if (v > 250) store.go(-1);
      },
      child: AnimatedSwitcher(
        duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 240),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        layoutBuilder: (current, previous) => Stack(fit: StackFit.expand, children: [...previous, ?current]),
        transitionBuilder: (child, animation) {
          final incoming = child.key == ValueKey('${word.id}-${store.mode.name}');
          final offset = Tween<Offset>(
            begin: Offset(incoming ? 0.08 * dir : -0.08 * dir, 0),
            end: Offset.zero,
          ).animate(animation);
          return FadeTransition(opacity: animation, child: SlideTransition(position: offset, child: child));
        },
        child: KeyedSubtree(
          key: ValueKey('${word.id}-${store.mode.name}'),
          child: FlipCard(
            flipped: store.flipped,
            front: CardFront(word: word, status: status, mode: store.mode, position: position, onSpeak: onSpeak),
            back: CardBack(word: word, status: status, position: position, onSpeak: onSpeak),
          ),
        ),
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.store, required this.onMark});

  final StudyStore store;
  final void Function(CardStatus) onMark;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final word = store.current;
    final enabled = word != null;
    final status = word == null ? CardStatus.fresh : store.statusOf(word.id);
    return Row(
      children: [
        _SquareButton(icon: Icons.chevron_left_rounded, tooltip: 'Oldingi', onTap: enabled ? () => store.go(-1) : null),
        const SizedBox(width: 8),
        Expanded(
          child: _MarkButton(
            label: 'Takrorlash',
            fg: p.learn,
            bg: p.learnSoft,
            active: status == CardStatus.learning,
            onTap: enabled ? () => onMark(CardStatus.learning) : null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MarkButton(
            label: 'Bilaman',
            fg: p.known,
            bg: p.knownSoft,
            active: status == CardStatus.known,
            onTap: enabled ? () => onMark(CardStatus.known) : null,
          ),
        ),
        const SizedBox(width: 8),
        _SquareButton(icon: Icons.chevron_right_rounded, tooltip: 'Keyingi', onTap: enabled ? () => store.go(1) : null),
      ],
    );
  }
}

class _MarkButton extends StatelessWidget {
  const _MarkButton({required this.label, required this.fg, required this.bg, required this.active, required this.onTap});

  final String label;
  final Color fg;
  final Color bg;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.45 : 1,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: active ? fg : Colors.transparent, width: 2),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: SizedBox(
            height: 52,
            child: Center(
              child: Text(label, style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600, color: fg)),
            ),
          ),
        ),
      ),
    );
  }
}

class _SquareButton extends StatelessWidget {
  const _SquareButton({required this.icon, required this.tooltip, required this.onTap});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Tooltip(
      message: tooltip,
      child: Opacity(
        opacity: onTap == null ? 0.45 : 1,
        child: Material(
          color: p.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: p.line)),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: SizedBox(width: 52, height: 52, child: Icon(icon, size: 26, color: p.ink)),
          ),
        ),
      ),
    );
  }
}

/// Keeps the word list's dot colours in one place.
Color statusColor(Palette p, CardStatus s) => switch (s) {
      CardStatus.known => p.known,
      CardStatus.learning => p.learn,
      CardStatus.fresh => p.muted,
    };
