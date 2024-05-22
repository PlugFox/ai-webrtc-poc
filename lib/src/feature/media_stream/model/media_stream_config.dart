import 'package:meta/meta.dart';

@immutable
class MediaStreamConfig {
  const MediaStreamConfig({
    required this.url, // Config.mediaStreamURL
    required this.audioBufferSize, // Config.mediaStreamAudioBufferSize
    required this.sampleRate, // Config.mediaStreamSampleRate
  });

  final String url;
  final int audioBufferSize;
  final int sampleRate;

  MediaStreamConfig copyWith({
    String? url,
    int? audioBufferSize,
    int? sampleRate,
  }) =>
      MediaStreamConfig(
        url: url ?? this.url,
        audioBufferSize: audioBufferSize ?? this.audioBufferSize,
        sampleRate: sampleRate ?? this.sampleRate,
      );

  Map<String, Object?> toJson() => <String, Object?>{
        'url': url,
        'audioBufferSize': audioBufferSize,
        'sampleRate': sampleRate,
      };
}
