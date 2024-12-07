//
//  OpenGLVideoLayer.swift
//  VideoFactory
//
//  Created by Jie Chen on 2024/12/2.
//

import Cocoa
import OpenGL.GL
import OpenGL.GL3

func getProcAddress(_ ctx: UnsafeMutableRawPointer?,
                    _ name: UnsafePointer<Int8>?) -> UnsafeMutableRawPointer? {
    let symbol: CFString = CFStringCreateWithCString(kCFAllocatorDefault, name, kCFStringEncodingASCII)
    let indentifier = CFBundleGetBundleWithIdentifier("com.apple.opengl" as CFString)
    let addr = CFBundleGetFunctionPointerForName(indentifier, symbol)

    if addr == nil {
        print("Cannot get OpenGL function pointer!")
    }
    return addr
}

func updateCallback(_ ctx: UnsafeMutableRawPointer?) {
    let this = unsafeBitCast(ctx, to: VideoLayer.self)
    this.queue.async {
        this.display()
    }
}

class VideoLayer: CAOpenGLLayer {

    var mpv: OpaquePointer?
    var mpvRenderContext: OpaquePointer?
    var surfaceSize: NSSize?
    var link: CVDisplayLink?
    var queue: DispatchQueue = DispatchQueue(label: "io.mpv.callbackQueue")

    var currentFile: String?

    override init() {
        super.init()
        autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        backgroundColor = NSColor.black.cgColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func canDraw(inCGLContext ctx: CGLContextObj,
                          pixelFormat pf: CGLPixelFormatObj,
                          forLayerTime t: CFTimeInterval,
                          displayTime ts: UnsafePointer<CVTimeStamp>?) -> Bool {
        return true
    }

    override func draw(inCGLContext ctx: CGLContextObj,
                       pixelFormat pf: CGLPixelFormatObj,
                       forLayerTime t: CFTimeInterval,
                       displayTime ts: UnsafePointer<CVTimeStamp>?) {
        var i: GLint = 0
        var flip: CInt = 1
        var ditherDepth = 8
        glGetIntegerv(GLenum(GL_DRAW_FRAMEBUFFER_BINDING), &i)

        if mpvRenderContext != nil {
            surfaceSize = self.bounds.size

            var data = mpv_opengl_fbo(fbo: Int32(i),
                                      w: Int32(surfaceSize!.width),
                                      h: Int32(surfaceSize!.height),
                                      internal_format: 0)
            var params: [mpv_render_param] = [
                mpv_render_param(type: MPV_RENDER_PARAM_OPENGL_FBO, data: &data),
                mpv_render_param(type: MPV_RENDER_PARAM_FLIP_Y, data: &flip),
                mpv_render_param(type: MPV_RENDER_PARAM_DEPTH, data: &ditherDepth),
                mpv_render_param()
            ]
            mpv_render_context_render(mpvRenderContext, &params);
        } else {
            glClearColor(0, 0, 0, 1)
            glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT ))
        }

