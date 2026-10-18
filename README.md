# Human or AI?

A pass-and-play party game for Android. One player answers a question,
two bots answer too, and the other player has to find the human.

- Flutter app, no packages, works offline, collects no data
- 60 questions with pre-written bot answers in `assets/questions.json`
- Built in the cloud by GitHub Actions (`.github/workflows/build-android.yml`)

**To publish:** follow [PUBLISHING.md](PUBLISHING.md).
**Store text and questionnaires:** [STORE_LISTING.md](STORE_LISTING.md).

## Project layout

```
lib/main.dart          app entry
lib/game.dart          game rules and scoring
lib/screens.dart       all screens
lib/theme.dart         colors and theme
assets/questions.json  questions + bot answers (edit to add more)
test/widget_test.dart  rule tests, run on every build
tool/configure_android.py  sets app name, ID, icon, signing in the cloud build
tool/make_icons.py     redraws the icon and store graphics
branding/              launcher icons and store graphics
docs/privacy.html      privacy policy (served by GitHub Pages)
```

## Adding questions

Add entries to `assets/questions.json`:

```json
{"q": "Your question?", "bots": ["answer 1", "answer 2", "answer 3", "answer 4", "answer 5"]}
```

Each question needs at least 2 bot answers; 5 keeps rounds from repeating.
Write bot answers short and casual, like a text message.
