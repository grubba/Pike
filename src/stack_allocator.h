#include "global.h"

struct stack_allocator {
    struct chunk * cur;
    size_t initial;
};

struct chunk {
    struct chunk * prev;
    void * data, * top;
    size_t size;
};

void stack_alloc_enlarge(struct stack_allocator * a, size_t size);
void stack_alloc_destroy(struct stack_allocator * a);
size_t stack_alloc_count(struct stack_allocator * a);

static INLINE void stack_alloc_init(struct stack_allocator * a, size_t initial) {
    a->cur = NULL;
    a->initial = initial;
}

static INLINE size_t left(struct chunk * c) {
    return (size_t)(((char*)c->data + c->size) - (char*)c->top);
}

static INLINE void sa_alloc_enlarge(struct stack_allocator * a, size_t size) {
    struct chunk * c = a->cur;

    if (!c || left(c) < size)
        stack_alloc_enlarge(a, size);
}

static INLINE void * sa_alloc_fast(struct stack_allocator * a, size_t size) {
    struct chunk * c = a->cur;
    void * ret = c->top;
    c->top = (char*)c->top + size;
    return ret;
}

static INLINE void * sa_alloc(struct stack_allocator * a, size_t size) {
    sa_alloc_enlarge(a, size);
    return sa_alloc_fast(a, size);
}
