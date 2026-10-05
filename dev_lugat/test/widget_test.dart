import 'package:dev_lugat/data/words.dart';
import 'package:dev_lugat/main.dart';
import 'package:dev_lugat/services/speech.dart';
import 'package:dev_lugat/state/study_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<StudyStore> freshStore([Map<String, Object> values = const {}]) async {
  SharedPreferences.setMockInitialValues(values);
  return StudyStore(await SharedPreferences.getInstance());
}

void main() {
  test('every example contains the highlighted word', () {
    for (final w in kWords) {
      final hl = (w.highlight ?? w.en).toLowerCase();
      expect(w.example.toLowerCase(), contains(hl), reason: w.id);
    }
    expect(kWords.map((w) => w.id).toSet().length, kWords.length);
  });

  test('marking a card saves progress and moves to the next card', () async {
    final store = await freshStore();
    final first = store.current!;
    store.mark(CardStatus.known);
    expect(store.statusOf(first.id), CardStatus.known);
    expect(store.current!.id, isNot(first.id));

    final reloaded = StudyStore(await SharedPreferences.getInstance());
    expect(reloaded.statusOf(first.id), CardStatus.known);
    expect(reloaded.countOf(CardStatus.known), 1);
  });

  test('filtering by status keeps a valid current card', () async {
    final store = await freshStore();
    store.setFilter(StatusFilter.learning);
    expect(store.deck, isEmpty);
    expect(store.current, isNull);

    store.setFilter(StatusFilter.all);
    store.mark(CardStatus.learning);
    store.setFilter(StatusFilter.learning);
    expect(store.deck.length, 1);
    store.mark(CardStatus.known);
    expect(store.deck, isEmpty);
  });

  testWidgets('shows the first word and flips to the translation', (tester) async {
    final store = await freshStore();
    await tester.pumpWidget(DevLugatApp(store: store, speech: Speech()));
    await tester.pumpAndSettle();

    expect(find.text('repository'), findsOneWidget);
    expect(find.text('Bilaman'), findsWidgets);

    await tester.tap(find.text('repository'));
    await tester.pumpAndSettle();
    expect(find.text('repozitoriy, kod ombori'), findsOneWidget);

    await tester.tap(find.widgetWithText(InkWell, 'Bilaman'));
    await tester.pumpAndSettle();
    expect(find.text('commit'), findsOneWidget);
  });
}
