// ignore_for_file: avoid_types_on_closure_parameters, avoid_print

import 'dart:async';
import 'dart:js_interop' as web;

import 'package:poc/src/feature/media_stream/model/media_stream_config.dart';
import 'package:poc/src/feature/media_stream/model/media_stream_context.dart';
import 'package:web/web.dart' as web;

Future<void> $stopMediaStream(MediaStreamContext context) async {
  if (context is! _MediaStreamContext$JS) throw UnsupportedError('Unsupported MediaStreamContext: $context');
  final mediaStream = context._mediaStream;
  final tracks = mediaStream.getTracks().toDart;

  // Stop all audio tracks
  for (final track in tracks) track.stop();

  // Close web socket
  context._webSocket.close();

  // Disconnect AudioContext & AudioWorkletNode
  context._audioWorkletNode.disconnect();
  context._audioContext.close().toDart.ignore();
}

Future<MediaStreamContext> $startMediaStream(MediaStreamConfig config) async {
  web.MediaStream? mediaStream;
  try {
    // Get microphone access
    mediaStream = await _getMicrophoneAccess();

    // Setup audio context
    final (context: web.AudioContext audioContext, worklet: web.AudioWorkletNode audioWorkletNode) =
        await _setupAudioContext(mediaStream);

    // Create subtitles controller
    final subtitlesController = StreamController<Object>();
    final wsCompleter = Completer<void>();
    Timer? heartbeatTimer;
    final socket = web.WebSocket(config.url);

    void close(String reason) {
      if (!wsCompleter.isCompleted) wsCompleter.completeError(reason);
      if (!subtitlesController.isClosed) subtitlesController.close();
      heartbeatTimer?.cancel();
    }

    // Setup Web Socket connection
    socket
      ..addEventListener(
          'open',
          (web.Event event) {
            print('WebSocket connected');
            if (!wsCompleter.isCompleted) wsCompleter.complete();
          }.toJS)
      ..addEventListener(
          'message',
          (web.MessageEvent event) {
            // https://developer.mozilla.org/en-US/docs/Web/API/WebSocket/message_event
            //final data = event.data;
            // TODO(plugfox): decode subtitles
            subtitlesController.add(event.data ?? <int>[]);
          }.toJS)
      ..addEventListener(
          'close',
          (web.CloseEvent event) {
            close('WebSocket closed: ${event.reason}');
          }.toJS)
      ..addEventListener(
          'error',
          (web.Event event) {
            close('WebSocket error: $event');
          }.toJS);
    await wsCompleter.future;

    heartbeatTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (socket.readyState != web.WebSocket.OPEN) close('WebSocket closed unexpectedly');
    });

    audioWorkletNode.port.onmessage = (web.MessageEvent event) {
      final audioData = event.data;
      if (audioData is! web.Float32List) return;
      //print('Audio data ${audioData.runtimeType}: $audioData');
      if (socket.readyState == web.WebSocket.OPEN) socket.send(audioData);
    }.toJS;

    //_setupWebSocket(audioWorkletNode);
    return _MediaStreamContext$JS(
      mediaStream: mediaStream,
      audioContext: audioContext,
      audioWorkletNode: audioWorkletNode,
      webSocket: socket,
      subtitles: subtitlesController.stream,
    );
  } on Object {
    final tracks = mediaStream?.getTracks().toDart ?? <web.MediaStreamTrack>[];
    for (final track in tracks) track.stop();
    rethrow;
  }
}

Future<web.MediaStream> _getMicrophoneAccess() async {
  /* // new (window.AudioContext || window.webkitSpeechRecognition)()
  web.JSAny? constructor;
  if (web.window.has('webkitSpeechRecognition')) {
    constructor = web.window['webkitAudioContext'];
  } else if (web.window.has('AudioContext')) {
    constructor = web.window['AudioContext '];
  }
  if (constructor == null) {
    throw UnsupportedError('AudioContext is not supported.');
  } else if (constructor is! web.JSFunction) {
    throw UnsupportedError('AudioContext is not supported. $constructor');
  }
  final object = constructor.callAsConstructor<web.JSObject>(); */

  // Request media stream
  final completer = Completer<web.MediaStream>();
  web.window.navigator.getUserMedia(
    web.MediaStreamConstraints(
      audio: true.toJS,
      video: false.toJS,
      /* video: config.video.toJS, audio: config.audio.toJS */
    ),
    (web.MediaStream stream) {
      print('Media stream started: $stream');
      completer.complete(stream);
    }.toJS,
    (web.DOMException error) {
      completer.completeError('Error accessing microphone: ${error.message}');
    }.toJS,
  );
  return await completer.future;
}

Future<({web.AudioContext context, web.AudioWorkletNode worklet})> _setupAudioContext(web.MediaStream stream) async {
  //const audioContext = new (window.AudioContext || window.webkitAudioContext)();
  final audioContext = web.AudioContext();

  /* const processorCode = '''
    class AudioProcessor extends AudioWorkletProcessor {
      constructor() {
        super();
        this.port.onmessage = (event) => {
          // Handle messages from the main thread
        };
      }

      process(inputs, outputs, parameters) {
        const input = inputs[0];
        if (input.length > 0) {
          const channelData = input[0];
          this.port.postMessage(channelData);
        }
        return true;
      }
    }
    registerProcessor('processor', AudioProcessor);
  ''';

  final blob =
      web.Blob(web.JSArray.withLength(1)..add(processorCode.toJS), web.BlobPropertyBag(type: 'application/javascript'));
  final url = web.URL.createObjectURL(blob);
  await audioContext.audioWorklet.addModule(url).toDart; */

  await audioContext.audioWorklet.addModule('audio_processor.js').toDart;
  final source = audioContext.createMediaStreamSource(stream);
  final audioWorkletNode = web.AudioWorkletNode(audioContext, 'audio-processor');
  source.connect(audioWorkletNode);
  audioWorkletNode.connect(audioContext.destination);
  return (
    context: audioContext,
    worklet: audioWorkletNode,
  );
}

class _MediaStreamContext$JS implements MediaStreamContext {
  _MediaStreamContext$JS({
    required web.MediaStream mediaStream,
    required web.AudioContext audioContext,
    required web.AudioWorkletNode audioWorkletNode,
    required web.WebSocket webSocket,
    required this.subtitles,
  })  : _audioWorkletNode = audioWorkletNode,
        _audioContext = audioContext,
        _mediaStream = mediaStream,
        _webSocket = webSocket;

  final web.MediaStream _mediaStream;
  final web.AudioContext _audioContext;
  final web.AudioWorkletNode _audioWorkletNode;
  final web.WebSocket _webSocket;

  @override
  final Stream<Object> subtitles;
}
