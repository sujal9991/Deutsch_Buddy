# DeutschBuddy 🇩🇪

**DeutschBuddy** is a Flutter app for beginners learning German. It
brings together bite-sized lessons, vocabulary, grammar basics, quizzes,
progress tracking, and German text-to-speech in one place.

> DeutschBuddy is a learning project. Pronunciation hints are simplified
> approximations for beginners; use the audio and trusted
> language-learning resources to build accurate pronunciation.

## Features

-   **Beginner-friendly lessons** covering:
    -   German alphabet and special characters
    -   Greetings and introductions
    -   Numbers and counting
    -   Days and months
    -   Family and people
    -   Personal pronouns
    -   German articles
    -   The verbs *sein* and *haben*
    -   Basic sentence structure
-   **German pronunciation audio** using text-to-speech (`de-DE`)
    through `flutter_tts`.
-   **Simplified pronunciation guides** alongside vocabulary and
    phrases.
-   **Short quizzes** with answer explanations.
-   **Local learning progress**, including lesson completion, best quiz
    scores, and XP.
-   **Supabase authentication** for sign-up and login.
-   **Home, Learn, Tools, and Profile** navigation.

## Tech stack

-   [Flutter](https://flutter.dev/) and Dart
-   [Supabase Flutter](https://pub.dev/packages/supabase_flutter) for
    authentication
-   [flutter_tts](https://pub.dev/packages/flutter_tts) for
    text-to-speech
-   [shared_preferences](https://pub.dev/packages/shared_preferences)
    for local progress storage

## Getting started

### Prerequisites

Install the Flutter SDK and configure an Android development
environment. See the [Flutter installation
guide](https://docs.flutter.dev/get-started/install).

You will also need access to a Supabase project if you want to use
authentication.

### 1. Clone the repository

``` bash
git clone https://github.com/YOUR-USERNAME/YOUR-REPOSITORY.git
cd deutsch_buddy
```

Replace the repository URL and directory name with the ones you use on
GitHub.

### 2. Install dependencies

``` bash
flutter pub get
```

### 3. Configure Supabase locally

DeutschBuddy uses a local `config/dev.json` file for values passed to
Flutter at build/run time. Create that file on your own machine and
provide the exact define keys expected by your app's Supabase
initialization.

For example, the file may use a structure like this, **only if these are
the keys your app reads**:

``` json
{
  "SUPABASE_URL": "https://YOUR-PROJECT.supabase.co",
  "SUPABASE_ANON_KEY": "YOUR_SUPABASE_PUBLISHABLE_OR_ANON_KEY"
}
```

Check the app's initialization code to confirm the expected key names
before running. Do not commit your real configuration file or any
private keys. A Supabase publishable/anon key is intended for client use
when Row Level Security and database policies are configured correctly;
never put a `service_role` key or other secret in a client app.

### 4. Run the app

From the project root:

``` bash
flutter run --dart-define-from-file=config/dev.json
```

If your configuration uses a different filename or setup, adjust the
command accordingly.

### 5. Check code quality

``` bash
dart format .
flutter analyze
```

## Text-to-speech notes

The app asks the device's text-to-speech engine to speak German
(`de-DE`). Available voices and pronunciation quality depend on the
Android device and its installed speech services. If audio does not
play, check the device's text-to-speech settings and install a German
voice if needed.

The written pronunciation guides use learner-friendly English
approximations. They are not a replacement for phonetic transcription or
listening to native German speakers.

## Project structure

A simplified view of the project:

``` text
deutsch_buddy/
├── lib/
│   └── app.dart
├── config/
│   └── dev.json          # Local only; do not commit
├── pubspec.yaml
├── android/
├── test/
├── README.md
├── LICENSE
└── .gitignore
```

Your actual project may include additional files and folders.

## Security and configuration

-   Keep `config/dev.json` out of Git if it contains project
    configuration or credentials.
-   Never commit Supabase `service_role` keys, passwords, signing keys,
    or other secrets.
-   Enable appropriate Supabase Row Level Security and policies for any
    database tables.
-   If a secret was committed, removing it in a later commit does not
    erase it from Git history; rotate/revoke it and clean the history if
    necessary.

## Roadmap ideas

-   More A1-level lessons and vocabulary
-   Listening and pronunciation practice
-   Flashcards and spaced repetition
-   Daily learning goals and streaks
-   More quiz types and review sessions
-   Additional grammar explanations

These are possible future improvements, not current features.

## Contributing

Contributions, suggestions, and bug reports are welcome.

1.  Fork the repository.
2.  Create a branch for your change.
3.  Make your changes and run `dart format .` and `flutter analyze`.
4.  Open a pull request describing the change.

For significant changes, open an issue first to discuss the proposal.

## License

DeutschBuddy is released under the MIT License. See [`LICENSE`](LICENSE)
for details.
