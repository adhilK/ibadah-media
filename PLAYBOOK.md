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
Voices: Google Chirp 3 HD `Charon` (en-US / ml-IN) only — free tier covers this volume. Never use Gemini-TTS or Studio voices (not free).
QA before upload: view frames at every caption, verse card and the end card; no text may overflow or overlap.

## 5. Publish
1. Copy MP4s to `reels/DATE/ibadah-daily.mp4` and `reels/DATE/ibadah-malayalam.mp4`, commit and push.
2. Public URL: `https://raw.githubusercontent.com/adhilK/ibadah-media/main/reels/DATE/<file>.mp4`
3. Composio `INSTAGRAM_POST_IG_USER_MEDIA` (media_type REELS, video_url, caption, share_to_feed true) with the right account, then `INSTAGRAM_POST_IG_USER_MEDIA_PUBLISH` (max_wait_seconds 180).
4. **Approval period (until 2026-12-01):** don't publish until Adhil replies "approve" in the run's conversation; send both MP4s + captions first. After that date, publish directly.

Caption: hook line · source line(s) · one short reflection · CTA (save/share) · 4–6 hashtags (mix of #islamicreminder #quran #hadith #sunnah #dua and, for Malayalam, #malayalamislamic #ഇസ്ലാം).

## 6. Learn and improve
Every run, first pull the last 14 days of reels for both accounts (Composio `INSTAGRAM_GET_IG_USER_MEDIA` with `insights.metric(views,reach,saved,shares,total_interactions,ig_reels_avg_watch_time)`), and append them to `log.json`. Compare hooks, topic types, length and posting time. Write one line in `log.json` → `learnings` on what to try next, and apply it to today's script. Change one variable at a time.
