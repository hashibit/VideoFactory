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
    let symbol: CFString = CFStringCreateWithCString(
        kCFAllocatorDefault, name, kCFStringEncodingASCII)
    let indentifier = CFBundleGetBundleWithIdentifier("com.apple.opengl" as CFString)
    let addr = CFBundleGetFunctionPointerForName(indentifier, symbol)

    if addr == nil {
        print("Cannot get OpenGL function pointer!")
    }
    return addr
}

func updateCallback(_ ctx: UnsafeMutableRawPointer?) {
    let videoLayer = unsafeBitCast(ctx, to: VideoLayer.self)
    videoLayer.queue.async {
        if !videoLayer.isAsynchronous {
            videoLayer.display()
        }
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

        print("set option terminal")
        checkError(mpv_set_option_string(mpv, "terminal", "yes"))
        print("set option input-media-keys")
        checkError(mpv_set_option_string(mpv, "input-media-keys", "yes"))
        print("set option input-ipc-server")
        checkError(mpv_set_option_string(mpv, "input-ipc-server", "/tmp/mpvsocket"))
        print("set option input-default-bindings")
        checkError(mpv_set_option_string(mpv, "input-default-bindings", "yes"))
        print("set option config")
        checkError(mpv_set_option_string(mpv, "config", "yes"))
        print("set option msg-level")
        checkError(mpv_set_option_string(mpv, "msg-level", "all=v"))
        print("set option config-dir")
        checkError(mpv_set_option_string(mpv, "config-dir", NSHomeDirectory()+"/.config/mpv"))
        print("set option vo")
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
            let mpvController = unsafeBitCast(ctx, to: VideoLayer.self)
            mpvController.readEvents()
        }, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))

        if let filepath = self.currentFile {
            loadFile(filepath)
        }
    }

    func uninitMPV() {
        let cmd = ["quit", nil]
        mpvCommand(cmd: cmd, sync: true)
    }

    func tryLoadFile(_ filepath: String) {
        self.currentFile = filepath
        // initialized
        if mpv != nil {
            loadFile(filepath)
        }
    }

    private func loadFile(_ filepath: String) {
        let cmd = ["loadfile", filepath, nil]
        mpvCommand(cmd: cmd)
    }

    func mpvCommand(cmd: [String?], sync: Bool = false) {
        // sync
        if sync {
            var args = cmd.map{ $0.flatMap{ UnsafePointer<Int8>(strdup($0)) } }
            defer { args.compactMap { $0 }.forEach { free(UnsafeMutablePointer(mutating: $0)) } }
            self.checkError(mpv_command(self.mpv, &args))
            return
        }
        // async
        queue.async {
            var args = cmd.map{ $0.flatMap{ UnsafePointer<Int8>(strdup($0)) } }
            defer { args.compactMap { $0 }.forEach { free(UnsafeMutablePointer(mutating: $0)) }}
            self.checkError(mpv_command(self.mpv, &args))
        }
    }

    func mpvSetPropertyAsync<T>(property: String, value: T, id: UInt64) {
        var node = mpv_node()
        node.format = MPV_FORMAT_NONE
        defer {
            if node.format == MPV_FORMAT_STRING {
                free(UnsafeMutablePointer(mutating: node.u.string))
            }
        }

        switch value {
        case let value as String:
            node.format = MPV_FORMAT_STRING
            value.withCString { valuePtr in
                node.u.string = strdup(value)
            }
        case let value as Bool:
            node.format = MPV_FORMAT_FLAG
            node.u.flag = value ? 1 : 0
            break
        case let value as Int64:
            node.format = MPV_FORMAT_INT64
            node.u.int64 = value
            break
        case let value as Double:
            node.format = MPV_FORMAT_DOUBLE
            node.u.double_ = value
            break
        default:
            break
        }

        property.withCString { propertyPtr in
            mpv_set_property_async(self.mpv, id, propertyPtr, MPV_FORMAT_NODE, &node)
        }

    }

    private func readEvents() {
        queue.async {
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
            print("log:", String(cString: (logmsg!.pointee.prefix)!),
                  String(cString: (logmsg!.pointee.level)!),
                  String(cString: (logmsg!.pointee.text)!))
        default:
            print("event:", String(cString: mpv_event_name(event.pointee.event_id)))
        }
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
        CVDisplayLinkSetOutputCallback(link!, displayLinkCallback,
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