        CGLFlushDrawable(ctx)
    }

    override func copyCGLPixelFormat(forDisplayMask mask: UInt32) -> CGLPixelFormatObj {
        let attrs: [CGLPixelFormatAttribute] = [
            kCGLPFAOpenGLProfile, CGLPixelFormatAttribute(kCGLOGLPVersion_3_2_Core.rawValue),
            kCGLPFADoubleBuffer,
            kCGLPFAAllowOfflineRenderers,
            kCGLPFABackingStore,
            kCGLPFAAccelerated,
            kCGLPFASupportsAutomaticGraphicsSwitching,
            _CGLPixelFormatAttribute(rawValue: 0)
        ]

        var npix: GLint = 0
        var pix: CGLPixelFormatObj?
        CGLChoosePixelFormat(attrs, &pix, &npix)

        return pix!
    }

    override func copyCGLContext(forPixelFormat pf: CGLPixelFormatObj) -> CGLContextObj {
        let ctx = super.copyCGLContext(forPixelFormat:pf)

        var i: GLint = 1
        CGLSetParameter(ctx, kCGLCPSwapInterval, &i)
        CGLEnable(ctx, kCGLCEMPEngine)
        CGLSetCurrentContext(ctx)

        initMPV()
        initDisplayLink()

        return ctx
    }

    override func display() {
        super.display()
        CATransaction.flush()
    }

    func initMPV() {
        mpv = mpv_create()
        if mpv == nil {
            print("failed creating context")
            exit(1)
        }

        checkError(mpv_set_option_string(mpv, "terminal", "yes"))
        checkError(mpv_set_option_string(mpv, "input-media-keys", "yes"))
        checkError(mpv_set_option_string(mpv, "input-ipc-server", "/tmp/mpvsocket"))
        checkError(mpv_set_option_string(mpv, "input-default-bindings", "yes"))
        checkError(mpv_set_option_string(mpv, "config", "yes"))
        checkError(mpv_set_option_string(mpv, "msg-level", "all=v"))
        checkError(mpv_set_option_string(mpv, "config-dir", NSHomeDirectory()+"/.config/mpv"))
        checkError(mpv_set_option_string(mpv, "vo", "opengl-cb"))
        //        print("set option display-fps")
        //        checkError(mpv_set_option_string(mpv, "display-fps", "60"))
        print("initialize mpv")
        checkError(mpv_initialize(mpv))

        let api = UnsafeMutableRawPointer(mutating: (MPV_RENDER_API_TYPE_OPENGL as NSString).utf8String)
        var pAddress = mpv_opengl_init_params(get_proc_address: getProcAddress,
                                              get_proc_address_ctx: nil)

        var params: [mpv_render_param] = [
            mpv_render_param(type: MPV_RENDER_PARAM_API_TYPE, data: api),
            mpv_render_param(type: MPV_RENDER_PARAM_OPENGL_INIT_PARAMS, data: &pAddress),
            mpv_render_param()
        ]

        if (mpv_render_context_create(&mpvRenderContext, mpv, &params) < 0)
        {
            print("Render context init has failed.")
            exit(1)
        }

        mpv_render_context_set_update_callback(mpvRenderContext,
                                               updateCallback,
                                               UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))

        mpv_set_wakeup_callback(mpv, { (ctx) in
            let this = unsafeBitCast(ctx, to: VideoLayer.self)
            this.readEventsThread()
        }, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))

        if let filepath = self.currentFile {
            loadFile(filepath)
            mpvGetPropertyAsync(property: MpvProperty.volume.rawValue, asyncID: AsyncID.volume)
        }
    }

    func uninitMPV() {
        let cmd = ["quit", nil]
        mpvCommand(cmd: cmd, blocking: true)
    }

    func tryLoadFile(_ filepath: String) {
        self.currentFile = filepath
        if mpv != nil {
            loadFile(filepath)
        }
    }

    private func loadFile(_ filepath: String) {
        let cmd = ["loadfile", filepath, nil]
        mpvCommand(cmd: cmd)
    }


    private let displayLinkCallback: CVDisplayLinkOutputCallback = { (displayLink, now, outputTime, flagsIn, flagsOut, displayLinkContext) -> CVReturn in
        let layer: VideoLayer = unsafeBitCast(displayLinkContext, to: VideoLayer.self)
        if layer.mpvRenderContext != nil {
            mpv_render_context_report_swap(layer.mpvRenderContext)
        }
        return kCVReturnSuccess
    }

    private func initDisplayLink() {
        let displayId = UInt32(NSScreen.main?.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as! Int)

        CVDisplayLinkCreateWithCGDisplay(displayId, &link)
        CVDisplayLinkSetOutputCallback(link!,
                                       displayLinkCallback,
                                       UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
        CVDisplayLinkStart(link!)
    }

    private func uninitDisplaylink() {
        if CVDisplayLinkIsRunning(link!) {
            CVDisplayLinkStop(link!)
        }
    }

    private func checkError(_ status: CInt) {
        if (status < 0) {
            if let cstr = mpv_error_string(status) {
                print("mpv API error:", String(cString: cstr))
            } else {
                print("mpv API error: nil")
            }
            exit(1)
        }
    }

}


