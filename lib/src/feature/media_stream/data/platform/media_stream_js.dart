// ignore_for_file: avoid_types_on_closure_parameters, avoid_print

import 'dart:async';
import 'dart:js_interop' as web;

import 'package:poc/src/feature/media_stream/model/media_stream_config.dart';
import 'package:poc/src/feature/media_stream/model/media_stream_context.dart';
import 'package:web/web.dart' as web;

Future<void> $stopMediaStream(MediaStreamContext context) async {
  if (context is! _MediaStreamContext$JS) return;
  final mediaStream = context.mediaStream;
  final tracks = mediaStream.getTracks().toDart;

  // Stop all audio tracks
  for (final track in tracks) track.stop();

  // Disconnect audio context and close web socket
  // ws?.close();

  // Disconnect AudioContext & AudioWorkletNode
  context.audioWorkletNode.disconnect();
  context.audioContext.close();
}

Future<MediaStreamContext> $startMediaStream(MediaStreamConfig config) async {
  final stream = await _getMicrophoneAccess();
  final context = await _setupAudioContext(stream);

  context.worklet.port.onmessage = (web.MessageEvent event) {
    final audioData = event.data;
    if (audioData is! web.Float32List) return;
    print('Audio data ${audioData.runtimeType}: $audioData');
    /* if (socket.readyState == web.WebSocket.OPEN) {
      socket.send(audioData);
    } */
  }.toJS;
  //_setupWebSocket(audioWorkletNode);

  return _MediaStreamContext$JS(
    mediaStream: stream,
    audioContext: context.context,
    audioWorkletNode: context.worklet,
  );
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
    required this.mediaStream,
    required this.audioContext,
    required this.audioWorkletNode,
  });

  final web.MediaStream mediaStream;
  final web.AudioContext audioContext;
  final web.AudioWorkletNode audioWorkletNode;
}

/* extension type TypedArray(web.JSObject _) implements web.JSObject {
  external ArrayBuffer get buffer;

  external int get length;
}

extension type ArrayBuffer._(web.JSObject _) implements web.JSObject {}
 */