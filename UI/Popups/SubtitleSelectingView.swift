import SwiftUI

public struct SubtitleSelectingView: View {
    @State private var appLanguage: String = "中文"
    @State private var showChatGPT: Bool = true
    @State private var autoCorrect: Bool = false
    @State private var autoLaunch: Bool = false
    @State private var openLinksInApp: Bool = true

    public var body: some View {
        NavigationView {
            List {
                // 第一部分：账户
                Section(header: Text("账户")) {
                    HStack {
                        Image(systemName: "envelope")
                        Text("电子邮件")
                        Spacer()
                        Text("nickelchen0101@gmail.com")
                          .foregroundColor(.gray)
                    }

                    HStack {
                        Image(systemName: "plus.circle")
                        Text("订阅")
                        Spacer()
                        Text("Free 套餐")
                          .foregroundColor(.gray)
                    }

                    NavigationLink(destination: Text("升级到 ChatGPT Plus")) {
                        HStack {
                            Image(systemName: "arrow.up.circle")
                            Text("升级至 ChatGPT Plus")
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

                // 第二部分：应用
                Section(header: Text("应用")) {
                    HStack {
                        Image(systemName: "globe")
                        Text("应用语言")
                        Spacer()
                        Text(appLanguage)
                          .foregroundColor(.gray)
                    }

                    Toggle(isOn: $showChatGPT) {
                        HStack {
                            Image(systemName: "eye")
                            Text("显示 ChatGPT")
                        }
                    }

                    Toggle(isOn: $autoCorrect) {
                        HStack {
                            Image(systemName: "pencil.circle")
                            Text("自动更正拼写")
                        }
                    }

                    Toggle(isOn: $autoLaunch) {
                        HStack {
                            Image(systemName: "arrow.right.circle")
                            Text("在登录时启动")
                        }
                    }

                    Toggle(isOn: $openLinksInApp) {
                        HStack {
                            Image(systemName: "link")
                            Text("在桌面 App 中打开 ChatGPT 链接")
                        }
                    }

                    NavigationLink(destination: Text("检查更新")) {
                        HStack {
                            Image(systemName: "arrow.clockwise.circle")
                            Text("检查更新...")
                        }
                    }
                }
            }
              .navigationTitle("设置")
        }
    }
}

struct SubtitleSelectingView_Previews: PreviewProvider {
    static var previews: some View {
        SubtitleSelectingView()
    }
}
