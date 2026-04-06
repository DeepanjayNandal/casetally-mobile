/// Pure data models for articles
/// No Flutter dependencies - just Dart
/// Easy to modify: add fields, change structure, UI won't break

enum SectionType {
  paragraph,
  list,
  quote,
  highlight,
}

class ArticleSection {
  final String heading;
  final String content;
  final SectionType type;

  const ArticleSection({
    required this.heading,
    required this.content,
    required this.type,
  });
}

class Article {
  final String id;
  final String title;
  final String category;
  final String introduction;
  final List<ArticleSection> sections;
  final List<String> keyTakeaways;
  final int readingMinutes;

  const Article({
    required this.id,
    required this.title,
    required this.category,
    required this.introduction,
    required this.sections,
    required this.keyTakeaways,
    required this.readingMinutes,
  });
}