extension VideoLayer {

    func mpvCommand(cmd: [String?], blocking: Bool = false) {
        // blocking
        if blocking {
            var args = cmd.map{ $0.flatMap{ UnsafePointer<Int8>(strdup($0)) } }
            defer { args.compactMap { $0 }.forEach { free(UnsafeMutablePointer(mutating: $0)) } }
            self.checkError(mpv_command(self.mpv, &args))
            return
        }
        // non-blocking
        queue.async {
            var args = cmd.map{ $0.flatMap{ UnsafePointer<Int8>(strdup($0)) } }
            defer { args.compactMap { $0 }.forEach { free(UnsafeMutablePointer(mutating: $0)) }}
            self.checkError(mpv_command(self.mpv, &args))
        }
    }

    func mpvCommandAsync(cmd: [String?], asyncID: AsyncID, blocking: Bool = false) {
        if blocking {
            var args = cmd.map{ $0.flatMap{ UnsafePointer<Int8>(strdup($0)) } }
            defer { args.compactMap { $0 }.forEach { free(UnsafeMutablePointer(mutating: $0)) } }
            self.checkError(mpv_command_async(self.mpv, asyncID.rawValue, &args))
            return
        }
        queue.async {
            var args = cmd.map{ $0.flatMap{ UnsafePointer<Int8>(strdup($0)) } }
            defer { args.compactMap { $0 }.forEach { free(UnsafeMutablePointer(mutating: $0)) } }
            self.checkError(mpv_command_async(self.mpv, asyncID.rawValue, &args))
        }
    }

    func mpvSetProperty<T>(property: String, value: T) {
        var node = mpv_node()
        defer {
            mpv_free_node_contents(&node)
        }

        setNode(&node, value)
        property.withCString { propertyPtr in
            checkError(mpv_set_property(self.mpv, propertyPtr, MPV_FORMAT_NODE, &node))
        }
    }

    func mpvSetPropertyAsync<T>(property: String, value: T, id: UInt64) {
        var node = mpv_node()
        defer {
            mpv_free_node_contents(&node)
        }

        setNode(&node, value)
        property.withCString { propertyPtr in
            checkError(mpv_set_property_async(self.mpv, id, propertyPtr, MPV_FORMAT_NODE, &node))
        }
    }

    func mpvGetProperty<T>(property: String) -> T? {
        var node = mpv_node()
        defer {
            mpv_free_node_contents(&node)
        }

        property.withCString { propertyPtr in
            checkError(mpv_get_property(self.mpv, propertyPtr, MPV_FORMAT_NODE, &node))
        }

        return nodeToValue(&node) as? T
    }

    func mpvGetPropertyAsync(property: String, asyncID: AsyncID) {
        property.withCString { propertyPtr in
            checkError(mpv_get_property_async(self.mpv, asyncID.rawValue, propertyPtr, MPV_FORMAT_NODE))
        }
    }

    private func nodeToValue(_ node: inout mpv_node) -> Any? {
        switch node.format {
        case MPV_FORMAT_STRING:
            return String(cString: node.u.string, encoding: .utf8)
        case MPV_FORMAT_INT64:
            return node.u.int64
        case MPV_FORMAT_DOUBLE:
            return node.u.double_
        case MPV_FORMAT_NODE_ARRAY:
            return nodeToArray(&node)
        case MPV_FORMAT_NODE_MAP:
            return nodeToMap(&node)
        case MPV_FORMAT_NONE:
            print("mpv node format is none, failed to get property")
        default:
            break
        }
        return nil
    }

