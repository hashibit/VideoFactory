import Foundation

enum MpvProperty: String {
    // 播放器状态相关
    case trackList = "track-list"          // 轨道列表
    case pause = "pause"                   // 暂停状态
    case position = "time-pos"             // 当前播放位置(秒)
    case duration = "duration"             // 总时长(秒)
    case volume = "volume"                 // 音量
    case mute = "mute"                    // 静音状态

    // 视频相关
    case videoFormat = "video-format"      // 视频格式
    case videoCodec = "video-codec"        // 视频编码
    case width = "width"                   // 视频宽度
    case height = "height"                 // 视频高度

    // 音频相关
    case audioFormat = "audio-format"      // 音频格式
    case audioCodec = "audio-codec"        // 音频编码
    case audioDeviceList = "audio-device-list" // 音频设备列表
}
