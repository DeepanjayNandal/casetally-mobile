import '../models/search_response.dart';
import '../models/ai_summary.dart';
import '../models/law_reference.dart';
import '../models/related_article.dart';
import '../models/source.dart';

/// Mock AI responses for testing UI before backend is ready
/// These mirror what the real API will return
class MockSearchResponses {
  /// Miranda Rights query response
  static SearchResponse get mirandaRightsResponse => SearchResponse(
        query: 'what are my miranda rights during a police stop',
        timestamp: DateTime.now(),
        response: SearchResponseData(
          aiSummary: AISummary(
            text:
                '''**Miranda rights** are constitutional protections that police must inform you about before custodial interrogation:

• **Right to remain silent** - You don't have to answer questions
• **Anything you say can be used against you** in court
• **Right to an attorney** - You can have a lawyer present
• **Free attorney** if you cannot afford one

During a traffic stop, you must provide license and registration, but you don't have to answer questions about where you're going or consent to searches. **Always clearly invoke your rights** by saying "I want to speak with my attorney."''',
            confidenceScore: 0.96,
            modelUsed: 'gpt-4-turbo',
            generatedAt: DateTime.now(),
          ),
          relevantLaws: [
            LawReference(
              id: 'miranda-v-arizona-1966',
              title: 'Miranda v. Arizona',
              citation: '384 U.S. 436 (1966)',
              summary:
                  'Landmark Supreme Court case establishing the requirement that police inform suspects of their constitutional rights before interrogation.',
              jurisdiction: 'Federal',
              type: LawType.caseLaw,
              relevanceScore: 0.98,
            ),
            LawReference(
              id: 'fifth-amendment',
              title: 'Fifth Amendment - Right Against Self-Incrimination',
              citation: 'U.S. Constitution, Amendment V',
              summary:
                  'No person shall be compelled in any criminal case to be a witness against himself.',
              jurisdiction: 'Federal',
              type: LawType.constitutional,
              relevanceScore: 0.95,
            ),
            LawReference(
              id: 'sixth-amendment',
              title: 'Sixth Amendment - Right to Counsel',
              citation: 'U.S. Constitution, Amendment VI',
              summary:
                  'In all criminal prosecutions, the accused shall enjoy the right to have the Assistance of Counsel for his defence.',
              jurisdiction: 'Federal',
              type: LawType.constitutional,
              relevanceScore: 0.93,
            ),
          ],
          relatedArticles: [
            RelatedArticle(
              id: 'miranda-rights-101',
              title: 'Miranda Rights: What You Need to Know',
              category: 'know-your-rights',
              readingMinutes: 5,
              relevanceReason:
                  'Comprehensive guide to understanding and invoking Miranda rights',
            ),
            RelatedArticle(
              id: 'traffic-stop-rights',
              title: 'Your Rights During Traffic Stops',
              category: 'know-your-rights',
              readingMinutes: 4,
              relevanceReason:
                  'Specific guidance on police interactions during traffic stops',
            ),
            RelatedArticle(
              id: 'right-to-attorney',
              title: 'Understanding Your Right to an Attorney',
              category: 'know-your-rights',
              readingMinutes: 6,
              relevanceReason:
                  'Detailed explanation of legal representation rights',
            ),
          ],
          sources: [
            Source(
              name: 'Cornell Law School - Legal Information Institute',
              url: 'https://www.law.cornell.edu/wex/miranda_rights',
              type: SourceType.legalDatabase,
              credibility: SourceCredibility.high,
            ),
            Source(
              name: 'Supreme Court of the United States',
              url: 'https://supreme.justia.com/cases/federal/us/384/436/',
              type: SourceType.primarySource,
              credibility: SourceCredibility.primary,
            ),
          ],
        ),
        metadata: SearchMetadata(
          processingTimeMs: 2341,
          tokensUsed: 567,
          cached: false,
          userId: 'user_abc123',
          sessionId: 'session_xyz789',
        ),
      );

  /// General legal question response
  static SearchResponse get generalLegalResponse => SearchResponse(
        query: 'can i record police officers',
        timestamp: DateTime.now(),
        response: SearchResponseData(
          aiSummary: AISummary(
            text:
                '''**Yes, you generally have the right to record police officers** in public spaces under the First Amendment.

**Key Points:**
• Recording is protected as freedom of speech and press
• Must not interfere with police duties
• Keep a reasonable distance
• Some states require two-party consent for audio recording

**Important:** While recording is legal, always remain respectful and follow lawful orders. Never physically interfere with police activity.''',
            confidenceScore: 0.92,
            modelUsed: 'gpt-4-turbo',
            generatedAt: DateTime.now(),
          ),
          relevantLaws: [
            LawReference(
              id: 'first-amendment',
              title: 'First Amendment - Freedom of Speech',
              citation: 'U.S. Constitution, Amendment I',
              summary:
                  'Congress shall make no law abridging the freedom of speech, or of the press.',
              jurisdiction: 'Federal',
              type: LawType.constitutional,
              relevanceScore: 0.94,
            ),
          ],
          relatedArticles: [
            RelatedArticle(
              id: 'traffic-stop-rights',
              title: 'Your Rights During Traffic Stops',
              category: 'know-your-rights',
              readingMinutes: 4,
              relevanceReason:
                  'Covers recording rights during police interactions',
            ),
          ],
          sources: [
            Source(
              name: 'ACLU - Know Your Rights',
              url: 'https://www.aclu.org/know-your-rights/stopped-by-police',
              type: SourceType.other,
              credibility: SourceCredibility.high,
            ),
          ],
        ),
        metadata: SearchMetadata(
          processingTimeMs: 1834,
          tokensUsed: 423,
          cached: false,
        ),
      );

  /// Get mock response based on query
  /// Returns miranda response for now, expand later
  static SearchResponse getResponseForQuery(String query) {
    final lowerQuery = query.toLowerCase();

    if (lowerQuery.contains('miranda') ||
        lowerQuery.contains('remain silent')) {
      return mirandaRightsResponse;
    } else if (lowerQuery.contains('record') || lowerQuery.contains('camera')) {
      return generalLegalResponse;
    }

    // Default to miranda response for any other query
    return mirandaRightsResponse;
  }
}
