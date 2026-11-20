# Ibadah pages — daily reel playbook

Two faceless Instagram Reel pages, posted once a day each:
- **@ibadah.daily** — English (Composio account `instagram_purga-talari`, IG id 29072176985736928)
- **@ibadah.malayalam** — Malayalam (Composio account `instagram_semic-ratio`, IG id 28964248069904574)

Both reels each day cover the **same topic**, written natively for each audience (not a word-for-word translation).

## 1. Content rules (non-negotiable)
- **No faces, people, animals or depictions of prophets/companions.** Visuals are the engine's scenes only (dunes, arch corridor, lanterns).
- **No music.** Voice only.
- **The voice never recites Qur'an.** Arabic appears on screen; the voice reads the translation and explanation only.
- **Qur'an:** text and translations from Quran.com (api.quran.com v4). English = Saheeh International (id 20). Malayalam = Cheriyamundam Abdul Hameed & Kunhi Mohammed Parappoor (id 37). Copy translations exactly.
- **Hadith:** only grade *sahih* or *hasan*. Verify on sunnah.com: collection, hadith number, and the grading shown there. Cross-check the grading on dorar.net when sunnah.com shows none. Never use a hadith graded da'if/mawdu', and never attribute a scholar's saying to the Prophet ﷺ.
- **Tafsir/explanations:** only from named classical sources (Ibn Kathir, al-Tabari, al-Sa'di) as shown on quran.com/tafsir pages, or from the hadith itself. If a claim can't be traced to a source you opened today, leave it out.
- **Stories of the prophets:** only what the Qur'an or sahih/hasan hadith state; no Isra'iliyyat details, no invented dialogue.
- **Duas/adhkar:** give the source (e.g. Sahih Muslim 2723) and when it is said.
- Avoid fiqh disputes, sectarian topics, politics, and anything that needs a mufti.
- Malayalam must read naturally (Kerala Muslim register: അല്ലാഹു, ദുആ, സ്വബ്ർ, നബി ﷺ). Avoid stiff literal translation.

## 2. Topic rotation (one per day, cycling)
1. Qur'an āyah reflection
2. Authentic hadith
3. Stories of the prophets
4. Daily dua / adhkar

Check `log.json` so no topic or source repeats within 60 days. Lean towards what performed best (see §6).

## 3. Script format (`scripts/YYYY-MM-DD-en.json`, `-ml.json`)
```json
{"lang":"en","handle":"@ibadah.daily","offset":0.6,"gap":0.35,"tail":5.0,
 "endcard":"Save this for the hard days",
 "save":{"ar":"key Arabic, one line per verse","tr":"“translation”","ref":"Qur'an 94 : 5–6"},
 "lines":[{"say":"Hook question that names the viewer's feeling."},
          {"say":"...","scene":"v1","cap":"optional shorter on-screen text"}],
 "scenes":{"v1":{"ar":"Arabic text","tr":"“Exact translation”","ref":"Qur'an 94 : 5"}}}
```
- 30–45 s, 7–9 lines. Line 1 is the hook (shown big over the arch corridor). Lines with `scene` show the verse/hadith card (over the night dunes). Remaining lines play over the lanterns.
- Hook: the viewer's feeling or a striking question; never open with the page name.
- Last spoken line is the call to action (share/save). The reel ends on a 5-second **save card** (gold logo, the `save` verse/hadith, its reference, `endcard` line, handle) designed to be screenshotted and saved; `tail` must be 5.0.
- Brand: deep green + gold only. The gold logo lockups in brand/ (logo-daily-gold.png, logo-malayalam-gold.png) are added automatically.
- For a hadith, `ar` = the key Arabic phrase (short), `tr` = translation, `ref` e.g. "Sahih al-Bukhari 6018".
- Malayalam handle `@ibadah.malayalam`; endcard is a short save/share line in Malayalam.

## 4. Build
```
pip install playwright --break-system-packages && python3 -m playwright install chromium
export GOOGLE_TTS_KEY=...        # given in the scheduled task prompt
mkdir -p work/en work/ml && cp scripts/DATE-en.json work/en/script.json && cp scripts/DATE-ml.json work/ml/script.json
PREVIEW=1.5,10,20,30 python3 engine/build.py work/en   # look at prev_*.jpg first
python3 engine/build.py work/en && python3 engine/build.py work/ml
```
A full render takes ~20 min and background jobs can be killed. Run each render in the foreground as `RESUME=1 timeout 580 python3 engine/build.py work/en` and repeat the same command until it prints `wrote`; RESUME keeps finished frames and the voiceover. (Run the first pass without RESUME so the voiceover is generated.)
Voices: Google Chirp 3 HD `Charon` (en-US / ml-IN) only — free tier covers this volume. Never use Gemini-TTS or Studio voices (not free).
Transliterated Arabic in English `say` lines: join short particles to the next word ("wabihamdihi", not "wa bi hamdihi"); the en-US voice spells a lone "wa" as "W A". Check the transliteration line's audio before the full render.
QA before upload: view frames at every caption, verse card and the end card; no text may overflow or overlap.

**Content-specific design (Adhil, 2026-11-19; replaces the generic dunes/arches/lanterns look):** every video gets its own visual theme designed from its content — never reuse the same scene set for a new topic.
1. Before writing frames, plan 3–5 scenes that tell the topic visually (e.g. Yunus 21:87-88 → night sea, descent into the deep, a lone light calling in the dark, light rays breaking down, dawn over the sea; a dua for rain → gathering clouds, falling rain, green earth; a verse on night prayer → late-night sky, a single lit window, the last third of the night).
2. Write them as GLSL in `engine/themes/<slug>.glsl` defining `vec3 theme(int s, vec2 uv, float ts)` for scene ids 10+ (`ts` = seconds since that scene began; helpers `h1 n2 fbm stars GOLD R T` are available). Optional `engine/themes/<slug>.css` restyles the card/ornament for the topic. See `engine/themes/yunus.glsl` as a reference.
3. In the script set `"theme":"<slug>"`, `"end_bg"`, and a `"bg"` id on each line so scene changes follow the narration (the bg crossfades ~1.3 s before a card line).
4. Animations must serve the meaning (e.g. the light growing while the dua is spoken, rays when the answer comes). Also keep adding at least one new motion idea per day (word reveals, Arabic RTL reveal + gold shimmer, parallax, particles, transitions) and note it in log.json.
5. Rules still apply: no people, faces, prophets, companions or animals (show a story's setting and symbols, never the creature — e.g. no fish/whale for Yunus), no music, deep green + gold palette, text legible over every scene (keep bright elements such as a sun out of the caption zone ~1170–1470 px). Check a preview contact sheet of 10+ timestamps before the full render. The old scenes 0–2 are only a fallback.

## 5. Publish
1. Copy MP4s to `reels/DATE/ibadah-daily.mp4` and `reels/DATE/ibadah-malayalam.mp4`, commit and push.
2. Public URL: `https://raw.githubusercontent.com/adhilK/ibadah-media/main/reels/DATE/<file>.mp4`
3. Composio `INSTAGRAM_POST_IG_USER_MEDIA` (media_type REELS, video_url, caption, share_to_feed true) with the right account, then `INSTAGRAM_POST_IG_USER_MEDIA_PUBLISH` (max_wait_seconds 180).
4. **Approval period (until 2026-12-01):** don't publish until Adhil replies "approve" in the run's conversation; send both MP4s + captions first. After that date, publish directly.

Caption: write hashtags with a plain `#` — never `%23` (Composio's schema hint is wrong; `%23` shows up literally). Hook line · source line(s) · one short reflection · CTA (save/share) · 4–6 hashtags (mix of #islamicreminder #quran #hadith #sunnah #dua and, for Malayalam, #malayalamislamic #ഇസ്ലാം).

## 5b. YouTube Shorts (same day, same approval)
Both reels also go to the YouTube channel **Ibadah Daily** (@ibadahdailyquran, channel UCIWN0KrGc8N2V12ob3Ml80Q, Composio account `youtube_gunsel-anyway`). English and Malayalam Shorts share this one channel.
1. In COMPOSIO_REMOTE_WORKBENCH: download each MP4 from its raw.githubusercontent URL to /home/user, then `upload_local_file(path)` to get an `s3key`.
2. `YOUTUBE_MULTIPART_UPLOAD_VIDEO` once per video (never re-run on success — it would duplicate): title ≤ 100 chars ending with `#Shorts` (Malayalam titles include "| Malayalam"), description = the Instagram caption plus "One authentic reminder every day — every source cited." and `#Shorts`, 5–9 tags, categoryId "27", privacyStatus "public", videoFile {name, mimetype "video/mp4", s3key}.
3. Save the returned video ids in log.json (`yt_en_id`, `yt_ml_id`). Shorts URL: https://youtube.com/shorts/<id>.
4. For learning, pull Shorts stats with `YOUTUBE_GET_VIDEO_DETAILS_BATCH` (parts snippet,statistics) alongside the Instagram insights.

## 6. Learn and improve
Every run, first pull the last 14 days of reels for both accounts (Composio `INSTAGRAM_GET_IG_USER_MEDIA` with `insights.metric(views,reach,saved,shares,total_interactions,ig_reels_avg_watch_time)`), and append them to `log.json`. Compare hooks, topic types, length and posting time. Write one line in `log.json` → `learnings` on what to try next, and apply it to today's script. Change one variable at a time.
