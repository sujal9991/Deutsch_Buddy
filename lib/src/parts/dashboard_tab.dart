part of '../../app.dart';

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
