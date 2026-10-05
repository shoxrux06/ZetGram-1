import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Reads English words aloud with the phone's built-in voice (works offline).
class Speech {
  final FlutterTts _tts = FlutterTts();
  Future<bool>? _init;

  Future<bool> _setup() async {
    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        // "playback" keeps the voice audible even when the silent switch is on.
        await _tts.setSharedInstance(true);
        await _tts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [IosTextToSpeechAudioCategoryOptions.duckOthers],
          IosTextToSpeechAudioMode.spokenAudio,
        );
      }
      await _tts.setLanguage('en-US');
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Speaks [text]. `slow` uses a slower rate for careful listening.
  Future<bool> say(String text, {bool slow = false}) async {
    final ok = await (_init ??= _setup());
    if (!ok) return false;
    try {
      await _tts.stop();
      // 0.5 is the normal speed on both iOS and Android in flutter_tts.
      await _tts.setSpeechRate(slow ? 0.3 : 0.48);
      await _tts.speak(text);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