    private func nodeToArray(_ node: inout mpv_node) -> [Any]? {
        switch node.format {
        case MPV_FORMAT_NODE_ARRAY:
            var result: [Any] = []
            if let listPtr = node.u.list {
                let list = listPtr.pointee
                let buffer = UnsafeBufferPointer(start: list.values, count: Int(list.num))
                for var nodeItem in buffer {
                    if let value = nodeToValue(&nodeItem)  {
                        result.append(value)
                    }
                }
                return result
            }
        default:
            break
        }
        return nil
    }

    private func nodeToMap(_ node: inout mpv_node) -> [String: Any]? {
        switch node.format {
        case MPV_FORMAT_NODE_MAP:
            var result: [String: Any] = [:]
            if let listPtr = node.u.list {
                let list = listPtr.pointee
                let keysBuffer = UnsafeBufferPointer(start: list.keys, count: Int(list.num))
                let valsBuffer = UnsafeBufferPointer(start: list.values, count: Int(list.num))
                for i in 0 ..< keysBuffer.count {
                    if let keyItem = keysBuffer[i] {
                        let keyString = String(cString: keyItem, encoding: .utf8)!
                        var nodeItem = valsBuffer[i]
                        if let val = nodeToValue(&nodeItem) {
                            result[keyString] = val
                        }
                    }
                }
                return result
            }
        default:
            break
        }
        return nil
    }

    private func setNode(_ node: inout mpv_node, _ value: Any) {
        switch value {
        case let v as Double:
            node.format = MPV_FORMAT_DOUBLE
            node.u.double_ = v
        case let v as Int64:
            node.format = MPV_FORMAT_INT64
            node.u.int64 = v
        case let v as Bool:
            node.format = MPV_FORMAT_FLAG
            node.u.flag = v ? 1 : 0
        case let v as String:
            node.format = MPV_FORMAT_STRING
            v.withCString { strPtr in
                node.u.string = strdup(strPtr)
            }
        default:
            node.format = MPV_FORMAT_NONE
        }
    }


}

extension VideoLayer {

    private func readEventsThread() {
        Task {
            while self.mpv != nil {
                let event = mpv_wait_event(self.mpv, 0)
                if event!.pointee.event_id == MPV_EVENT_NONE {
                    break
                }
                self.handleEvent(event)
            }
        }
    }

