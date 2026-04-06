import 'dart:async';
import 'package:flutter/foundation.dart';
import '../features/search/models/search_event.dart';

/// Development-only WebSocket client that simulates streaming responses.
/// Mirrors the exact event protocol the real backend uses.
class FakeRealtimeClient {
  Stream<SearchEvent> search({
    required String query,
    required String requestId,
    String? groupId,
  }) async* {
    debugPrint('[FakeWS] query: "$query"');

    await Future.delayed(const Duration(milliseconds: 500));
    yield StartedEvent(requestId: requestId, groupId: groupId, query: query);

    await Future.delayed(const Duration(milliseconds: 300));
    yield SourcesCountEvent(requestId: requestId, groupId: groupId, count: 5);

    await Future.delayed(const Duration(milliseconds: 400));
    yield CitationsEvent(
      requestId: requestId,
      groupId: groupId,
      data: [
        {
          'id': 'miranda-v-arizona',
          'title': 'Miranda v. Arizona',
          'citation': '384 U.S. 436 (1966)',
          'summary': 'Landmark case establishing Miranda rights',
          'jurisdiction': 'Federal',
          'type': 'case_law',
          'relevance_score': 0.98,
        },
        {
          'id': 'fifth-amendment',
          'title': 'Fifth Amendment',
          'citation': 'U.S. Constitution, Amendment V',
          'summary': 'Right against self-incrimination',
          'jurisdiction': 'Federal',
          'type': 'constitutional',
          'relevance_score': 0.95,
        },
      ],
    );

    final summaryParts = [
      '**Miranda rights** are constitutional protections that police must inform you about before custodial interrogation.\n\n',
      '• **Right to remain silent** - You don\'t have to answer questions\n',
      '• **Anything you say can be used against you** in court\n',
      '• **Right to an attorney** - You can have a lawyer present\n',
      '• **Free attorney** if you cannot afford one\n\n',
      'Always clearly invoke your rights by saying "I want to speak with my attorney."',
    ];

    for (int i = 0; i < summaryParts.length; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      yield SummaryChunkEvent(
        requestId: requestId,
        groupId: groupId,
        chunk: summaryParts[i],
        isComplete: i == summaryParts.length - 1,
      );
    }

    await Future.delayed(const Duration(milliseconds: 300));
    yield SourcesEvent(
      requestId: requestId,
      groupId: groupId,
      data: [
        {
          'name': 'Cornell Law School',
          'url': 'https://www.law.cornell.edu/wex/miranda_rights',
          'type': 'legal_database',
          'credibility': 'high',
        },
        {
          'name': 'Supreme Court of the United States',
          'url': 'https://supreme.justia.com/cases/federal/us/384/436/',
          'type': 'primary_source',
          'credibility': 'primary',
        },
      ],
    );

    await Future.delayed(const Duration(milliseconds: 400));
    yield ArtifactsEvent(
      requestId: requestId,
      groupId: groupId,
      data: [
        {
          'title': 'Miranda v. Arizona, 384 U.S. 436 (1966)',
          'type': 'court_case',
          'resource_uri': 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
          'publisher': 'Supreme Court of the United States',
          'date': '1966-06-13',
          'pages': 23,
        },
        {
          'title': '42 USC § 1983 - Civil Rights Act',
          'type': 'statute',
          'resource_uri': 'https://www.govinfo.gov/content/pkg/USCODE-2022-title42/pdf/USCODE-2022-title42-chap21-subchapI-sec1983.pdf',
          'publisher': 'U.S. Congress',
          'date': '1871-04-20',
          'pages': 8,
        },
        {
          'title': 'Fifth Amendment - Right Against Self-Incrimination',
          'type': 'regulation',
          'resource_uri': 'https://constitution.congress.gov/constitution/amendment-5/',
          'publisher': 'National Archives',
          'date': '1791-12-15',
          'pages': 2,
        },
        {
          'title': 'Sample Legal Document',
          'type': 'legal_memo',
          'resource_uri': 'https://www.africau.edu/images/default/sample.pdf',
          'publisher': 'Test Publisher',
          'date': '2020-01-01',
          'pages': 5,
        },
      ],
      isComplete: true,
    );

    await Future.delayed(const Duration(milliseconds: 300));
    yield RelatedArticlesEvent(
      requestId: requestId,
      groupId: groupId,
      data: [
        {
          'id': 'miranda-rights-101',
          'title': 'Miranda Rights: What You Need to Know',
          'category': 'know-your-rights',
          'reading_minutes': 5,
          'relevance_reason': 'Comprehensive guide to Miranda rights',
        },
        {
          'id': 'traffic-stop-rights',
          'title': 'Your Rights During Traffic Stops',
          'category': 'know-your-rights',
          'reading_minutes': 4,
          'relevance_reason': 'Specific guidance on police interactions',
        },
      ],
    );

    await Future.delayed(const Duration(milliseconds: 100));
    yield DoneEvent(
      requestId: requestId,
      groupId: groupId,
      processingTimeMs: 2900,
    );

    debugPrint('[FakeWS] done');
  }

  Stream<SearchEvent> searchWithError({
    required String query,
    required String requestId,
    String? groupId,
  }) async* {
    await Future.delayed(const Duration(milliseconds: 500));
    yield StartedEvent(requestId: requestId, groupId: groupId, query: query);

    await Future.delayed(const Duration(milliseconds: 800));
    yield ErrorEvent(
      requestId: requestId,
      groupId: groupId,
      message: 'Simulated connection error for testing',
      errorCode: 'FAKE_ERROR',
    );
  }
}
