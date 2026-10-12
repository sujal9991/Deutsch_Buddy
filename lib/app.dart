
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const Color brandBlue = Color(0xFF315CDB);
const Color pageBackground = Color(0xFFF6F7FB);
const Color darkText = Color(0xFF19213D);

class DeutschBuddyApp extends StatelessWidget {
  const DeutschBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeutschBuddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: brandBlue),
        scaffoldBackgroundColor: pageBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: pageBackground,
          foregroundColor: darkText,
          elevation: 0,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE3E7F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: brandBlue, width: 1.5),
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

// ------------------------------------------------------------
// AUTHENTICATION GATE
// ------------------------------------------------------------

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Supabase.instance.client.auth;

    return StreamBuilder<AuthState>(
      stream: auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.hasData
            ? snapshot.data!.session
            : auth.currentSession;

        if (session == null) {
          return const AuthPage();
        }

        return HomePage(
          email: session.user.email ?? 'German learner',
        );
      },
    );
  }
}

// ------------------------------------------------------------
// LOGIN AND REGISTRATION
// ------------------------------------------------------------

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _signUp = true;
  bool _loading = false;
  String? _message;
  bool _error = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      final auth = Supabase.instance.client.auth;

      if (_signUp) {
        final response = await auth.signUp(
          email: _email.text.trim(),
          password: _password.text,
        );

        if (!mounted) return;

        setState(() {
          _message = response.session == null
              ? 'Account created. Check your email to confirm it, '
                  'then sign in.'
              : 'Account created successfully!';
          _error = false;
        });
      } else {
        await auth.signInWithPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _message = e.message;
        _error = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _message =
            'Unable to connect. Check your internet connection '
            'and Supabase configuration.';
        _error = true;
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.language_rounded,
                      size: 76,
                      color: brandBlue,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'DeutschBuddy',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: darkText,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Learn German, one step at a time.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 36),
                    Text(
                      _signUp ? 'Create your account' : 'Welcome back',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        final v = value?.trim() ?? '';
                        if (!v.contains('@') || !v.contains('.')) {
                          return 'Enter a valid email address.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (value) {
                        if ((value ?? '').length < 6) {
                          return 'Use at least 6 characters.';
                        }
                        return null;
                      },
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
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(_signUp ? 'Create account' : 'Sign in'),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: _loading
                          ? null
                          : () {
                              setState(() {
                                _signUp = !_signUp;
                                _message = null;
                              });
                            },
                      child: Text(
                        _signUp
                            ? 'Already registered? Sign in'
                            : 'New to DeutschBuddy? Create account',
                      ),
                    ),
                    if (_message != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _message!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _error
                              ? Theme.of(context).colorScheme.error
                              : Colors.green.shade800,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// HOME AND NAVIGATION
// ------------------------------------------------------------

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.email});

  final String email;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  String get _displayName {
    final name = widget.email.split('@').first;
    if (name.isEmpty) return 'Learner';

    return name[0].toUpperCase() + name.substring(1);
  }

  Future<void> _signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to sign out. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardTab(
        displayName: _displayName,
        onNavigate: (index) => setState(() => _selectedIndex = index),
      ),
      const LearnTab(),
      const ToolsTab(),
      ProfileTab(
        email: widget.email,
        onSignOut: _signOut,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE5EAFF),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Learn',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Tools',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// DASHBOARD
// ------------------------------------------------------------

class DashboardTab extends StatelessWidget {
  const DashboardTab({
    super.key,
    required this.displayName,
    required this.onNavigate,
  });

