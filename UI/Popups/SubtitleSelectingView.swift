import Common
import SwiftUI

public struct SubtitleSelectingView: View {
    @State public var embededSubtitles: [SubtitleModel] = []
    @State public var externalSubtitles: [SubtitleModel] = []
    @State public var transcribeSubtitles: [SubtitleModel] = []
    @State public var translateSubtitles: [SubtitleModel] = []
    @State public var selectedSubtitleID: UUID?

    // for public
    public init(embededSubtitles: [SubtitleModel],
                externalSubtitles: [SubtitleModel],
                transcribeSubtitles: [SubtitleModel],
                translateSubtitles: [SubtitleModel],
                selectedSubtitleID: UUID?) {
        self.embededSubtitles = embededSubtitles
        self.externalSubtitles = externalSubtitles
        self.transcribeSubtitles = transcribeSubtitles
        self.translateSubtitles = translateSubtitles
        self.selectedSubtitleID = selectedSubtitleID
    }

    public var body: some View {
        NavigationStack {
            List {
                Section1(embededSubtitles: $embededSubtitles,
                         selectedSubtitleID: $selectedSubtitleID)

                Section2(externalSubtitles: $externalSubtitles,
                         selectedSubtitleID: $selectedSubtitleID)

                Section3(transcribeSubtitles: $transcribeSubtitles,
                         selectedSubtitleID: $selectedSubtitleID)

                Section4(translateSubtitles: $translateSubtitles,
                         selectedSubtitleID: $selectedSubtitleID)

            }
        }
        .navigationTitle("设置")
    }
}

struct Section1: View {
    @Binding var embededSubtitles: [SubtitleModel]
    @Binding var selectedSubtitleID: UUID?

    var body: some View {
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

            NavigationLink(destination: Text("归档的聊天记录")) {
                HStack {
                    Image(systemName: "tray")
                    Text("已归档的聊天")
                }
            }
        }
    }
}

struct Section2: View {
    @Binding var externalSubtitles: [SubtitleModel]
    @Binding var selectedSubtitleID: UUID?

    @State var showFileImporter: Bool = false

    var body: some View {
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

            HStack {
                Button {
                    showFileImporter = true
                } label: {
                    Label("添加外部字幕...", systemImage: "arrow.clockwise.circle")
                }
                .fileImporter(
                    isPresented: $showFileImporter,
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
}

// 第 3 部分：AI 识别字幕
struct Section3: View {
    @Binding var transcribeSubtitles: [SubtitleModel]
    @Binding var selectedSubtitleID: UUID?

    var body: some View {
        Section(header: Text("识别字幕")) {
            ForEach(transcribeSubtitles.indices, id: \.self) { index in
                let sub = transcribeSubtitles[index]
                Toggle(
                    isOn: Binding(
                        get: { sub.id == selectedSubtitleID },
                        set: { newValue in
                            selectedSubtitleID = newValue ? sub.id : nil
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
}

// 第 4 部分：翻译字幕
struct Section4: View {
    @Binding var translateSubtitles: [SubtitleModel]
    @Binding var selectedSubtitleID: UUID?

    var body: some View {
        Section(header: Text("翻译字幕")) {
            ForEach(translateSubtitles.indices, id: \.self) { index in
                let sub = translateSubtitles[index]
                Toggle(
                    isOn: Binding(
                        get: { sub.id == selectedSubtitleID
 },
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

            NavigationLink(destination: SubtitleTranslate()) {
                HStack {
                    Image(systemName: "arrow.clockwise.circle")
                    Text("翻译更多...")
                }
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
            translateSubtitles: translateSubtitles,
            selectedSubtitleID: nil
        )
    }
}
