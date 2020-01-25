# flex-arr-mem

Figuring out how structs with flexible array members work in Swift.

Short answer: they don't. If the field is declared with no length, it's not visible at all.

If declared with 0 length, behavior is very strange. The offset that Swift's `MemoryLayout` provides is 0, and trying to get a pointer to the field in the allocation produces inconsistent results. It is sometimes the base of the allocation, sometimes NULL. Or, as the argument to a C function with multiple arguments, it is a value very high in the address space (on the stack?).

If the field is declared with length 1, everything works more or less as desired. The type in Swift is a 1-tuple, but you can fairly easily get a pointer to read and to write to the allocation.
