//
//  SubtitleTranslate.swift
//  UI
//
//  Created by Jie Chen on 2024/12/13.
//

import SwiftUI

struct SubtitleTranslate: View {
    typealias Callback = () -> Void

    var width: Int = 500
    var height: Int = 500

    @Environment(\.dismiss) var dismiss

    var onConfirm: Callback?
    var onCancel: Callback?

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("翻译字幕内容")
                Spacer()
                HStack {
                    Button("取消") {
                        print("取消")
                        if let onCancel { onCancel() }
                        dismiss()
                    }
                    Button("开始") {
                        print("开始")
                        if let onConfirm { onConfirm() }
                        dismiss()
                    }
                }
            }
            .padding(10)
            .navigationBarBackButtonHidden()
            .navigationTitle("翻译字幕")
            .frame(width: CGFloat(width), height: CGFloat(height))
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
#Preview {
    SubtitleTranslate(width: 500,
                      height: 500)
}
