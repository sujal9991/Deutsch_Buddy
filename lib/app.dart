import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const brandBlue = Color(0xFF3157D5);
const pageBackground = Color(0xFFF5F7FC);
const darkText = Color(0xFF17233C);
const softBlue = Color(0xFFEDF1FF);
const softGreen = Color(0xFFEAF8EF);

class DeutschBuddyApp extends StatelessWidget {
  const DeutschBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeutschBuddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: pageBackground,
        colorScheme: ColorScheme.fromSeed(seedColor: brandBlue),
        appBarTheme: const AppBarTheme(
          backgroundColor: pageBackground,
          foregroundColor: darkText,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFE7EAF2)),
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

// ============================================================
// GERMAN TEXT-TO-SPEECH + LEARNER PRONUNCIATION
// ============================================================

class GermanSpeech {
  GermanSpeech._();
  static final FlutterTts _tts = FlutterTts();
  static bool _configured = false;
  static bool _speaking = false;

  static Future<void> speak(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;
    try {
      if (!_configured) {
        await _tts.setLanguage('de-DE');
        await _tts.setSpeechRate(0.42);
        await _tts.setPitch(1.0);
        await _tts.awaitSpeakCompletion(true);
        _configured = true;
      }
      if (_speaking) await _tts.stop();
      _speaking = true;
      await _tts.speak(cleanText);
    } catch (_) {
      // Text-to-speech depends on the device having a German voice installed.
    } finally {
      _speaking = false;
    }
  }
}

/// A beginner-friendly approximation, not phonetic transcription.
/// Prefer the hand-written pronunciation on entries when one is provided.
String pronunciationFor(WordEntry entry) {
  if (entry.pronunciation != null && entry.pronunciation!.trim().isNotEmpty) {
    return entry.pronunciation!;
  }

  var value = entry.german.toLowerCase();
  // Common German spelling-to-sound patterns. These are deliberately simple
  // learning hints; the speaker button provides the actual spoken model.
  value = value
      .replaceAll('sch', 'sh')
      .replaceAll('ch', 'kh')
      .replaceAll('ei', 'eye')
      .replaceAll('ie', 'ee')
      .replaceAll('eu', 'oy')
      .replaceAll('äu', 'oy')
      .replaceAll('sp', 'shp')
      .replaceAll('st', 'sht')
      .replaceAll('z', 'ts')
      .replaceAll('v', 'f')
      .replaceAll('w', 'v')
      .replaceAll('j', 'y')
      .replaceAll('ß', 'ss')
      .replaceAll('ä', 'eh')
      .replaceAll('ö', 'eu')
      .replaceAll('ü', 'ue')
      .replaceAll('qu', 'kv')
      .replaceAll('tsch', 'ch');
  value = value.replaceAll(RegExp(r'[^a-z0-9\s.,!?-]'), '');
  value = value.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (value.isEmpty) return 'Listen to the speaker for pronunciation';
  return value;
}

// ============================================================
// CONTENT MODELS
// ============================================================

class WordEntry {
  final String german;
  final String english;
  final String? pronunciation;
  final String? note;

  const WordEntry(this.german, this.english, {this.pronunciation, this.note});
}

class LessonSection {
  final String title;
  final String description;
  final List<WordEntry> entries;

  const LessonSection({
    required this.title,
    required this.description,
    required this.entries,
  });
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int answer;
  final String explanation;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.answer,
    required this.explanation,
  });
}

class LessonResource {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final IconData icon;
  final List<String> notes;
  final List<LessonSection> sections;
  final List<QuizQuestion> questions;

  const LessonResource({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.icon,
    required this.notes,
    required this.sections,
    required this.questions,
  });
}

// ============================================================
// COMPLETE LEARNING LIBRARY
// ============================================================

