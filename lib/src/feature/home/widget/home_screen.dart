import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';
import 'package:poc/src/common/widget/common_actions.dart';
import 'package:poc/src/common/widget/scaffold_padding.dart';

/// {@template home_screen}
/// HomeScreen widget.
/// {@endtemplate}
class HomeScreen extends StatelessWidget {
  /// {@macro home_screen}
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
          body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            title: const Text('Home'),
            leading: const SizedBox.shrink(),
            actions: CommonActions(),
          ),
          ScaffoldPadding.sliver(
            context,
            DefaultTextStyle(
              style: Theme.of(context).textTheme.labelMedium!,
              child: SliverFixedExtentList(
                itemExtent: 92,
                delegate: SliverChildListDelegate(
                  <Widget>[
                    _HomeTile(
                      label: 'WebSpeech API',
                      description: 'The Web Speech API provides two distinct areas '
                          'of functionality — speech recognition, '
                          'and speech synthesis, also known as text to speech, or tts.',
                      onTap: () => Octopus.of(context).pushNamed('web-speech'),
                    ),
                    _HomeTile(
                      label: 'Media Stream',
                      description: 'The MediaStream interface of the Media Capture and '
                          'Streams API represents a stream of media content. '
                          'A stream consists of several tracks, such as video or audio tracks. '
                          'Each track is specified as an instance of MediaStreamTrack.',
                      onTap: () => Octopus.of(context).pushNamed('media-stream'),
                    ),
                    _HomeTile(
                      label: 'WebRTC API',
                      description: 'With WebRTC, you can add real-time communication capabilities to '
                          'your application that works on top of an open standard. '
                          'It supports video, voice, and generic data to be sent between peers.',
                      onTap: () => Octopus.of(context).pushNamed('web-rtc'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          /* const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Home'),
                ],
              ),
            ),
          ), */
        ],
      ));
}

class _HomeTile extends StatelessWidget {
  const _HomeTile({
    required this.label,
    this.description = '',
    this.onTap,
    super.key, // ignore: unused_element
  });

  final String label;
  final String description;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: true,
        onTap: onTap,
      );
}
