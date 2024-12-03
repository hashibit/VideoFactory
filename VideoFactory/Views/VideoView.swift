//
//  VideoView.swift
//  VideoFactory
//
//  Created by Jie Chen on 2024/12/2.
//

import SwiftUI

struct VideoView<Content: View>: View {
    var content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    VideoView() {
        Text("hello world")
    }
}
