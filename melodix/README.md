# 🎵 Melodix — Premium Music Player

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.19-02569B?style=for-the-badge&logo=flutter" />
  <img src="https://img.shields.io/badge/Android-5.0+-3DDC84?style=for-the-badge&logo=android" />
  <img src="https://img.shields.io/badge/YouTube_Music-API-FF0000?style=for-the-badge&logo=youtube" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" />
</p>

A Spotify-inspired Android music player powered by YouTube Music. Stream millions of songs for free with background playback, offline downloads, lyrics, a 10-band equalizer, and a rotating vinyl player UI.

---

## ✨ Features

| Category | Features |
|---|---|
| 🎵 **Streaming** | YouTube Music API, 320kbps audio, auto quality |
| 🎨 **Player UI** | Rotating vinyl disc, dynamic color from album art |
| 📥 **Downloads** | Save songs locally, manage from Downloads tab |
| 📋 **Library** | Playlists, Liked Songs, Recently Played |
| 🎤 **Lyrics** | Fetched live from YouTube Music |
| 🎚️ **Equalizer** | 10-band EQ, 12 presets (Rock, Pop, Bass Boost…) |
| 🔁 **Playback** | Shuffle, Repeat One/All, Crossfade, Sleep Timer |
| ⏩ **Speed** | 0.25× to 3× playback speed |
| 🔔 **Notifications** | Lock screen controls, media session |
| 🌙 **Theme** | Dark (default) / Light mode |
| 📱 **Queue** | Drag-to-reorder, live queue management |

---

## 📂 Project Structure

```
melodix/
├── lib/
│   ├── main.dart                    # Entry point
│   ├── theme/app_theme.dart         # Colors & typography
│   ├── router/app_router.dart       # GoRouter navigation
│   ├── models/
│   │   ├── song_model_clean.dart    # Song data + Hive adapter
│   │   └── playlist_model.dart      # Playlist data + Hive adapter
│   ├── services/
│   │   ├── youtube_music_service.dart  # YT Music API + search
│   │   ├── audio_player_service.dart   # just_audio + background
│   │   └── download_service.dart       # Offline download manager
│   ├── providers/
│   │   ├── audio_provider.dart      # Riverpod audio state
│   │   ├── search_provider.dart     # Search & home feed state
│   │   ├── playlist_provider.dart   # Playlist & liked songs
│   │   └── theme_provider.dart      # Dark/light theme
│   ├── screens/
│   │   ├── home_screen.dart         # Home feed + quick access
│   │   ├── search_screen.dart       # Search + genre browse
│   │   ├── player_screen.dart       # Full-screen player
│   │   ├── library_screen.dart      # Playlists & liked songs
│   │   ├── playlist_screen.dart     # Playlist detail
│   │   ├── downloads_screen.dart    # Offline songs
│   │   ├── lyrics_screen.dart       # Full lyrics view
│   │   ├── equalizer_screen.dart    # 10-band EQ
│   │   ├── settings_screen.dart     # App settings
│   │   └── onboarding_screen.dart   # First-launch walkthrough
│   └── widgets/
│       ├── song_tile.dart           # List song item
│       └── song_card.dart           # Card (horizontal scroll)
├── android/
│   └── app/src/main/
│       ├── AndroidManifest.xml      # Permissions + services
│       └── kotlin/.../MainActivity.kt
├── .github/workflows/build.yml      # ← GitHub Actions (auto-build APK)
└── pubspec.yaml                     # Dependencies
```

---

## 🚀 Build the APK — No Local Install Needed

> **You don't need Flutter, Java, or Android SDK on your PC.**  
> GitHub Actions builds the APK for free in the cloud. Follow these steps exactly.

---

### Method 1 — GitHub Actions (Recommended, Zero Install)

