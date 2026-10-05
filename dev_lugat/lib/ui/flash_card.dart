import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/word.dart';
import '../state/study_store.dart';
import 'palette.dart';

typedef SpeakCallback = void Function(String text, {bool slow});

/// Rotates between [front] and [back] around the Y axis.
class FlipCard extends StatefulWidget {
  const FlipCard({super.key, required this.flipped, required this.front, required this.back});

  final bool flipped;
  final Widget front;
  final Widget back;

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 480),
    value: widget.flipped ? 1 : 0,
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );

  @override
  void didUpdateWidget(FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.flipped == widget.flipped) return;
    if (MediaQuery.of(context).disableAnimations) {
      _controller.value = widget.flipped ? 1 : 0;
    } else if (widget.flipped) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      builder: (context, _) {
        final angle = _curve.value * math.pi;
        final showBack = angle > math.pi / 2;
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.0012)
          ..rotateY(angle);
        return Transform(
          alignment: Alignment.center,
          transform: transform,
          child: showBack
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: widget.back,
                )
              : widget.front,
        );
      },
    );
  }
}

/// The shared card surface: border, radius and soft shadow.
class CardSurface extends StatelessWidget {
  const CardSurface({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.line),
        boxShadow: [BoxShadow(color: p.shadow, blurRadius: 36, spreadRadius: -16, offset: const Offset(0, 18))],
      ),
      child: Padding(padding: const EdgeInsets.fromLTRB(20, 14, 20, 12), child: child),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.left, required this.right});

  final String left;
  final String right;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final style = TextStyle(fontFamily: kMono, fontSize: 11, letterSpacing: 0.9, color: p.muted);
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Text(left.toUpperCase(), style: style, overflow: TextOverflow.ellipsis)),
            Text(right, style: style.copyWith(letterSpacing: 0.2, fontFeatures: const [FontFeature.tabularFigures()])),
          ],
        ),
        const SizedBox(height: 10),
        const DashedLine(),
      ],
    );
  }
}

class DashedLine extends StatelessWidget {
  const DashedLine({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      width: double.infinity,
      child: CustomPaint(painter: _DashPainter(context.palette.line)),
    );
  }
}

class _DashPainter extends CustomPainter {
  _DashPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 7) {
      canvas.drawLine(Offset(x, 0.5), Offset(math.min(x + 3.5, size.width), 0.5), paint);
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.color != color;
}

class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});

  final CardStatus status;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final (bg, fg, border) = switch (status) {
      CardStatus.known => (p.knownSoft, p.known, Colors.transparent),
      CardStatus.learning => (p.learnSoft, p.learn, Colors.transparent),
      CardStatus.fresh => (Colors.transparent, p.muted, p.line),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: border),
      ),
      child: Text(status.label, style: TextStyle(fontFamily: kMono, fontSize: 11.5, color: fg)),
    );
  }
}

class _Foot extends StatelessWidget {
  const _Foot({required this.word, required this.status});

  final Word word;
  final CardStatus status;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        Expanded(
          child: Text.rich(
            TextSpan(
              text: 'Qayerda uchraydi: ',
              children: [
                TextSpan(
                  text: word.context,
                  style: TextStyle(fontFamily: kMono, color: p.ink, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            style: TextStyle(fontSize: 12.5, color: p.muted),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        StatusChip(status),
      ],
    );
  }
}

class SpeakPill extends StatelessWidget {
  const SpeakPill({super.key, required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: p.surface2,
      shape: StadiumBorder(side: BorderSide(color: p.line)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 17, color: p.ink),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: p.ink)),
            ],
          ),
        ),
      ),
    );
  }
}

class SpeakIcon extends StatelessWidget {
  const SpeakIcon({super.key, required this.onTap, required this.tooltip});

  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: p.surface2,
        shape: CircleBorder(side: BorderSide(color: p.line)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: Icon(Icons.volume_up_rounded, size: 17, color: p.ink),
          ),
        ),
      ),
    );
  }
}

class _FlipHint extends StatelessWidget {
  const _FlipHint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: context.palette.muted)),
    );
  }
}

/// Front of the card: the English word (or the Uzbek meaning in UZ → EN mode).
class CardFront extends StatelessWidget {
  const CardFront({
    super.key,
    required this.word,
    required this.status,
    required this.mode,
    required this.position,
    required this.onSpeak,
  });

