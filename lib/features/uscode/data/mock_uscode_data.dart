import '../models/uscode_title.dart';
import '../models/uscode_hierarchy_node.dart';

/// Mock U.S. Code data for Phase 1 testing
/// Concept: Hardcoded sample data that mirrors real API structure
///
/// **Why Mock Data?**
/// 1. Frontend development continues while backend is built
/// 2. Consistent test data for UI development
/// 3. No API dependency for demos and screenshots
/// 4. Easy to swap with real API later (just change provider)
class MockUsCodeData {
  MockUsCodeData._();

  /// Featured titles for home preview (3 titles)
  static List<UsCodeTitle> get featuredTitles => [
        title18,
        title42,
        title8,
      ];

  /// All 54 titles (lightweight - no children loaded)
  static List<UsCodeTitle> get allTitles => [
        title18,
        title42,
        title8,
        const UsCodeTitle(
          number: 1,
          name: 'General Provisions',
          summary: 'General rules for interpreting federal laws',
        ),
        const UsCodeTitle(
          number: 2,
          name: 'The Congress',
          summary: 'Rules and procedures for the U.S. Congress',
        ),
        const UsCodeTitle(
          number: 10,
          name: 'Armed Forces',
          summary: 'Military organization and uniform code',
        ),
        const UsCodeTitle(
          number: 26,
          name: 'Internal Revenue Code',
          summary: 'Federal tax laws and regulations',
        ),
      ];

  // ==================== TITLE 18: CRIMES ====================

  static UsCodeTitle get title18 => UsCodeTitle(
        number: 18,
        name: 'Crimes and Criminal Procedure',
        summary: 'Federal criminal laws including civil rights violations',
        isFeatured: true,
        children: [
          UsCodeHierarchyNode(
            id: '18-part1',
            type: HierarchyNodeType.part,
            label: 'Part I',
            name: 'Crimes',
            children: [
              UsCodeHierarchyNode(
                id: '18-part1-ch13',
                type: HierarchyNodeType.chapter,
                label: 'Chapter 13',
                name: 'Civil Rights',
                children: [
                  UsCodeHierarchyNode(
                    id: '18-part1-ch13-s242',
                    type: HierarchyNodeType.section,
                    label: '§242',
                    name: 'Deprivation of rights under color of law',
                    content:
                        '''Whoever, under color of any law, statute, ordinance, regulation, or custom, willfully subjects any person in any State, Territory, Commonwealth, Possession, or District to the deprivation of any rights, privileges, or immunities secured or protected by the Constitution or laws of the United States shall be fined under this title or imprisoned not more than one year, or both.

If bodily injury results from the acts committed in violation of this section or if such acts include the use, attempted use, or threatened use of a dangerous weapon, explosives, or fire, shall be fined under this title or imprisoned not more than ten years, or both.

If death results from the acts committed in violation of this section or if such acts include kidnapping or an attempt to kidnap, aggravated sexual abuse, or an attempt to commit aggravated sexual abuse, or an attempt to kill, shall be fined under this title, or imprisoned for any term of years or for life, or both, or may be sentenced to death.''',
                    lastUpdated: DateTime(2024, 1, 15),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

  // ==================== TITLE 42: PUBLIC HEALTH ====================

  static UsCodeTitle get title42 => UsCodeTitle(
        number: 42,
        name: 'The Public Health and Welfare',
        summary: 'Healthcare, social security, and public welfare programs',
        isFeatured: true,
        children: [
          UsCodeHierarchyNode(
            id: '42-ch7',
            type: HierarchyNodeType.chapter,
            label: 'Chapter 7',
            name: 'Social Security',
            children: [
              UsCodeHierarchyNode(
                id: '42-ch7-sch2',
                type: HierarchyNodeType.subchapter,
                label: 'Subchapter II',
                name:
                    'Federal Old-Age, Survivors, and Disability Insurance Benefits',
                children: [
                  UsCodeHierarchyNode(
                    id: '42-ch7-sch2-s402',
                    type: HierarchyNodeType.section,
                    label: '§402',
                    name: 'Old-age and survivors insurance benefit payments',
                    content:
                        '''Every individual who is fully insured or currently insured shall be entitled to receive an old-age insurance benefit for each month, beginning with the first month in which he becomes so entitled to such insurance benefits and ending with the month preceding the month in which he dies.

The amount of an old-age insurance benefit for each month shall equal the primary insurance amount of the individual on whose wages and self-employment income such old-age insurance benefit is based.''',
                    lastUpdated: DateTime(2023, 12, 10),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

  // ==================== TITLE 8: IMMIGRATION ====================

  static UsCodeTitle get title8 => UsCodeTitle(
        number: 8,
        name: 'Aliens and Nationality',
        summary: 'Immigration and naturalization laws',
        isFeatured: true,
        children: [
          UsCodeHierarchyNode(
            id: '8-ch12',
            type: HierarchyNodeType.chapter,
            label: 'Chapter 12',
            name: 'Immigration and Nationality',
            children: [
              UsCodeHierarchyNode(
                id: '8-ch12-sch2',
                type: HierarchyNodeType.subchapter,
                label: 'Subchapter II',
                name: 'Immigration',
                children: [
                  UsCodeHierarchyNode(
                    id: '8-ch12-sch2-s1182',
                    type: HierarchyNodeType.section,
                    label: '§1182',
                    name: 'Inadmissible aliens',
                    content:
                        '''Any alien who is determined to be inadmissible under one or more of the following classes of aliens is inadmissible:

(1) Health-related grounds
(2) Criminal and related grounds
(3) Security and related grounds
(4) Public charge
(5) Labor certification and qualifications for certain immigrants
(6) Illegal entrants and immigration violators
(7) Documentation requirements''',
                    lastUpdated: DateTime(2024, 2, 20),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

  /// Find title by number
  static UsCodeTitle? findTitleByNumber(int number) {
    try {
      return allTitles.firstWhere((title) => title.number == number);
    } catch (e) {
      return null;
    }
  }

  /// Find section by ID (searches all titles)
  static UsCodeHierarchyNode? findSectionById(String sectionId) {
    for (final title in allTitles) {
      for (final child in title.children) {
        final found = child.findChildById(sectionId);
        if (found != null) return found;
      }
    }
    return null;
  }
}
