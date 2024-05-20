import 'package:meta/meta.dart';

@immutable
class MediaStreamConfig {
  const MediaStreamConfig({
    required this.url,
    required this.audioBufferSize,
  });

  final String? url;
  final int audioBufferSize;
}
