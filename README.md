# Load Tax Calculator Pakistan

## 1. Setup
```bash
flutter create --org com.yourname --project-name loadtaxpk --platforms android .
# say "no" if asked to overwrite lib/main.dart, pubspec.yaml (or copy them back after)
flutter pub get
flutter run
```
Set the app name in `android/app/src/main/AndroidManifest.xml`:
`android:label="Load Tax Calculator Pakistan"`

Release builds have no INTERNET permission (Flutter adds it only for debug). Do not add any.

## 2. Icon
Put a 1024x1024 `assets/icon/icon.png` and a transparent `assets/icon/icon_foreground.png`, then:
```bash
dart run flutter_launcher_icons
```
Use your own artwork. No telecom logos.

## 3. Signing + AAB
```bash
keytool -genkey -v -keystore ~/loadtaxpk-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
Create `android/key.properties` (never commit it):
```
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=upload
storeFile=/home/you/loadtaxpk-upload.jks
```
In `android/app/build.gradle.kts` (older projects: `build.gradle`), add at the top:
```kotlin
import java.util.Properties
import java.io.FileInputStream
val keystoreProperties = Properties().apply {
    val f = rootProject.file("key.properties")
    if (f.exists()) load(FileInputStream(f))
}
```
and inside `android { }`:
```kotlin
signingConfigs {
    create("release") {
        keyAlias = keystoreProperties["keyAlias"] as String
        keyPassword = keystoreProperties["keyPassword"] as String
        storeFile = file(keystoreProperties["storeFile"] as String)
        storePassword = keystoreProperties["storePassword"] as String
    }
}
buildTypes { getByName("release") { signingConfig = signingConfigs.getByName("release") } }
```
Build:
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`. Back up the .jks file safely.
Target SDK follows your Flutter version; run `flutter upgrade` first so it meets Play's current requirement.

## 4. Upload to Google Play
1. Create a developer account at play.google.com/console (one-time $25).
2. Create app -> name, language, App, Free.
3. Complete App content: Privacy policy URL, Ads = No, Data safety = no data collected, Content rating questionnaire, Target audience (13+/all).
4. Store listing: paste text below, add icon 512x512, feature graphic 1024x500, 2+ phone screenshots.
5. Production (or Internal testing first) -> Create release -> upload .aab -> Save -> Review -> Roll out.
6. New personal accounts may need closed testing (12+ testers, 14 days) before production. Check the Console's current rules.

## 5. Store listing
**Title:** Load Tax Calculator Pakistan

**Short description:** See your real balance after tax on Jazz, Zong, Ufone, Telenor and SCO load.

**Full description:**
Ever wondered why Rs 100 load doesn't give you Rs 100 balance?

Load Tax Calculator Pakistan shows exactly how much usable balance you get after advance income tax and sales tax, and how much tax was deducted.

HOW IT WORKS
1. Enter your load amount.
2. Tap "Calculate Original Balance".
3. Instantly see your balance and total tax deducted.

FEATURES
- Works for Jazz, Zong, Ufone, Telenor and SCO
- Tax breakdown: income tax and sales tax
- Reverse calculator: find how much load to buy for the balance you want
- Editable tax rates when the budget changes
- English and Urdu, light and dark mode
- Fully offline, no login, no ads, no data collected

Estimates only. Actual deduction may vary by network and current tax rates. Not affiliated with any telecom company.

## 6. Privacy policy (host on any public URL, e.g. GitHub Pages)
Load Tax Calculator Pakistan does not collect, store, or share any personal data. All calculations happen on your device. Your settings (tax rates, theme, language) are stored locally on your phone only. The app does not use the internet, analytics, or advertising. Contact: your-email@example.com. Last updated: November 2026.
