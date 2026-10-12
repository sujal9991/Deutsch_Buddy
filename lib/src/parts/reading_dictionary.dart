part of '../../app.dart';

// ============================================================
// A1 READING LIBRARY + OFFLINE DICTIONARY
// ============================================================

class ReadingParagraph {
  final String german;
  final String english;
  const ReadingParagraph(this.german, this.english);
}

class ReadingBook {
  final String id;
  final String title;
  final String description;
  final int minutes;
  final List<ReadingParagraph> paragraphs;
  final List<QuizQuestion> questions;

  const ReadingBook({
    required this.id,
    required this.title,
    required this.description,
    required this.minutes,
    required this.paragraphs,
    required this.questions,
  });
}

const readingBooks = <ReadingBook>[
  ReadingBook(
    id: 'ein_tag_in_berlin',
    title: 'Ein Tag in Berlin',
    description: 'A day in Berlin · greetings, places and daily routine',
    minutes: 4,
    paragraphs: [
      ReadingParagraph(
        'Hallo! Ich heiße Mia. Ich wohne in Berlin. Ich bin zwanzig Jahre alt.',
        'Hello! My name is Mia. I live in Berlin. I am twenty years old.',
      ),
      ReadingParagraph(
        'Am Morgen stehe ich um sieben Uhr auf. Ich frühstücke und trinke Tee. Dann fahre ich mit dem Bus zur Schule.',
        'In the morning, I get up at seven o’clock. I eat breakfast and drink tea. Then I take the bus to school.',
      ),
      ReadingParagraph(
        'Am Nachmittag treffe ich meinen Freund Leo im Park. Wir sprechen und spielen Fußball. Am Abend esse ich zu Hause und lese ein Buch.',
        'In the afternoon, I meet my friend Leo in the park. We talk and play football. In the evening, I eat at home and read a book.',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'Wo wohnt Mia?',
        options: ['In Berlin', 'In Wien', 'In Hamburg', 'In München'],
        answer: 0,
        explanation: 'Mia sagt: Ich wohne in Berlin.',
      ),
      QuizQuestion(
        question: 'Was trinkt Mia am Morgen?',
        options: ['Kaffee', 'Tee', 'Wasser', 'Milch'],
        answer: 1,
        explanation: 'Sie trinkt Tee.',
      ),
      QuizQuestion(
        question: 'Wen trifft Mia im Park?',
        options: [
          'Ihre Mutter',
          'Ihren Lehrer',
          'Ihren Freund Leo',
          'Ihre Schwester',
        ],
        answer: 2,
        explanation: 'Am Nachmittag trifft sie Leo.',
      ),
    ],
  ),
  ReadingBook(
    id: 'meine_familie',
    title: 'Meine Familie',
    description: 'My family · people, ages and simple descriptions',
    minutes: 3,
    paragraphs: [
      ReadingParagraph(
        'Meine Familie ist klein. Ich wohne mit meiner Mutter, meinem Vater und meiner Schwester zusammen.',
        'My family is small. I live together with my mother, my father and my sister.',
      ),
      ReadingParagraph(
        'Meine Mutter heißt Anna. Sie ist Ärztin. Mein Vater heißt Paul und er arbeitet in einem Büro. Meine Schwester Lisa ist zwölf Jahre alt.',
        'My mother is called Anna. She is a doctor. My father is called Paul and he works in an office. My sister Lisa is twelve years old.',
      ),
      ReadingParagraph(
        'Am Sonntag frühstücken wir zusammen. Danach gehen wir spazieren oder besuchen meine Großeltern. Ich liebe meine Familie.',
        'On Sunday, we have breakfast together. Afterwards, we go for a walk or visit my grandparents. I love my family.',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'Wie heißt die Mutter?',
        options: ['Lisa', 'Anna', 'Maria', 'Julia'],
        answer: 1,
        explanation: 'Die Mutter heißt Anna.',
      ),
      QuizQuestion(
        question: 'Wie alt ist Lisa?',
        options: ['Sieben', 'Zehn', 'Zwölf', 'Zwanzig'],
        answer: 2,
        explanation: 'Lisa ist zwölf Jahre alt.',
      ),
      QuizQuestion(
        question: 'Was macht die Familie am Sonntag zuerst?',
        options: [
          'Sie arbeitet',
          'Sie frühstückt zusammen',
          'Sie geht zur Schule',
          'Sie fährt Bus',
        ],
        answer: 1,
        explanation: 'Am Sonntag frühstücken sie zusammen.',
      ),
    ],
  ),
  ReadingBook(
    id: 'im_cafe',
    title: 'Im Café',
    description: 'At a café · food, drinks and polite expressions',
    minutes: 3,
    paragraphs: [
      ReadingParagraph(
        'Tom und Sara gehen in ein Café. Sie haben Hunger und Durst. Das Café ist klein, aber sehr schön.',
        'Tom and Sara go into a café. They are hungry and thirsty. The café is small but very nice.',
      ),
      ReadingParagraph(
        'Der Kellner kommt. Tom sagt: „Einen Kaffee, bitte.“ Sara möchte einen Tee und ein Stück Kuchen. Der Kellner sagt: „Gern!“',
        'The waiter comes. Tom says: “A coffee, please.” Sara would like a tea and a piece of cake. The waiter says: “Certainly!”',
      ),
      ReadingParagraph(
        'Nach dem Essen bezahlen sie. Sara sagt: „Vielen Dank!“ Tom und Sara sind glücklich. Dann gehen sie nach Hause.',
        'After eating, they pay. Sara says: “Thank you very much!” Tom and Sara are happy. Then they go home.',
      ),
    ],
    questions: [
      QuizQuestion(
        question: 'Wohin gehen Tom und Sara?',
        options: ['In die Schule', 'In ein Café', 'In den Park', 'Nach Berlin'],
        answer: 1,
        explanation: 'Sie gehen in ein Café.',
      ),
      QuizQuestion(
        question: 'Was bestellt Sara?',
        options: [
          'Kaffee und Brot',
          'Wasser und Suppe',
          'Tee und Kuchen',
          'Milch und Reis',
        ],
        answer: 2,
        explanation: 'Sara möchte einen Tee und ein Stück Kuchen.',
      ),
      QuizQuestion(
        question: 'Was sagt Sara am Ende?',
        options: [
          'Gute Nacht',
          'Auf Wiedersehen',
          'Vielen Dank',
          'Entschuldigung',
        ],
        answer: 2,
        explanation: 'Sara sagt: Vielen Dank!',
      ),
    ],
  ),
];

