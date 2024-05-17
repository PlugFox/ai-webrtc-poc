import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import 'package:poc/src/common/widget/common_actions.dart';
import 'package:poc/src/common/widget/not_available_screen.dart';
import 'package:poc/src/common/widget/scaffold_padding.dart';

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
  late final web.SpeechRecognition recognition;

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    recognition = web.SpeechRecognition();
  }

  @override
  void didUpdateWidget(covariant _WebSpeechForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Widget configuration changed
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The configuration of InheritedWidgets has changed
    // Also called after initState but before build
  }

  @override
  void dispose() {
    recognition.stop();
    super.dispose();
  }
  /* #endregion */

  @override
  Widget build(BuildContext context) => const Placeholder();
}
