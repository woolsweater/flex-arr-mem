import flex_arr_mem_layout

typealias FooRef = UnsafeMutablePointer<Foo>

extension Foo {

    static func alloc(payload: [Int8]) -> FooRef {

        let new: FooRef =
            UnsafeMutableRawPointer.allocateWithFlexibleMember(ofSize: payload.count)
        new.pointee.len = payload.count

        let offset = MemoryLayout<Foo>.offset(of: \Foo.payload)!
        assert(offset == 0 && offset != kFoo_payload_offset)

        let payloadStart = UnsafeMutableRawPointer(&new.pointee.payload)
        whats_this_addr(payloadStart)    // Garbage, somewhere above `new`
        let payloadStart_C = UnsafeMutableRawPointer(Foo_payload(new))
        whats_this_addr(payloadStart_C)    // Correct address, `new + 8`

        _ = payload.withUnsafeBytes {
            my_memcpy(payloadStart, $0.baseAddress!, payload.count)    // Prints payloadStart as 0x7ff...
        }

        whats_this_addr(&new.pointee.payload)    // Garbage, _different_ from L17, somewhere below `new`
        whats_this_addr(&new.pointee.payload)    // NULL
        whats_this_addr(payloadStart)            // NULL

        return new
    }

    // Convenience, getting bytes of a string
    static func alloc(string: String) -> FooRef {
        self.alloc(payload: Array(string.utf8CString))
    }
}

extension UnsafeMutableRawPointer {
    static func allocateWithFlexibleMember<T>(ofSize trailingSize: Int) -> UnsafeMutablePointer<T> {
        let layout = MemoryLayout<T>.self
        let allocation = Self.allocate(byteCount: layout.size + trailingSize,
                                       alignment: layout.alignment)
        return allocation.bindMemory(to: T.self, capacity: 1)
    }
}

let foo = Foo.alloc(string: "As our case is new, so we must think anew and act anew.")
