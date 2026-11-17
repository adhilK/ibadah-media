#!/usr/bin/env python3
"""Build one faceless Islamic reel.
usage: python3 engine/build.py <reel_dir>   (reel_dir holds script.json)
env: GOOGLE_TTS_KEY (optional; without it a silent timing preview is made)
"""
import json, os, sys, base64, subprocess, urllib.request, wave, contextlib, shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parent
VOICES = {  # Google Cloud TTS voices; override per script with "voice"
    "en": {"languageCode": "en-US", "name": "en-US-Chirp3-HD-Charon"},
    "ml": {"languageCode": "ml-IN", "name": "ml-IN-Chirp3-HD-Charon"},
}
FALLBACK = {"en": "en-US-Neural2-D", "ml": "ml-IN-Wavenet-D"}
FPS = 30


def tts(text, lang, voice, out):
    import hashlib
    cache = ROOT.parent / "cache"; cache.mkdir(exist_ok=True)
    ck = cache / (hashlib.sha1(f"{voice['name']}|{voice.get('rate',0.95)}|{text}".encode()).hexdigest() + ".wav")
    if ck.exists():
        shutil.copy(ck, out); return
    _tts(text, lang, voice, out)
    if os.environ.get("GOOGLE_TTS_KEY"): shutil.copy(out, ck)


def _tts(text, lang, voice, out):
    key = os.environ.get("GOOGLE_TTS_KEY")
    if not key:
        secs = max(1.6, len(text.split()) * (0.42 if lang == "en" else 0.62))
        subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-f", "lavfi", "-i",
                        "anullsrc=r=24000:cl=mono", "-t", f"{secs:.2f}", out], check=True)
        return
    for name in [voice["name"], FALLBACK[lang]]:
        body = {"input": {"text": text},
                "voice": {"languageCode": voice["languageCode"], "name": name},
                "audioConfig": {"audioEncoding": "LINEAR16", "sampleRateHertz": 24000,
                                "speakingRate": voice.get("rate", 0.95)}}
        req = urllib.request.Request(
            "https://texttospeech.googleapis.com/v1/text:synthesize?key=" + key,
            data=json.dumps(body).encode(), headers={"Content-Type": "application/json"})
        try:
            data = json.load(urllib.request.urlopen(req, timeout=60))
            Path(out).write_bytes(base64.b64decode(data["audioContent"]))
            return
        except urllib.error.HTTPError as e:
            print("TTS", name, "failed:", e.code, e.read()[:200])
    raise SystemExit("TTS failed for all voices")


def dur(path):
    with contextlib.closing(wave.open(str(path))) as w:
        return w.getnframes() / w.getframerate()