class ReadingProgressStore {
  static const _key = 'reading_books_completed_v1';

  static Future<Set<String>> loadCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? <String>[]).toSet();
  }

  static Future<void> markCompleted(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = (prefs.getStringList(_key) ?? <String>[]).toSet()..add(id);
    await prefs.setStringList(_key, ids.toList());
  }
}

class SavedVocabularyStore {
  static const _key = 'saved_vocabulary_v1';

  static Future<Set<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? <String>[]).toSet();
  }

  static Future<void> save(Set<String> words) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, words.toList());
  }
}

List<WordEntry> get dictionaryEntries {
  final entries = <WordEntry>[];
  final seen = <String>{};
  for (final lesson in lessons) {
    for (final section in lesson.sections) {
      for (final entry in section.entries) {
        final key = entry.german.trim().toLowerCase();
        if (key.isNotEmpty && seen.add(key)) entries.add(entry);
      }
    }
  }
  const extra = <WordEntry>[
    WordEntry('das Wasser', 'the water', pronunciation: 'dahs VAH-ser'),
    WordEntry('das Brot', 'the bread', pronunciation: 'dahs broht'),
    WordEntry('der Kaffee', 'the coffee', pronunciation: 'dair kah-FAY'),
    WordEntry('der Tee', 'the tea', pronunciation: 'dair tay'),
    WordEntry('der Apfel', 'the apple', pronunciation: 'dair AHP-fel'),
    WordEntry('die Milch', 'the milk', pronunciation: 'dee milkh'),
    WordEntry('das Haus', 'the house', pronunciation: 'dahs hows'),
    WordEntry('die Schule', 'the school', pronunciation: 'dee SHOO-luh'),
    WordEntry('die Arbeit', 'the work', pronunciation: 'dee AHR-bайт'),
    WordEntry('lernen', 'to learn', pronunciation: 'LAIR-nen'),
    WordEntry('sprechen', 'to speak', pronunciation: 'SHPREH-khen'),
    WordEntry('lesen', 'to read', pronunciation: 'LAY-zen'),
    WordEntry('schreiben', 'to write', pronunciation: 'SHRY-ben'),
    WordEntry('essen', 'to eat', pronunciation: 'ESS-en'),
    WordEntry('trinken', 'to drink', pronunciation: 'TRINK-en'),
    WordEntry('gehen', 'to go / walk', pronunciation: 'GAY-en'),
    WordEntry('kommen', 'to come', pronunciation: 'KOM-en'),
    WordEntry('heute', 'today', pronunciation: 'HOY-tuh'),
    WordEntry('bitte', 'please / you are welcome', pronunciation: 'BIT-tuh'),
    WordEntry(
      'Entschuldigung',
      'excuse me / sorry',
      pronunciation: 'ent-SHOOL-dee-goong',
    ),
    WordEntry(
      'Wie viel kostet das?',
      'How much does that cost?',
      pronunciation: 'vee feel KOS-tet dahs',
    ),
    WordEntry(
      'Wo ist die Toilette?',
      'Where is the toilet?',
      pronunciation: 'voh ist dee toy-LET-tuh',
    ),
  ];
  for (final entry in extra) {
    if (seen.add(entry.german.toLowerCase())) entries.add(entry);
  }
  entries.sort(
    (a, b) => a.german.toLowerCase().compareTo(b.german.toLowerCase()),
  );
  return entries;
}

