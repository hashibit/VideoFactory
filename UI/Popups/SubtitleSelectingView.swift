import Common
import SwiftUI

public struct SubtitleSelectingView: View {
    @State public var appLanguage: String = "中文"
    @State public var showChatGPT: Bool = true
    @State public var autoCorrect: Bool = false
    @State public var autoLaunch: Bool = false
    @State public var apply: Bool = true
    @State public var openLinksInApp: Bool = true

    @State public var selectedSubtitleID: UUID?

    @State public var embededSubtitles: [SubtitleModel] = []
    @State public var externalSubtitles: [SubtitleModel] = []
    @State public var transcribeSubtitles: [SubtitleModel] = []
    @State public var translateSubtitles: [SubtitleModel] = []

    public init(embededSubtitles: [SubtitleModel],
                externalSubtitles: [SubtitleModel],
                transcribeSubtitles: [SubtitleModel],
                translateSubtitles: [SubtitleModel]
    ) {
        self.embededSubtitles = embededSubtitles
        self.externalSubtitles = externalSubtitles
        self.translateSubtitles = translateSubtitles
        self.transcribeSubtitles = transcribeSubtitles
    }

    public var body: some View {
        NavigationStack {
            List {
                // 第一部分：账户
                Section(header: Text("内置字幕")) {
                    ForEach(embededSubtitles.indices, id: \.self) { index in
                        let sub = embededSubtitles[index]
                        Toggle(
                            isOn: Binding(
                                get: { sub.id == selectedSubtitleID},
                                set: {
                                    newValue in selectedSubtitleID = newValue ? sub.id : nil
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
                        let sub = externalSubtitles[index]
                        Toggle(
                            isOn: Binding(
                                get: { sub.id == selectedSubtitleID},
                                set: {
                                    newValue in selectedSubtitleID = newValue ? sub.id : nil
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
                        let sub = transcribeSubtitles[index]
                        Toggle(
                            isOn: Binding(
                                get: { sub.id == selectedSubtitleID},
                                set: {
                                    newValue in selectedSubtitleID = newValue ? sub.id : nil
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
                        let sub = translateSubtitles[index]
                        Toggle(
                            isOn: Binding(
                                get: { sub.id == selectedSubtitleID},
                                set: {
                                    newValue in selectedSubtitleID = newValue ? sub.id : nil
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

                    NavigationLink(destination: TranslationView()) {
                        HStack {
                            Image(systemName: "arrow.clockwise.circle")
                            Text("翻译更多...")
                        }
                    }
                }
            }
        }
        .navigationTitle("设置")
    }
}

struct TranslationView: View {
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("翻译字幕内容")
                Spacer()
                HStack {
                    Button("取消") {
                        print("取消")
                    }
                    Button("开始") {
                        print("开始")
                    }
                }
            }
            .padding(10)
            .navigationBarBackButtonHidden()
            .navigationTitle("翻译字幕")
            .frame(width: 500, height: 300)
            .background(.background)
            .position(
                x: geometry.size.width/2,
                y: geometry.size.height/2
            )
            .onTapGesture {
                print("onTap")
            }
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
