part of '../../app.dart';

// ============================================================
// TOOLS
// ============================================================

class ToolsTab extends StatelessWidget {
  const ToolsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final items =
        <({String title, String subtitle, IconData icon, Widget page})>[
          (
            title: 'A1 Reading Library',
            subtitle: 'Read original beginner stories with translations, audio and quizzes.',
            icon: Icons.auto_stories_rounded,
            page: const ReadingLibraryPage(),
          ),
          (
            title: 'German–English Dictionary',
            subtitle: 'Search vocabulary, hear words and save favourites.',
            icon: Icons.translate_rounded,
            page: const DictionaryPage(),
          ),
          (
            title: 'Vocabulary Flashcards',
            subtitle: 'Practise the words you saved in your personal wordbook.',
            icon: Icons.style_rounded,
            page: const FlashcardsPage(),
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
        const Text('Read, look up words and revise what you learn.'),
        const SizedBox(height: 20),
        ...items.map(
          (item) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: softBlue,
                foregroundColor: brandBlue,
                child: Icon(item.icon),
              ),
              title: Text(
                item.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(item.subtitle),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => item.page),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'More features to build next',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 8),
        const _PlannedToolTile(
          icon: Icons.calendar_month_rounded,
          title: 'Daily goals and streaks',
          subtitle: 'Build a consistent learning habit.',
        ),
        const _PlannedToolTile(
          icon: Icons.assignment_outlined,
          title: 'A1 exam practice',
          subtitle: 'Listening, reading and grammar mock tests.',
        ),
        const _PlannedToolTile(
          icon: Icons.chat_bubble_outline_rounded,
          title: 'Conversation practice',
          subtitle: 'Guided dialogues for everyday situations.',
        ),
        const _PlannedToolTile(
          icon: Icons.insights_rounded,
          title: 'Learning analytics',
          subtitle: 'See strengths, weak areas and revision needs.',
        ),
      ],
    );
  }
}

class _PlannedToolTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _PlannedToolTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      leading: Icon(icon, color: Colors.black45),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Text(
        'Planned',
        style: TextStyle(fontSize: 11, color: Colors.black45),
      ),
    ),
  );
}
