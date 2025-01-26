import Common
import SwiftUI

public struct SubtitleSelectingView: View {
    @Binding public var embededSubtitles: [SubtitleModel]
    @Binding public var externalSubtitles: [SubtitleModel]
    @Binding public var transcribeSubtitles: [SubtitleModel]
    @Binding public var translateSubtitles: [SubtitleModel]
    @Binding public var selectedSubtitleID: UUID?

    public var onInsertOrUpdateSubtitle: (SubtitleModel) -> Void

    @State private var showTranscribeView: Bool = false
    @State private var showTranslateView: Bool = false

    public init(
        embededSubtitles: Binding<[SubtitleModel]>,
        externalSubtitles: Binding<[SubtitleModel]>,
        transcribeSubtitles: Binding<[SubtitleModel]>,
        translateSubtitles: Binding<[SubtitleModel]>,
        selectedSubtitleID: Binding<UUID?>,
        onInsertOrUpdateSubtitle: @escaping (SubtitleModel) -> Void
    ) {
        _embededSubtitles = embededSubtitles
        _externalSubtitles = externalSubtitles
        _transcribeSubtitles = transcribeSubtitles
        _translateSubtitles = translateSubtitles
        _selectedSubtitleID = selectedSubtitleID
        self.onInsertOrUpdateSubtitle = onInsertOrUpdateSubtitle
    }

    public var body: some View {
        NavigationStack {
            List {
                Section1(embededSubtitles: $embededSubtitles,
                         selectedSubtitleID: $selectedSubtitleID)

                Section2(externalSubtitles: $externalSubtitles,
                         selectedSubtitleID: $selectedSubtitleID,
                         onInsertOrUpdateSubtitle: onInsertOrUpdateSubtitle)

                Section3(transcribeSubtitles: $transcribeSubtitles,
                         selectedSubtitleID: $selectedSubtitleID,
                         showTranscribeView: $showTranscribeView
                )

                Section4(translateSubtitles: $translateSubtitles,
                         selectedSubtitleID: $selectedSubtitleID,
                         showTranslateView: $showTranslateView
                )
            }
            .navigationDestination(isPresented: $showTranscribeView) {
                SubtitleTranscribe()
            }
            .navigationDestination(isPresented: $showTranslateView) {
                SubtitleTranslate()
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
                        get: { sub.id == selectedSubtitleID },
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
        }
        .onAppear {
            print("Section1 appeared with \(embededSubtitles.count) subtitles")
        }
    }
}

struct Section2: View {
    @Binding var externalSubtitles: [SubtitleModel]
    @Binding var selectedSubtitleID: UUID?

    var onInsertOrUpdateSubtitle: ((SubtitleModel) -> Void)?

    @State var showFileImporter: Bool = false

    var body: some View {
        Section(header: Text("外部字幕")) {
            content()
        }
    }

    @ViewBuilder
    private func content() -> some View {
        ForEach(externalSubtitles.indices, id: \.self) { index in
            let sub = externalSubtitles[index]
            Toggle(
                isOn: Binding(
                    get: { sub.id == selectedSubtitleID },
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
                allowedContentTypes: [.vtt, .srt],
                allowsMultipleSelection: false
            ) {
                result in
                switch result {
                case let .success(file):
                    print("success \(file)")
                    if let path = file.first?.path {
                        let subtitle = SubtitleModel()
                        subtitle.filepath = path
                        subtitle.origin = "external"
                        onInsertOrUpdateSubtitle?(subtitle)
                    }
                case let .failure(error):
                    print("failed \(error)")
                }
            }
        }
    }
}

// 第 3 部分：AI 识别字幕
struct Section3: View {
    @Binding var transcribeSubtitles: [SubtitleModel]
    @Binding var selectedSubtitleID: UUID?
    @Binding var showTranscribeView: Bool

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

                VStack {
                    Button {
                        showTranscribeView = true
                    } label: {
                        Label("重新识别", systemImage: "arrow.clockwise.circle")
                    }
                }

            }
    }
}

// 第 4 部分：翻译字幕
struct Section4: View {
    @Binding var translateSubtitles: [SubtitleModel]
    @Binding var selectedSubtitleID: UUID?
    @Binding var showTranslateView: Bool

    var body: some View {
            Section(header: Text("翻译字幕")) {
                ForEach(translateSubtitles.indices, id: \.self) { index in
                    let sub = translateSubtitles[index]
                    Toggle(
                        isOn: Binding(
                            get: { sub.id == selectedSubtitleID },
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

                VStack {
                    Button {
                        showTranslateView = true
                    } label: {
                        Label("翻译更多", systemImage: "arrow.clockwise.circle")
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
            embededSubtitles: .constant(embededSubtitles),
            externalSubtitles: .constant(externalSubtitles),
            transcribeSubtitles: .constant(transcribeSubtitles),
            translateSubtitles: .constant(translateSubtitles),
            selectedSubtitleID: .constant(nil),
            onInsertOrUpdateSubtitle: { subtitle in
                print("insert or update subtitle: \(subtitle)")
            }
        )
    }
}
