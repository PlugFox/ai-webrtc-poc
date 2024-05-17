import 'package:control/control.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:poc/src/common/widget/common_actions.dart';
import 'package:poc/src/common/widget/not_available_screen.dart';
import 'package:poc/src/common/widget/scaffold_padding.dart';
import 'package:poc/src/feature/web_speech/controller/web_speech_controller.dart';
import 'package:poc/src/feature/web_speech/controller/web_speech_state.dart';
import 'package:poc/src/feature/web_speech/data/web_speech_repository.dart';
import 'package:poc/src/feature/web_speech/model/text_speech_config.dart';
import 'package:poc/src/feature/web_speech/model/text_speech_result.dart';

/// {@template web_speech_screen}
/// WebSpeechScreen widget.
/// {@endtemplate}
class WebSpeechScreen extends StatefulWidget {
  /// {@macro web_speech_screen}
  const WebSpeechScreen({super.key});

  @override
  State<WebSpeechScreen> createState() => _WebSpeechScreenState();
}

class _WebSpeechScreenState extends State<WebSpeechScreen> {
  late final WebSpeechController controller;
  late ThemeData theme;
  late TextStyle textStyle;
  TextSpeechConfig config = const TextSpeechConfig();

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    controller = WebSpeechController(
      repository: WebSpeechRepositoryImpl(),
    );
    controller.addListener(_onState);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    theme = Theme.of(context);
    textStyle = theme.textTheme.bodyLarge ?? const TextStyle();
  }

  @override
  void dispose() {
    controller
      ..stop()
      ..dispose();
    super.dispose();
  }
  /* #endregion */

  void _onState() {
    final state = controller.state;
    if (!state.hasError) return;
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.red,
        ),
      );
  }

  /// Start speech recognition
  void start() => controller.start(
        config: config,
      );

  /// Stop speech recognition
  void stop() => controller.stop();

  Widget buildSentence(TextSpeechResult result) {
    final sentence = result.alternatives.first;
    //final text = '[${(sentence.confidence * 100).round().clamp(0, 100)}%] ${sentence.transcript}';
    final color = switch (result.isFinal) {
      false => textStyle.color?.withAlpha(127) ?? Colors.grey,
      _ => Color.lerp(Colors.red, textStyle.color, sentence.confidence),
    };
    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          WidgetSpan(
            baseline: TextBaseline.ideographic,
            alignment: PlaceholderAlignment.baseline,
            child: Tooltip(
              message: 'Confidence: ${(sentence.confidence * 100).round().clamp(0, 100)}%',
              child: Icon(
                switch (sentence.confidence) {
                  < .7 => Icons.error,
                  < .9 => Icons.warning,
                  _ => Icons.check,
                },
                size: 16,
                color: color,
              ),
            ),
          ),
          const WidgetSpan(child: SizedBox(width: 8)),
          TextSpan(text: sentence.transcript),
        ],
        style: textStyle.copyWith(
          color: color,
          fontStyle: result.isFinal ? FontStyle.normal : FontStyle.italic,
          fontWeight: result.isFinal ? FontWeight.bold : FontWeight.normal,
          decoration: sentence.confidence < .7 ? TextDecoration.underline : TextDecoration.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return const NotAvailableScreen(reason: 'WebSpeech API is available only on web platform.');
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebSpeech API'),
        actions: CommonActions(),
      ),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ScaffoldPadding.widget(
              context,
              SizedBox(
                height: 48,
                child: LayoutBuilder(builder: (context, constraints) {
                  final collapsed = constraints.maxWidth < 600;
                  return StateConsumer<WebSpeechController, WebSpeechState>(
                    controller: controller,
                    buildWhen: (previous, current) => previous.isProcessing != current.isProcessing,
                    builder: (context, state, _) => AbsorbPointer(
                      absorbing: state.isProcessing,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 500),
                        opacity: state.isProcessing ? .5 : 1,
                        child: StatefulBuilder(
                          builder: (context, setState) => Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(collapsed ? '[${config.lang}]' : 'Language: [${config.lang}]'),
                              _WebSpeechConfigCheckbox(
                                label: collapsed ? null : 'Continuous',
                                value: config.continuous,
                                onChanged: (value) => setState(
                                  () => config = config.copyWith(
                                    continuous: value ?? !config.continuous,
                                  ),
                                ),
                              ),
                              _WebSpeechConfigCheckbox(
                                label: collapsed ? null : 'Interim',
                                value: config.interimResults,
                                onChanged: (value) => setState(
                                  () => config = config.copyWith(
                                    interimResults: value ?? !config.interimResults,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: collapsed ? 128 : 164,
                                child: Slider(
                                  value: config.maxAlternatives.toDouble(),
                                  min: 1,
                                  max: 10,
                                  divisions: 9,
                                  label: 'Alternatives: ${config.maxAlternatives}',
                                  onChanged: (value) => setState(
                                    () => config = config.copyWith(
                                      maxAlternatives: value.round().clamp(1, 10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const Divider(height: 16, thickness: 1),
            Expanded(
              child: RepaintBoundary(
                child: StateConsumer<WebSpeechController, WebSpeechState>(
                  controller: controller,
                  builder: (context, state, _) => ListView.builder(
                    padding: ScaffoldPadding.of(context),
                    itemBuilder: (context, index) {
                      final result = state.sentences[index];
                      return Align(
                        alignment: Alignment.topLeft,
                        child: buildSentence(result),
                      );
                    },
                    itemCount: state.sentences.length,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: StateConsumer<WebSpeechController, WebSpeechState>(
        controller: controller,
        buildWhen: (previous, current) => previous.isProcessing != current.isProcessing,
        builder: (context, state, _) => state.isProcessing
            ? FloatingActionButton(
                backgroundColor: Colors.grey,
                onPressed: stop,
                child: const Icon(
                  Icons.stop,
                  size: 32,
                  color: Colors.black,
                ),
              )
            : FloatingActionButton(
                backgroundColor: Colors.red,
                onPressed: start,
                child: const Icon(Icons.mic, size: 32, color: Colors.white),
              ),
      ),
    );
  }
}

class _WebSpeechConfigCheckbox extends StatelessWidget {
  const _WebSpeechConfigCheckbox({
    required this.value,
    this.label,
    this.onChanged,
    super.key, // ignore: unused_element
  });

  final String? label;
  final bool value;
  final void Function(bool? value)? onChanged; // ignore: avoid_positional_boolean_parameters

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          if (label != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(label ?? ''),
            ),
          Checkbox.adaptive(
            value: value,
            onChanged: onChanged,
          ),
        ],
      );
}
