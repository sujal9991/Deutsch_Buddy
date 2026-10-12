part of '../../app.dart';

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
