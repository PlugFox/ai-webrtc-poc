// ignore_for_file: directives_ordering, avoid_print, close_sinks, inference_failure_on_untyped_parameter, avoid_types_on_closure_parameters

import 'dart:async';
import 'dart:js_interop' as web;

import 'package:poc/src/feature/web_speech/model/text_speech_config.dart';
import 'package:web/web.dart' as web;

Stream<String> $startTextSpeech(TextSpeechConfig config) {
  try {
    //final speechList = web.SpeechGrammarList();
    final recognition = web.SpeechRecognition()
      //..grammars = speechList
      ..lang = config.lang
      ..interimResults = config.interimResults
      ..maxAlternatives = config.maxAlternatives
      ..continuous = config.continuous
      ..start();
    final controller = StreamController<String>(
      onListen: () {
        print('SpeechRecognition.onListen');
      },
      onCancel: () {
        print('SpeechRecognition.onCancel');
        recognition.stop();
      },
    );
    recognition
      ..onresult = (web.SpeechSynthesisEvent event) {
        try {
          final result = SpeechSynthesisEvent(event).toArray().lastOrNull?.firstOrNull ?? '';
          print('SpeechRecognition.onresult: $result');
          controller.add(result);
        } on Object catch (error) {
          print('SpeechRecognition.error: $error');
          controller.add('Error $error');
        }
        controller.add(/* event.results[0][0].transcript */ event.toString());
      }.toJS
      ..onend = (web.Event event) {
        print('SpeechRecognition.onend: $event');
        controller.close();
      }.toJS;
    return controller.stream;
  } on Object catch (error, stackTrace) {
    print('SpeechRecognition.error: $error');
    return Stream.error(error, stackTrace);
  }
}

extension type SpeechSynthesisEvent(web.SpeechSynthesisEvent _) implements web.SpeechSynthesisEvent {
  external web.SpeechRecognitionResultList results;

  /// Convert to array.
  /// Array of results where each result is a list of alternatives.
  List<List<String>> toArray() {
    final results = this.results;
    final array = List<List<String>>.generate(
      results.length,
      (i) {
        final result = results.item(i);
        return List<String>.generate(
          result.length,
          (j) => result.item(j).transcript,
          growable: false,
        );
      },
      growable: false,
    );
    return array;
  }
}
