#!/usr/bin/env python3
"""Minimal BPS (beat) patch creator/applier for Crystal Adventures releases.

Release procedure:
  1. Build the vanilla base ROM (Pokemon Crystal 1.0, CRC32 EE6F5188):
       git clone https://github.com/pret/pokecrystal.git && cd pokecrystal
       git checkout 8e13593~1   # last revision compatible with rgbds 0.5.2
       make crystal
  2. Create the patch:
       python3 tools/make_bps.py create pokecrystal.gbc CrystalAdventures.gbc CrystalAdventures.bps
  3. Verify (applies the patch and checks CRCs; then byte-compare):
       python3 tools/make_bps.py apply CrystalAdventures.bps pokecrystal.gbc out.gbc
       cmp out.gbc CrystalAdventures.gbc
  4. Attach to the GitHub release:
       gh release upload vX.Y CrystalAdventures.bps -R altbanty/CrystalAdventures


Encoder strategy: aligned diff (SourceRead for identical runs, TargetRead for
literals) plus RLE via TargetCopy offset -1 for repeated-byte runs. Valid BPS,
readable by flips/beat/any compliant patcher.
"""
import struct, sys, zlib

def wnum(n):
    out = bytearray()
    while True:
        x = n & 0x7F
        n >>= 7
        if n == 0:
            out.append(x | 0x80)
            return bytes(out)
        out.append(x)
        n -= 1

def rnum(buf, pos):
    data, shift = 0, 1
    while True:
        x = buf[pos]; pos += 1
        data += (x & 0x7F) * shift
        if x & 0x80:
            return data, pos
        shift <<= 7
        data += shift

SOURCE_READ, TARGET_READ, SOURCE_COPY, TARGET_COPY = 0, 1, 2, 3

def cmd(action, length):
    return wnum(((length - 1) << 2) + action)

def create(source, target, metadata=b""):
    K = 16          # index key width
    STRIDE = 4      # source index stride
    MIN_COPY = 40   # min length for a SourceCopy to beat literal cost

    # Index source content for relocated-chunk matching
    idx = {}
    for k in range(0, len(source) - K, STRIDE):
        key = bytes(source[k:k + K])
        if key not in idx:
            idx[key] = k

    # Pass 1: op list
    ops = []            # ('sread', len) | ('scopy', src_off, len) | ('lit', bytes)
    lit = bytearray()

    def flush():
        if lit:
            ops.append(("lit", bytes(lit)))
            lit.clear()

    n = len(target)
    i = 0
    while i < n:
        # aligned identical run -> SourceRead
        if i < len(source) and source[i] == target[i]:
            j = i
            while j < n and j < len(source) and source[j] == target[j]:
                j += 1
            if j - i >= 4:
                flush()
                ops.append(("sread", j - i))
                i = j
                continue
        # relocated chunk -> SourceCopy
        k = idx.get(bytes(target[i:i + K]))
        if k is not None:
            l = 0
            while i + l < n and k + l < len(source) and source[k + l] == target[i + l]:
                l += 1
            if l >= MIN_COPY:
                flush()
                ops.append(("scopy", k, l))
                i += l
                continue
        lit.append(target[i])
        i += 1
    flush()

    # Pass 2: emit, with RLE (TargetCopy offset -1) inside literal chunks
    p = bytearray(b"BPS1")
    p += wnum(len(source)) + wnum(len(target)) + wnum(len(metadata)) + metadata
    out_pos = 0
    src_rel = 0
    tgt_rel = 0

    def emit_signed(off):
        p.extend(wnum((abs(off) << 1) | (1 if off < 0 else 0)))

    for op in ops:
        if op[0] == "sread":
            p.extend(cmd(SOURCE_READ, op[1]))
            out_pos += op[1]
        elif op[0] == "scopy":
            _, k, l = op
            p.extend(cmd(SOURCE_COPY, l))
            emit_signed(k - src_rel)
            src_rel = k + l
            out_pos += l
        else:
            data = op[1]
            j, m = 0, len(data)
            while j < m:
                # find next long repeated-byte run
                s = j
                while s < m:
                    t = s
                    while t + 1 < m and data[t + 1] == data[s]:
                        t += 1
                    if t - s + 1 >= 16:
                        break
                    s = t + 1
                # literals up to the run (or end), then RLE the run
                lit_end = min(s + 1, m) if s < m else m
                if lit_end > j:
                    p.extend(cmd(TARGET_READ, lit_end - j))
                    p.extend(data[j:lit_end])
                    out_pos += lit_end - j
                j = lit_end
                if s < m:
                    run_len = t - s  # after the 1 literal byte emitted above
                    p.extend(cmd(TARGET_COPY, run_len))
                    emit_signed((out_pos - 1) - tgt_rel)
                    tgt_rel = (out_pos - 1) + run_len
                    out_pos += run_len
                    j = t + 1

    p += struct.pack("<II", zlib.crc32(source), zlib.crc32(target))
    p += struct.pack("<I", zlib.crc32(bytes(p)))
    return bytes(p)

def apply(patch, source):
    assert patch[:4] == b"BPS1", "not a BPS patch"
    src_crc, tgt_crc, pat_crc = struct.unpack("<III", patch[-12:])
    assert zlib.crc32(patch[:-4]) == pat_crc, "patch CRC mismatch"
    assert zlib.crc32(source) == src_crc, "source CRC mismatch"
    pos = 4
    src_size, pos = rnum(patch, pos)
    tgt_size, pos = rnum(patch, pos)
    meta_size, pos = rnum(patch, pos)
    pos += meta_size
    assert src_size == len(source), "source size mismatch"
    out = bytearray(tgt_size)
    o = 0
    src_rel = tgt_rel = 0
    end = len(patch) - 12
    while pos < end:
        data, pos = rnum(patch, pos)
        action = data & 3
        length = (data >> 2) + 1
        if action == SOURCE_READ:
            out[o:o+length] = source[o:o+length]
        elif action == TARGET_READ:
            out[o:o+length] = patch[pos:pos+length]; pos += length
        else:
            off, pos = rnum(patch, pos)
            off = -(off >> 1) if (off & 1) else (off >> 1)
            if action == SOURCE_COPY:
                src_rel += off
                out[o:o+length] = source[src_rel:src_rel+length]
                src_rel += length
            else:
                tgt_rel += off
                for k in range(length):  # byte-wise: may self-overlap (RLE)
                    out[o + k] = out[tgt_rel + k]
                tgt_rel += length
        o += length
    assert o == tgt_size, f"output size {o} != {tgt_size}"
    assert zlib.crc32(bytes(out)) == tgt_crc, "target CRC mismatch"
    return bytes(out)

if __name__ == "__main__":
    mode, *args = sys.argv[1:]
    if mode == "create":
        src, tgt, out = args
        patch = create(open(src, "rb").read(), open(tgt, "rb").read())
        open(out, "wb").write(patch)
        print(f"wrote {out}: {len(patch)} bytes")
    elif mode == "apply":
        pat, src, out = args
        result = apply(open(pat, "rb").read(), open(src, "rb").read())
        open(out, "wb").write(result)
        print(f"wrote {out}: {len(result)} bytes CRC32 {zlib.crc32(result):08X}")
