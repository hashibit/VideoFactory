//
//  Transcribe.swift
//  VideoFactory
//
//  Created by Jie Chen on 2025/2/4.
//

import Foundation

func getWhisEngineExecutable() -> String? {
    return Bundle.main.resourcePath?.appending("/ExternalTools/whis-engine/whis-engine")
}

func getWhisModelPath() -> String? {
    return Bundle.main.resourcePath?.appending("/ExternalTools/whis-models")
}
