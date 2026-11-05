"""UI-40 G0 (KHÔNG còn dùng — thay bằng mon_beast / mon_catalog, MD-1 docs/39; giữ để so sánh): Sói Sương + Sói Chúa Hư Vô HD — dựng chung một khung sói 4 chân, nhìn sang phải."""
import math

from vec import Canvas, Tone, bezier, polar, sheet

KINDS = {
    "wolf": dict(fw=96, fh=96, ox=48, oy=88, u=1.0, px=4, size_mul=1.35, name="Sói Sương",
                 fur=Tone("#aebdd1", "#6c7d98", "#eef4fb"), belly=Tone("#e3eaf2", "#aab7c8", "#ffffff"),
                 dark=Tone("#5d6c84", "#3e4a5e", "#8494ad"), eye="#6fe0ff", mane=None, aura=None),
    "boss": dict(fw=192, fh=192, ox=96, oy=176, u=2.0, px=4, size_mul=1.3, name="Sói Chúa Hư Vô",
                 fur=Tone("#3f3657", "#231d35", "#6f6296"), belly=Tone("#5a4f78", "#372e50", "#8a7cb3"),
                 dark=Tone("#2a2340", "#17122a", "#4a3f6a"), eye="#ff5ad1", mane=Tone("#7b4fd6", "#4b2a96", "#c9a6ff"),
                 aura="#a066ff"),
}
OUTLINE = "#160f22"


