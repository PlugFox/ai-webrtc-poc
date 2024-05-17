// ignore_for_file: directives_ordering, avoid_print, close_sinks, inference_failure_on_untyped_parameter

import 'dart:async';
import 'dart:js_interop' as web;

import 'package:web/web.dart' as web;

Stream<String> $textSpeach({String? lang}) {
  try {
    final speechList = web.SpeechGrammarList();
    final recognition = web.SpeechRecognition()
      ..grammars = speechList
      ..lang = lang ?? 'en-US'
      ..interimResults = true
      ..maxAlternatives = 1
      ..start(); //..onresult = web.Js
    final controller = StreamController<String>(
      onListen: () {
        print('SpeechRecognition.onListen');
        recognition.start();
      },
      onCancel: () {
        print('SpeechRecognition.onCancel');
        recognition.stop();
      },
    );
    recognition
      ..onresult = (event) {
        print('SpeechRecognition.onresult: $event');
        controller.add(/* event.results[0][0].transcript */ event.toString());
      }.toJS
      ..onend = (event) {
        print('SpeechRecognition.onend: $event');
        controller.close();
      }.toJS;
    return controller.stream;
  } on Object catch (error, stackTrace) {
    return Stream.error(error, stackTrace);
  }
}
