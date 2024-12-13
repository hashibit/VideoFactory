import Common
import SwiftUI

public struct SubtitleSelectingView: View {
    @State public var appLanguage: String = "中文"
    @State public var showChatGPT: Bool = true
    @State public var autoCorrect: Bool = false
    @State public var autoLaunch: Bool = false
    @State public var apply: Bool = true
    @State public var openLinksInApp: Bool = true

    @State public var showSelectExternalSubtitleFile: Bool = false

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
                section1(embededSubtitles: $embededSubtitles,
                         selectedSubtitleID: $selectedSubtitleID)

                section2(externalSubtitles: $externalSubtitles,
                         selectedSubtitleID: $selectedSubtitleID,
                         showSelectExternalSubtitleFile: $showSelectExternalSubtitleFile)

                section3(transcribeSubtitles: $transcribeSubtitles,
                         selectedSubtitleID: $selectedSubtitleID)

                section4(translateSubtitles: $translateSubtitles,
                         selectedSubtitleID: $selectedSubtitleID)

            }
        }
        .navigationTitle("设置")
    }
}

@ViewBuilder
func section1(embededSubtitles: Binding<[SubtitleModel]>,
              selectedSubtitleID: Binding<UUID?>) -> some View {

    Section(header: Text("内置字幕")) {
        ForEach(embededSubtitles.wrappedValue.indices, id: \.self) { index in
            let sub = embededSubtitles.wrappedValue[index]
            Toggle(
                isOn: Binding(
                    get: { sub.id == selectedSubtitleID.wrappedValue},
                    set: {
                        newValue in selectedSubtitleID.wrappedValue = newValue ? sub.id : nil
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

        NavigationLink(destination: Text("归档的聊天记录")) {
            HStack {
                Image(systemName: "tray")
                Text("已归档的聊天")
            }
        }
    }
}

@ViewBuilder
func section2(externalSubtitles: Binding<[SubtitleModel]>,
              selectedSubtitleID: Binding<UUID?>,
              showSelectExternalSubtitleFile: Binding<Bool>) -> some View {

    Section(header: Text("外部字幕")) {
        ForEach(externalSubtitles.wrappedValue.indices, id: \.self) { index in
            let sub = externalSubtitles.wrappedValue[index]
            Toggle(
                isOn: Binding(
                    get: { sub.id == selectedSubtitleID.wrappedValue},
                    set: {
                        newValue in selectedSubtitleID.wrappedValue = newValue ? sub.id : nil
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

        HStack {
            Button {
                showSelectExternalSubtitleFile.wrappedValue = true
            } label: {
                Label("添加外部字幕...", systemImage: "arrow.clockwise.circle")
            }
            .fileImporter(
                isPresented: showSelectExternalSubtitleFile,
                allowedContentTypes: [.text],
                allowsMultipleSelection: false
            ) {
                result in
                switch result {
                case .success(let file):
                    print("success \(file)")
                case .failure(let error):
                    print("failed \(error)")
                }
            }
        }

    }

}

// 第 3 部分：AI 识别字幕
@ViewBuilder
func section3(transcribeSubtitles: Binding<[SubtitleModel]>,
              selectedSubtitleID: Binding<UUID?>) -> some View {
    
    Section(header: Text("识别字幕")) {
        ForEach(transcribeSubtitles.wrappedValue.indices, id: \.self) { index in
            let sub = transcribeSubtitles.wrappedValue[index]
            Toggle(
                isOn: Binding(
                    get: { sub.id == selectedSubtitleID.wrappedValue},
                    set: {
                        newValue in selectedSubtitleID.wrappedValue = newValue ? sub.id : nil
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
}

// 第 4 部分：翻译字幕
@ViewBuilder
func section4(translateSubtitles: Binding<[SubtitleModel]>,
              selectedSubtitleID: Binding<UUID?>) -> some View {
    Section(header: Text("翻译字幕")) {
        ForEach(translateSubtitles.wrappedValue.indices, id: \.self) { index in
            let sub = translateSubtitles.wrappedValue[index]
            Toggle(
                isOn: Binding(
                    get: { sub.id == selectedSubtitleID.wrappedValue},
                    set: {
                        newValue in selectedSubtitleID.wrappedValue = newValue ? sub.id : nil
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

        NavigationLink(destination: SubtitleTranslate()) {
            HStack {
                Image(systemName: "arrow.clockwise.circle")
                Text("翻译更多...")
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
