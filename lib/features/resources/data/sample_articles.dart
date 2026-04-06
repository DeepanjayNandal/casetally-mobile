import '../models/article.dart';

/// Static articles - replace with API later, UI unchanged
final List<Article> sampleArticles = [
  // Article 1: Miranda Rights
  Article(
    id: 'miranda-rights-101',
    title: 'Miranda Rights: What You Need to Know',
    category: 'know-your-rights',
    readingMinutes: 5,
    introduction:
        'If you\'ve ever watched a crime show, you\'ve heard police say "You have the right to remain silent." But what does this actually mean in real life? Understanding your Miranda rights is crucial when dealing with law enforcement.',
    sections: [
      ArticleSection(
        heading: 'What Are Miranda Rights?',
        content:
            'Miranda rights are warnings that police must give to suspects before custodial interrogation. These rights come from the 1966 Supreme Court case Miranda v. Arizona, which established that the Fifth Amendment privilege against self-incrimination requires law enforcement to inform suspects of their rights.\n\nThe standard Miranda warning includes your right to remain silent, that anything you say can be used against you in court, your right to an attorney, and that an attorney will be provided if you cannot afford one.',
        type: SectionType.paragraph,
      ),
      ArticleSection(
        heading: 'When Must Police Read Your Rights?',
        content:
            '• When you are under arrest or in custody\n• When you are being questioned by police\n• When you are not free to leave\n• Before any custodial interrogation begins',
        type: SectionType.list,
      ),
      ArticleSection(
        heading: 'The Actual Miranda Warning',
        content:
            'You have the right to remain silent. Anything you say can and will be used against you in a court of law. You have the right to an attorney. If you cannot afford an attorney, one will be provided for you.',
        type: SectionType.quote,
      ),
      ArticleSection(
        heading: 'What Happens If Police Don\'t Read Your Rights?',
        content:
            'If police fail to read your Miranda rights before questioning you in custody, any statements you make cannot be used as evidence against you in court. However, this doesn\'t mean your arrest is invalid or that charges will be dropped—it only affects the admissibility of your statements.',
        type: SectionType.paragraph,
      ),
      ArticleSection(
        heading: 'Important: You Must Invoke Your Rights',
        content:
            'Simply being read your Miranda rights is not enough. You must actively invoke them by clearly stating that you wish to remain silent or that you want an attorney. Once you invoke these rights, police must stop questioning you.',
        type: SectionType.highlight,
      ),
    ],
    keyTakeaways: [
      'You can invoke Miranda rights at any time during questioning',
      'Silence cannot be used against you in court',
      'Always ask for a lawyer before answering questions',
      'Police must stop questioning once you invoke your rights',
      'Miranda rights only apply to custodial interrogation',
    ],
  ),

  // Article 2: Traffic Stop Rights
  Article(
    id: 'traffic-stop-rights',
    title: 'Your Rights During Traffic Stops',
    category: 'know-your-rights',
    readingMinutes: 4,
    introduction:
        'Being pulled over by police can be stressful, but knowing your rights can help you handle the situation calmly and legally. Here\'s what you need to know about your rights during a traffic stop.',
    sections: [
      ArticleSection(
        heading: 'What Police Can and Cannot Do',
        content:
            'During a traffic stop, police have the authority to ask for your license, registration, and proof of insurance. You are legally required to provide these documents. However, you are not required to answer questions about where you\'re going, where you\'ve been, or what you\'re doing.',
        type: SectionType.paragraph,
      ),
      ArticleSection(
        heading: 'Do You Have to Exit Your Vehicle?',
        content:
            'Yes. If a police officer asks you to step out of your vehicle, you must comply. The Supreme Court has ruled that officers can order both drivers and passengers out of the car during a traffic stop for officer safety reasons.',
        type: SectionType.paragraph,
      ),
      ArticleSection(
        heading: 'Can Police Search Your Car?',
        content:
            '• With your consent (you can refuse)\n• If they have probable cause to believe there\'s evidence of a crime\n• If they see illegal items in plain view\n• After arresting you, they can search areas within your reach\n• With a valid search warrant',
        type: SectionType.list,
      ),
      ArticleSection(
        heading: 'What to Say If Asked to Search',
        content:
            'I do not consent to searches. I would like to speak with my attorney.',
        type: SectionType.quote,
      ),
      ArticleSection(
        heading: 'Recording the Stop',
        content:
            'You have the First Amendment right to record police officers performing their duties in public. However, you cannot interfere with their work. Keep your phone visible and inform the officer you are recording for your safety and theirs.',
        type: SectionType.highlight,
      ),
    ],
    keyTakeaways: [
      'Stay calm and keep your hands visible at all times',
      'You must provide license, registration, and insurance',
      'You can refuse consent to search your vehicle',
      'You have the right to remain silent beyond basic identification',
      'You can record the interaction with police',
    ],
  ),

  // Article 3: Right to Attorney
  Article(
    id: 'right-to-attorney',
    title: 'Understanding Your Right to an Attorney',
    category: 'know-your-rights',
    readingMinutes: 6,
    introduction:
        'The Sixth Amendment guarantees your right to legal representation. This fundamental right ensures that everyone, regardless of income, has access to a defense attorney when facing criminal charges.',
    sections: [
      ArticleSection(
        heading: 'When Does This Right Apply?',
        content:
            'Your right to an attorney applies in all criminal prosecutions, from minor misdemeanors to serious felonies. This right attaches at critical stages of prosecution, including arraignment, preliminary hearings, trial, sentencing, and appeals.\n\nThe right begins when formal charges are filed or when you are taken into custody for questioning, whichever comes first.',
        type: SectionType.paragraph,
      ),
      ArticleSection(
        heading: 'Public Defenders vs Private Attorneys',
        content:
            'If you cannot afford an attorney, the court will appoint one for you at no cost. These are called public defenders or court-appointed attorneys. They are fully licensed lawyers with the same qualifications as private attorneys.\n\nPublic defenders often handle heavy caseloads, but they are experienced in criminal law and familiar with local courts and prosecutors.',
        type: SectionType.paragraph,
      ),
      ArticleSection(
        heading: 'How to Invoke Your Right to Counsel',
        content:
            '• "I want to speak with an attorney before answering any questions"\n• "I am invoking my right to counsel"\n• "I will not answer questions without my lawyer present"\n• Be clear and unambiguous in your request',
        type: SectionType.list,
      ),
      ArticleSection(
        heading: 'Critical Warning',
        content:
            'Once you invoke your right to an attorney, police must stop questioning you immediately. Do not continue talking or answering questions while waiting for your lawyer. Anything you say can still be used against you.',
        type: SectionType.highlight,
      ),
      ArticleSection(
        heading: 'What Your Attorney Can Do',
        content:
            'Your attorney represents your interests throughout the legal process. They investigate your case, negotiate with prosecutors, file motions, advise you on plea deals, and represent you at trial. They also ensure your constitutional rights are protected at every stage.',
        type: SectionType.paragraph,
      ),
    ],
    keyTakeaways: [
      'You have the right to an attorney in all criminal cases',
      'Public defenders are real lawyers provided at no cost',
      'Clearly invoke your right: "I want a lawyer"',
      'Police must stop questioning once you request counsel',
      'Never waive your right to an attorney without understanding consequences',
    ],
  ),

  // Article 4: Federal vs State Laws
  Article(
    id: 'federal-vs-state-laws',
    title: 'Understanding Federal vs State Laws',
    category: 'federal-laws-codes',
    readingMinutes: 5,
    introduction:
        'The United States has a dual system of government—federal and state—each with its own laws and courts. Understanding which laws apply to your situation is essential for knowing your rights and obligations.',
    sections: [
      ArticleSection(
        heading: 'What Are Federal Laws?',
        content:
            'Federal laws are created by the United States Congress and apply to everyone in all 50 states. These laws cover matters of national importance such as immigration, bankruptcy, Social Security, civil rights, patents, federal crimes, and interstate commerce.\n\nFederal laws are enforced by federal agencies like the FBI, DEA, and ATF, and violations are prosecuted in federal courts.',
        type: SectionType.paragraph,
      ),
      ArticleSection(
        heading: 'What Are State Laws?',
        content:
            'State laws are created by state legislatures and apply only within that state\'s borders. Each state has its own constitution, statutes, and regulations covering areas like criminal law, family law, property law, contracts, and most traffic violations.\n\nState laws are enforced by state and local police, and cases are heard in state courts.',
        type: SectionType.paragraph,
      ),
      ArticleSection(
        heading: 'When Federal Law Overrides State Law',
        content:
            '• The Supremacy Clause of the U.S. Constitution makes federal law superior\n• When federal and state laws conflict, federal law prevails\n• States cannot pass laws that violate the U.S. Constitution\n• Federal law sets minimum standards; states can provide more protections',
        type: SectionType.list,
      ),
      ArticleSection(
        heading: 'Key Principle: Supremacy Clause',
        content:
            'This Constitution, and the Laws of the United States which shall be made in Pursuance thereof... shall be the supreme Law of the Land.',
        type: SectionType.quote,
      ),
      ArticleSection(
        heading: 'Why This Matters',
        content:
            'Understanding the difference helps you know which court system has jurisdiction over your case, which law enforcement agency might be involved, and what specific laws apply to your situation. Some crimes can be prosecuted in both federal and state courts.',
        type: SectionType.highlight,
      ),
    ],
    keyTakeaways: [
      'Federal laws apply nationwide; state laws apply within state borders',
      'Federal law overrides state law when they conflict',
      'Most criminal cases are prosecuted at the state level',
      'Some violations can be charged in both systems',
      'Constitutional rights apply in both federal and state courts',
    ],
  ),
];

/// Get articles by category
/// Later: replace with API call, callers unchanged
List<Article> getArticlesByCategory(String category) {
  return sampleArticles.where((a) => a.category == category).toList();
}

/// Get single article by ID
/// Later: replace with API call, callers unchanged
Article? getArticleById(String id) {
  try {
    return sampleArticles.firstWhere((a) => a.id == id);
  } catch (e) {
    return null;
  }
}
