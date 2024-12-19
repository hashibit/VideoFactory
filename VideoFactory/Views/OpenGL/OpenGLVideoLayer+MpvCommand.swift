import Foundation

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

}