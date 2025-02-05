//
//  Engine.swift
//  VideoFactory
//
//  Created by Jie Chen on 2025/2/5.
//



public struct Engine {
    private let bridge = AudioProcessorBridge()

    public func extractAudioFromVideo(_ videoFilepath: String, _ audioFilepath: String) {
        bridge.extractAudio(fromVideo: videoFilepath, output: audioFilepath)
    }
}