def frame(k, pose):
    K = KINDS[k]
    u = K["u"]
    c = Canvas(K["fw"], K["fh"])
    P = dict(BASE)
    P.update(pose)
    ox, oy = K["ox"] + P["dx"] * u, K["oy"]
    leg = 15 * u
    body_y = oy - leg - 7 * u + P["dy"] * u
    tilt = math.radians(P["tilt"])
    # thân: hông (sau) → ngực (trước)
    hip = (ox - 13 * u, body_y + math.sin(tilt) * 13 * u)
    chest = (ox + 10 * u, body_y - math.sin(tilt) * 10 * u)
    neck = (chest[0] + 6 * u, chest[1] - 7 * u + P["head_dy"] * u)
    head = (neck[0] + 7 * u, neck[1] - 3 * u + P["head_dy"] * u * 0.5)

    if K["aura"]:
        # khói Hư Vô bốc lên từ lưng + vòng sáng dưới chân
        c.glow(lambda d: c.ellipse(d, ox, oy, 26 * u, 5 * u), K["aura"], radius=3 * u, alpha=110)
        def wisps(d):
            for i in range(5):
                bx = ox - 16 * u + i * 8 * u
                t = (P["aura"] + i * 0.37) % 1.0
                c.ribbon(d, bezier((bx, body_y - 4 * u), (bx - 3 * u, body_y - 12 * u - t * 4 * u), (bx + 3 * u, body_y - 20 * u - t * 6 * u), n=10),
                         [4.5 * u * (1 - j / 11) for j in range(11)])
        c.glow(wisps, K["aura"], radius=1.6 * u, alpha=120)
    c.flat(lambda d: c.ellipse(d, ox - 1 * u, oy + 0.5 * u, 22 * u * P["shadow"], 4 * u), (10, 8, 20, 255), alpha=80, blur=1.0 * u)

    def legs(back):
        sets = [("bb", hip, -3), ("fb", chest, -2)] if back else [("bf", hip, 2), ("ff", chest, 3)]
        tone = K["dark"] if back else K["fur"]
        for key, o, off in sets:
            a1, a2 = P[key]
            top = (o[0] + off * u, o[1] + 3 * u)
            knee, paw = (polar(top, 8 * u, a1), None)
            paw = polar(knee, 9 * u, a1 + a2)
            c.part(lambda d, top=top, knee=knee: c.capsule(d, top, knee, 5.4 * u, 3.6 * u), tone, shade_d=1.8 * u)
            c.part(lambda d, knee=knee, paw=paw: c.capsule(d, knee, paw, 3.3 * u, 2.8 * u), tone, shade_d=1.2 * u)
            c.part(lambda d, paw=paw: c.ellipse(d, paw[0] + 1.8 * u, paw[1] + 0.4 * u, 4.0 * u, 2.6 * u), tone, shade_d=0.8 * u)

    legs(True)
    # đuôi
    tb = (hip[0] - 5 * u, hip[1] - 3 * u)
    tw = P["tail"]
    tail = bezier(tb, (tb[0] - 7 * u, tb[1] - 7 * u - tw * 2 * u), (tb[0] - 14 * u, tb[1] - 5 * u + tw * 3 * u),
                  (tb[0] - 18 * u, tb[1] + 1 * u + tw * 4 * u), 14)
    def tailf(d):
        c.ribbon(d, tail, [12.0 * u * math.sin(math.pi * (0.3 + 0.62 * i / 14)) for i in range(15)])
        for i in range(3, 14, 3):
            x, y = tail[i]
            c.poly(d, [(x - 2 * u, y - 2 * u), (x - 4.5 * u, y - 6 * u - tw * u), (x + 1.5 * u, y - 3 * u)])
    c.part(tailf, K["fur"], shade_d=1.8 * u)
    c.part(lambda d: c.ellipse(d, tail[-2][0], tail[-2][1], 3.4 * u, 2.6 * u), K["belly"], shade_d=0.6 * u)
    # thân
    def body(d):
        c.ellipse(d, (hip[0] + chest[0]) / 2, (hip[1] + chest[1]) / 2, 17 * u, 9.5 * u, tilt * -1)
        c.circle(d, chest[0] + 1 * u, chest[1] - 1 * u, 10.5 * u)
        c.circle(d, hip[0], hip[1] - 0.5 * u, 8.8 * u)
        # lông xù dọc lưng + dưới bụng
        for i in range(7):
            t = i / 6
            x = hip[0] - 4 * u + (chest[0] - hip[0] + 6 * u) * t
            y = hip[1] + (chest[1] - hip[1]) * t - 8.5 * u - 1.5 * u * math.sin(math.pi * t)
            c.poly(d, [(x - 3 * u, y + 2 * u), (x - 4.5 * u, y - 3.5 * u), (x + 2 * u, y + 1 * u)])
        for i in range(4):
            x = hip[0] + 2 * u + i * 6 * u
            y = (hip[1] + chest[1]) / 2 + 8.5 * u
            c.poly(d, [(x - 2.5 * u, y - 2 * u), (x - 1 * u, y + 3.5 * u), (x + 2.5 * u, y - 2 * u)])
    bm = c.part(body, K["fur"], shade_d=3.0 * u, light_d=1.4 * u)
    c.part(lambda d: c.ellipse(d, (hip[0] + chest[0]) / 2 + 3 * u, (hip[1] + chest[1]) / 2 + 5.5 * u, 13 * u, 3.6 * u, tilt * -1),
           K["belly"], shade_d=0.8 * u, clip=bm)
    if K["mane"]:
        def mane(d):
            for i in range(7):
                a = math.radians(-150 + i * 22)
                b = (chest[0] + math.cos(a) * 6 * u, chest[1] - 2 * u + math.sin(a) * 6 * u)
                t = (chest[0] + math.cos(a) * 13 * u - 3 * u, chest[1] - 2 * u + math.sin(a) * 12 * u - 2 * u)
                c.poly(d, [(b[0] - 2.5 * u, b[1]), t, (b[0] + 2.5 * u, b[1] + 1 * u)])
            c.circle(d, chest[0] + 1 * u, chest[1] - 2 * u, 7.5 * u)
        c.part(mane, K["mane"], shade_d=1.6 * u, light_d=1.0 * u)
    else:
        def ruff(d):
            for i in range(5):
                a = math.radians(-130 + i * 30)
                b = (chest[0] + math.cos(a) * 5 * u, chest[1] + math.sin(a) * 5 * u)
                t = (chest[0] + math.cos(a) * 10 * u - 1 * u, chest[1] + math.sin(a) * 9 * u + 2 * u)
                c.poly(d, [(b[0] - 2 * u, b[1]), t, (b[0] + 2 * u, b[1] + 1 * u)])
        c.part(ruff, K["belly"], shade_d=1.0 * u)
    legs(False)

    # đầu
    hx, hy = head
    jaw = P["jaw"]
    c.part(lambda d: c.capsule(d, (neck[0] - 2 * u, neck[1] + 3 * u), (hx - 2 * u, hy + 1 * u), 6 * u, 5.5 * u), K["fur"], shade_d=1.6 * u)
    # tai
    for ex, tone in ((-4.5, K["dark"]), (-1.0, K["fur"])):
        c.part(lambda d, ex=ex: c.poly(d, [(hx + ex * u - 3.2 * u, hy - 3.5 * u), (hx + ex * u - 1.5 * u + P["ear"] * u, hy - 14 * u),
                                            (hx + ex * u + 3.6 * u, hy - 4 * u)]), tone, shade_d=1.0 * u)
    c.flat(lambda d: c.poly(d, [(hx - 1.6 * u, hy - 4 * u), (hx - 0.6 * u + P["ear"] * u, hy - 9.5 * u), (hx + 1.4 * u, hy - 4 * u)]),
           "#e8a3b4", alpha=200)
    # hàm dưới (mở khi cắn)
    jaw_a = math.radians(18 * jaw)
    jb = (hx + 2 * u, hy + 3 * u)
    jt = (jb[0] + math.cos(jaw_a) * 9 * u, jb[1] + math.sin(jaw_a) * 9 * u)
    if jaw > 0:
        c.flat(lambda d: c.poly(d, [(hx + 2 * u, hy + 1 * u), (hx + 12 * u, hy + 2 * u), jt, jb]), "#5a1f2e")
        c.flat(lambda d: c.poly(d, [(hx + 6 * u, hy + 2 * u), (hx + 7 * u, hy + 4.2 * u), (hx + 8 * u, hy + 2 * u)]), "#ffffff")
        c.flat(lambda d: c.poly(d, [(hx + 9.5 * u, hy + 2 * u), (hx + 10.3 * u, hy + 3.8 * u), (hx + 11.2 * u, hy + 2 * u)]), "#ffffff")
    c.part(lambda d: c.capsule(d, jb, jt, 2.4 * u, 1.6 * u), K["belly"], shade_d=0.8 * u)
    # sọ + mõm
    c.part(lambda d: (c.ellipse(d, hx, hy - 0.5 * u, 8.0 * u, 6.8 * u), c.capsule(d, (hx + 2 * u, hy + 0.5 * u), (hx + 11 * u, hy + 1.5 * u), 4.2 * u, 3.0 * u),
                      c.poly(d, [(hx - 7 * u, hy - 1 * u), (hx - 11 * u, hy + 4 * u), (hx - 4 * u, hy + 5 * u)])),
           K["fur"], shade_d=1.8 * u, light_d=1.0 * u)
    c.part(lambda d: c.capsule(d, (hx + 4 * u, hy + 2.6 * u), (hx + 10 * u, hy + 2.8 * u), 1.8 * u, 1.4 * u), K["belly"], shade_d=0.5 * u)
    c.flat(lambda d: c.ellipse(d, hx + 11.6 * u, hy + 0.9 * u, 1.9 * u, 1.5 * u), "#1c1726")
    # mắt phát sáng
    c.glow(lambda d: c.ellipse(d, hx + 2.8 * u, hy - 1.6 * u, 2.6 * u, 1.6 * u), K["eye"], radius=1.6 * u, alpha=200)
    c.flat(lambda d: c.poly(d, [(hx + 0.8 * u, hy - 1.2 * u), (hx + 4.8 * u, hy - 2.6 * u), (hx + 4.2 * u, hy - 0.6 * u), (hx + 1.2 * u, hy - 0.4 * u)]), K["eye"])
    c.flat(lambda d: c.circle(d, hx + 3.6 * u, hy - 1.7 * u, 0.6 * u), "#ffffff")
    img = c.render(outline=OUTLINE, width=1.8 * (1.0 if u == 1 else 1.4))
    if P["fade"] < 1.0:
        img.putalpha(img.getchannel("A").point(lambda v: int(v * P["fade"])))
    return img


