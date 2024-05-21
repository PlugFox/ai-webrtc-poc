import 'package:control/control.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _controller = MediaStreamController(
      repository: MediaStreamRepositoryImpl(),
    );
  }

  /// Start media stream
  void start() => _controller.start(const MediaStreamConfig(
        url: Config.mediaStreamURL,
        audioBufferSize: Config.mediaStreamAudioBufferSize,
      ));

  /// Stop media stream
  void stop() => _controller.stop();

  @override
  void dispose() {
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
              const SizedBox(
                height: 48,
                child: Placeholder(),
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
