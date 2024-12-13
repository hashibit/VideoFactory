//
//  SubtitleTranscribe.swift
//  UI
//
//  Created by Jie Chen on 2024/12/13.
//

import SwiftUI

struct SubtitleTranscribe: View {
    typealias Callback = () -> Void
    
    var width: Int = 500
    var height: Int = 500
    
    var onConfirm: Callback?
    var onCancel: Callback?

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("语音识别")
                Spacer()
                HStack {
                    Button("取消") {
                        print("取消")
                        if let onConfirm { onConfirm() }
                    }
                    Button("开始") {
                        print("开始")
                        if let onCancel { onCancel() }
                    }
                }
            }
            .padding(10)
            .navigationBarBackButtonHidden()
            .navigationTitle("语音识别")
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
    SubtitleTranscribe(width: 500,
                      height: 500)
}
