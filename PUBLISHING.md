# How to publish Human or AI? on Google Play

You don't need Android Studio or any Android knowledge. GitHub builds the app
in the cloud; you only click buttons and upload one file to Google.

**What you need**
- A GitHub account (you have one: AliakbarMehdizadeh)
- A Google account and **$25** for the one-time Play developer fee
- An Android phone for testing and screenshots
- **12 people with Android phones** who will install a test version
- About **3 weeks**: Google makes new personal accounts run a closed test with
  at least 12 testers for 14 days in a row before the app can go public

**Files you got**
- `human_or_ai.zip`: the app code (this folder)
- `upload-keystore.jks` and `HUMAN-OR-AI-SIGNING-SECRETS.txt`: your signing key.
  Keep both private. Never upload them to GitHub as files.

---

## Step 1. Put the code on GitHub (10 min)

1. Go to github.com/new.
2. Repository name: `human-or-ai`. Choose **Public** (needed for the free
   privacy-policy page). Don't add a README. Click **Create repository**.
3. On the empty repo page click **uploading an existing file**.
4. Unzip `human_or_ai.zip`. Open the folder, select **everything inside it**
   and drag it into the browser. Click **Commit changes**.
5. Check that you can see a `.github` folder in the repo. If it's missing
   (Macs hide folders starting with a dot):
   - Click **Add file > Create new file**
   - Name it exactly `.github/workflows/build-android.yml`
   - Paste the contents of `build-android.yml` from the zip and commit.

## Step 2. Add your signing secrets (5 min)

1. In the repo: **Settings > Secrets and variables > Actions >
   New repository secret**.
2. Open `HUMAN-OR-AI-SIGNING-SECRETS.txt` and create the three secrets it lists:
   `KEY_ALIAS`, `KEYSTORE_PASSWORD`, `KEYSTORE_BASE64`.
   (For `KEYSTORE_BASE64`, copy the whole long line.)

## Step 3. Build the app (10 min, mostly waiting)

1. Go to the **Actions** tab. If asked, click **I understand my workflows,
   go ahead and enable them**.
2. Click **Build Android app > Run workflow > Run workflow**.
3. Wait for the green check (about 6-10 minutes). If it turns red, open it,
   copy the error and send it to Claude.
4. Open the finished run, scroll to **Artifacts**, and download
   `human-or-ai-build-N`. Unzip it. Inside:
   - `app-release.apk`: to install on your own phone right now
   - `app-release.aab`: the file you upload to Google Play

**Try it on your phone:** send the `.apk` to your phone (email or Drive),
tap it, and allow "Install unknown apps" when Android asks. Play a round.
Take 3-4 screenshots for the store listing.

## Step 4. Turn on the privacy policy page (2 min)

Google requires a privacy policy link.
1. Repo **Settings > Pages**.
2. Source: **Deploy from a branch**. Branch: **main**, folder: **/docs**. Save.
3. After a minute it's live at
   `https://aliakbarmehdizadeh.github.io/human-or-ai/privacy.html`

## Step 5. Create your Google Play developer account (30 min + waiting)

1. Go to play.google.com/console and sign up.
2. Choose **Personal** account (organization accounts need a D-U-N-S number).
3. Pay $25 and verify your identity with an ID. Google may also ask you to
   verify a phone and confirm you have an Android device.
4. Verification can take a few days.

## Step 6. Create the app in Play Console (30 min)

1. **Create app**. Name: `Human or AI? Party Game`. Language: English.
   App or game: **Game**. Free or paid: **Free**. Accept the declarations.
2. Open **Dashboard** and work through "Set up your app". Everything you need
   to paste or answer is in `STORE_LISTING.md`:
   - Privacy policy URL (from step 4)
   - App access, Ads, Content rating, Target audience, Data safety
   - **Main store listing**: name, descriptions, icon, feature graphic,
     screenshots

## Step 7. Closed test with 12 testers (14 days)

1. **Test and release > Testing > Closed testing > Create track**
   (or use the default "Closed testing - Alpha").
2. **Testers**: create an email list and add at least 12 Gmail addresses
   (friends, family, labmates). Add a few extra in case someone drops out.
3. **Create new release**. Accept **Play App Signing** when offered (Google
   keeps the final signing key; yours is only the upload key). Upload
   `app-release.aab`. Release name: `1.0.0`. Release notes: `First test`.
4. Save, review, **Start rollout to Closed testing**. Google reviews it
   (hours to a few days).
5. Copy the **opt-in link** from the Testers tab and send it to your testers.
   Each one must open it, tap **Become a tester**, and install the app.
6. They must **stay opted in for 14 days straight**. Ask them to play once or
   twice; Google looks at whether testing actually happened.

## Step 8. Go public

1. After 14 days, the Dashboard shows **Apply for production**. Answer the
   questions about your test (how many testers, what feedback, what you
   changed). Short honest answers are fine.
2. Once approved (usually within about a week): **Production > Create new
   release**, add the same `.aab` (or a newer one), roll out.
3. Review takes 1-7 days. Then it's live on Google Play.

---

## Shipping an update later

1. Change the code (or ask Claude to), and bump the version in `pubspec.yaml`
   (for example `1.0.0` to `1.0.1`; leave the `+1` alone, the build sets it).
2. Commit to GitHub. The build runs by itself.
3. Download the new `.aab` from Actions and upload it as a new release.

## Things you should not change

- **App ID** `io.github.aliakbarmehdizadeh.humanorai` (in
  `tool/configure_android.py`). Once you upload to Google, it is permanent.
  If you want a different one, change it **before** your first upload.
- Keep `upload-keystore.jks` and the secrets file somewhere safe (password
  manager or private cloud folder). If lost, Google can reset the upload key,
  but it takes a few days.
