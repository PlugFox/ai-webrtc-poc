// ignore_for_file: one_member_abstracts

import 'dart:async';

import 'package:poc/src/feature/web_speech/data/platform/text_speach_stub.dart'
    // ignore: uri_does_not_exist
    if (dart.library.js_interop) 'package:poc/src/feature/web_speech/data/platform/text_speach_js.dart'
    // ignore: uri_does_not_exist
    if (dart.library.io) 'package:poc/src/feature/web_speech/data/platform/text_speach_vm.dart';

/// WebSpeechRepository interface.
abstract interface class IWebSpeechRepository {
  Stream<String> startTextSpeach({String? lang});
}

/// WebSpeechRepository.
class WebSpeechRepositoryImpl implements IWebSpeechRepository {
  @override
  Stream<String> startTextSpeach({String? lang}) => $textSpeach(lang: lang);
}
