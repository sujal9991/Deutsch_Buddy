part of '../../app.dart';

// ============================================================
// GERMAN TEXT-TO-SPEECH + LEARNER PRONUNCIATION
// ============================================================

class GermanSpeech {
  GermanSpeech._();
  static final FlutterTts _tts = FlutterTts();
  static bool _configured = false;
  static bool _speaking = false;

  static Future<void> speak(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;
    try {
      if (!_configured) {
        await _tts.setLanguage('de-DE');
        await _tts.setSpeechRate(0.42);
        await _tts.setPitch(1.0);
        await _tts.awaitSpeakCompletion(true);
        _configured = true;
      }
      if (_speaking) await _tts.stop();
      _speaking = true;
      await _tts.speak(cleanText);
    } catch (_) {
      // Text-to-speech depends on the device having a German voice installed.
    } finally {
      _speaking = false;
    }
  }
}

/// A beginner-friendly approximation, not phonetic transcription.
/// Prefer the hand-written pronunciation on entries when one is provided.
String pronunciationFor(WordEntry entry) {
  if (entry.pronunciation != null && entry.pronunciation!.trim().isNotEmpty) {
    return entry.pronunciation!;
  }

  var value = entry.german.toLowerCase();
  // Common German spelling-to-sound patterns. These are deliberately simple
  // learning hints; the speaker button provides the actual spoken model.
  value = value
      .replaceAll('sch', 'sh')
      .replaceAll('ch', 'kh')
      .replaceAll('ei', 'eye')
      .replaceAll('ie', 'ee')
      .replaceAll('eu', 'oy')
      .replaceAll('äu', 'oy')
      .replaceAll('sp', 'shp')
      .replaceAll('st', 'sht')
      .replaceAll('z', 'ts')
      .replaceAll('v', 'f')
      .replaceAll('w', 'v')
      .replaceAll('j', 'y')
      .replaceAll('ß', 'ss')
      .replaceAll('ä', 'eh')
      .replaceAll('ö', 'eu')
      .replaceAll('ü', 'ue')
      .replaceAll('qu', 'kv')
      .replaceAll('tsch', 'ch');
  value = value.replaceAll(RegExp(r'[^a-z0-9\s.,!?-]'), '');
  value = value.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (value.isEmpty) return 'Listen to the speaker for pronunciation';
  return value;
}
