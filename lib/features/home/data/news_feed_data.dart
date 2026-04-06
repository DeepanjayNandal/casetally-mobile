import '../models/news_item.dart';
import '../models/learning_tip.dart';

/// Mock news feed data for home screen
/// Replace with API call in Phase 3 - UI stays the same!
class NewsFeedData {
  /// Top featured story (hero section)
  static NewsItem get topStory => NewsItem(
        id: 'news-top-1',
        title: 'Supreme Court Clarifies Miranda Rights in Landmark Decision',
        summary:
            'In a unanimous ruling, the Court reaffirms the importance of informing suspects of their constitutional rights before custodial interrogation.',
        category: 'Constitutional Law',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        articleId: 'miranda-rights-101', // Links to existing Resources article
      );

  /// Latest legal updates (3 items)
  static List<NewsItem> get latestUpdates => [
        NewsItem(
          id: 'news-update-1',
          title: 'Federal Court Rules on Digital Privacy Rights',
          category: 'Privacy Law',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          articleId: null, // No linked article yet
        ),
        NewsItem(
          id: 'news-update-2',
          title: 'New Guidelines for Police Body Cameras in Traffic Stops',
          category: 'Criminal Procedure',
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          articleId:
              'traffic-stop-rights', // Links to existing Resources article
        ),
        NewsItem(
          id: 'news-update-3',
          title: 'Department of Justice Updates on Right to Counsel',
          category: 'Constitutional Rights',
          timestamp: DateTime.now().subtract(const Duration(days: 5)),
          articleId: 'right-to-attorney', // Links to existing Resources article
        ),
      ];

  /// Daily learning tip
  static LearningTip get todaysTip => LearningTip(
        id: 'tip-1',
        title: 'Understanding Qualified Immunity',
        description:
            'Qualified immunity protects government officials from civil lawsuits unless they violated a "clearly established" constitutional right. Learn how this doctrine affects your ability to seek justice.',
        articleId: null, // Could link to future article
      );

  /// Alternative tips (rotate daily in future)
  static List<LearningTip> get allTips => [
        todaysTip,
        LearningTip(
          id: 'tip-2',
          title: 'What is Probable Cause?',
          description:
              'Probable cause means a reasonable belief that a crime has been committed. Police need probable cause to make arrests and obtain search warrants.',
          articleId: null,
        ),
        LearningTip(
          id: 'tip-3',
          title: 'Your Fifth Amendment Rights',
          description:
              'The Fifth Amendment protects you from self-incrimination. You have the right to remain silent and cannot be forced to testify against yourself.',
          articleId: 'miranda-rights-101',
        ),
      ];
}
