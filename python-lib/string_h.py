"""
NAME
    string_h - A string librabry for Python, as the standard one is lacking.

SYNOPSIS
    void *memset(void *s, int c, size_t n)
    size_t strlen(const char *s)

DESCRIPTION
    A string library for Python. Strings are defined to be a sequence
    of characters terminated by a null byte (\\0), as described by
    ISO/IEC 9899:TC3 section 7.1.1.

NOTES
    These functions, unless stated to the contrary, do not check for
    length. If the string is not null-terminated, or the size
    parameter exceeds the capacity, the behaviour is undefined.

SEE ALSO
    Full documentation <https://en.cppreference.com/w/c/header/string.html>

    memset(3), strlen(3)
"""

from math import ceil
from random import randrange
from gc import get_objects

PAGESIZE = 4096 # 4 KB

def memset(dest, ch, count):
    """
    void *memset(void *dest, int ch, size_t count)

    Fill dest up to count elements with ch and return dest. If count
    exceeds the capacity of dest, assumes the next page does not have
    write permissions.
    """
    for i in range(min(count, len(dest))):
        dest[i] = ch
    if count > len(dest):
        garbage_size = count - len(dest)
        garbage = [ch] * garbage_size
        _write_garbage(dest, garbage)

        if count >= _page_end(len(dest)):
            raise SegmentationFault()
    return dest

def strlen(s):
    """
    size_t strlen(const char *s)

    Return the length of s. If no null byte is found, assumes the
    next page does not have read permissions.
    """
    index = s.find('\0')
    if index >= 0:
        return index
    until = _page_end(len(s))
    for i in range(len(s), until):
        garbage = randrange(256)
        if garbage == 0:
            return i
    raise SegmentationFault()

def _page_end(addr):
    return ceil(addr / PAGESIZE) * PAGESIZE

def _write_garbage(dest, data):
    dest += data

    objs = [o for o in get_objects() if isinstance(o, (list, dict, bytearray))]
    while len(data) > 0:
        i = randrange(len(objs))
        obj = objs[i]
        objs.pop(i)
        written = _overwrite_obj(obj, data)
        data = data[written:]

def _overwrite_obj(obj, data):
    if isinstance(obj, (list, bytearray)):
        n = min(len(obj), len(data))
        for i in range(n):
            obj[i] = data[i]
        return n
    elif isinstance(obj, dict):
        keys = list(obj.keys())
        n = min(len(keys), len(data) // 2)
        for i in range(n):
            old_key = keys[i]
            new_key = str(data[2*i])
            val = data[2*i + 1]
            del obj[old_key]
            obj[new_key] = val
        if len(data) % 2 != 0:
            new_key = str(data[-1])
            if n == len(keys):
                obj[new_key] = _garbage_whatever()
            else:
                old_key = keys[n]
                val = obj[old_key]
                obj[new_key] = val
                del obj[old_key]
        return len(data)


def _garbage_whatever():
    typ = randrange(2)
    if typ == 0:
        return _garbage_int()
    elif typ == 1:
        return _garbage_key()

def _garbage_key():
    out = ""
    for i in range(8):
        out += _garbage_char()
    return out

def _garbage_char():
    return chr(randrange(256))

def _garbage_int():
    return randrange(1 << 64)

class SegmentationFault(Exception):
    def __init__(self, message="(core dumped)"):
        super().__init__(message)
