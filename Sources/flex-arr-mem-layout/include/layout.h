#include <stdlib.h>

#pragma clang assume_nonnull begin

typedef struct {

    // Arbitrary data for inspection
    uint32_t flags;

    // Actual length of the payload
    size_t len;

    // Swift does not like non-zero size for the array.
    // If it's a true FAM with empty size, `int8_t payload[]`,
    // it is not visible at all in Swift.
    // If size 0, it comes across as `Void`, and Swift does not
    // know its offset: `MemoryLayout<AbrahamLincoln>.offset(of: \.payload)` is 0
    // and `&abeRef.pointee.payload` produces one of: garbage, the address of the
    // struct as a whole, or NULL, apparently depending on the context and
    // how many times it's been evaluated.
    #ifdef ZERO_LENGTH
    int8_t payload[0];
    #else
    int8_t payload[1];
    #endif

} AbrahamLincoln;

// Validate interop by passing the address of the payload field
// from Swift to be printf'd in C.
void print_quote(const int8_t * string);

// Get a reference to the payload field of the given struct ref.
// This allows addressing it in Swift.
int8_t * AbrahamLincoln_payload(const AbrahamLincoln * abe);

// Having the offset calculated in C also allows creating a pointer to
// the correct address in Swift (after taking a raw pointer to the base
// struct ref): `UnsafeMutableRawPointer(ref) + payload_offset`
static const size_t kAbrahamLincoln_payload_offset = __offsetof(AbrahamLincoln, payload);

// Pass a pointer from Swift and put a breakpoint inside here for
// easy debugger inspection (the debugger is sometimes cranky about
// recognizing Swift pointers as usable addresses)
void whats_this_addr(void * p);

// Wrapper around memcpy, allowing inspection of the addresses
// and/or memory in the debugger
void my_memcpy(void * dest, const void * src, size_t len);

#pragma clang assume_nonnull end
