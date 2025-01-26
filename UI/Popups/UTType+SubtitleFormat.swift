import UniformTypeIdentifiers

extension UTType {
    static var vtt: UTType {
        UTType(importedAs: "org.w3c.vtt")
    }

    static var srt: UTType {
        UTType(importedAs: "application.x-subrip")
    }
}