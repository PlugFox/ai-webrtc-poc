import 'package:poc/src/feature/media_stream/data/platform/media_stream_stub.dart'
    // ignore: uri_does_not_exist
    if (dart.library.js_interop) 'package:poc/src/feature/media_stream/data/platform/media_stream_js.dart'
    // ignore: uri_does_not_exist
    if (dart.library.io) 'package:poc/src/feature/media_stream/data/platform/media_stream_vm.dart';
import 'package:poc/src/feature/media_stream/model/media_stream_config.dart';
import 'package:poc/src/feature/media_stream/model/media_stream_context.dart';

abstract interface class IMediaStreamRepository {
  /// Start and get media stream
  Future<MediaStreamContext> startMediaStream(MediaStreamConfig config);

  /// Stop media stream
  Future<void> stopMediaStream(MediaStreamContext context);
}

final class MediaStreamRepositoryImpl implements IMediaStreamRepository {
  @override
  Future<MediaStreamContext> startMediaStream(MediaStreamConfig config) => $startMediaStream(config);

  @override
  Future<void> stopMediaStream(MediaStreamContext context) => $stopMediaStream(context);
}
