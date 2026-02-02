// lib/services/stt_service.dart

/// Abstract interface for Speech-to-Text providers
/// This allows swapping STT implementations without changing app code
abstract class SttService {
  /// Initialize the STT service
  Future<void> initialize();

  /// Check if speech recognition is available
  Future<bool> isAvailable();

  /// Check if microphone permission is granted
  Future<bool> hasPermission();

  /// Request microphone permission
  Future<bool> requestPermission();

  /// Start listening for speech
  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onError,
    String locale = 'vi-VN',
  });

  /// Stop listening
  Future<void> stopListening();

  /// Cancel listening
  Future<void> cancelListening();

  /// Get supported locales
  Future<List<String>> getSupportedLocales();
}

/// Default implementation using speech_to_text plugin
import 'package:speech_to_text/speech_to_text.dart' as stt;

class DefaultSttService implements SttService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (!_isInitialized) {
      _isInitialized = await _speech.initialize(
        onError: (error) => print('STT Error: $error'),
        onStatus: (status) => print('STT Status: $status'),
      );
    }
  }

  @override
  Future<bool> isAvailable() async {
    await initialize();
    return _isInitialized;
  }

  @override
  Future<bool> hasPermission() async {
    await initialize();
    return _speech.hasPermission;
  }

  @override
  Future<bool> requestPermission() async {
    await initialize();
    return _speech.hasPermission;
  }

  @override
  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onError,
    String locale = 'vi-VN',
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!_isInitialized) {
      onError('STT not available');
      return;
    }

    try {
      await _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            onResult(result.recognizedWords);
          }
        },
        localeId: locale,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: true,
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  @override
  Future<void> stopListening() async {
    await _speech.stop();
  }

  @override
  Future<void> cancelListening() async {
    await _speech.cancel();
  }

  @override
  Future<List<String>> getSupportedLocales() async {
    await initialize();
    final locales = await _speech.locales();
    return locales.map((l) => l.localeId).toList();
  }
}

// Example: Mock STT service for testing
class MockSttService implements SttService {
  final List<String> mockResponses;
  int _responseIndex = 0;

  MockSttService({
    this.mockResponses = const [
      'Hôm nay chi 120 ngàn ăn trưa',
      'Nhận lương 10 triệu',
      'Mua sắm hết 1.5 triệu',
    ],
  });

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<bool> hasPermission() async => true;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onError,
    String locale = 'vi-VN',
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (_responseIndex < mockResponses.length) {
      onResult(mockResponses[_responseIndex]);
      _responseIndex++;
    } else {
      onResult(mockResponses.first);
      _responseIndex = 1;
    }
  }

  @override
  Future<void> stopListening() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> cancelListening() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<List<String>> getSupportedLocales() async {
    return ['vi-VN', 'en-US'];
  }
}
