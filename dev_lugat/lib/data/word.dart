enum PartOfSpeech {
  noun('noun', 'ot'),
  verb('verb', 'fe’l'),
  adj('adjective', 'sifat'),
  adv('adverb', 'ravish'),
  phrasal('phrasal verb', 'frazali fe’l');

  const PartOfSpeech(this.en, this.uz);

  final String en;
  final String uz;
}

class Word {
  const Word({
    required this.id,
    required this.category,
    required this.en,
    required this.ipa,
    required this.pos,
    required this.uz,
    required this.definition,
    required this.example,
    required this.exampleUz,
    required this.context,
    this.highlight,
  });

  final String id;
  final String category;
  final String en;
  final String ipa;
  final PartOfSpeech pos;
  final String uz;
  final String definition;
  final String example;
  final String exampleUz;

  /// Where a developer usually meets this word (PR review, Jira, Slack…).
  final String context;

  /// The exact form of the word used in [example], when it differs from [en].
  final String? highlight;
}

class Category {
  const Category(this.id, this.name);

  final String id;
  final String name;
}

const List<Category> kCategories = <Category>[
  Category('git', 'Git va versiyalar'),
  Category('review', 'Kod sharhi'),
  Category('debug', 'Debug va xatolar'),
  Category('arch', 'Arxitektura'),
  Category('devops', 'DevOps va deploy'),
  Category('team', 'Jamoa va Agile'),
];

String categoryName(String id) =>
    kCategories.firstWhere((c) => c.id == id, orElse: () => const Category('all', 'Barcha bo‘limlar')).name;
