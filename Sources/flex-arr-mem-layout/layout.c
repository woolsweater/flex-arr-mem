#include "layout.h"
#include <stdio.h>
#include <string.h>

void print_quote(const int8_t * string)
{
    printf("%s\n", string);
}

int8_t * Foo_payload(const Foo * abe)
{
    const void * root = abe;
    return (int8_t *)(root + __offsetof(Foo, payload));
}

void whats_this_addr(void * p)
{
    printf("Addr: %p\n", p);
}

void my_memcpy(void * dest, const void * src, size_t len)
{
    printf("Dest: %p\n", dest);
}