BASE = dict(dx=0.0, dy=0.0, tilt=0.0, head_dy=0.0, jaw=0.0, ear=0.0, tail=0.0, shadow=1.0, aura=0.0, fade=1.0,
            bb=(-8, 14), fb=(6, 4), bf=(4, 10), ff=(12, -2))

ANIMS = {
    "idle": [dict(), dict(dy=0.4, tail=0.5, head_dy=0.3, aura=0.5), dict(dy=0.8, tail=1.0, head_dy=0.6, ear=0.6, aura=1.0),
             dict(dy=0.4, tail=0.5, head_dy=0.3, aura=0.5)],
    "run": [
        dict(dy=-1.2, tilt=4, bb=(-40, 30), bf=(-30, 26), fb=(40, -10), ff=(52, -24), tail=-1.0, head_dy=-0.5, aura=1),
        dict(dy=0.6, tilt=0, bb=(-10, 40), bf=(0, 30), fb=(10, 20), ff=(20, 10), tail=0.0, head_dy=0.3),
        dict(dy=-0.4, tilt=-4, bb=(34, -6), bf=(44, -16), fb=(-34, 40), ff=(-24, 34), tail=1.0, head_dy=0.6, aura=1),
        dict(dy=0.8, tilt=0, bb=(10, 18), bf=(20, 10), fb=(-10, 36), ff=(0, 30), tail=0.2, head_dy=0.2),
    ],
    "attack": [
        dict(dx=-2, dy=1.4, tilt=-6, head_dy=1.5, jaw=0.4, ear=-1, bb=(-18, 30), bf=(-10, 26), fb=(-6, 20), ff=(4, 16), tail=1.2),
        dict(dx=4, dy=-1.6, tilt=8, head_dy=-1.0, jaw=1.0, ear=-1.5, bb=(-46, 20), bf=(-36, 18), fb=(50, -20), ff=(62, -30),
             tail=-1.2, aura=1),
        dict(dx=3, dy=0.0, tilt=3, head_dy=0.6, jaw=0.5, bb=(-24, 20), bf=(-14, 16), fb=(24, 0), ff=(34, -8), tail=-0.4),
    ],
    "hurt": [dict(dx=-3, tilt=-8, head_dy=-1.2, jaw=0.5, ear=-2, tail=1.5), dict(dx=-1, tilt=-3, head_dy=-0.4, jaw=0.2, ear=-1, tail=0.8)],
    "death": [
        dict(dx=-2, dy=2, tilt=-10, head_dy=1.0, jaw=0.6, ear=-2, tail=1.5, bb=(10, 30), bf=(20, 20), fb=(-10, 30), ff=(0, 30)),
        dict(dx=-3, dy=6, tilt=-4, head_dy=3.0, jaw=0.3, ear=-2, tail=2.0, bb=(50, 10), bf=(60, 0), fb=(40, 10), ff=(50, 0), shadow=1.1),
        dict(dx=-3, dy=8, tilt=-2, head_dy=4.0, jaw=0.2, ear=-2, tail=2.2, bb=(70, 0), bf=(80, 0), fb=(60, 0), ff=(70, 0), shadow=1.2,
             fade=0.7),
    ],
}
ORDER = ["idle", "run", "attack", "hurt", "death"]
FPS = {"idle": 4, "run": 10, "attack": 10, "hurt": 8, "death": 6}
LOOP = {"idle": True, "run": True, "attack": False, "hurt": False, "death": False}


def build(k):
    K = KINDS[k]
    rows = [[frame(k, p) for p in ANIMS[a]] for a in ORDER]
    meta = {"w": K["fw"], "h": K["fh"], "origin": [K["ox"], K["oy"]], "px": K["px"], "name": K["name"], "size_mul": K["size_mul"],
            "anims": {a: {"row": i, "frames": len(ANIMS[a]), "fps": FPS[a], "loop": LOOP[a]} for i, a in enumerate(ORDER)}}
    return sheet(rows, K["fw"], K["fh"]), meta


if __name__ == "__main__":
    import os
    for k in KINDS:
        img, _ = build(k)
        out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "_preview", "hd-%s.png" % k)
        bg = img.copy()
        from PIL import Image
        b = Image.new("RGBA", img.size, (58, 84, 52, 255))
        b.alpha_composite(img)
        b.save(out)
        print(out, img.size)
