part of '../../app.dart';

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
