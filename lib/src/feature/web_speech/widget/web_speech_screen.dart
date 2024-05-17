import 'package:control/control.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:poc/src/common/widget/common_actions.dart';
import 'package:poc/src/common/widget/not_available_screen.dart';
import 'package:poc/src/common/widget/scaffold_padding.dart';
import 'package:poc/src/feature/web_speech/controller/web_speech_controller.dart';
import 'package:poc/src/feature/web_speech/controller/web_speech_state.dart';
import 'package:poc/src/feature/web_speech/data/web_speech_repository.dart';

/// {@template web_speech_screen}
/// WebSpeechScreen widget.
/// {@endtemplate}
class WebSpeechScreen extends StatelessWidget {
  /// {@macro web_speech_screen}
  const WebSpeechScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return const NotAvailableScreen(reason: 'WebSpeech API is available only on web platform.');
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebSpeech API'),
        actions: CommonActions(),
      ),
      body: SafeArea(
        child: ScaffoldPadding.widget(
          context,
          const _WebSpeechForm(),
        ),
      ),
    );
  }
}

class _WebSpeechForm extends StatefulWidget {
  const _WebSpeechForm({
    super.key, // ignore: unused_element
  });

  @override
  State<_WebSpeechForm> createState() => _WebSpeechFormState();
}

class _WebSpeechFormState extends State<_WebSpeechForm> {
  late final WebSpeechController controller;

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    controller = WebSpeechController(
      repository: WebSpeechRepositoryImpl(),
    );
  }

  @override
  void dispose() {
    controller
      ..stop()
      ..dispose();
    super.dispose();
  }
  /* #endregion */

  @override
  Widget build(BuildContext context) => Center(
        child: StateConsumer<WebSpeechController, WebSpeechState>(
          controller: controller,
          listener: (context, controller, previous, current) {
            if (listEquals(previous.sentences, current.sentences)) return;
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(
                SnackBar(
                  content: Text('Recognized ${current.sentences.length} sentences'),
                ),
              );
          },
          builder: (context, state, _) {
            if (state.isProcessing) {
              return IconButton(
                iconSize: 64,
                icon: const Icon(Icons.stop),
                onPressed: () => controller.stop(),
              );
            } else {
              return IconButton(
                iconSize: 64,
                color: Colors.red,
                icon: const Icon(Icons.mic),
                onPressed: () => controller.start(),
              );
            }
          },
        ),
      );
}
