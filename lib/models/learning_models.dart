import 'package:flutter/material.dart';

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
