"""Gera o ícone do projeto: pixel art 32x32 ampliado (sem dependências)."""
import struct, zlib, sys

N = 64
def hexc(h): h = h.lstrip('#'); return tuple(int(h[i:i+2], 16) for i in (0, 2, 4)) + (255,)
g = [[None] * N for _ in range(N)]
def px(x, y, c):
    if 0 <= x < N and 0 <= y < N: g[y][x] = hexc(c) if isinstance(c, str) else c
def rect(x0, y0, x1, y1, c):
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1): px(x, y, c)
def line(x0, y0, x1, y1, c):
    n = max(abs(x1 - x0), abs(y1 - y0), 1)
    for i in range(round(n) + 1): px(round(x0 + (x1 - x0) * i / n), round(y0 + (y1 - y0) * i / n), c)
def inside(pt, poly):
    x, y = pt; ok = False
    for i in range(len(poly)):
        (x1, y1), (x2, y2) = poly[i], poly[(i + 1) % len(poly)]
        if (y1 > y) != (y2 > y) and x < (x2 - x1) * (y - y1) / (y2 - y1) + x1: ok = not ok
    return ok
def fill(poly, c):
    for y in range(N):
        for x in range(N):
            if inside((x + .5, y + .5), poly): px(x, y, c)
def outline(poly, c):
    for i in range(len(poly)):
        a, b = poly[i], poly[(i + 1) % len(poly)]
        line(round(a[0]), round(a[1]), round(b[0]), round(b[1]), c)

# fundo índigo profundo com degradê
top, bot = (0x24, 0x2C, 0x7A), (0x0A, 0x0D, 0x2C)
for y in range(N):
    t = y / (N - 1)
    col = tuple(round(top[i] + (bot[i] - top[i]) * t) for i in range(3)) + (255,)
    for x in range(N): g[y][x] = col
# estrelinhas
for (x, y) in ((7, 8), (55, 10), (10, 54), (56, 52), (50, 4), (4, 30), (59, 32)): px(x, y, '#8FA3E8')
for (x, y) in ((12, 14), (53, 18)): px(x, y, '#FFFFFF')
# moldura dourada em degrau
for i in range(2, N - 2):
    for (x, y) in ((i, 1), (i, N - 2), (1, i), (N - 2, i)): px(x, y, '#FFD166')
for (x, y) in ((2, 2), (N - 3, 2), (2, N - 3), (N - 3, N - 3)): px(x, y, '#FFD166')
for i in range(2, N - 2):
    for (x, y) in ((i, 2), (i, N - 3), (2, i), (N - 3, i)): px(x, y, '#B8791A')

k = N / 48.0
def P(x, y): return (x * k, y * k + 1)
H = [P(24, 5), P(40, 14), P(40, 34), P(24, 43), P(8, 34), P(8, 14)]
H0, H1, H2, H3, H4, H5 = H
P1, P2, P3 = P(24, 10), P(10, 34), P(38, 34)
# sombra dura do dado
shadow = [(x + 3, y + 3) for (x, y) in H]
fill(shadow, '#05071A')
faces = [
    ([H5, H0, P1], '#FFEFB0'), ([H0, H1, P1], '#EDBE48'),
    ([H5, P1, P2], '#FFD166'), ([H1, P1, P3], '#D9A030'),
    ([H5, P2, H4], '#F0B840'), ([H1, P3, H2], '#B97A18'),
    ([P2, H4, H3], '#D9A030'), ([P3, H2, H3], '#A86C12'),
    ([P2, P3, H3], '#C8901E'), ([P1, P2, P3], '#FFDB7A'),
]
for poly, c in faces: fill(poly, c)
for poly, _ in faces: outline(poly, '#5A3300')
outline(H, '#3A1F00')
# brilho
rect(14, 24, 15, 29, '#FFF3C4'); rect(16, 21, 17, 23, '#FFF3C4')

# "20" em fonte 3x5, escala 2, no triângulo central
F = {'2': ['111', '001', '111', '100', '111'], '0': ['111', '101', '101', '101', '111']}
ox, oy = 25, 33
for di, d in enumerate('20'):
    for r, row in enumerate(F[d]):
        for c, ch in enumerate(row):
            if ch == '1': rect(ox + di * 8 + c * 2, oy + r * 2, ox + di * 8 + c * 2 + 1, oy + r * 2 + 1, '#5A3300')

def png(size, path, pad=0.0, bg=None):
    """Amplia por vizinho-mais-próximo. pad: margem relativa (ícones adaptativos)."""
    inner = round(size * (1 - 2 * pad))
    off = (size - inner) // 2
    rows = []
    for y in range(size):
        row = bytearray([0])
        for x in range(size):
            if off <= x < off + inner and off <= y < off + inner:
                c = g[min(N - 1, (y - off) * N // inner)][min(N - 1, (x - off) * N // inner)]
            else:
                c = bg or (0, 0, 0, 0)
            row += bytes(c)
        rows.append(bytes(row))
    raw = b''.join(rows)
    def chunk(t, d): 
        c = struct.pack('>I', len(d)) + t + d
        return c + struct.pack('>I', zlib.crc32(t + d) & 0xffffffff)
    data = b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', size, size, 8, 6, 0, 0, 0)) + chunk(b'IDAT', zlib.compress(raw, 9)) + chunk(b'IEND', b'')
    open(path, 'wb').write(data)

if __name__ == '__main__':
    png(1024, 'assets/icon/icon.png')
    png(1024, 'assets/icon/icon_foreground.png', pad=0.18)       # frente do ícone adaptativo (Android)
    png(512, 'assets/icon/logo.png')
    png(128, 'assets/icon/logo_small.png')
    png(1024, 'assets/icon/splash.png', pad=0.0)