def main(d):
    d = Path(d)
    if os.environ.get("RESUME") and (d / "timeline.json").exists() and (d / "vo.wav").exists():
        return render(d, json.loads((d / "timeline.json").read_text()))
    S = json.loads((d / "script.json").read_text())
    lang = S["lang"]
    voice = {**VOICES[lang], **S.get("voice", {})}
    gap, t = S.get("gap", 0.35), S.get("offset", 0.6)
    seg = d / "seg"; shutil.rmtree(seg, ignore_errors=True); seg.mkdir()
    parts, caps, spans, bg = [], [], {}, []
    sil = seg / "gap.wav"
    for i, L in enumerate(S["lines"]):
        f = seg / f"{i:02d}.wav"
        tts(L["say"], lang, voice, str(f))
        n = dur(f)
        caps.append({"start": round(t, 3), "end": round(t + n + gap * .8, 3), "text": L.get("cap", L["say"])})
        if L.get("scene"):
            a, b = spans.get(L["scene"], (t, t))
            spans[L["scene"]] = (min(a, t), t + n)
        b = L.get("bg", 1 if i == 0 else (0 if L.get("scene") else 2))
        if not bg or bg[-1]["scene"] != b:
            bg.append({"start": round(max(0, t - (1.3 if L.get("scene") else .3)), 3), "scene": b})
        parts.append(f)
        t += n + gap + L.get("pause", 0)
    total = t + S.get("tail", 1.8)
    bg.append({"start": round(t - .2, 3), "scene": S.get("end_bg", 0)})
    # audio: place each segment at its caption start
    inputs, filt = [], []
    for i, (f, c) in enumerate(zip(parts, caps)):
        inputs += ["-i", str(f)]
        ms = int(c["start"] * 1000)
        filt.append(f"[{i}]adelay={ms}|{ms}[a{i}]")
    filt.append("".join(f"[a{i}]" for i in range(len(parts))) +
                f"amix=inputs={len(parts)}:normalize=0,apad,atrim=0:{total:.2f},"
                "loudnorm=I=-15:TP=-1.5:LRA=7[out]")
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", *inputs, "-filter_complex",
                    ";".join(filt), "-map", "[out]", "-ar", "48000", str(d / "vo.wav")], check=True)
    keys = list(spans)
    scenes = []
    for j, k in enumerate(keys):
        a, b = spans[k]
        a = a - .3 if j == 0 else a
        b = spans[keys[j + 1]][0] if j + 1 < len(keys) else b + .6
        scenes.append({"start": round(a, 3), "end": round(b, 3), **S["scenes"][k]})
    TL = {"lang": lang, "duration": total, "handle": S["handle"], "scenes": scenes, "caps": caps, "endcard": S.get("endcard", ""), "bg": bg, "seed": S.get("seed", 3), "save": S.get("save"),
          "logo": (ROOT.parent / "brand" / ("logo-daily-gold.png" if lang == "en" else "logo-malayalam-gold.png")).as_uri()}
    (d / "timeline.json").write_text(json.dumps(TL, ensure_ascii=False, indent=1))
    render(d, TL)


def render(d, TL):
    from playwright.sync_api import sync_playwright
    frames = d / "frames"
    resume = bool(os.environ.get("RESUME")) and frames.exists()
    if not resume:
        shutil.rmtree(frames, ignore_errors=True); frames.mkdir()
    done = sorted(frames.glob("*.jpg"))
    start = max(0, len(done) - 2) if resume else 0
    N = int(TL["duration"] * FPS)
    with sync_playwright() as p:
        b = p.chromium.launch(args=["--use-angle=swiftshader", "--enable-unsafe-swiftshader", "--ignore-gpu-blocklist"])
        pg = b.new_page(viewport={"width": 1080, "height": 1920})
        pg.goto((ROOT / "reel.html").as_uri())
        pg.evaluate("tl => { window.TL = tl }", TL)
        pg.wait_for_function("window.READY === true")
        err = pg.evaluate("window.SHERR || ''")
        if err: raise SystemExit("shader: " + err)
        if os.environ.get("PREVIEW"):
            for ts in os.environ["PREVIEW"].split(","):
                pg.evaluate(f"renderAt({ts})"); pg.screenshot(path=str(d / f"prev_{ts}.jpg"), type="jpeg", quality=85)
            b.close(); print("preview done"); return
        for i in range(start, N):
            pg.evaluate(f"renderAt({i / FPS})")
            pg.screenshot(path=str(frames / f"{i:05d}.jpg"), type="jpeg", quality=92)
            if i % 150 == 0:
                print(f"frame {i}/{N}", flush=True)
        b.close()
    out = d / (d.name + ".mp4")
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-framerate", str(FPS), "-i", str(frames / "%05d.jpg"),
                    "-i", str(d / "vo.wav"), "-c:v", "libx264", "-preset", "veryfast", "-crf", "18",
                    "-pix_fmt", "yuv420p", "-c:a", "aac", "-b:a", "192k", "-shortest",
                    "-movflags", "+faststart", str(out)], check=True)
    shutil.rmtree(frames)
    print("wrote", out)


if __name__ == "__main__":
    main(sys.argv[1])