const lessons = <LessonResource>[
  LessonResource(
    id: 'alphabet',
    title: 'German alphabet',
    subtitle: 'Learn your letters and special characters',
    category: 'Basics',
    icon: Icons.abc_rounded,
    notes: [
      'German uses the same 26 basic letters as the English alphabet.',
      'German also uses ä, ö and ü, called umlaut vowels, plus ß, called Eszett.',
      'Letter names and actual pronunciation in words are not always the same.',
      'The pronunciation hints below are approximations. Listen to native speakers to learn the exact sounds.',
    ],
    sections: [
      LessonSection(
        title: 'The 26 letters',
        description: 'Select a letter to study its name and a German example.',
        entries: [
          WordEntry('A a', 'ah', pronunciation: 'ah', note: 'Apfel — apple'),
          WordEntry('B b', 'bay', pronunciation: 'beh', note: 'Ball — ball'),
          WordEntry(
            'C c',
            'tsay',
            pronunciation: 'tseh',
            note: 'Computer — computer',
          ),
          WordEntry('D d', 'day', pronunciation: 'deh', note: 'Dach — roof'),
          WordEntry('E e', 'eh', pronunciation: 'eh', note: 'Ente — duck'),
          WordEntry('F f', 'eff', pronunciation: 'eff', note: 'Fisch — fish'),
          WordEntry(
            'G g',
            'gay',
            pronunciation: 'geh',
            note: 'Garten — garden',
          ),
          WordEntry('H h', 'hah', pronunciation: 'hah', note: 'Haus — house'),
          WordEntry('I i', 'ee', pronunciation: 'ee', note: 'Igel — hedgehog'),
          WordEntry('J j', 'yot', pronunciation: 'yot', note: 'Ja — yes'),
          WordEntry('K k', 'kah', pronunciation: 'kah', note: 'Katze — cat'),
          WordEntry('L l', 'ell', pronunciation: 'ell', note: 'Lampe — lamp'),
          WordEntry(
            'M m',
            'emm',
            pronunciation: 'emm',
            note: 'Mutter — mother',
          ),
          WordEntry('N n', 'enn', pronunciation: 'enn', note: 'Nase — nose'),
          WordEntry(
            'O o',
            'oh',
            pronunciation: 'oh',
            note: 'Oma — grandmother',
          ),
          WordEntry('P p', 'pay', pronunciation: 'peh', note: 'Papier — paper'),
          WordEntry(
            'Q q',
            'koo',
            pronunciation: 'koo',
            note: 'Quelle — spring',
          ),
          WordEntry('R r', 'err', pronunciation: 'air', note: 'Rot — red'),
          WordEntry('S s', 'ess', pronunciation: 'ess', note: 'Sonne — sun'),
          WordEntry('T t', 'tay', pronunciation: 'teh', note: 'Tisch — table'),
          WordEntry('U u', 'oo', pronunciation: 'oo', note: 'Uhr — clock'),
          WordEntry('V v', 'fow', pronunciation: 'fow', note: 'Vater — father'),
          WordEntry('W w', 'vay', pronunciation: 'vay', note: 'Wasser — water'),
          WordEntry(
            'X x',
            'iks',
            pronunciation: 'iks',
            note: 'Xylofon — xylophone',
          ),
          WordEntry(
            'Y y',
            'üpsilon',
            pronunciation: 'UUP-see-lon',
            note: 'Yoga — yoga',
          ),
          WordEntry('Z z', 'tset', pronunciation: 'tset', note: 'Zeit — time'),
        ],
      ),
      LessonSection(
        title: 'Special German characters',
        description:
            'These characters are essential for correct German spelling.',
        entries: [
          WordEntry(
            'Ä ä',
            'Umlaut A',
            pronunciation: 'similar to the vowel in “bed”',
            note: 'Mädchen — girl',
          ),
          WordEntry(
            'Ö ö',
            'Umlaut O',
            pronunciation: 'round your lips while saying “eh”',
            note: 'schön — beautiful',
          ),
          WordEntry(
            'Ü ü',
            'Umlaut U',
            pronunciation: 'round your lips while saying “ee”',
            note: 'Tür — door',
          ),
          WordEntry(
            'ẞ ß',
            'Eszett / sharp S',
            pronunciation: 'ss',
            note: 'Straße — street',
          ),
        ],
      ),
      LessonSection(
        title: 'Useful pronunciation rules',
        description: 'Common letter combinations to recognise.',
        entries: [
          WordEntry('ei', 'like “eye”', note: 'mein — my'),
          WordEntry('ie', 'long “ee”', note: 'Liebe — love'),
          WordEntry('eu', 'similar to “oy”', note: 'Deutsch — German'),
          WordEntry('sch', 'similar to “sh”', note: 'Schule — school'),
          WordEntry('z', '“ts” sound', note: 'zehn — ten'),
          WordEntry('w', 'similar to English “v”', note: 'Wasser — water'),
          WordEntry('j', 'similar to English “y”', note: 'ja — yes'),
          WordEntry(
            'v',
            'often “f” in native German words',
            note: 'Vater — father',
          ),
        ],
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'Which character is an umlaut vowel?',
        options: ['B', 'Ä', 'K', 'Z'],
        answer: 1,
        explanation: 'Ä is one of the three German umlaut vowels.',
      ),
      QuizQuestion(
        question: 'How is German J usually pronounced?',
        options: [
          'Like English J',
          'Like English Y',
          'Like English W',
          'Like English Z',
        ],
        answer: 1,
        explanation: 'German J usually sounds like the Y in “yes”.',
      ),
      QuizQuestion(
        question: 'Which combination sounds similar to “eye”?',
        options: ['ie', 'eu', 'ei', 'sch'],
        answer: 2,
        explanation: 'The German combination ei sounds similar to “eye”.',
      ),
      QuizQuestion(
        question: 'What is ß called?',
        options: ['Umlaut', 'Eszett', 'Artikel', 'Vokal'],
        answer: 1,
        explanation: 'ß is called Eszett or sharp S.',
      ),
      QuizQuestion(
        question: 'How is German Z pronounced?',
        options: ['Like English Z', 'Like “ts”', 'Like “sh”', 'Like “th”'],
        answer: 1,
        explanation: 'German Z is pronounced like “ts”.',
      ),
    ],
  ),

  LessonResource(
    id: 'greetings',
    title: 'Greetings and introductions',
    subtitle: 'Say hello and introduce yourself',
    category: 'Basics',
    icon: Icons.waving_hand_rounded,
    notes: [
      'Use Hallo in casual situations. Guten Tag is a polite daytime greeting.',
      'Ich heiße ... means “My name is ...”.',
      'Wie geht es dir? is informal. Wie geht es Ihnen? is formal.',
      'Tschüss is a common informal goodbye. Auf Wiedersehen is more formal.',
    ],
    sections: [
      LessonSection(
        title: 'Greetings',
        description: 'Choose a greeting that suits the time and situation.',
        entries: [
          WordEntry('Hallo!', 'Hello!', pronunciation: 'HAH-loh'),
          WordEntry(
            'Guten Morgen!',
            'Good morning!',
            pronunciation: 'GOO-ten MOR-gen',
          ),
          WordEntry(
            'Guten Tag!',
            'Good day / Hello!',
            pronunciation: 'GOO-ten tahk',
          ),
          WordEntry(
            'Guten Abend!',
            'Good evening!',
            pronunciation: 'GOO-ten AH-bent',
          ),
          WordEntry(
            'Gute Nacht!',
            'Good night!',
            pronunciation: 'GOO-tuh nakht',
          ),
          WordEntry('Tschüss!', 'Bye!', pronunciation: 'choos'),
          WordEntry(
            'Auf Wiedersehen!',
            'Goodbye!',
            pronunciation: 'owf VEE-der-zay-en',
          ),
        ],
      ),
      LessonSection(
        title: 'Introductions',
        description: 'Introduce yourself and ask another person’s name.',
        entries: [
          WordEntry('Ich heiße ...', 'My name is ...'),
          WordEntry('Ich bin ...', 'I am ...'),
          WordEntry('Wie heißt du?', 'What is your name? (informal)'),
          WordEntry('Wie heißen Sie?', 'What is your name? (formal)'),
          WordEntry('Freut mich.', 'Nice to meet you.'),
          WordEntry('Woher kommst du?', 'Where are you from? (informal)'),
          WordEntry('Ich komme aus Indien.', 'I come from India.'),
        ],
      ),
      LessonSection(
        title: 'Polite expressions',
        description: 'Essential expressions for everyday conversations.',
        entries: [
          WordEntry('Bitte', 'Please / You are welcome'),
          WordEntry('Danke', 'Thank you'),
          WordEntry('Vielen Dank', 'Thank you very much'),
          WordEntry('Entschuldigung', 'Excuse me / Sorry'),
          WordEntry('Ja', 'Yes'),
          WordEntry('Nein', 'No'),
          WordEntry('Wie geht es dir?', 'How are you? (informal)'),
          WordEntry('Gut, danke.', 'Good, thank you.'),
        ],
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'What does Guten Morgen mean?',
        options: ['Good evening', 'Good morning', 'Goodbye', 'Thank you'],
        answer: 1,
        explanation: 'Guten Morgen is the standard morning greeting.',
      ),
      QuizQuestion(
        question: 'How do you say “My name is Anna”?',
        options: [
          'Ich bin aus Anna',
          'Ich heiße Anna',
          'Wie geht Anna',
          'Danke Anna',
        ],
        answer: 1,
        explanation: 'Ich heiße Anna means My name is Anna.',
      ),
      QuizQuestion(
        question: 'What does Danke mean?',
        options: ['Please', 'Goodbye', 'Thank you', 'Hello'],
        answer: 2,
        explanation: 'Danke means Thank you.',
      ),
      QuizQuestion(
        question: 'Which is a formal goodbye?',
        options: ['Tschüss', 'Hallo', 'Auf Wiedersehen', 'Bitte'],
        answer: 2,
        explanation: 'Auf Wiedersehen is a polite goodbye.',
      ),
      QuizQuestion(
        question: 'Which question means “How are you?”',
        options: [
          'Wie geht es dir?',
          'Wie heißt du?',
          'Woher kommst du?',
          'Wie spät ist es?',
        ],
        answer: 0,
        explanation: 'Wie geht es dir? means How are you?',
      ),
    ],
  ),

  LessonResource(
    id: 'numbers',
    title: 'Numbers and counting',
    subtitle: 'Count, ask prices and use numbers',
    category: 'Vocabulary',
    icon: Icons.pin_outlined,
    notes: [
      'Learn zero to twelve first. These are the foundation for larger numbers.',
      'Many numbers from thirteen to nineteen end in zehn.',
      'In numbers such as 21, German says “one-and-twenty”: einundzwanzig.',
    ],
    sections: [
      LessonSection(
        title: 'Numbers 0–12',
        description: 'Memorise these basic numbers first.',
        entries: [
          WordEntry('null', 'zero'),
          WordEntry('eins', 'one'),
          WordEntry('zwei', 'two'),
          WordEntry('drei', 'three'),
          WordEntry('vier', 'four'),
          WordEntry('fünf', 'five'),
          WordEntry('sechs', 'six'),
          WordEntry('sieben', 'seven'),
          WordEntry('acht', 'eight'),
          WordEntry('neun', 'nine'),
          WordEntry('zehn', 'ten'),
          WordEntry('elf', 'eleven'),
          WordEntry('zwölf', 'twelve'),
        ],
      ),
      LessonSection(
        title: 'Numbers 13–20',
        description: 'Notice the patterns as you practise.',
        entries: [
          WordEntry('dreizehn', 'thirteen'),
          WordEntry('vierzehn', 'fourteen'),
          WordEntry('fünfzehn', 'fifteen'),
          WordEntry('sechzehn', 'sixteen'),
          WordEntry('siebzehn', 'seventeen'),
          WordEntry('achtzehn', 'eighteen'),
          WordEntry('neunzehn', 'nineteen'),
          WordEntry('zwanzig', 'twenty'),
        ],
      ),
      LessonSection(
        title: 'Tens and useful numbers',
        description: 'Useful for prices, age and counting.',
        entries: [
          WordEntry('dreißig', 'thirty'),
          WordEntry('vierzig', 'forty'),
          WordEntry('fünfzig', 'fifty'),
          WordEntry('sechzig', 'sixty'),
          WordEntry('siebzig', 'seventy'),
          WordEntry('achtzig', 'eighty'),
          WordEntry('neunzig', 'ninety'),
          WordEntry('einhundert', 'one hundred'),
          WordEntry('einundzwanzig', 'twenty-one'),
        ],
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'What does fünf mean?',
        options: ['Four', 'Five', 'Six', 'Seven'],
        answer: 1,
        explanation: 'Fünf means five.',
      ),
      QuizQuestion(
        question: 'What is the German word for twelve?',
        options: ['zehn', 'zwölf', 'zwei', 'zwanzig'],
        answer: 1,
        explanation: 'Zwölf means twelve.',
      ),
      QuizQuestion(
        question: 'What does neunzehn mean?',
        options: ['Nine', 'Ninety', 'Nineteen', 'Ninety-nine'],
        answer: 2,
        explanation: 'Neunzehn means nineteen.',
      ),
      QuizQuestion(
        question: 'What does dreißig mean?',
        options: ['Three', 'Thirteen', 'Thirty', 'Thirteen hundred'],
        answer: 2,
        explanation: 'Dreißig means thirty.',
      ),
      QuizQuestion(
        question: 'How do you say twenty?',
        options: ['zwölf', 'zwanzig', 'zwei', 'zehn'],
        answer: 1,
        explanation: 'Zwanzig means twenty.',
      ),
    ],
  ),

  LessonResource(
    id: 'days',
    title: 'Days of the week',
    subtitle: 'Talk about your weekly routine',
    category: 'Vocabulary',
    icon: Icons.view_week_rounded,
    notes: [
      'German days are nouns and therefore begin with capital letters.',
      'Use am with days of the week: am Montag means on Monday.',
      'Heute ist Montag means Today is Monday.',
      'The German week usually starts with Montag in calendars.',
    ],
    sections: [
      LessonSection(
        title: 'The seven days',
        description: 'Learn the complete week in order.',
        entries: [
          WordEntry('Montag', 'Monday', note: 'am Montag — on Monday'),
          WordEntry('Dienstag', 'Tuesday', note: 'am Dienstag — on Tuesday'),
          WordEntry(
            'Mittwoch',
            'Wednesday',
            note: 'am Mittwoch — on Wednesday',
          ),
          WordEntry(
            'Donnerstag',
            'Thursday',
            note: 'am Donnerstag — on Thursday',
          ),
          WordEntry('Freitag', 'Friday', note: 'am Freitag — on Friday'),
          WordEntry('Samstag', 'Saturday', note: 'am Samstag — on Saturday'),
          WordEntry('Sonntag', 'Sunday', note: 'am Sonntag — on Sunday'),
        ],
      ),
      LessonSection(
        title: 'Useful time expressions',
        description: 'Use these phrases to talk about your schedule.',
        entries: [
          WordEntry('heute', 'today'),
          WordEntry('morgen', 'tomorrow'),
          WordEntry('gestern', 'yesterday'),
          WordEntry('die Woche', 'the week'),
          WordEntry('das Wochenende', 'the weekend'),
          WordEntry('jeden Montag', 'every Monday'),
          WordEntry('am Wochenende', 'at the weekend'),
        ],
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'What does Mittwoch mean?',
        options: ['Monday', 'Wednesday', 'Friday', 'Sunday'],
        answer: 1,
        explanation: 'Mittwoch means Wednesday.',
      ),
      QuizQuestion(
        question: 'What does Sonntag mean?',
        options: ['Saturday', 'Sunday', 'Monday', 'Thursday'],
        answer: 1,
        explanation: 'Sonntag means Sunday.',
      ),
      QuizQuestion(
        question: 'How do you say “on Friday”?',
        options: ['im Freitag', 'am Freitag', 'an Freitag', 'in Freitag'],
        answer: 1,
        explanation: 'Use am with a day: am Freitag.',
      ),
      QuizQuestion(
        question: 'What does gestern mean?',
        options: ['Today', 'Tomorrow', 'Yesterday', 'Week'],
        answer: 2,
        explanation: 'Gestern means yesterday.',
      ),
      QuizQuestion(
        question: 'Which day comes after Dienstag?',
        options: ['Montag', 'Mittwoch', 'Donnerstag', 'Sonntag'],
        answer: 1,
        explanation: 'Mittwoch follows Dienstag.',
      ),
    ],
  ),

  LessonResource(
    id: 'months',
    title: 'Months of the year',
    subtitle: 'Learn dates, birthdays and seasons',
    category: 'Vocabulary',
    icon: Icons.calendar_month_rounded,
    notes: [
      'German month names are nouns and begin with capital letters.',
      'Use im with months: im Januar means in January.',
      'Use am with a date: am dritten Mai means on the third of May.',
      'Seasons are der Frühling (spring), der Sommer (summer), der Herbst (autumn) and der Winter (winter).',
    ],
    sections: [
      LessonSection(
        title: 'The twelve months',
        description: 'Study the months in calendar order.',
        entries: [
          WordEntry('Januar', 'January', note: 'im Januar — in January'),
          WordEntry('Februar', 'February', note: 'im Februar — in February'),
          WordEntry('März', 'March', note: 'im März — in March'),
          WordEntry('April', 'April', note: 'im April — in April'),
          WordEntry('Mai', 'May', note: 'im Mai — in May'),
          WordEntry('Juni', 'June', note: 'im Juni — in June'),
          WordEntry('Juli', 'July', note: 'im Juli — in July'),
          WordEntry('August', 'August', note: 'im August — in August'),
          WordEntry(
            'September',
            'September',
            note: 'im September — in September',
          ),
          WordEntry('Oktober', 'October', note: 'im Oktober — in October'),
          WordEntry('November', 'November', note: 'im November — in November'),
          WordEntry('Dezember', 'December', note: 'im Dezember — in December'),
        ],
      ),
      LessonSection(
        title: 'The four seasons',
        description: 'Describe the time of year.',
        entries: [
          WordEntry('der Frühling', 'spring'),
          WordEntry('der Sommer', 'summer'),
          WordEntry('der Herbst', 'autumn / fall'),
          WordEntry('der Winter', 'winter'),
        ],
      ),
      LessonSection(
        title: 'Dates and birthdays',
        description: 'Practise common expressions.',
        entries: [
          WordEntry('Wann hast du Geburtstag?', 'When is your birthday?'),
          WordEntry('Ich habe im Mai Geburtstag.', 'My birthday is in May.'),
          WordEntry('das Datum', 'the date'),
          WordEntry('der Monat', 'the month'),
          WordEntry('das Jahr', 'the year'),
        ],
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'What does März mean?',
        options: ['May', 'March', 'June', 'August'],
        answer: 1,
        explanation: 'März means March.',
      ),
      QuizQuestion(
        question: 'What does Dezember mean?',
        options: ['October', 'November', 'December', 'January'],
        answer: 2,
        explanation: 'Dezember means December.',
      ),
      QuizQuestion(
        question: 'How do you say “in July”?',
        options: ['am Juli', 'im Juli', 'an Juli', 'in der Juli'],
        answer: 1,
        explanation: 'Use im with months: im Juli.',
      ),
      QuizQuestion(
        question: 'Which German word means summer?',
        options: ['Winter', 'Herbst', 'Frühling', 'Sommer'],
        answer: 3,
        explanation: 'Sommer means summer.',
      ),
      QuizQuestion(
        question: 'How do you ask “When is your birthday?”',
        options: [
          'Wie alt bist du?',
          'Wann hast du Geburtstag?',
          'Wie heißt du?',
          'Wo wohnst du?',
        ],
        answer: 1,
        explanation:
            'Wann hast du Geburtstag? asks when someone’s birthday is.',
      ),
    ],
  ),

  LessonResource(
    id: 'family',
    title: 'Family and people',
    subtitle: 'Talk about friends and family',
    category: 'Vocabulary',
    icon: Icons.family_restroom_rounded,
    notes: [
      'Learn German nouns together with their articles.',
      'Mein and meine both mean “my”, but the form depends on grammatical gender and case.',
      'Example: meine Mutter, mein Vater, meine Schwester.',
    ],
    sections: [
      LessonSection(
        title: 'Family members',
        description: 'Words for immediate and extended family.',
        entries: [
          WordEntry('die Familie', 'family'),
          WordEntry('die Mutter', 'mother'),
          WordEntry('der Vater', 'father'),
          WordEntry('die Eltern', 'parents'),
          WordEntry('der Bruder', 'brother'),
          WordEntry('die Schwester', 'sister'),
          WordEntry('das Kind', 'child'),
          WordEntry('die Kinder', 'children'),
          WordEntry('die Großmutter', 'grandmother'),
          WordEntry('der Großvater', 'grandfather'),
          WordEntry('die Großeltern', 'grandparents'),
        ],
      ),
      LessonSection(
        title: 'Friends and relationships',
        description: 'Describe people in your life.',
        entries: [
          WordEntry(
            'der Freund',
            'male friend / boyfriend, depending on context',
          ),
          WordEntry(
            'die Freundin',
            'female friend / girlfriend, depending on context',
          ),
          WordEntry('der Mensch', 'person / human being'),
          WordEntry('die Person', 'person'),
          WordEntry('der Mann', 'man'),
          WordEntry('die Frau', 'woman'),
        ],
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'What does die Mutter mean?',
        options: ['Mother', 'Sister', 'Friend', 'Grandmother'],
        answer: 0,
        explanation: 'Die Mutter means mother.',
      ),
      QuizQuestion(
        question: 'What does der Bruder mean?',
        options: ['Father', 'Brother', 'Son', 'Grandfather'],
        answer: 1,
        explanation: 'Der Bruder means brother.',
      ),
      QuizQuestion(
        question: 'What does die Eltern mean?',
        options: ['Children', 'Parents', 'Friends', 'Sisters'],
        answer: 1,
        explanation: 'Die Eltern means parents.',
      ),
      QuizQuestion(
        question: 'What does die Schwester mean?',
        options: ['Sister', 'Mother', 'Daughter', 'Friend'],
        answer: 0,
        explanation: 'Die Schwester means sister.',
      ),
      QuizQuestion(
        question: 'What does die Großeltern mean?',
        options: ['Parents', 'Grandparents', 'Children', 'Cousins'],
        answer: 1,
        explanation: 'Die Großeltern means grandparents.',
      ),
    ],
  ),

  LessonResource(
    id: 'pronouns',
    title: 'Personal pronouns',
    subtitle: 'Ich, du, er, sie and wir',
    category: 'Grammar',
    icon: Icons.people_alt_outlined,
    notes: [
      'Pronouns replace names and nouns.',
      'Du is informal singular “you”. Sie is formal “you” and is capitalised in that use.',
      'Sie can also mean “she” or “they”. Context helps you understand its meaning.',
    ],
    sections: [
      LessonSection(
        title: 'Subject pronouns',
        description: 'Learn the pronouns used as the subject of a sentence.',
        entries: [
          WordEntry('ich', 'I'),
          WordEntry('du', 'you — informal singular'),
          WordEntry('er', 'he'),
          WordEntry('sie', 'she'),
          WordEntry('es', 'it'),
          WordEntry('wir', 'we'),
          WordEntry('ihr', 'you — informal plural'),
          WordEntry('sie', 'they'),
          WordEntry('Sie', 'you — formal'),
        ],
      ),
      LessonSection(
        title: 'Example sentences',
        description: 'See how pronouns work in context.',
        entries: [
          WordEntry('Ich bin Student.', 'I am a student.'),
          WordEntry('Du bist nett.', 'You are nice.'),
          WordEntry('Er wohnt hier.', 'He lives here.'),
          WordEntry('Sie lernt Deutsch.', 'She is learning German.'),
          WordEntry('Wir lernen zusammen.', 'We learn together.'),
          WordEntry('Sie wohnen in Berlin.', 'They live in Berlin.'),
        ],
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'What does ich mean?',
        options: ['You', 'I', 'We', 'They'],
        answer: 1,
        explanation: 'Ich means I.',
      ),
      QuizQuestion(
        question: 'Which pronoun means we?',
        options: ['ihr', 'er', 'wir', 'du'],
        answer: 2,
        explanation: 'Wir means we.',
      ),
      QuizQuestion(
        question: 'Which is formal “you”?',
        options: ['du', 'ich', 'er', 'Sie'],
        answer: 3,
        explanation: 'Sie is the formal form of you.',
      ),
      QuizQuestion(
        question: 'What does er mean?',
        options: ['She', 'He', 'We', 'You'],
        answer: 1,
        explanation: 'Er means he.',
      ),
      QuizQuestion(
        question: 'Which is informal singular “you”?',
        options: ['du', 'wir', 'sie', 'es'],
        answer: 0,
        explanation: 'Du is informal singular you.',
      ),
    ],
  ),

  LessonResource(
    id: 'articles',
    title: 'German articles',
    subtitle: 'Der, die, das, ein and eine',
    category: 'Grammar',
    icon: Icons.menu_book_rounded,
    notes: [
      'German nouns have grammatical gender: masculine, feminine or neuter.',
      'The basic nominative definite articles are der, die and das.',
      'Learn every noun with its article, such as der Tisch and das Buch.',
      'Articles change in other grammatical cases. These examples focus on the nominative.',
    ],
    sections: [
      LessonSection(
        title: 'Definite articles',
        description: 'These correspond to “the” in basic nominative examples.',
        entries: [
          WordEntry('der Mann', 'the man — masculine'),
          WordEntry('die Frau', 'the woman — feminine'),
          WordEntry('das Kind', 'the child — neuter'),
          WordEntry('der Tisch', 'the table — masculine'),
          WordEntry('die Lampe', 'the lamp — feminine'),
          WordEntry('das Buch', 'the book — neuter'),
        ],
      ),
      LessonSection(
        title: 'Indefinite articles',
        description: 'These often correspond to “a” or “an”.',
        entries: [
          WordEntry('ein Mann', 'a man'),
          WordEntry('eine Frau', 'a woman'),
          WordEntry('ein Kind', 'a child'),
          WordEntry('ein Tisch', 'a table'),
          WordEntry('eine Lampe', 'a lamp'),
          WordEntry('ein Buch', 'a book'),
        ],
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'Which article goes with Frau?',
        options: ['der', 'die', 'das', 'dem'],
        answer: 1,
        explanation: 'Frau is feminine: die Frau.',
      ),
      QuizQuestion(
        question: 'What is the basic nominative article for Buch?',
        options: ['der', 'die', 'das', 'den'],
        answer: 2,
        explanation: 'Buch is neuter: das Buch.',
      ),
      QuizQuestion(
        question: 'How do you say “the man”?',
        options: ['die Mann', 'das Mann', 'der Mann', 'dem Mann'],
        answer: 2,
        explanation: 'Mann is masculine: der Mann.',
      ),
      QuizQuestion(
        question: 'How do you say “a woman”?',
        options: ['ein Frau', 'eine Frau', 'der Frau', 'das Frau'],
        answer: 1,
        explanation: 'Eine is the basic nominative indefinite article for feminine nouns.',
      ),
      QuizQuestion(
        question: 'What is the best way to memorise a noun?',
        options: [
          'Without its article',
          'Only the English word',
          'Together with its article',
          'Only the first letter',
        ],
        answer: 2,
        explanation: 'Learn nouns together with their grammatical articles.',
      ),
    ],
  ),

  LessonResource(
    id: 'verbs',
    title: 'Sein and haben',
    subtitle: 'Learn “to be” and “to have”',
    category: 'Grammar',
    icon: Icons.edit_note_rounded,
    notes: [
      'Sein means “to be”. It is irregular, so memorise its forms.',
      'Haben means “to have”. Notice that du hast and er/sie/es hat differ from the infinitive.',
      'Example: Ich bin Student. Ich habe ein Buch.',
    ],
    sections: [
      LessonSection(
        title: 'The verb sein',
        description: 'Learn the present-tense forms.',
        entries: [
          WordEntry('ich bin', 'I am'),
          WordEntry('du bist', 'you are — informal'),
          WordEntry('er/sie/es ist', 'he/she/it is'),
          WordEntry('wir sind', 'we are'),
          WordEntry('ihr seid', 'you all are'),
          WordEntry('sie/Sie sind', 'they are / you are — formal'),
        ],
      ),
      LessonSection(
        title: 'The verb haben',
        description: 'Learn the present-tense forms.',
        entries: [
          WordEntry('ich habe', 'I have'),
          WordEntry('du hast', 'you have — informal'),
          WordEntry('er/sie/es hat', 'he/she/it has'),
          WordEntry('wir haben', 'we have'),
          WordEntry('ihr habt', 'you all have'),
          WordEntry('sie/Sie haben', 'they have / you have — formal'),
        ],
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'Complete: Ich ___ müde.',
        options: ['habe', 'bin', 'bist', 'sind'],
        answer: 1,
        explanation: 'Use bin with ich: Ich bin müde.',
      ),
      QuizQuestion(
        question: 'Complete: Du ___ nett.',
        options: ['ist', 'sind', 'bist', 'seid'],
        answer: 2,
        explanation: 'The form for du is bist.',
      ),
      QuizQuestion(
        question: 'What does haben mean?',
        options: ['To go', 'To have', 'To speak', 'To be'],
        answer: 1,
        explanation: 'Haben means to have.',
      ),
      QuizQuestion(
        question: 'Complete: Wir ___ hier.',
        options: ['bin', 'bist', 'ist', 'sind'],
        answer: 3,
        explanation: 'Use sind with wir.',
      ),
      QuizQuestion(
        question: 'Complete: Er ___ ein Buch.',
        options: ['habe', 'hast', 'hat', 'haben'],
        answer: 2,
        explanation: 'Use hat with er, sie or es.',
      ),
    ],
  ),

  LessonResource(
    id: 'sentences',
    title: 'Basic sentence structure',
    subtitle: 'Build your first German sentences',
    category: 'Grammar',
    icon: Icons.format_align_left_rounded,
    notes: [
      'In a simple German main clause, the conjugated verb usually occupies the second position.',
      'Ich lerne Deutsch means “I am learning German”.',
      'A time expression can come first: Heute lerne ich Deutsch. The verb remains in second position.',
      'Question and subordinate-clause word order can differ. Start with simple main clauses.',
    ],
    sections: [
      LessonSection(
        title: 'Simple sentences',
        description:
            'Subject + verb + other information is a useful starting pattern.',
        entries: [
          WordEntry('Ich lerne Deutsch.', 'I am learning German.'),
          WordEntry('Du bist nett.', 'You are nice.'),
          WordEntry('Er wohnt in Berlin.', 'He lives in Berlin.'),
          WordEntry('Wir spielen Fußball.', 'We play football.'),
          WordEntry('Ich habe einen Hund.', 'I have a dog.'),
        ],
      ),
      LessonSection(
        title: 'Time expressions first',
        description: 'The verb still stays in the second position.',
        entries: [
          WordEntry('Heute lerne ich Deutsch.', 'Today I am learning German.'),
          WordEntry('Morgen arbeite ich.', 'Tomorrow I am working.'),
          WordEntry('Am Montag lerne ich.', 'On Monday I study.'),
          WordEntry('Im Sommer reise ich.', 'In summer I travel.'),
        ],
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'Choose the correct sentence.',
        options: [
          'Ich Deutsch lerne.',
          'Ich lerne Deutsch.',
          'Lerne Deutsch ich.',
          'Deutsch ich lerne.',
        ],
        answer: 1,
        explanation: 'The conjugated verb lerne is in the second position.',
      ),
      QuizQuestion(
        question: 'Complete: Heute ___ ich Deutsch.',
        options: ['lerne', 'Deutsch', 'ich', 'lernen'],
        answer: 0,
        explanation: 'Heute is first and lerne is second.',
      ),
      QuizQuestion(
        question: 'What does Ich habe einen Hund mean?',
        options: ['I see a dog', 'I have a dog', 'I am a dog', 'I like dogs'],
        answer: 1,
        explanation: 'Ich habe einen Hund means I have a dog.',
      ),
      QuizQuestion(
        question: 'Where does the conjugated verb usually go in a simple main clause?',
        options: [
          'Always last',
          'Usually second',
          'Always first',
          'It is omitted',
        ],
        answer: 1,
        explanation: 'The verb usually occupies the second position.',
      ),
      QuizQuestion(
        question: 'What does Wir spielen Fußball mean?',
        options: [
          'We play football',
          'They learn German',
          'We have a car',
          'I play football',
        ],
        answer: 0,
        explanation: 'Wir means we and spielen means play.',
      ),
    ],
  ),
];

