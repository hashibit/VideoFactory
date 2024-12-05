import Foundation
import CryptoKit

func generateHash(_ filepath: String) -> String? {
    guard let data = FileManager.default.contents(atPath: filepath) else {
        return nil
    }

    let hash = Insecure.MD5.hash(data: data)
    return hash.map { String(format: "%02hhx", $0) }.joined()
}
