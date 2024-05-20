import 'package:poc/src/feature/media_stream/model/media_stream_config.dart';
import 'package:poc/src/feature/media_stream/model/media_stream_context.dart';

Future<MediaStreamContext> $startMediaStream(MediaStreamConfig config) =>
    throw UnsupportedError('Cannot start media stream at the current platform.');

Future<void> $stopMediaStream(MediaStreamContext context) =>
    throw UnsupportedError('Cannot stop media stream at the current platform.');