// ============================================================
// LOCAL PROGRESS STORAGE
// ============================================================

class ProgressStore {
  static String completedKey(String id) => 'lesson_${id}_completed';
  static String bestKey(String id) => 'lesson_${id}_best';
  static String lastKey(String id) => 'lesson_${id}_last';

  static Future<Map<String, dynamic>> load() async {
    final prefs = await SharedPreferences.getInstance();
    int completedCount = 0;
    int xp = 0;
    final byLesson = <String, Map<String, dynamic>>{};

    for (final lesson in lessons) {
      final completed = prefs.getBool(completedKey(lesson.id)) ?? false;
      final best = prefs.getInt(bestKey(lesson.id)) ?? 0;
      final last = prefs.getInt(lastKey(lesson.id)) ?? 0;
      if (completed) completedCount++;
      xp += best * 10;
      byLesson[lesson.id] = {
        'completed': completed,
        'best': best,
        'last': last,
      };
    }

    return {'completedCount': completedCount, 'xp': xp, 'lessons': byLesson};
  }

  static Future<void> saveResult(LessonResource lesson, int score) async {
    final prefs = await SharedPreferences.getInstance();
    final oldBest = prefs.getInt(bestKey(lesson.id)) ?? 0;

    await prefs.setBool(completedKey(lesson.id), true);
    await prefs.setInt(bestKey(lesson.id), score > oldBest ? score : oldBest);
    await prefs.setInt(lastKey(lesson.id), score);
  }

  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    for (final lesson in lessons) {
      await prefs.remove(completedKey(lesson.id));
      await prefs.remove(bestKey(lesson.id));
      await prefs.remove(lastKey(lesson.id));
    }
  }
}

