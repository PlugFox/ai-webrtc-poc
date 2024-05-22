# Voice Recognition server using Vosk and WebSockets
#
# To make it work:
# 1) Download vosk-model-en-us-0.22 from https://alphacephei.com/vosk/models
# 2) Unpack it as vosk-model to app.py directory
# 3) Run pip install websockets vosk numpy
# 4) And start with python app.py

import asyncio
import websockets
import numpy as np
from vosk import Model, KaldiRecognizer
import wave
import uuid
from datetime import datetime

#SAMPLE_RATE = 16000  # Sample rate of 16000 Hz
SAMPLE_RATE = 44100  # Sample rate of 44100 Hz

# Buffer threshold for accumulating data (e.g., 1 second of data)
BUFFER_THRESHOLD = SAMPLE_RATE * 1 # 1 second of data at a sample rate of 44100 Hz

# Path to the unpacked Vosk model directory
# Downloaded from https://alphacephei.com/vosk/models and unpacked
# e.g. vosk-model-en-us-0.22
model_path = "vosk-model"
model = Model(model_path)
recognizer = KaldiRecognizer(model, SAMPLE_RATE)  # Sample rate of 44100 Hz


# Function to write audio data to a file
def write_wave_file(filename, data, frame_rate):
    with wave.open(filename, 'wb') as wf:
        wf.setnchannels(1)  # mono
        wf.setsampwidth(2)  # 16-bit
        wf.setframerate(frame_rate)
        wf.writeframes(data)

async def recognize_audio(websocket, path):
    audio_buffer = np.array([], dtype=np.float32)
    raw_audio_data = bytearray()  # to store raw audio data

    # Generate a unique filename
    unique_filename = f"received_audio_{datetime.now().strftime('%Y%m%d_%H%M%S')}_{uuid.uuid4()}.wav"

    while True:
        try:
            message = await websocket.recv()
            audio_data = np.frombuffer(message, dtype=np.float32)
            audio_buffer = np.concatenate((audio_buffer, audio_data))

            # Convert audio data to PCM 16-bit format
            int_audio_data = (audio_data * 32767).astype(np.int16)
            raw_audio_data.extend(int_audio_data.tobytes())  # add converted audio data

            # Process accumulated data when there is enough
            if len(audio_buffer) >= BUFFER_THRESHOLD:
                chunk = audio_buffer[:BUFFER_THRESHOLD]
                audio_buffer = audio_buffer[BUFFER_THRESHOLD:]

                # Convert chunk to PCM 16-bit format for recognition
                int_chunk = (chunk * 32767).astype(np.int16)

                if recognizer.AcceptWaveform(int_chunk.tobytes()):
                    result = recognizer.Result()
                    print(f"Full result: {result}")
                    await websocket.send(result)
                else:
                    partial_result = recognizer.PartialResult()
                    print(f"Partial result: {partial_result}")
                    await websocket.send(partial_result)

        except websockets.ConnectionClosed:
            print("Connection closed")
            break

    # Save audio data to a file after the connection is closed
    write_wave_file(unique_filename, raw_audio_data, SAMPLE_RATE)
    print(f"Audio data saved to {unique_filename}")

# Start the WebSocket server on port 8080
start_server = websockets.serve(recognize_audio, 'localhost', 8080)

asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()
