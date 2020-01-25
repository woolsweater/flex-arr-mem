import flex_arr_mem_layout

typealias AbeRef = UnsafeMutablePointer<AbrahamLincoln>

extension AbrahamLincoln {

    static func alloc(flags: UInt32, payload: [Int8]) -> AbeRef {

        // Acquire space for base size of struct + number of bytes in payload
        let new: AbeRef =
            UnsafeMutableRawPointer.allocateWithFlexibleMember(ofSize: payload.count)
        // Set other fields
        new.pointee.flags = flags
        new.pointee.len = payload.count

        // Swift's calculation of the location of the payload field in the struct. Note
        // assertions below about its value.
        let offset = MemoryLayout<AbrahamLincoln>.offset(of: \AbrahamLincoln.payload)!

        // Acquire a pointer to the location of the payload field in
        // the memory allocated above.
        // There are a few ways to do this, partly depending on how the
        // struct is declared.
        #if ZERO_LENGTH && USE_OFFSET_ARITHMETIC
        // For a field declared with 0 length, un-type the pointer to the
        // allocation as a whole, and then do arithmetic (this is really
        // just the Swift implementation of the `AbrahamLincoln_payload` function)
        let payloadStart = UnsafeMutableRawPointer(new) + kAbrahamLincoln_payload_offset
        assert(offset == 0 && offset != kAbrahamLincoln_payload_offset)
        #elseif ZERO_LENGTH
        // For a field declared with 0 length, let C code calculate the
        // right address, since it knows the offset.
        let payloadStart = AbrahamLincoln_payload(new)
        let rawPayloadStart = UnsafeRawPointer(payloadStart)!
        let rawRoot = UnsafeRawPointer(new)!
        assert((rawPayloadStart - rawRoot) == kAbrahamLincoln_payload_offset)
        assert((rawPayloadStart - rawRoot) != offset)
        #else
        // For a field declared with length 1.
        // This will be wrong if the array field has length 0
        let payloadStart = UnsafeMutableRawPointer(&new.pointee.payload)
        let rawPayloadStart = UnsafeRawPointer(payloadStart)!
        let rawRoot = UnsafeRawPointer(new)!
        assert((rawPayloadStart - rawRoot) == offset)
        assert(offset == kAbrahamLincoln_payload_offset)
        #endif

        #if USE_MEMCPY
        // Copy bytes from array to allocated space
        _ = payload.withUnsafeBytes {
            my_memcpy(payloadStart, $0.baseAddress!, payload.count)
        }
        #else
        // Wrap the pointer to the payload as a buffer pointer
        let buf = UnsafeMutableBufferPointer<Int8>(start: payloadStart,
                                                   count: payload.count)
        // And let Swift copy the bytes
        _ = buf.initialize(from: payload)
        #endif

        #if DEBUG_INSPECT_ADDRS
        whats_this_addr(&new.pointee.payload)    // Base of struct when ZERO_LENGTH
        whats_this_addr(&new.pointee.payload)    // NULL when ZERO_LENGTH (but previous line is not)
        whats_this_addr(payloadStart)
        #endif

        return new
    }

    // Convenience, getting bytes of a string
    static func alloc(flags: UInt32, string: String) -> AbeRef {
        self.alloc(flags: flags, payload: Array(string.utf8CString))
    }

    // Cannot obtain a pointer to the payload field without
    // this being mutating
    mutating func string() -> String {
        let payload: UnsafeMutablePointer<Int8>

        #if ZERO_LENGTH && USE_OFFSET_ARITHMETIC
        // In C: ((void *)&self) + kAbrahamLincoln_payload_offset
        let raw = UnsafeMutableRawPointer(&self) + kAbrahamLincoln_payload_offset
        payload = raw.assumingMemoryBound(to: Int8.self)
        #elseif ZERO_LENGTH
        payload = AbrahamLincoln_payload(UnsafePointer(&self))
        #else
        // (int8_t *)&(self.payload)
        payload = UnsafeMutableRawPointer(&self.payload).assumingMemoryBound(to: Int8.self)
        #endif

        return String(cString: payload)
    }
}

extension AbeRef {

    var payloadAddress: UnsafeMutablePointer<Int8> {
        let pointer: UnsafeMutablePointer<Int8>

        #if ZERO_LENGTH && USE_OFFSET_ARITHMETIC
        let raw = UnsafeMutableRawPointer(self) + kAbrahamLincoln_payload_offset
        pointer = raw.assumingMemoryBound(to: Int8.self)
        #elseif ZERO_LENGTH
        pointer = AbrahamLincoln_payload(self)
        #else
        pointer = UnsafeMutablePointer<Int8>(&self.pointee.payload)
        #endif

        return pointer
    }

    func string() -> String {
        return String(cString: self.payloadAddress)
    }
}

extension UnsafeMutableRawPointer {
    static func allocateWithFlexibleMember<T>(ofSize trailingSize: Int) -> UnsafeMutablePointer<T> {
        let layout = MemoryLayout<T>.self
        // Grab the appropriate amount of memory
        let allocation = Self.allocate(byteCount: layout.size + trailingSize,
                                       alignment: layout.alignment)
        // And "cast" it to the desired type
        return allocation.bindMemory(to: T.self, capacity: 1)
    }
}

let abe = AbrahamLincoln.alloc(flags: 0xabadcafe,
                               string: "As our case is new, so we must think anew and act anew.")
// Print from Swift
print(abe.pointee.string())
// Print from C using address calculated in Swift
print_quote(abe.payloadAddress)