#### Step 1 — Create a GitHub Account
Go to [github.com](https://github.com) and sign up for a free account if you don't have one.

#### Step 2 — Create a New Repository
1. Click the **+** icon (top-right) → **New repository**
2. Name it: `melodix`
3. Set to **Public** (free Actions minutes)
4. Do **NOT** check "Add README" (we have our own)
5. Click **Create repository**

#### Step 3 — Upload the Project Files
You have two options here:

**Option A — GitHub Web Upload (No Git needed)**
1. On your new repo page, click **uploading an existing file**
2. Open the `melodix/` folder on your computer
3. Select **ALL files and folders** and drag them into the GitHub upload area
4. ⚠️ GitHub web upload doesn't support folders — use Option B or the zip method below

**Option B — GitHub Desktop (Easiest for folders)**
1. Download [GitHub Desktop](https://desktop.github.com) — it's a GUI, no command line needed
2. Sign in with your GitHub account
3. Click **File → Clone Repository** → find `melodix`
4. Copy all project files into the cloned folder on your computer
5. In GitHub Desktop: you'll see all files listed as changes
6. Write a commit message (e.g. "Initial upload") → click **Commit to main**
7. Click **Push origin**

**Option C — Upload as ZIP via GitHub**
1. Zip the entire `melodix/` folder → `melodix.zip`
2. In your repo, go to **Code** tab
3. Use the GitHub web editor: press `.` (dot key) to open VS Code in browser
4. Drag and drop the unzipped files into the browser editor
5. Commit via the Source Control panel on the left

#### Step 4 — Trigger the Build
Once your files are pushed:

1. Go to your repo on GitHub
2. Click the **Actions** tab
3. You'll see **"Build Melodix APK"** workflow
4. If it didn't start automatically, click on it → **Run workflow** → **Run workflow**
5. ⏳ Wait 5–10 minutes for the build to complete

#### Step 5 — Download the APK
When the workflow shows a green ✅:

1. Click on the completed workflow run
2. Scroll down to **Artifacts**
3. Download **`melodix-universal-apk`** (works on all phones)  
   — or download `melodix-split-apks` and pick `app-arm64-v8a-release.apk` for modern phones

> Alternatively, if the workflow pushed to the **Releases** section, go to:  
> `github.com/YOUR_USERNAME/melodix/releases` and download from there.

#### Step 6 — Install on Android
1. Transfer the APK to your Android phone (USB, email, Google Drive, WhatsApp to yourself)
2. On your phone: **Settings → Security → Install unknown apps** → allow your file manager or browser
3. Open the APK file → **Install**
4. Open **Melodix** 🎵

---

### Method 2 — Gitpod (Online IDE, No Local Install)

Gitpod gives you a full Linux environment in your browser.

1. Go to [gitpod.io](https://gitpod.io) → **Sign in with GitHub**
2. Open your `melodix` repo URL prefixed with `gitpod.io/#`:  
   `https://gitpod.io/#https://github.com/YOUR_USERNAME/melodix`
3. Wait for the workspace to load
4. In the terminal that opens, run:
   ```bash
   # Install Flutter
   git clone https://github.com/flutter/flutter.git -b stable ~/flutter
   export PATH="$PATH:$HOME/flutter/bin"
   flutter doctor

   # Build
   flutter pub get
   flutter build apk --release

   # APK is at:
   ls build/app/outputs/flutter-apk/app-release.apk
   ```
5. Right-click `app-release.apk` in the file explorer → **Download**

---

### Method 3 — Replit (Alternative Online IDE)

1. Go to [replit.com](https://replit.com) → Create a new **Bash** repl
2. In the Shell tab, run:
   ```bash
   # Install Flutter
   wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.19.6-stable.tar.xz
   tar xf flutter_linux_3.19.6-stable.tar.xz
   export PATH="$PATH:$PWD/flutter/bin"

   # Clone your repo
   git clone https://github.com/YOUR_USERNAME/melodix.git
   cd melodix

   # Install Android SDK (cmdline-tools)
   wget https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip
   unzip commandlinetools-linux-*.zip -d android-sdk
   export ANDROID_SDK_ROOT=$PWD/android-sdk
   yes | $ANDROID_SDK_ROOT/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_SDK_ROOT \
     "platform-tools" "platforms;android-34" "build-tools;34.0.0"

   flutter config --android-sdk $ANDROID_SDK_ROOT
   flutter pub get
   flutter build apk --release
   ```

---

### Method 4 — Codemagic CI/CD (Dedicated Mobile Build Service)

Codemagic is purpose-built for Flutter apps. Free tier included.

1. Go to [codemagic.io](https://codemagic.io) → **Sign up with GitHub**
2. Click **Add application** → select your `melodix` repo
3. Choose **Flutter App**
4. Under **Build** settings:
   - Build for: **Android**
   - Mode: **Release**
   - Build format: **APK**
5. Click **Start new build**
6. Download the APK from the **Artifacts** section when done

---

## 📋 GitHub Actions Workflow Explained

The file `.github/workflows/build.yml` does this automatically on every push:

```
Push to GitHub
     │
     ▼
Ubuntu runner starts
     │
     ▼
Java 17 installed
     │
     ▼
Flutter 3.19.6 installed
     │
     ▼
flutter pub get  (downloads all dependencies)
     │
     ▼
flutter build apk --release --split-per-abi
     │  (creates arm64, armeabi-v7a, x86_64 APKs)
     ▼
flutter build apk --release
     │  (creates universal APK)
     ▼
Upload to GitHub Artifacts (downloadable for 30 days)
     │
     ▼
Create GitHub Release with all APKs attached
```

**Total build time:** ~6–10 minutes  
**Cost:** Free (GitHub gives 2,000 free Actions minutes/month for public repos; unlimited for public repos)

---

## 🔧 Troubleshooting

### ❌ "Workflow not found"
Make sure the file is at exactly: `.github/workflows/build.yml`  
The `.github` folder must be at the root of your repo.

### ❌ "Gradle build failed"
Check the Actions log for the exact error. Common fixes:
- Make sure `android/local.properties` is NOT committed (it's in `.gitignore`) — GitHub Actions generates it automatically
- If you see `minSdkVersion` errors, the `build.gradle` already sets it to 21

### ❌ "Package not found" errors
Run the build again — sometimes pub.dev has temporary outages.  
You can also try adding this to `pubspec.yaml` to pin a working resolver:
```yaml
dependency_overrides:
  collection: ^1.18.0
```

### ❌ APK installs but crashes on launch
Enable **Unknown sources** in Android settings first.  
On Android 8+: Settings → Apps → Special app access → Install unknown apps.

### ❌ "No stream URL" / songs don't play
YouTube occasionally changes their API internals. The app uses `youtube_explode_dart` which is actively maintained. Update to the latest version:
```yaml
youtube_explode_dart: ^2.2.0  # bump this if needed
```

### ❌ Downloads don't save
On Android 10+, the app saves to `/storage/emulated/0/Music/Melodix/`.  
Grant **Storage permission** from phone Settings → Apps → Melodix → Permissions.

---

## 📱 Compatibility

| Android Version | Support |
|---|---|
| Android 5.0 (Lollipop) | ✅ Minimum supported |
| Android 6–9 | ✅ Full support |
| Android 10–12 | ✅ Full support |
| Android 13–14 | ✅ Full support (new media permissions) |

**Recommended:** Android 9+ for best background playback experience.

---

## 🎨 Customization

### Change App Name
Edit `android/app/src/main/AndroidManifest.xml`:
```xml
android:label="YourAppName"
```

### Change Package ID
Edit `android/app/build.gradle`:
```groovy
applicationId "com.yourname.yourapp"
```
Also update `AndroidManifest.xml` `package=` attribute.

### Change Primary Color
Edit `lib/theme/app_theme.dart`:
```dart
static const primary = Color(0xFF1DB954);  // change this hex
```

### Add Font
1. Put `.ttf`/`.otf` files in `assets/fonts/`
2. Register in `pubspec.yaml` under `flutter: fonts:`
3. Update `fontFamily` in `app_theme.dart`

---

## 🛡️ Legal Notes

- This app uses the **YouTube Data API** and `youtube_explode_dart` to access publicly available YouTube content
- It does **not** bypass DRM or distribute copyrighted content
- For personal use only
- YouTube's Terms of Service prohibit downloading videos for redistribution; use the download feature for personal offline listening only
- This is an open-source project not affiliated with YouTube, Google, or Spotify

---

## 📄 License

MIT License — see `LICENSE` file.

---

<p align="center">Built with ❤️ using Flutter · Powered by YouTube Music</p>
