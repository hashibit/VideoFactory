import Foundation

extension VideoLayer {

    func nodeToValue(_ node: inout mpv_node) -> Any? {
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

     func nodeToArray(_ node: inout mpv_node) -> [Any]? {
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

     func nodeToMap(_ node: inout mpv_node) -> [String: Any]? {
        switch node.format {
        case MPV_FORMAT_NODE_MAP:
            var result: [String: Any] = [:]
            if let listPtr = node.u.list {
                let list = listPtr.pointee
                let keysBuffer = UnsafeBufferPointer(start: list.keys, count: Int(list.num))
                let valsBuffer = UnsafeBufferPointer(start: list.values, count: Int(list.num))
                for i in 0 ..< keysBuffer.count {
                    guard let keyItem = keysBuffer[i] else {continue}
                    var valItem = valsBuffer[i]
                    let keyString = String(cString: keyItem, encoding: .utf8)!
                    if let val = nodeToValue(&valItem) {
                        result[keyString] = val
                    }
                }
                return result
            }
        default:
            break
        }
        return nil
    }

     func setNode(_ node: inout mpv_node, _ value: Any) {
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
        case let v as [Any]:
            break
        case let v as [String: Any]:
            break
        default:
            node.format = MPV_FORMAT_NONE
        }
    }

}