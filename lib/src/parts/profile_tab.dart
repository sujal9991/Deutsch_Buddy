part of '../../app.dart';

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
