import 'package:control/control.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poc/src/common/constant/config.dart';
import 'package:poc/src/common/widget/common_actions.dart';
import 'package:poc/src/common/widget/not_available_screen.dart';
import 'package:poc/src/common/widget/scaffold_padding.dart';
import 'package:poc/src/feature/media_stream/controller/media_stream_controller.dart';
import 'package:poc/src/feature/media_stream/controller/media_stream_state.dart';
import 'package:poc/src/feature/media_stream/data/media_stream_repository.dart';
import 'package:poc/src/feature/media_stream/model/media_stream_config.dart';

/// {@template media_stream_screen}
/// MediaStreamScreen widget.
/// {@endtemplate}
class MediaStreamScreen extends StatefulWidget {
  /// {@macro media_stream_screen}
  const MediaStreamScreen({
    super.key, // ignore: unused_element
  });

  @override
  State<MediaStreamScreen> createState() => _MediaStreamScreenState();
}

class _MediaStreamScreenState extends State<MediaStreamScreen> {
  late final MediaStreamController _controller;
  late final TextEditingController _urlController = TextEditingController(text: Config.mediaStreamURL);
  late final TextEditingController _sampleRateController =
      TextEditingController(text: Config.mediaStreamSampleRate.toString());
  late final TextEditingController _audioBufferSizeController =
      TextEditingController(text: Config.mediaStreamAudioBufferSize.toString());
  MediaStreamConfig _config = const MediaStreamConfig(
    url: Config.mediaStreamURL,
    audioBufferSize: Config.mediaStreamAudioBufferSize,
    sampleRate: Config.mediaStreamSampleRate,
  );

  @override
  void initState() {
    super.initState();
    _controller = MediaStreamController(
      repository: MediaStreamRepositoryImpl(),
    );
    _urlController.addListener(_changeConfig);
    _sampleRateController.addListener(_changeConfig);
    _audioBufferSizeController.addListener(_changeConfig);
    _controller.addListener(_onState);
  }

  /// Start media stream
  void start() => _controller.start(_config);

  /// Stop media stream
  void stop() => _controller.stop();

  void _changeConfig() => _config = _config.copyWith(
        url: _urlController.text.isEmpty ? Config.mediaStreamURL : _urlController.text.trim(),
        audioBufferSize: int.tryParse(_audioBufferSizeController.text) ?? Config.mediaStreamAudioBufferSize,
        sampleRate: int.tryParse(_sampleRateController.text) ?? Config.mediaStreamSampleRate,
      );

  void _onState() {
    final state = _controller.state;
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

  @override
  void dispose() {
    _urlController.dispose();
    _sampleRateController.dispose();
    _audioBufferSizeController.dispose();
    _controller
      ..stop()
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return const NotAvailableScreen(reason: 'MediaStream is available only on web platform.');
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyLarge ?? const TextStyle();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Stream'),
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
                height: 72,
                child: StateConsumer<MediaStreamController, MediaStreamState>(
                  controller: _controller,
                  buildWhen: (previous, current) => previous.isProcessing != current.isProcessing,
                  builder: (context, state, _) => AbsorbPointer(
                    absorbing: state.isProcessing,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      opacity: state.isProcessing ? .5 : 1,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: TextField(
                                controller: _urlController,
                                readOnly: state.isProcessing,
                                enabled: !state.isProcessing,
                                keyboardType: TextInputType.url,
                                autofillHints: const <String>[AutofillHints.url],
                                decoration: const InputDecoration(
                                  labelText: 'URL',
                                  hintText: 'Enter URL',
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: TextField(
                                controller: _sampleRateController,
                                readOnly: state.isProcessing,
                                enabled: !state.isProcessing,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: const InputDecoration(
                                  labelText: 'Sample Rate',
                                  hintText: 'Enter Sample Rate',
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: TextField(
                                controller: _audioBufferSizeController,
                                readOnly: state.isProcessing,
                                enabled: !state.isProcessing,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: const InputDecoration(
                                  labelText: 'Audio Buffer Size',
                                  hintText: 'Enter Audio Buffer Size',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Divider(height: 16, thickness: 1),
            Expanded(
              child: ScaffoldPadding.widget(
                context,
                Align(
                  alignment: const Alignment(0, -0.3),
                  child: RepaintBoundary(
                    child: StateConsumer<MediaStreamController, MediaStreamState>(
                      controller: _controller,
                      builder: (context, state, _) => ListView(
                        children: <Widget>[
                          Text(
                            state.subtitles['text']?.toString() ?? '--',
                            style: textStyle.copyWith(
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.subtitles['partial']?.toString() ?? '--',
                            style: textStyle.copyWith(
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      floatingActionButton: StateConsumer<MediaStreamController, MediaStreamState>(
        controller: _controller,
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
