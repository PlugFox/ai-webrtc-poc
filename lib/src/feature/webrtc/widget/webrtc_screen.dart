import 'package:flutter/material.dart';
import 'package:poc/src/common/widget/common_actions.dart';

/// {@template webrtc_screen}
/// WebRTCScreen widget.
/// {@endtemplate}
class WebRTCScreen extends StatelessWidget {
  /// {@macro webrtc_screen}
  const WebRTCScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
          body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            title: const Text('WebRTC API'),
            actions: CommonActions(),
          ),
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('WebRTC API'),
                ],
              ),
            ),
          ),
        ],
      ));
}
