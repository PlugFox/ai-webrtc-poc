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
            const leftChannel = input[0]; // Left channel
            const rightChannel = input[1]; // Right channel (if exists)

            // Combine channels if stereo, otherwise just use left channel
            let combinedChannel;
            if (rightChannel) {
                combinedChannel = new Float32Array(leftChannel.length);
                for (let i = 0; i < leftChannel.length; i++) {
                    combinedChannel[i] = (leftChannel[i] + rightChannel[i]) / 2; // Average both channels
                }
            } else {
                combinedChannel = leftChannel;
            }

            this.port.postMessage(combinedChannel);
        }
        return true;
    }
}

registerProcessor('audio-processor', AudioProcessor);
