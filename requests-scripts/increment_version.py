import sys

v_str = sys.argv[1]
parts = [int(p) for p in v_str.split('.')]

parts[-1] += 1
for i in range(len(parts) - 1, 0, -1):
    if parts[i] >= 10:
        parts[i] = 0
        parts[i-1] += 1

print(".".join(map(str, parts)))