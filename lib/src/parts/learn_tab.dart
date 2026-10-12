part of '../../app.dart';

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
