# Motivation

The Python standard string library is lacking.
It does not even have `memset`, `strlen`, etc. Thus, I have decided to write my
own.

# Possible Corruptions

Running this program multiple times gave the following errors.

```py
from string_h import memset

for i in range(1_000_000):
    dest = [1]
    memset(dest, 0, 1024)
    print(i)
```

| When? | Error | Comment |
| ----- | ----- | ------- |
| 39 | Segfault | (core dumped) |
| 7 | `NameError: name '_garbage_whatever' is not defined`, then segfault |
| 99 | Segfault | (core dumped) |
| 3 | Lost stdout \[1\] | I have no mouth and I must scream |
| 57 | Segfault | (core dumped) |
| 27 | Lost `_index`, `AttributeError: module has no attribute 'acquire_lock'` \[2\] | 
| 4 | Lost `_index`, `longobject.c:495: bad argument to internal function` \[3\] | 
| 135 | Segfault | (core dumped) |
| 28 | Segfault | (core dumped) |

Now continuing, with segfaults omitted, and the following addition:

```py
    try:
        memset(dest, 0, 1024)
    except Exception as e:
        print(f"Got error: {e}")
```

| When? | Error | Comment |
| ----- | ----- | ------- |
| 38 | Lost `str` and `print` while handling `NameError` \[4\] |
| 15 | Segfault while printing stack trace |
| 2  | Lost stdout \[1\] | I have no mouth and I must cream |
| 29 | Lost stdout \[1\] | I have no mouth and I must cream |
| 114 | Lost `str` and `print` \[4\], but during handling lost `sys` |
| 42 | Lost `i` and `ref` \[5\] (did you mean `id`?) | Lmao it deleted a local variable |
| 22 | Lost `i`, `FileFinder.path`, and `sys` \[6\] |
| 13 | Lost `i`, tried to iterate `int`
| 9 | Lost stdout \[1\] | I have no mouth and I must cream |
| 14 | Lost stdout \[1\] | I have no mouth and I must cream |


1.
```
sys.excepthook is missing
object address  : 0x7be4924449a0
object refcount : 2
object type     : 0x570c90524240
object type name: RuntimeError
object repr     : RuntimeError('lost sys.stdout')
lost sys.stderr
```

2.
```
Traceback (most recent call last):
  File "/home/honzik/dev/random-shit/python-lib/test.py", line 5, in <module>
    memset(dest, 0, 1024)
  File "/home/honzik/dev/random-shit/python-lib/string_h.py", line 48, in memset
    _write_garbage(dest, garbage)
  .
  .
  .
    typ = randrange(2)
  File "/usr/lib/python3.10/random.py", line 303, in randrange
    istart = _index(start)
NameError: name '_index' is not defined
Error in sys.excepthook:
Traceback (most recent call last):
  File "/usr/lib/python3/dist-packages/apport_python_hook.py", line 55, in apport_excepthook
    import apt_pkg
  File "<frozen importlib._bootstrap>", line 1024, in _find_and_load
  File "<frozen importlib._bootstrap>", line 170, in __enter__
  File "<frozen importlib._bootstrap>", line 185, in _get_module_lock
AttributeError: module has no attribute 'acquire_lock'
Segmentation fault (core dumped)
```

3.
```
Traceback (most recent call last):
  File "/home/honzik/dev/random-shit/python-lib/test.py", line 5, in <module>
    memset(dest, 0, 1024)
  File "/home/honzik/dev/random-shit/python-lib/string_h.py", line 48, in memset
    _write_garbage(dest, garbage)
  .
  .
  .
    typ = randrange(2)
  File "/usr/lib/python3.10/random.py", line 303, in randrange
    istart = _index(start)
NameError: name '_index' is not defined
Error in sys.excepthook:
Traceback (most recent call last):
  File "/usr/lib/python3/dist-packages/apport_python_hook.py", line 55, in apport_excepthook
    import apt_pkg
  File "<frozen importlib._bootstrap>", line 1027, in _find_and_load
  File "<frozen importlib._bootstrap>", line 1002, in _find_and_load_unlocked
  File "<frozen importlib._bootstrap>", line 945, in _find_spec
  File "<frozen importlib._bootstrap_external>", line 1439, in find_spec
  File "<frozen importlib._bootstrap_external>", line 1411, in _get_spec
  File "<frozen importlib._bootstrap_external>", line 1544, in find_spec
  File "<frozen importlib._bootstrap_external>", line 147, in _path_stat
SystemError: ../Objects/longobject.c:495: bad argument to internal function
Segmentation fault (core dumped)
```

4.
```
Traceback (most recent call last):
  File "/home/honzik/dev/random-shit/python-lib/test.py", line 6, in <module>
  File "/home/honzik/dev/random-shit/python-lib/string_h.py", line 48, in memset
  File "/home/honzik/dev/random-shit/python-lib/string_h.py", line 85, in _write_garbage
  File "/home/honzik/dev/random-shit/python-lib/string_h.py", line 99, in _overwrite_obj
NameError: name 'str' is not defined

During handling of the above exception, another exception occurred:

Traceback (most recent call last):
  File "/home/honzik/dev/random-shit/python-lib/test.py", line 8, in <module>
NameError: name 'print' is not defined
Segmentation fault (core dumped)
```
5.
```
Traceback (most recent call last):
  File "/home/honzik/dev/random-shit/python-lib/test.py", line 9, in <module>
NameError: name 'i' is not defined. Did you mean: 'id'?
Error in sys.excepthook:
Traceback (most recent call last):
  File "/usr/lib/python3/dist-packages/apport_python_hook.py", line 55, in apport_excepthook
  File "<frozen importlib._bootstrap>", line 1024, in _find_and_load
  File "<frozen importlib._bootstrap>", line 170, in __enter__
  File "<frozen importlib._bootstrap>", line 209, in _get_module_lock
AttributeError: module has no attribute 'ref'
Segmentation fault (core dumped)
```

6.
```
Error in sys.excepthook:
Traceback (most recent call last):
  File "/usr/lib/python3/dist-packages/apport_python_hook.py", line 55, in apport_excepthook
    import apt_pkg
  File "<frozen importlib._bootstrap>", line 1027, in _find_and_load
  File "<frozen importlib._bootstrap>", line 1002, in _find_and_load_unlocked
  File "<frozen importlib._bootstrap>", line 945, in _find_spec
  File "<frozen importlib._bootstrap_external>", line 1439, in find_spec
  File "<frozen importlib._bootstrap_external>", line 1411, in _get_spec
  File "<frozen importlib._bootstrap_external>", line 1544, in find_spec
AttributeError: 'FileFinder' object has no attribute 'path'

During handling of the above exception, another exception occurred:

Traceback (most recent call last):
  File "/usr/lib/python3/dist-packages/apport_python_hook.py", line 160, in apport_excepthook
    if sys:
NameError: name 'sys' is not defined

Original exception was:
Traceback (most recent call last):
  File "/home/honzik/dev/random-shit/python-lib/test.py", line 9, in <module>
    print(i)
NameError: name 'i' is not defined. Did you mean: 'id'?
Segmentation fault (core dumped)
```