// ============================================================
// AUTH
// ============================================================

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (Supabase.instance.client.auth.currentSession != null) {
          return const HomePage();
        }
        return const AuthPage();
      },
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _login = true;
  bool _loading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text;

    if (email.isEmpty || password.isEmpty) {
      _message('Enter your email and password.');
      return;
    }

    setState(() => _loading = true);
    try {
      final auth = Supabase.instance.client.auth;
      if (_login) {
        await auth.signInWithPassword(email: email, password: password);
      } else {
        await auth.signUp(email: email, password: password);
      }
    } on AuthException catch (e) {
      _message(e.message);
    } catch (_) {
      _message('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _message(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: brandBlue,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.translate_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'DeutschBuddy',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _login
                        ? 'Welcome back! Continue learning German.'
                        : 'Create your account.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email address',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _password,
                    obscureText: _hidePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => _hidePassword = !_hidePassword),
                        icon: Icon(
                          _hidePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 22),
                  FilledButton(
                    onPressed: _loading ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: brandBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_login ? 'Log in' : 'Create account'),
                  ),
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () => setState(() => _login = !_login),
                    child: Text(
                      _login
                          ? 'New here? Create an account'
                          : 'Already registered? Log in',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// MAIN NAVIGATION
// ============================================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;
  int _refresh = 0;

  void _progressUpdated() => setState(() => _refresh++);

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardTab(
        refreshToken: _refresh,
        onLearn: () => setState(() => _index = 1),
      ),
      LearnTab(onProgressUpdated: _progressUpdated),
      const ToolsTab(),
      ProfileTab(onProgressUpdated: _progressUpdated),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _index, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            label: 'Learn',
          ),
          NavigationDestination(
            icon: Icon(Icons.widgets_outlined),
            label: 'Tools',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DASHBOARD
// ============================================================

class DashboardTab extends StatefulWidget {
  final int refreshToken;
  final VoidCallback onLearn;

  const DashboardTab({
    super.key,
    required this.refreshToken,
    required this.onLearn,
  });

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  Map<String, dynamic>? _progress;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant DashboardTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) _load();
  }

  Future<void> _load() async {
    final progress = await ProgressStore.load();
    if (mounted) setState(() => _progress = progress);
  }

  @override
  Widget build(BuildContext context) {
    final count = _progress?['completedCount'] ?? 0;
    final xp = _progress?['xp'] ?? 0;
    final progress = count / lessons.length;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Hallo! 👋', style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 5),
        const Text(
          'Your German journey',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: const LinearGradient(
              colors: [Color(0xFF3157D5), Color(0xFF7187E9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'DEIN DEUTSCH',
                style: TextStyle(color: Colors.white70, letterSpacing: 1.5),
              ),
              const SizedBox(height: 12),
              const Text(
                'Learn German.\nOne step at a time.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Build your vocabulary and confidence every day.',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: widget.onLearn,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: brandBlue,
                ),
                child: const Text('Explore lessons'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Your progress',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _stat(
                'Lessons',
                _progress == null ? '—' : '$count/${lessons.length}',
                Icons.menu_book,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _stat(
                'Total XP',
                _progress == null ? '—' : '$xp',
                Icons.bolt,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'A1 learning progress',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(value: progress, minHeight: 9),
                ),
                const SizedBox(height: 8),
                Text('${(progress * 100).round()}% of lessons completed'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Start learning',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...lessons
            .take(4)
            .map(
              (lesson) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  leading: CircleAvatar(
                    backgroundColor: softBlue,
                    foregroundColor: brandBlue,
                    child: Icon(lesson.icon),
                  ),
                  title: Text(
                    lesson.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(lesson.category),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                  ),
                  onTap: widget.onLearn,
                ),
              ),
            ),
      ],
    );
  }

  Widget _stat(String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: brandBlue, size: 27),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),
            Text(label, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// LEARN TAB
// ============================================================

class LearnTab extends StatefulWidget {
  final VoidCallback onProgressUpdated;

  const LearnTab({super.key, required this.onProgressUpdated});

  @override
  State<LearnTab> createState() => _LearnTabState();
}

class _LearnTabState extends State<LearnTab> {
  String _category = 'All';
  Map<String, dynamic> _progress = {};
  bool _loading = true;

  final categories = const ['All', 'Basics', 'Vocabulary', 'Grammar'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ProgressStore.load();
    if (!mounted) return;
    setState(() {
      _progress = data['lessons'] as Map<String, dynamic>;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = lessons
        .where((lesson) => _category == 'All' || lesson.category == _category)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Learn German',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 7),
        const Text('Choose a topic and study at your own pace.'),
        const SizedBox(height: 20),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((category) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(category),
                  selected: _category == category,
                  onSelected: (_) => setState(() => _category = category),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        if (_loading) const LinearProgressIndicator(),
        ...filtered.map((lesson) {
          final data = _progress[lesson.id] as Map<String, dynamic>?;
          final completed = data?['completed'] == true;
          final best = data?['best'] ?? 0;

          return Card(
            margin: const EdgeInsets.only(bottom: 13),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => LessonPage(lesson: lesson)),
                );
                if (result == true) {
                  await _load();
                  widget.onProgressUpdated();
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 60,
                      decoration: BoxDecoration(
                        color: softBlue,
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Icon(lesson.icon, color: brandBlue, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lesson.category.toUpperCase(),
                            style: const TextStyle(
                              color: brandBlue,
                              fontSize: 10,
                              letterSpacing: 1.1,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            lesson.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lesson.subtitle,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                          if (completed) ...[
                            const SizedBox(height: 7),
                            Text(
                              'Completed · Best: $best/${lesson.questions.length}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      completed
                          ? Icons.check_circle_rounded
                          : Icons.arrow_forward_ios_rounded,
                      size: 18,
                      color: completed ? Colors.green : Colors.black38,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ============================================================
// LESSON PAGE
// ============================================================

class LessonPage extends StatefulWidget {
  final LessonResource lesson;

  const LessonPage({super.key, required this.lesson});

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  int _stage = 0;
  int _questionIndex = 0;
  int _score = 0;
  int? _selected;
  bool _answered = false;
  bool _saving = false;
  bool _saved = false;
  String? _saveError;

  Future<void> _finishQuiz() async {
    setState(() {
      _stage = 2;
      _saving = true;
      _saveError = null;
    });

    try {
      await ProgressStore.saveResult(widget.lesson, _score);
      if (mounted) {
        setState(() {
          _saving = false;
          _saved = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _saveError = 'Could not save your progress. Please retry.';
        });
      }
    }
  }

  Future<void> _retrySave() async {
    setState(() {
      _saving = true;
      _saveError = null;
    });

    try {
      await ProgressStore.saveResult(widget.lesson, _score);
      if (mounted) {
        setState(() {
          _saving = false;
          _saved = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _saveError = 'Could not save your progress. Please try again.';
        });
      }
    }
  }

  void _answer(int index) {
    if (_answered) return;
    setState(() {
      _selected = index;
      _answered = true;
      if (index == widget.lesson.questions[_questionIndex].answer) _score++;
    });
  }

  void _next() {
    if (_questionIndex < widget.lesson.questions.length - 1) {
      setState(() {
        _questionIndex++;
        _selected = null;
        _answered = false;
      });
    } else {
      _finishQuiz();
    }
  }

  void _restart() {
    setState(() {
      _stage = 0;
      _questionIndex = 0;
      _score = 0;
      _selected = null;
      _answered = false;
      _saving = false;
      _saved = false;
      _saveError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.lesson.title)),
      body: SafeArea(
        child: _stage == 0
            ? _buildStudyPage()
            : _stage == 1
            ? _buildQuiz()
            : _buildResult(),
      ),
    );
  }

  Widget _buildStudyPage() {
    final isAlphabet = widget.lesson.id == 'alphabet';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFF3157D5), Color(0xFF7187E9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.lesson.category.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white70,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.lesson.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.lesson.subtitle,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Icon(
                    Icons.menu_book_rounded,
                    color: Colors.white70,
                    size: 18,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    '${widget.lesson.sections.fold<int>(0, (sum, section) => sum + section.entries.length)} study items',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 18),
                  const Icon(
                    Icons.quiz_outlined,
                    color: Colors.white70,
                    size: 18,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    '${widget.lesson.questions.length} questions',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _SectionHeading(
          title: 'Before you begin',
          subtitle: 'A few important things to remember',
        ),
        ...widget.lesson.notes.map(
          (note) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE7EAF2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline_rounded, color: brandBlue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(note, style: const TextStyle(height: 1.5)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        for (var i = 0; i < widget.lesson.sections.length; i++)
          _buildSection(widget.lesson.sections[i], i, isAlphabet),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => setState(() => _stage = 1),
          icon: const Icon(Icons.quiz_rounded),
          label: Text('Start ${widget.lesson.questions.length}-question quiz'),
          style: FilledButton.styleFrom(
            backgroundColor: brandBlue,
            padding: const EdgeInsets.symmetric(vertical: 17),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSection(LessonSection section, int index, bool isAlphabet) {
    final alphabetSection = isAlphabet && index == 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(title: section.title, subtitle: section.description),
          const SizedBox(height: 12),
          if (alphabetSection)
            _buildAlphabetGrid(section.entries)
          else
            ...section.entries.map(_buildWordCard),
        ],
      ),
    );
  }

  Widget _buildAlphabetGrid(List<WordEntry> entries) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 520 ? 7 : 4;
        final spacing = 9.0;
        final tileWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: entries.map((entry) {
            return SizedBox(
              width: tileWidth,
              height: 94,
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => showModalBottomSheet<void>(
                    context: context,
                    showDragHandle: true,
                    builder: (context) => SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.german,
                              style: const TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.bold,
                                color: brandBlue,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Letter name: ${entry.english}',
                              style: const TextStyle(fontSize: 17),
                            ),
                            const SizedBox(height: 8),
                            Text('Say it like: ${pronunciationFor(entry)}'),
                            if (entry.note != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                entry.note!,
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                            const SizedBox(height: 14),
                            FilledButton.icon(
                              onPressed: () => GermanSpeech.speak(
                                entry.german.replaceAll(
                                  RegExp(r'\s+[a-z]$'),
                                  '',
                                ),
                              ),
                              icon: const Icon(Icons.volume_up_rounded),
                              label: const Text('Listen in German'),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Pronunciation hints are approximations. Audio uses your device’s German voice.',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE4E9F5)),
                    ),
                    padding: const EdgeInsets.all(7),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          entry.german.split(' ').first,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: brandBlue,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Say: ${pronunciationFor(entry)}',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 9, color: brandBlue),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          entry.english,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildWordCard(WordEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E9F2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: softBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.translate_rounded,
                color: brandBlue,
                size: 21,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.german,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(entry.english, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 6),
                  Text(
                    'Say it like: ${pronunciationFor(entry)}',
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                  if (entry.note != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      entry.note!,
                      style: const TextStyle(color: brandBlue, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              tooltip: 'Listen to German pronunciation',
              onPressed: () => GermanSpeech.speak(entry.german),
              icon: const Icon(Icons.volume_up_rounded, color: brandBlue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuiz() {
    final question = widget.lesson.questions[_questionIndex];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'KNOWLEDGE CHECK',
              style: TextStyle(
                color: brandBlue,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            Text('${_questionIndex + 1}/${widget.lesson.questions.length}'),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: (_questionIndex + 1) / widget.lesson.questions.length,
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 30),
        Text(
          question.question,
          style: const TextStyle(
            fontSize: 25,
            height: 1.3,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 22),
        ...List.generate(question.options.length, (index) {
          final correct = index == question.answer;
          final selected = index == _selected;
          Color background = Colors.white;
          Color border = const Color(0xFFE2E7F0);

          if (_answered && correct) {
            background = softGreen;
            border = Colors.green;
          } else if (_answered && selected) {
            background = const Color(0xFFFFEEEE);
            border = Colors.red;
          } else if (selected) {
            background = softBlue;
            border = brandBlue;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border, width: 1.4),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _answered ? null : () => _answer(index),
              child: Padding(
                padding: const EdgeInsets.all(17),
                child: Row(
                  children: [
                    Expanded(child: Text(question.options[index])),
                    if (_answered && correct)
                      const Icon(Icons.check_circle, color: Colors.green),
                    if (_answered && selected && !correct)
                      const Icon(Icons.cancel, color: Colors.red),
                  ],
                ),
              ),
            ),
          );
        }),
        if (_answered) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '${_selected == question.answer ? 'Correct! ' : 'Not quite. '}${question.explanation}',
                style: const TextStyle(height: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _next,
            style: FilledButton.styleFrom(
              backgroundColor: brandBlue,
              padding: const EdgeInsets.all(16),
            ),
            child: Text(
              _questionIndex == widget.lesson.questions.length - 1
                  ? 'Finish quiz'
                  : 'Next question',
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResult() {
    final total = widget.lesson.questions.length;
    final percentage = (_score / total * 100).round();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.emoji_events_rounded,
              size: 78,
              color: Color(0xFFE6A323),
            ),
            const SizedBox(height: 18),
            const Text(
              'Lesson completed!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$_score / $total',
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: brandBlue,
              ),
            ),
            Text('$percentage% correct'),
            const SizedBox(height: 15),
            Text(
              _score == total
                  ? 'Ausgezeichnet! Perfect score!'
                  : _score >= (total / 2).ceil()
                  ? 'Sehr gut! Keep practising!'
                  : 'Gut gemacht! Review your notes and try again.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '+ ${_score * 10} XP for this score',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFE69B22),
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 16),
            if (_saving)
              const CircularProgressIndicator()
            else if (_saveError != null)
              Column(
                children: [
                  Text(_saveError!, style: const TextStyle(color: Colors.red)),
                  TextButton(
                    onPressed: _retrySave,
                    child: const Text('Retry saving'),
                  ),
                ],
              )
            else if (_saved)
              const Text(
                'Progress saved on this device.',
                style: TextStyle(color: Colors.green),
              ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: !_saved ? null : () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(
                  backgroundColor: brandBlue,
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text('Back to lessons'),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _saving ? null : _restart,
              child: const Text('Study again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeading({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.black54, height: 1.4),
        ),
      ],
    );
  }
}

// ============================================================
// TOOLS
// ============================================================

class ToolsTab extends StatelessWidget {
  const ToolsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        'Vocabulary library',
        'Study grouped vocabulary in the Learn tab.',
        Icons.translate_rounded,
      ),
      (
        'Pronunciation guide',
        'Review letter sounds and pronunciation hints.',
        Icons.record_voice_over_rounded,
      ),
      (
        'Grammar lessons',
        'Learn pronouns, articles and verbs.',
        Icons.menu_book_rounded,
      ),
      (
        'Exam practice',
        'Additional exam-style tests can be added next.',
        Icons.assignment_outlined,
      ),
      (
        'AI tutor',
        'AI conversation features are planned for a later stage.',
        Icons.smart_toy_outlined,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Learning tools',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 8),
        const Text('Extra resources to support your German learning.'),
        const SizedBox(height: 20),
        ...items.map(
          (item) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: softBlue,
                foregroundColor: brandBlue,
                child: Icon(item.$3),
              ),
              title: Text(
                item.$1,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(item.$2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// PROFILE
// ============================================================

class ProfileTab extends StatelessWidget {
  final VoidCallback onProgressUpdated;

  const ProfileTab({super.key, required this.onProgressUpdated});

  Future<void> _reset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset learning progress?'),
        content: const Text(
          'All saved lesson scores and completion status will be removed from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ProgressStore.reset();
    onProgressUpdated();

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Learning progress reset.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Your profile',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 20),
        Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(18),
            leading: const CircleAvatar(
              backgroundColor: softBlue,
              foregroundColor: brandBlue,
              child: Icon(Icons.person_rounded),
            ),
            title: const Text('DeutschBuddy learner'),
            subtitle: Text(user?.email ?? 'Signed-in user'),
          ),
        ),
        Card(
          child: Column(
            children: [
              const ListTile(
                leading: Icon(Icons.flag_outlined, color: brandBlue),
                title: Text('Learning level'),
                subtitle: Text('A1 · Beginner'),
              ),
              const Divider(height: 1),
              const ListTile(
                leading: Icon(Icons.storage_outlined, color: brandBlue),
                title: Text('Progress storage'),
                subtitle: Text('Saved locally on this device'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(
                  Icons.restart_alt_rounded,
                  color: Colors.red,
                ),
                title: const Text('Reset learning progress'),
                onTap: () => _reset(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () async {
            try {
              await Supabase.instance.client.auth.signOut();
            } catch (_) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sign out failed. Please try again.'),
                  ),
                );
              }
            }
          },
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Sign out'),
          style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
        ),
      ],
    );
  }
}