class ReadingLibraryPage extends StatefulWidget {
  const ReadingLibraryPage({super.key});

  @override
  State<ReadingLibraryPage> createState() => _ReadingLibraryPageState();
}

class _ReadingLibraryPageState extends State<ReadingLibraryPage> {
  Set<String> _completed = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final completed = await ReadingProgressStore.loadCompleted();
    if (!mounted) return;
    setState(() {
      _completed = completed;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('A1 Reading Library')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [brandBlue, Color(0xFF7187E9)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.auto_stories_rounded, color: Colors.white, size: 34),
                SizedBox(height: 12),
                Text(
                  'Read a little every day',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Original beginner stories with English translations, audio and quick comprehension checks.',
                  style: TextStyle(color: Colors.white70, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (_loading) const LinearProgressIndicator(),
          ...readingBooks.map((book) {
            final completed = _completed.contains(book.id);
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: completed ? softGreen : softBlue,
                  foregroundColor: completed
                      ? Colors.green.shade800
                      : brandBlue,
                  child: Icon(
                    completed
                        ? Icons.check_rounded
                        : Icons.auto_stories_rounded,
                  ),
                ),
                title: Text(
                  book.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${book.description}\n${book.minutes} min · A1 · ${book.paragraphs.length} short sections',
                  ),
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () async {
                  await Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReadingBookPage(book: book),
                    ),
                  );
                  _load();
                },
              ),
            );
          }),
          const SizedBox(height: 8),
          const Text(
            'These are original practice stories written for DeutschBuddy. They are not excerpts from published books.',
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class ReadingBookPage extends StatefulWidget {
  final ReadingBook book;
  const ReadingBookPage({super.key, required this.book});

  @override
  State<ReadingBookPage> createState() => _ReadingBookPageState();
}

class _ReadingBookPageState extends State<ReadingBookPage> {
  bool _showTranslation = true;
  bool _showPronunciation = true;
  bool _quizFinished = false;
  int _questionIndex = 0;
  int _score = 0;
  int? _selected;
  bool _answered = false;

  Future<void> _finishReading() async {
    await ReadingProgressStore.markCompleted(widget.book.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reading completed! Great work.')),
    );
    setState(() => _quizFinished = true);
  }

  void _answer(int index) {
    if (_answered) return;
    setState(() {
      _selected = index;
      _answered = true;
      if (index == widget.book.questions[_questionIndex].answer) _score++;
    });
  }

  void _nextQuestion() {
    if (_questionIndex + 1 >= widget.book.questions.length) {
      showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Reading check complete'),
          content: Text(
            'You scored $_score out of ${widget.book.questions.length}. Re-read the story and try again to improve your score.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      );
      return;
    }
    setState(() {
      _questionIndex++;
      _selected = null;
      _answered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final inQuiz = _quizFinished;
    return Scaffold(
      appBar: AppBar(title: Text(widget.book.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            widget.book.description,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 14),
          if (!inQuiz) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('English translation'),
                  selected: _showTranslation,
                  onSelected: (v) => setState(() => _showTranslation = v),
                ),
                FilterChip(
                  label: const Text('Pronunciation hints'),
                  selected: _showPronunciation,
                  onSelected: (v) => setState(() => _showPronunciation = v),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...widget.book.paragraphs.asMap().entries.map((item) {
              final paragraph = item.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: softBlue,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${item.key + 1}',
                              style: const TextStyle(
                                color: brandBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            tooltip: 'Listen to paragraph',
                            onPressed: () =>
                                GermanSpeech.speak(paragraph.german),
                            icon: const Icon(
                              Icons.volume_up_rounded,
                              color: brandBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        paragraph.german,
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.65,
                          fontWeight: FontWeight.w500,
                          color: darkText,
                        ),
                      ),
                      if (_showPronunciation) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Listen and repeat using the speaker above.',
                          style: TextStyle(
                            color: Colors.blueGrey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      if (_showTranslation) ...[
                        const SizedBox(height: 12),
                        const Divider(),
                        Text(
                          paragraph.english,
                          style: const TextStyle(
                            height: 1.5,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
            FilledButton.icon(
              onPressed: _finishReading,
              icon: const Icon(Icons.quiz_outlined),
              label: const Text('Mark read and take quiz'),
            ),
          ] else ...[
            LinearProgressIndicator(
              value: (_questionIndex + 1) / widget.book.questions.length,
            ),
            const SizedBox(height: 18),
            Text(
              'QUESTION ${_questionIndex + 1} OF ${widget.book.questions.length}',
              style: const TextStyle(
                color: brandBlue,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.book.questions[_questionIndex].question,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),
            const SizedBox(height: 16),
            ...widget.book.questions[_questionIndex].options
                .asMap()
                .entries
                .map((item) {
                  final correct =
                      item.key == widget.book.questions[_questionIndex].answer;
                  final selected = _selected == item.key;
                  return Card(
                    color: _answered && correct
                        ? softGreen
                        : (_answered && selected
                              ? const Color(0xFFFFEEEE)
                              : Colors.white),
                    child: ListTile(
                      title: Text(item.value),
                      leading: CircleAvatar(
                        child: Text(String.fromCharCode(65 + item.key)),
                      ),
                      onTap: _answered ? null : () => _answer(item.key),
                      trailing: _answered && correct
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                    ),
                  );
                }),
            if (_answered) ...[
              const SizedBox(height: 10),
              Text(
                widget.book.questions[_questionIndex].explanation,
                style: const TextStyle(height: 1.4),
              ),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: _nextQuestion,
                child: Text(
                  _questionIndex + 1 == widget.book.questions.length
                      ? 'See result'
                      : 'Next question',
                ),
              ),
            ],
            TextButton(
              onPressed: () => setState(() {
                _quizFinished = false;
                _questionIndex = 0;
                _score = 0;
                _selected = null;
                _answered = false;
              }),
              child: const Text('Back to story'),
            ),
          ],
        ],
      ),
    );
  }
}

class DictionaryPage extends StatefulWidget {
  const DictionaryPage({super.key});

  @override
  State<DictionaryPage> createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  final TextEditingController _search = TextEditingController();
  Set<String> _saved = {};
  bool _loading = true;
  bool _savedOnly = false;

  @override
  void initState() {
    super.initState();
    _loadSaved();
    _search.addListener(() => setState(() {}));
  }

  Future<void> _loadSaved() async {
    final words = await SavedVocabularyStore.load();
    if (!mounted) return;
    setState(() {
      _saved = words;
      _loading = false;
    });
  }

  Future<void> _toggleSaved(WordEntry entry) async {
    final key = entry.german.toLowerCase();
    setState(() {
      if (_saved.contains(key)) {
        _saved.remove(key);
      } else {
        _saved.add(key);
      }
    });
    await SavedVocabularyStore.save(_saved);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final entries = dictionaryEntries
        .where((entry) {
          final matchesQuery =
              query.isEmpty ||
              entry.german.toLowerCase().contains(query) ||
              entry.english.toLowerCase().contains(query);
          final matchesSaved =
              !_savedOnly || _saved.contains(entry.german.toLowerCase());
          return matchesQuery && matchesSaved;
        })
        .take(150)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('German–English Dictionary'),
        actions: [
          IconButton(
            tooltip: _savedOnly ? 'Show all words' : 'Show saved words',
            onPressed: () => setState(() => _savedOnly = !_savedOnly),
            icon: Icon(_savedOnly ? Icons.bookmark : Icons.bookmark_border),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: 'Search German or English…',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: _search.clear,
                        icon: const Icon(Icons.clear),
                      ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE5E9F2)),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                Text(
                  _savedOnly ? 'Saved words' : 'Dictionary',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${entries.length}${query.isEmpty && !_savedOnly ? '+' : ''} results',
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          Expanded(
            child: entries.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Text(
                        _savedOnly
                            ? 'No saved words yet. Tap the bookmark beside a word to save it.'
                            : 'No matches found. Try another spelling.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    itemCount: entries.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      final saved = _saved.contains(entry.german.toLowerCase());
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(15, 13, 5, 13),
                          child: Row(
                            children: [
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
                                    const SizedBox(height: 4),
                                    Text(entry.english),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Say it like: ${pronunciationFor(entry)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: 'Listen',
                                onPressed: () =>
                                    GermanSpeech.speak(entry.german),
                                icon: const Icon(
                                  Icons.volume_up_rounded,
                                  color: brandBlue,
                                ),
                              ),
                              IconButton(
                                tooltip: saved
                                    ? 'Remove saved word'
                                    : 'Save word',
                                onPressed: () => _toggleSaved(entry),
                                icon: Icon(
                                  saved
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  color: brandBlue,
                                ),
                              ),
                            ],
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

class FlashcardsPage extends StatefulWidget {
  const FlashcardsPage({super.key});

  @override
  State<FlashcardsPage> createState() => _FlashcardsPageState();
}

class _FlashcardsPageState extends State<FlashcardsPage> {
  bool _loading = true;
  bool _reveal = false;
  int _index = 0;
  List<WordEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final saved = await SavedVocabularyStore.load();
    final entries = dictionaryEntries
        .where((entry) => saved.contains(entry.german.toLowerCase()))
        .toList();
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final entry = _entries.isEmpty ? null : _entries[_index % _entries.length];
    return Scaffold(
      appBar: AppBar(title: const Text('Vocabulary Flashcards')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : entry == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bookmark_border,
                      size: 48,
                      color: brandBlue,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Your wordbook is empty',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Save words in the dictionary first, then come back here to practise.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DictionaryPage(),
                        ),
                      ),
                      child: const Text('Open dictionary'),
                    ),
                  ],
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'CARD ${_index + 1} OF ${_entries.length}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: brandBlue,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: () => setState(() => _reveal = !_reveal),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: const Color(0xFFE5E9F2)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _reveal
                                  ? Icons.lightbulb_rounded
                                  : Icons.style_rounded,
                              size: 38,
                              color: brandBlue,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _reveal ? entry.english : entry.german,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 27,
                                fontWeight: FontWeight.bold,
                                color: darkText,
                              ),
                            ),
                            if (_reveal) ...[
                              const SizedBox(height: 16),
                              Text(
                                'Say it like: ${pronunciationFor(entry)}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                            const SizedBox(height: 18),
                            Text(
                              _reveal
                                  ? 'Tap to hide answer'
                                  : 'Tap card to reveal meaning',
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: () => GermanSpeech.speak(entry.german),
                    icon: const Icon(Icons.volume_up_rounded),
                    label: const Text('Listen to pronunciation'),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () => setState(() {
                      _index = (_index + 1) % _entries.length;
                      _reveal = false;
                    }),
                    child: const Text('Next card'),
                  ),
                ],
              ),
            ),
    );
  }
}
