import 'package:flutter/material.dart';

import '../data/word.dart';
import '../state/study_store.dart';
import 'home_page.dart' show StatusDot, statusColor;
import 'palette.dart';

/// Bottom sheet listing every word in the current section; tap one to study it.
class WordListSheet extends StatelessWidget {
  const WordListSheet({super.key, required this.store});

  final StudyStore store;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final words = store.wordsInCategory();
    final title = store.category == 'all' ? 'Barcha so‘zlar' : categoryName(store.category);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, controller) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${title.toUpperCase()} · ${words.length}',
                    style: TextStyle(fontFamily: kMono, fontSize: 12, letterSpacing: 1, color: p.muted),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              controller: controller,
              padding: EdgeInsets.fromLTRB(12, 0, 12, MediaQuery.paddingOf(context).bottom + 16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisExtent: 64,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: words.length,
              itemBuilder: (context, i) {
                final w = words[i];
                final st = store.statusOf(w.id);
                final current = w.id == store.currentId;
                return Material(
                  color: current ? p.surface : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: current ? p.accent : Colors.transparent),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      store.jumpTo(w.id);
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: StatusDot(color: statusColor(p, st), hollow: st == CardStatus.fresh),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  w.en,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontFamily: kMono, fontSize: 14, fontWeight: FontWeight.w500, color: p.ink),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  w.uz,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 12, height: 1.3, color: p.muted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
