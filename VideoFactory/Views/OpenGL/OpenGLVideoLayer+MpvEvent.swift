import Foundation

extension VideoLayer {

    struct TrackList {
        let id: String
        let type: String
        let title: String
        let lang: String
        let url: String
    }

    enum EventType {
        case startFile
        case fileLoaded
        case endFile
    }

    func readEventsThread() {
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

    func registerEventCallback(type: EventType,  handler: @escaping EventCallback) {
        eventCallbacks[type, default: []].append(handler)
    }

    func handleEvent(_ event: UnsafePointer<mpv_event>!) {
        switch event.pointee.event_id {

        case MPV_EVENT_SHUTDOWN:
            mpv_render_context_free(mpvRenderContext)
            mpvRenderContext = nil
            mpv_terminate_destroy(mpv)
            mpv = nil
            // NSApp.terminate(self)

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

    func evtStartFile () {
        print("mpv event: start file")
        eventCallbacks[.startFile]?.forEach { $0(nil) }
    }

    func evtFileLoaded () {
        print("mpv event: file loaded")
        eventCallbacks[.fileLoaded]?.forEach { $0(nil) }
    }

    func evtEndFile(reason: String) {
        print("mpv event: end file, reason: \(reason)")
        eventCallbacks[.endFile]?.forEach { $0(reason) }
    }

}