    private func handleEvent(_ event: UnsafePointer<mpv_event>!) {
        switch event.pointee.event_id {

        case MPV_EVENT_SHUTDOWN:
            mpv_render_context_free(mpvRenderContext)
            mpvRenderContext = nil
            mpv_terminate_destroy(mpv)
            mpv = nil
            NSApp.terminate(self)

        case MPV_EVENT_LOG_MESSAGE:
            let logmsg = UnsafeMutablePointer<mpv_event_log_message>(OpaquePointer(event.pointee.data))
            print("log:",
                  String(cString: (logmsg!.pointee.prefix)!),
                  String(cString: (logmsg!.pointee.level)!),
                  String(cString: (logmsg!.pointee.text)!))

        case MPV_EVENT_START_FILE:
            evtStartFile()

        case MPV_EVENT_FILE_LOADED:
            evtFileLoaded()

        case MPV_EVENT_END_FILE:
            let prop = UnsafeMutablePointer<mpv_event_end_file>(OpaquePointer(event.pointee.data))
            let reason = prop!.pointee.reason
            if (reason == MPV_END_FILE_REASON_EOF) {
                evtEndFile(reason: "eof");
            } else if (reason == MPV_END_FILE_REASON_ERROR) {
                evtEndFile(reason: "error");
            }

        // case MPV_EVENT_VIDEO_RECONFIG: {
        //                                    Q_EMIT videoReconfig();
        //                                    break;
        //                                }

        case MPV_EVENT_GET_PROPERTY_REPLY:
            let asyncID: UInt64 = event.pointee.reply_userdata
            let prop = UnsafeMutablePointer<mpv_event_property>(OpaquePointer(event.pointee.data))
            let data = UnsafeMutablePointer<mpv_node>(OpaquePointer(prop?.pointee.data))
            switch AsyncID(rawValue: asyncID) {
            case .volume:
                let value = data!.pointee.u.double_
                print("get prop reply: volume value is: \(value)")
            default:
                print("get prop reply: unkown asyncID: \(asyncID)")
            }

        case MPV_EVENT_SET_PROPERTY_REPLY:
            let asyncID: UInt64 = event.pointee.reply_userdata
            switch AsyncID(rawValue: asyncID) {
            case .volume:
                print("set prop reply: volume is set.")
            case .pause:
                print("set prop reply: pause/unpause is set.")
            default:
                print("set prop reply: unkown asyncID: \(asyncID)")
            }

        case MPV_EVENT_COMMAND_REPLY:
            let asyncID: UInt64 = event.pointee.reply_userdata
            let prop = UnsafeMutablePointer<mpv_node>(OpaquePointer(event.pointee.data))
            switch AsyncID(rawValue: asyncID) {
            case .addSmartSubtitle:
                print("command reply: add smart subtitle")
                break
            case .addNormalSubtitle:
                print("command reply: add normal subtitle")
                break
            default:
                print("unkown command \(asyncID)")
            }

        // case MPV_EVENT_PROPERTY_CHANGE: {
        //                                     mpv_event_property* prop = static_cast<mpv_event_property*>(event->data);
        //                                     QVariant data;
        //                                     switch (prop->format) {
        //                                     case MPV_FORMAT_DOUBLE:
        //                                         data = *reinterpret_cast<double*>(prop->data);
        //                                         break;
        //                                     case MPV_FORMAT_STRING:
        //                                         data = QString::fromStdString(*reinterpret_cast<char**>(prop->data));
        //                                         break;
        //                                     case MPV_FORMAT_INT64:
        //                                         data = qlonglong(*reinterpret_cast<int64_t*>(prop->data));
        //                                         break;
        //                                     case MPV_FORMAT_FLAG:
        //                                         data = *reinterpret_cast<bool*>(prop->data);
        //                                         break;
        //                                     case MPV_FORMAT_NODE:
        //                                         data = d_ptr->nodeToVariant(reinterpret_cast<mpv_node*>(prop->data));
        //                                         break;
        //                                     case MPV_FORMAT_NONE:
        //                                     case MPV_FORMAT_OSD_STRING:
        //                                     case MPV_FORMAT_NODE_ARRAY:
        //                                     case MPV_FORMAT_NODE_MAP:
        //                                     case MPV_FORMAT_BYTE_ARRAY:
        //                                         break;
        //                                     }
        //                                     Q_EMIT propertyChanged(QString::fromStdString(prop->name), data);
        //                                     break;
        //                                 }
        // case MPV_EVENT_LOG_MESSAGE: {
        //                                 mpv_event_log_message* msg = static_cast<mpv_event_log_message*>(event->data);
        //                                 fprintf(stderr, "mpv message: %s", msg->text);
        //                                 break;
        //                             }
        // case MPV_EVENT_CLIENT_MESSAGE:
        // case MPV_EVENT_NONE:
        // case MPV_EVENT_SHUTDOWN:
        // case MPV_EVENT_AUDIO_RECONFIG:
        // case MPV_EVENT_SEEK:
        // case MPV_EVENT_PLAYBACK_RESTART:
        // case MPV_EVENT_QUEUE_OVERFLOW:
        // case MPV_EVENT_HOOK:
        //     #if MPV_ENABLE_DEPRECATED
        // case MPV_EVENT_IDLE:
        // case MPV_EVENT_TICK:
        //     #endif
        //     break;

        default:
            print("event:", String(cString: mpv_event_name(event.pointee.event_id)))
        }
    }

    private func evtStartFile () {
        print("mpv event: start file")
    }

    private func evtFileLoaded () {
        print("mpv event: file loaded")
    }

    private func evtEndFile(reason: String) {
        print("mpv event: end file, reason: \(reason)")
    }

}
