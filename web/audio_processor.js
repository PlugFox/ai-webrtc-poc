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

registerProcessor('audio-processor', AudioProcessor);