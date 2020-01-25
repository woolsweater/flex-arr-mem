#include <stdlib.h>

#pragma clang assume_nonnull begin

typedef struct {
    size_t len;
    int8_t payload[0];
} Foo;

// Get a reference to the payload field of the given struct ref.
// This allows addressing it in Swift.
int8_t * Foo_payload(const Foo * abe);

// Having the offset calculated in C also allows creating a pointer to
// the correct address in Swift (after taking a raw pointer to the base
// struct ref): `UnsafeMutableRawPointer(ref) + payload_offset`
static const size_t kFoo_payload_offset = __offsetof(Foo, payload);

// Pass a pointer from Swift and put a breakpoint inside here for
// easy debugger inspection (the debugger is sometimes cranky about
// recognizing Swift pointers as usable addresses)
void whats_this_addr(void * p);

// Wrapper around memcpy, allowing inspection of the addresses
// and/or memory in the debugger
void my_memcpy(void * dest, const void * src, size_t len);

#pragma clang assume_nonnull end
