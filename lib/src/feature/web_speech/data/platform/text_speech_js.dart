// ignore_for_file: directives_ordering, , close_sinks, inference_failure_on_untyped_parameter, avoid_types_on_closure_parameters

import 'dart:async';
import 'dart:js_interop' as web;

import 'package:poc/src/feature/web_speech/model/text_speech_config.dart';
import 'package:poc/src/feature/web_speech/model/text_speech_result.dart';
import 'package:web/web.dart' as web;

Stream<List<TextSpeechResult>> $startTextSpeech(TextSpeechConfig config) {
  try {
    //final speechList = web.SpeechGrammarList();
    final recognition = web.SpeechRecognition()
      //..grammars = speechList
      ..lang = config.lang
      ..interimResults = config.interimResults
      ..maxAlternatives = config.maxAlternatives
      ..continuous = config.continuous
      ..start();
    final controller = StreamController<List<TextSpeechResult>>(
      onListen: () {
        /* onListen */
      },
      onCancel: () {
        /* onCancel */
        recognition.stop();
      },
    );
    recognition
      ..onresult = (web.SpeechSynthesisEvent event) {
        try {
          controller.add(SpeechSynthesisEvent(event).toList());
        } on Object catch (error, stackTrace) {
          controller.addError(error, stackTrace);
        }
      }.toJS
      ..onend = (web.Event _) {
        controller.close();
      }.toJS;
    return controller.stream;
  } on Object catch (error, stackTrace) {
    return Stream.error(error, stackTrace);
  }
}

extension type SpeechSynthesisEvent(web.SpeechSynthesisEvent _) implements web.SpeechSynthesisEvent {
  external web.SpeechRecognitionResultList results;

  /// Convert to array of results where each result is a list of alternatives.
  List<TextSpeechResult> toList() {
    final results = this.results;
    final list = List<TextSpeechResult>.generate(
      results.length,
      (i) {
        final result = results.item(i);
        // Extract alternatives.
        final alternatives = List<TextSpeechAlternative>.generate(
          result.length,
          (j) {
            final alternative = result.item(j);
            return TextSpeechAlternative(
              transcript: alternative.transcript,
              confidence: alternative.confidence.toDouble(),
            );
          },
          growable: false,
        );
        if (alternatives.isEmpty) return TextSpeechResult(alternatives: alternatives, isFinal: result.isFinal);
        // Exclude duplicates.
        final duplicates = <String, TextSpeechAlternative>{};
        for (final alternative in alternatives) {
          final item = duplicates[alternative.transcript];
          if (item == null || item.confidence < alternative.confidence) {
            duplicates[alternative.transcript] = alternative;
          }
        }
        return TextSpeechResult(
          alternatives: duplicates.values.toList(growable: false)..sort((a, b) => b.confidence.compareTo(a.confidence)),
          isFinal: result.isFinal,
        );
      },
      growable: false,
    );
    return list.where((r) => r.alternatives.isNotEmpty).toList(growable: false);
  }
}
