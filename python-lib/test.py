from string_h import memset

for i in range(1_000_000):
    dest = [1]
    try:
        memset(dest, 0, 1024)
    except Exception as e:
        print(f"Got error: {e}")
    print(i)
