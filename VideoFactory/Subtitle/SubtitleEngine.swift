//
//  SubtitleFactory.swift
//  VideoFactory
//
//  Created by Jie Chen on 2024/12/3.
//

import Foundation
import Engine

public enum FactoryError: Error {
    case taskAlreadyRunning
}

// 10min
public let timeout = 60 * 10

public class SubtitleEngine {

    public static let shared = SubtitleEngine();

    public typealias FactoryTask = Task<Void, Error>

    private var transcribeTask : FactoryTask?
    private var translateTask : FactoryTask?

    private init() { }

    // transcribe return a cancellable task
    public func transcribe(videoFilePath: String, onFinished: @escaping (String) -> Void) -> Result<FactoryTask, Error> {
        if transcribeTask != nil {
            return .failure(FactoryError.taskAlreadyRunning)
        }

        transcribeTask = Task {
            do {
                try Task.checkCancellation()
                // do job
                await doExtractAudio(videoFilePath)
                await doTranscribe(videoFilePath)
                onFinished("")
            } catch is CancellationError {
                print("task is cancelled")
            }
        }
        return .success(transcribeTask!)
    }

    public func translate(subFilePath: String, onFinished: @escaping (String) -> Void) -> Result<FactoryTask, Error> {
        if translateTask != nil {
            return .failure(FactoryError.taskAlreadyRunning)
        }

        translateTask = Task {
            do {
                try Task.checkCancellation()
                // do job
                onFinished("")
            } catch is CancellationError {
                print("task is cancelled")
            }
        }
        return .success(translateTask!)
    }

    private func doExtractAudio(_ videoFilePath: String) async -> String? {
        let outputAudioFilepath = "/tmp/audio.pcm"
        Engine.shared.extractAudioFromVideo(videoFilePath, outputAudioFilepath)

//        let extractor = FFmpegAudioProcessorImpl()
        return ""
    }

    private func doTranscribe(_ videoFilePath: String) async -> String? {
        guard let whisperCmd = getWhisEngineExecutable() else {
            print("whis-engine file is not found")
            return ""
        }
        guard let modelFilepath = getWhisModelPath() else {
            print("whis-model dir is not found")
            return ""
        }

        let audioFilepath = ""
        let outputFilepath = ""

        let process = Process()
        process.executableURL = URL(fileURLWithPath: whisperCmd)
        process.arguments = ["/"]

        let pipe = Pipe()
        process.standardOutput = pipe

        do {
            try process.run()
            DispatchQueue.global().asyncAfter(deadline: .now() + TimeInterval(timeout)) {
                if process.isRunning {
                    process.terminate()
                }
            }

            await withCheckedContinuation { continuation in
                process.terminationHandler = { _ in
                    continuation.resume()
                }
            }

//            async let outputData: Data = {
//                var data = Data()
//                for try await byte in pipe.fileHandleForReading.bytes {
//                    data.append(byte)
//                }
//                return data
//            }()
//            let output = await outputData

            var outputData = Data()
            for try await byte in pipe.fileHandleForReading.bytes {
                outputData.append(byte)
            }

            return String(data: outputData, encoding: .utf8) ?? ""

        } catch {
            print("failed to run process: \(error.localizedDescription)")
            return ""
        }
    }

}
