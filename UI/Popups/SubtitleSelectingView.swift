import Common
import SwiftUI

public struct SubtitleSelectingView: View {
    @State public var appLanguage: String = "中文"
    @State public var showChatGPT: Bool = true
    @State public var autoCorrect: Bool = false
    @State public var autoLaunch: Bool = false
    @State public var apply: Bool = true
    @State public var openLinksInApp: Bool = true

    @State public var embededSubtitles: [SubtitleModel] = []
    @State public var embededSelectedIndex: Int?

    @State public var externalSubtitles: [SubtitleModel] = []
    @State public var externalSelectedIndex: Int?

    @State public var transcribeSubtitles: [SubtitleModel] = []
    @State public var transcribeSelectedIndex: Int?

    @State public var translateSubtitles: [SubtitleModel] = []
    @State public var translateSelectedIndex: Int?

    private func clearAllSelected() {
        embededSelectedIndex = nil
        externalSelectedIndex = nil
        transcribeSelectedIndex = nil
        translateSelectedIndex = nil

    }

    public var body: some View {
        NavigationStack {
            List {
                // 第一部分：账户
                Section(header: Text("内置字幕")) {
                    ForEach(embededSubtitles.indices, id: \.self) { index in
                        Toggle(
                            isOn: Binding(
                                get: { embededSelectedIndex == index },
                                set: { newValue in
                                    self.clearAllSelected()
                                    if newValue {
                                        embededSelectedIndex = index
                                    }
                                }
                            )
                        ) {
                            HStack {
                                Text("内嵌字幕 \(index)")
                                Spacer()
                                Text("英文")
                                    .foregroundColor(.gray)
                            }
                        }
                    }

                    NavigationLink(destination: Text("个性化设置")) {
                        HStack {
                            Image(systemName: "person.crop.circle")
                            Text("个性化")
                        }
                    }

                    NavigationLink(destination: Text("数据管理")) {
                        HStack {
                            Image(systemName: "archivebox")
                            Text("数据管理")
                        }
                    }

                    NavigationLink(destination: Text("归档的聊天记录")) {
                        HStack {
                            Image(systemName: "tray")
                            Text("已归档的聊天")
                        }
                    }
                }

                // 第二部分：外部字幕
                Section(header: Text("外部字幕")) {
                    ForEach(externalSubtitles.indices, id: \.self) { index in
                        Toggle(
                            isOn: Binding(
                                get: { externalSelectedIndex == index },
                                set: { newValue in
                                    self.clearAllSelected()
                                    if newValue {
                                        externalSelectedIndex = index
                                    }
                                }
                            )
                        ) {
                            HStack {
                                Text("外部字幕 \(index)")
                                Spacer()
                                Text("英文")
                                    .foregroundColor(.gray)
                            }
                        }
                    }

                    NavigationLink(destination: Text("添加外部字幕")) {
                        HStack {
                            Image(systemName: "arrow.clockwise.circle")
                            Text("添加外部字幕...")
                        }
                    }

                }

                // 第 3 部分：AI 识别字幕
                // 第二部分：外部字幕
                Section(header: Text("识别字幕")) {
                    ForEach(transcribeSubtitles.indices, id: \.self) { index in
                        Toggle(
                            isOn:
                                Binding(
                                    get: { transcribeSelectedIndex == index },
                                    set: { newValue in
                                        self.clearAllSelected()
                                        if newValue {
                                            transcribeSelectedIndex = index
                                        }
                                    }
                                )
                        ) {
                            HStack {
                                Text("识别字幕 \(index)")
                                Spacer()
                                Text("英文")
                                    .foregroundColor(.gray)
                            }
                        }
                    }

                    NavigationLink(destination: Text("识别字幕")) {
                        HStack {
                            Image(systemName: "arrow.clockwise.circle")
                            Text("重新识别...")
                        }
                    }
                }

                // 第 4 部分：翻译字幕
                Section(header: Text("翻译字幕")) {
                    ForEach(translateSubtitles.indices, id: \.self) { index in
                        Toggle(
                            isOn:
                                Binding(
                                    get: { translateSelectedIndex == index },
                                    set: { newValue in
                                        self.clearAllSelected()
                                        if newValue {
                                            translateSelectedIndex = index
                                        }
                                    }
                                )
                        ) {
                            HStack {
                                Text("翻译字幕 \(index)")
                                Spacer()
                                Text("英文")
                                    .foregroundColor(.gray)
                            }
                        }
                    }

                    NavigationLink(destination: Text("翻译字幕")) {
                        HStack {
                            Image(systemName: "arrow.clockwise.circle")
                            Text("翻译更多...")
                        }
                    }
                }
            }
            .navigationTitle("设置")
        }
    }
}

struct SubtitleSelectingView_Previews: PreviewProvider {
    static let embededSubtitles: [SubtitleModel] = [
        SubtitleModel(), SubtitleModel(), SubtitleModel(),
    ]
    static let externalSubtitles: [SubtitleModel] = [
        SubtitleModel(), SubtitleModel(),
    ]
    static let transcribeSubtitles: [SubtitleModel] = [
        SubtitleModel(), SubtitleModel(), SubtitleModel(),
    ]
    static let translateSubtitles: [SubtitleModel] = [
        SubtitleModel(), SubtitleModel(),
    ]
    static var previews: some View {
        SubtitleSelectingView(
            embededSubtitles: embededSubtitles,
            externalSubtitles: externalSubtitles,
            transcribeSubtitles: transcribeSubtitles,
            translateSubtitles: translateSubtitles
        )
    }
}