  final Word word;
  final CardStatus status;
  final StudyMode mode;
  final String position;
  final SpeakCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final english = mode == StudyMode.enToUz;
    return CardSurface(
      child: Column(
        children: [
          _Meta(left: categoryName(word.category), right: position),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: english
                      ? [
                          Text('${word.pos.en} · ${word.pos.uz}',
                              style: TextStyle(fontFamily: kMono, fontSize: 12.5, color: p.accent)),
                          const SizedBox(height: 6),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              word.en,
                              style: TextStyle(
                                fontFamily: kMono,
                                fontWeight: FontWeight.w600,
                                fontSize: 42,
                                height: 1.1,
                                letterSpacing: -1.4,
                                color: p.ink,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(word.ipa, style: TextStyle(fontSize: 17, color: p.muted)),
                          const SizedBox(height: 18),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              SpeakPill(
                                icon: Icons.volume_up_rounded,
                                label: 'Tinglash',
                                onTap: () => onSpeak(word.en),
                              ),
                              SpeakPill(
                                icon: Icons.slow_motion_video_rounded,
                                label: 'Sekin',
                                onTap: () => onSpeak(word.en, slow: true),
                              ),
                            ],
                          ),
                        ]
                      : [
                          Text('o‘zbekcha · ${word.pos.uz}',
                              style: TextStyle(fontFamily: kMono, fontSize: 12.5, color: p.accent)),
                          const SizedBox(height: 8),
                          Text(
                            word.uz,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, height: 1.2, color: p.ink),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '“${word.exampleUz}”',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: p.muted, height: 1.4),
                          ),
                        ],
                ),
              ),
            ),
          ),
          _Foot(word: word, status: status),
          _FlipHint(english ? 'Tarjimani ko‘rish uchun kartani bosing' : 'Inglizchasini eslang, so‘ng kartani bosing'),
        ],
      ),
    );
  }
}

/// Back of the card: translation, plain-English meaning and an example.
class CardBack extends StatelessWidget {
  const CardBack({
    super.key,
    required this.word,
    required this.status,
    required this.position,
    required this.onSpeak,
  });

  final Word word;
  final CardStatus status;
  final String position;
  final SpeakCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return CardSurface(
      child: Column(
        children: [
          _Meta(left: categoryName(word.category), right: position),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          word.en,
                          style: TextStyle(
                            fontFamily: kMono,
                            fontWeight: FontWeight.w600,
                            fontSize: 21,
                            letterSpacing: -0.5,
                            color: p.ink,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SpeakIcon(tooltip: 'So‘zni tinglash', onTap: () => onSpeak(word.en)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('${word.ipa} · ${word.pos.en}', style: TextStyle(fontSize: 14, color: p.muted)),
                  const SizedBox(height: 14),
                  const _Label('Tarjima'),
                  Text(word.uz, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, height: 1.25, color: p.ink)),
                  const SizedBox(height: 14),
                  const _Label('Ma’nosi (English)'),
                  Text(word.definition, style: TextStyle(fontSize: 15.5, height: 1.45, color: p.ink)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Expanded(child: _Label('Misol')),
                      SpeakIcon(tooltip: 'Misolni tinglash', onTap: () => onSpeak(word.example)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _Example(word: word),
                  const SizedBox(height: 6),
                  Text(
                    word.exampleUz,
                    style: TextStyle(fontSize: 14.5, fontStyle: FontStyle.italic, height: 1.45, color: p.muted),
                  ),
                ],
              ),
            ),
          ),
          _Foot(word: word, status: status),
          const _FlipHint('Old tomonga qaytish uchun bosing'),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(fontFamily: kMono, fontSize: 10.5, letterSpacing: 1.1, color: context.palette.muted),
      ),
    );
  }
}

class _Example extends StatelessWidget {
  const _Example({required this.word});

  final Word word;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final base = TextStyle(fontSize: 16.5, height: 1.45, color: p.ink);
    final ex = word.example;
    final hl = word.highlight ?? word.en;
    final i = ex.toLowerCase().indexOf(hl.toLowerCase());
    if (i < 0) return Text(ex, style: base);
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(text: ex.substring(0, i)),
          TextSpan(
            text: ex.substring(i, i + hl.length),
            style: TextStyle(backgroundColor: p.accentSoft, fontWeight: FontWeight.w600),
          ),
          TextSpan(text: ex.substring(i + hl.length)),
        ],
      ),
    );
  }
}

/// Shown in place of the card when the current filter has no words.
class EmptyDeck extends StatelessWidget {
  const EmptyDeck({super.key, required this.filter, required this.onShowAll});

  final StatusFilter filter;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = switch (filter) {
      StatusFilter.learning => 'Takrorlash ro‘yxati bo‘sh. Barakalla!',
      StatusFilter.fresh => 'Bu bo‘limdagi barcha so‘zlarni ko‘rib chiqdingiz.',
      _ => 'Hali hech bir so‘z bu holatga belgilanmagan.',
    };
    return CardSurface(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Bu filtrda so‘z qolmadi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: p.ink)),
            const SizedBox(height: 6),
            Text(text, textAlign: TextAlign.center, style: TextStyle(color: p.muted)),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onShowAll, child: const Text('Barcha so‘zlarni ko‘rsatish')),
          ],
        ),
      ),
    );
  }
}
