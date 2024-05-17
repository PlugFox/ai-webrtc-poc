// ignore_for_file: one_member_abstracts

import 'dart:async';

import 'package:poc/src/feature/web_speech/data/platform/text_speech_stub.dart'
    // ignore: uri_does_not_exist
    if (dart.library.js_interop) 'package:poc/src/feature/web_speech/data/platform/text_speech_js.dart'
    // ignore: uri_does_not_exist
    if (dart.library.io) 'package:poc/src/feature/web_speech/data/platform/text_speech_vm.dart';
import 'package:poc/src/feature/web_speech/model/text_speech_config.dart';

/// WebSpeechRepository interface.
abstract interface class IWebSpeechRepository {
  Stream<String> startTextSpeech({TextSpeechConfig? config});
}

/// WebSpeechRepository.
class WebSpeechRepositoryImpl implements IWebSpeechRepository {
  @override
  Stream<String> startTextSpeech({TextSpeechConfig? config}) => $startTextSpeech(config ?? const TextSpeechConfig());
}
