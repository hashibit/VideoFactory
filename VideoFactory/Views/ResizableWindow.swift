//
//  PlayerView.swift
//  VideoFactory
//
//  Created by Jie Chen on 2024/12/2.
//

import Foundation
import SwiftUI
import AppKit

struct ResizableWindow: NSViewControllerRepresentable {
    typealias NSViewControllerType = NSViewController

    @Binding var isResizing: Bool
    let content: AnyView

    init(isResizing: Binding<Bool>, @ViewBuilder content: @escaping () -> some View) {
        print("init")
        _isResizing = isResizing
        self.content = AnyView(content())
    }

    func makeNSViewController(context: Context) -> NSViewControllerType {
        print("makeNSViewController")
        let viewController = NSViewController()
        let hostingView = NSHostingView(rootView: content)
        hostingView.autoresizingMask = [.width, .height]
        viewController.view = hostingView
        return viewController
    }

    func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context) {
        DispatchQueue.main.async {
            print("updateNSViewController")
            guard let window = nsViewController.view.window else {
                print("window is nil");
                return
            }
            print("window delegate: \(String(describing: window.delegate))")
            window.delegate = context.coordinator
        }
    }

    func makeCoordinator() -> Coordinator {
        print("makeNSViewController called")
        return Coordinator(isResizing: $isResizing)
    }

    class Coordinator: NSObject, NSWindowDelegate {
        @Binding var isResizing: Bool
        init(isResizing: Binding<Bool>) {
            print("init coordinator")
            _isResizing = isResizing
        }

        func windowWillStartLiveResize(_ notification: Notification) {
            print("windowWillStartLiveResize")
            isResizing = true;
        }
        func windowDidEndLiveResize(_ notification: Notification) {
            print("windowDidEndLiveResize")
            isResizing = false
        }
    }

}