  final String displayName;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        Row(
          children: [
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFE5EAFF),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.language_rounded,
                color: brandBlue,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DeutschBuddy',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: darkText,
                    ),
                  ),
                  Text(
                    'Your German learning companion',
                    style: TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => onNavigate(3),
              tooltip: 'Profile',
              icon: const Icon(Icons.account_circle_outlined, size: 29),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Text(
          'Hallo, $displayName! 👋',
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'Ready to improve your German today?',
          style: TextStyle(color: Colors.black54, fontSize: 14),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF315CDB), Color(0xFF657FE8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'YOUR LEARNING JOURNEY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 17),
              const Text(
                'Start speaking\nGerman with confidence.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Build your vocabulary, master grammar and practise every day.',
                style: TextStyle(color: Colors.white70, height: 1.5),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => onNavigate(1),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: brandBlue,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Start learning'),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Your overview',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 14),
        const Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.local_fire_department_rounded,
                value: '0 days',
                label: 'Learning streak',
                color: Color(0xFFFF8A42),
                background: Color(0xFFFFF0E5),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.school_rounded,
                value: 'A1',
                label: 'Current level',
                color: Color(0xFF315CDB),
                background: Color(0xFFE8EDFF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.menu_book_rounded,
                value: '0',
                label: 'Lessons done',
                color: Color(0xFF199B76),
                background: Color(0xFFE1F7EE),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.stars_rounded,
                value: '0 XP',
                label: 'Total points',
                color: Color(0xFF9B63D7),
                background: Color(0xFFF2E8FF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        SectionHeading(
          title: 'Continue learning',
          action: 'View all',
          onTap: () => onNavigate(1),
        ),
        const SizedBox(height: 14),
        InkWell(
          onTap: () => onNavigate(1),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE9EBF2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EDFF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.waving_hand_rounded,
                    color: brandBlue,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'German basics',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: darkText,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Greetings and introductions',
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                      SizedBox(height: 9),
                      Text(
                        'Beginner • A1',
                        style: TextStyle(
                          color: brandBlue,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 17),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        SectionHeading(
          title: 'Explore learning tools',
          action: 'See all',
          onTap: () => onNavigate(2),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: MiniToolCard(
                icon: Icons.translate_rounded,
                title: 'Dictionary',
                color: const Color(0xFF199B76),
                onTap: () => onNavigate(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MiniToolCard(
                icon: Icons.record_voice_over_rounded,
                title: 'Pronunciation',
                color: const Color(0xFF9B63D7),
                onTap: () => onNavigate(2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: MiniToolCard(
                icon: Icons.psychology_alt_rounded,
                title: 'Memory tricks',
                color: const Color(0xFFFF8A42),
                onTap: () => onNavigate(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MiniToolCard(
                icon: Icons.quiz_rounded,
                title: 'Mock exams',
                color: const Color(0xFF315CDB),
                onTap: () => onNavigate(2),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ------------------------------------------------------------
// REUSABLE DASHBOARD WIDGETS
// ------------------------------------------------------------

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9EBF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 13),
          Text(
            value,
            style: const TextStyle(
              color: darkText,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.title,
    required this.action,
    required this.onTap,
  });

  final String title;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            action,
            style: const TextStyle(
              color: brandBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class MiniToolCard extends StatelessWidget {
  const MiniToolCard({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 17,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE9EBF2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 29),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: darkText,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// LEARN TAB
// ------------------------------------------------------------

class LearnTab extends StatelessWidget {
  const LearnTab({super.key});

  @override
  Widget build(BuildContext context) {
    final lessons = [
      (
        Icons.waving_hand_rounded,
        'Greetings and introductions',
        'Hallo! Wie heißt du?',
        'Greetings',
        const Color(0xFFE8EDFF),
        brandBlue,
      ),
      (
        Icons.abc_rounded,
        'German alphabet',
        'Letters and their sounds',
        'Pronunciation',
        const Color(0xFFFFF0E5),
        Color(0xFFFF8A42),
      ),
      (
        Icons.person_rounded,
        'Personal pronouns',
        'ich, du, er, sie, es',
        'Grammar',
        const Color(0xFFE1F7EE),
        Color(0xFF199B76),
      ),
      (
        Icons.chat_bubble_outline_rounded,
        'Everyday phrases',
        'Useful expressions for daily life',
        'Vocabulary',
        const Color(0xFFF2E8FF),
        Color(0xFF9B63D7),
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Learn German',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'Build your foundation, one lesson at a time.',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: brandBlue,
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'YOUR CURRENT LEVEL',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'A1 — Beginner',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Start with essential words, simple sentences and basic grammar.',
                style: TextStyle(color: Colors.white, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Beginner lessons',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 14),
        ...lessons.map(
          (lesson) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => LessonPreviewPage(
                      title: lesson.$2,
                      subtitle: lesson.$3,
                      category: lesson.$4,
                      color: lesson.$6,
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE9EBF2)),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        color: lesson.$5,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(lesson.$1, color: lesson.$6, size: 27),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lesson.$2,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: darkText,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            lesson.$3,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            lesson.$4,
                            style: TextStyle(
                              color: lesson.$6,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Lesson content and completion tracking will be expanded in the next development step.',
          style: TextStyle(color: Colors.black54, fontSize: 12),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------
// LESSON PREVIEW
// ------------------------------------------------------------

class LessonPreviewPage extends StatelessWidget {
  const LessonPreviewPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.color,
  });

  final String title;
  final String subtitle;
  final String category;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category)),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
              Icons.menu_book_rounded,
              size: 54,
              color: color,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 24),
          const Text(
            'Lesson overview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'This lesson is part of the A1 beginner learning path. '
            'We will add explanations, examples, pronunciation guidance '
            'and interactive exercises as we build the lesson engine.',
            style: TextStyle(height: 1.7),
          ),
          const SizedBox(height: 24),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Row(
                children: [
                  Icon(Icons.construction_rounded, color: brandBlue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Interactive lesson content is coming in the next step.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// TOOLS TAB
// ------------------------------------------------------------

class ToolsTab extends StatelessWidget {
  const ToolsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = [
      (
        Icons.translate_rounded,
        'Dictionary',
        'Look up German words and meanings.',
        Color(0xFF199B76),
      ),
      (
        Icons.record_voice_over_rounded,
        'Pronunciation practice',
        'Practise German sounds and speaking.',
        Color(0xFF9B63D7),
      ),
      (
        Icons.psychology_alt_rounded,
        'Memory tricks',
        'Use simple ways to remember vocabulary.',
        Color(0xFFFF8A42),
      ),
      (
        Icons.quiz_rounded,
        'Goethe-style mock exams',
        'Prepare with exam-style practice.',
        brandBlue,
      ),
      (
        Icons.auto_awesome_rounded,
        'AI German tutor',
        'Get help understanding German.',
        Color(0xFF199B76),
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Learning tools',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'Everything you need to practise German.',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 24),
        ...tools.map(
          (tool) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE9EBF2)),
              ),
              child: Row(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: tool.$4.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(tool.$1, color: tool.$4, size: 27),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tool.$2,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: darkText,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          tool.$3,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 7),
                        const Text(
                          'Planned feature',
                          style: TextStyle(
                            color: brandBlue,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.lock_clock_outlined,
                    color: Colors.black38,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------
// PROFILE TAB
// ------------------------------------------------------------

class ProfileTab extends StatelessWidget {
  const ProfileTab({
    super.key,
    required this.email,
    required this.onSignOut,
  });

  final String email;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(22),
      children: [
        const Text(
          'Your profile',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Container(
            height: 88,
            width: 88,
            decoration: BoxDecoration(
              color: const Color(0xFFE5EAFF),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 48,
              color: brandBlue,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          email,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: darkText,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'German learner • A1',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 28),
        const Card(
          child: ListTile(
            leading: Icon(Icons.school_outlined, color: brandBlue),
            title: Text('Learning level'),
            subtitle: Text('A1 — Beginner'),
          ),
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.cloud_outlined, color: brandBlue),
            title: Text('Account'),
            subtitle: Text('Authenticated with Supabase'),
          ),
        ),
        const SizedBox(height: 22),
        OutlinedButton.icon(
          onPressed: onSignOut,
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Sign out'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
            foregroundColor: Colors.red.shade700,
          ),
        ),
        const SizedBox(height: 20),
        const Center(
          child: Text(
            'DeutschBuddy • Learn German, one step at a time.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black45, fontSize: 11),
          ),
        ),
      ],
    );
  }
}
