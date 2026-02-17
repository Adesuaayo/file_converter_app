# File Converter Pro — Deployment & Build Guide

> **Enterprise-grade Flutter File Converter Application**
> Version 1.0.0 | Target: Android 6.0+ / iOS 14.0+

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Environment Setup](#environment-setup)
3. [Project Setup](#project-setup)
4. [Development Build](#development-build)
5. [Release Build — Android](#release-build--android)
6. [Release Build — iOS](#release-build--ios)
7. [AdMob Configuration](#admob-configuration)
8. [In-App Purchase Setup](#in-app-purchase-setup)
9. [Play Store Submission](#play-store-submission)
10. [App Store Submission](#app-store-submission)
11. [CI/CD Pipeline](#cicd-pipeline)
12. [Troubleshooting](#troubleshooting)

---

## Prerequisites

| Tool | Minimum Version | Purpose |
|------|----------------|---------|
| Flutter SDK | 3.16.0+ | Framework |
| Dart SDK | 3.2.0+ | Language (bundled with Flutter) |
| Android Studio | 2023.1+ | Android build toolchain |
| Xcode | 15.0+ | iOS build toolchain (macOS only) |
| CocoaPods | 1.14.0+ | iOS dependency management |
| Java JDK | 17 | Android Gradle builds |
| Git | 2.0+ | Version control |

---

## Environment Setup

### 1. Install Flutter SDK

```bash
# macOS / Linux
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Windows (PowerShell)
git clone https://github.com/flutter/flutter.git -b stable
$env:PATH += ";$(Get-Location)\flutter\bin"

# Verify installation
flutter doctor -v
```

### 2. Verify Environment

```bash
flutter doctor
```

Ensure all checkmarks pass for your target platforms. Resolve any issues before proceeding.

---

## Project Setup

### 1. Clone & Install Dependencies

```bash
cd file_converter_app
flutter pub get
```

### 2. Generate Code (Hive TypeAdapters)

The Hive TypeAdapter is pre-generated in `conversion_history_model.g.dart`. If you modify any `@HiveType` or `@HiveField` annotations, regenerate:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Run Analysis

```bash
flutter analyze
```

### 4. Run Tests

```bash
# Unit tests
flutter test

# Unit tests with coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## Development Build

### Android (Debug)

```bash
# Run on connected device or emulator
flutter run

# Run with verbose logging
flutter run --verbose

# Run on specific device
flutter devices                    # List available devices
flutter run -d <device_id>
```

### iOS (Debug) — macOS Only

```bash
cd ios && pod install && cd ..
flutter run -d <ios_device_or_simulator>
```

---

## Release Build — Android

### Step 1: Create Release Keystore

```bash
keytool -genkey -v \
  -keystore release-keystore.jks \
  -storetype JKS \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias file_converter_pro
```

**IMPORTANT**: Store this keystore securely. If lost, you cannot update your app on the Play Store.

### Step 2: Configure Signing

Edit `android/key.properties`:

```properties
storePassword=YOUR_ACTUAL_PASSWORD
keyPassword=YOUR_ACTUAL_KEY_PASSWORD
keyAlias=file_converter_pro
storeFile=../release-keystore.jks
```

**NEVER commit `key.properties` or `*.jks` files to version control.**

### Step 3: Build App Bundle (Recommended)

```bash
# App Bundle — preferred for Google Play (smaller download)
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

### Step 4: Build APK (Alternative)

```bash
# Fat APK (all architectures)
flutter build apk --release

# Split APKs by ABI (smaller individual files)
flutter build apk --release --split-per-abi

# Output: build/app/outputs/flutter-apk/
#   app-armeabi-v7a-release.apk    (~15-20 MB)
#   app-arm64-v8a-release.apk      (~16-22 MB)
#   app-x86_64-release.apk         (~17-23 MB)
```

### Step 5: Test Release Build

```bash
# Install release APK on device
flutter install --release

# Or manually
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Step 6: Verify Obfuscation (Optional)

```bash
flutter build appbundle --release --obfuscate --split-debug-info=debug-info/
```

Keep the `debug-info/` folder — it's needed to symbolicate crash reports.

---

## Release Build — iOS

### Step 1: Apple Developer Account

1. Enroll in the [Apple Developer Program](https://developer.apple.com/programs/) ($99/year)
2. Create an App ID in [App Store Connect](https://appstoreconnect.apple.com)
3. Create provisioning profiles (Development + Distribution)

### Step 2: Xcode Configuration

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the **Runner** target
3. Under **Signing & Capabilities**:
   - Select your Development Team
   - Set Bundle Identifier to `com.fileconverter.pro`
   - Ensure "Automatically manage signing" is checked
4. Under **General**:
   - Set Version to `1.0.0`
   - Set Build to `1`

### Step 3: Build IPA

```bash
# Install pods
cd ios && pod install && cd ..

# Build release IPA
flutter build ipa --release

# Output: build/ios/ipa/File Converter Pro.ipa
```

### Step 4: Upload to App Store Connect

```bash
# Option A: Using Xcode (recommended)
# Open build/ios/archive/Runner.xcarchive in Xcode
# Select "Distribute App" → "App Store Connect"

# Option B: Using xcrun
xcrun altool --upload-app \
  --file "build/ios/ipa/File Converter Pro.ipa" \
  --type ios \
  --apiKey YOUR_API_KEY \
  --apiIssuer YOUR_ISSUER_ID
```

---

## AdMob Configuration

### Step 1: Create AdMob Account

1. Go to [Google AdMob](https://admob.google.com)
2. Create an account and add your app (Android + iOS)
3. Note the **App IDs** and **Ad Unit IDs**

### Step 2: Replace Test IDs

Replace placeholder IDs in these files:

| File | Key | Current (Test) Value |
|------|-----|---------------------|
| `AndroidManifest.xml` | `com.google.android.gms.ads.APPLICATION_ID` | `ca-app-pub-3940256099942544~3347511713` |
| `Info.plist` | `GADApplicationIdentifier` | `ca-app-pub-3940256099942544~1458002511` |
| `lib/core/constants/app_constants.dart` | `bannerAdUnitIdAndroid` | `ca-app-pub-3940256099942544/6300978111` |
| `lib/core/constants/app_constants.dart` | `bannerAdUnitIdIos` | `ca-app-pub-3940256099942544/2934735716` |
| `lib/core/constants/app_constants.dart` | `interstitialAdUnitIdAndroid` | `ca-app-pub-3940256099942544/1033173712` |
| `lib/core/constants/app_constants.dart` | `interstitialAdUnitIdIos` | `ca-app-pub-3940256099942544/4411468910` |

**WARNING**: Never ship with test ad unit IDs. Google will flag your app.

### Step 3: Configure Ad Mediation (Optional)

For higher revenue, set up mediation in AdMob console to include:
- Meta Audience Network
- Unity Ads
- AppLovin

Add corresponding SKAdNetwork IDs to `Info.plist`.

---

## In-App Purchase Setup

### Google Play (Android)

1. **Google Play Console** → Your App → **Monetize** → **Products** → **Subscriptions**
2. Create a subscription with ID: `file_converter_premium_monthly`
3. Create a subscription with ID: `file_converter_premium_yearly`
4. Set pricing tiers and trial periods
5. Activate the products

### App Store Connect (iOS)

1. **App Store Connect** → Your App → **Features** → **In-App Purchases**
2. Create subscriptions:
   - Product ID: `file_converter_premium_monthly` (Auto-Renewable)
   - Product ID: `file_converter_premium_yearly` (Auto-Renewable)
3. Create a Subscription Group: "File Converter Premium"
4. Set pricing in all territories
5. Submit for review

### Testing

```
# Android — Use test accounts in Google Play Console
# Add test email in: Google Play Console → Settings → License Testing

# iOS — Use Sandbox tester accounts
# Create in: App Store Connect → Users and Access → Sandbox Testers
```

---

## Play Store Submission

### Pre-Submission Checklist

- [ ] Replace all test AdMob IDs with production IDs
- [ ] Set `versionCode` and `versionName` in `build.gradle`
- [ ] Create release keystore and configure `key.properties`
- [ ] Build signed App Bundle: `flutter build appbundle --release`
- [ ] Test release build on physical device
- [ ] Prepare Play Store listing assets:
  - App icon (512x512 PNG)
  - Feature graphic (1024x500 PNG)
  - Phone screenshots (min 2, 16:9 ratio recommended)
  - 7-inch tablet screenshots (optional but recommended)
  - 10-inch tablet screenshots (optional but recommended)
  - Short description (80 chars max)
  - Full description (4000 chars max)
- [ ] Set content rating (complete questionnaire)
- [ ] Set app categorization (Tools > File Manager)
- [ ] Configure pricing & distribution (Free with IAP)
- [ ] Set up Privacy Policy URL
- [ ] Data safety section completed
- [ ] Set target audience (13+)
- [ ] Set up IAP products and activate them

### Upload to Play Store

1. Go to [Google Play Console](https://play.google.com/console)
2. Create new app → "File Converter Pro"
3. Complete Store Listing (title, description, screenshots)
4. Upload AAB to **Production** track (or Internal Testing first)
5. Complete Content Rating questionnaire
6. Set pricing to "Free" (contains in-app purchases)
7. Review and publish

---

## App Store Submission

### Pre-Submission Checklist

- [ ] Replace all test AdMob IDs with production IDs
- [ ] Set version and build numbers in Xcode
- [ ] Build and archive: `flutter build ipa --release`
- [ ] Test on physical iOS device
- [ ] Prepare App Store listing assets:
  - 6.7" iPhone screenshots (1290 x 2796)
  - 6.5" iPhone screenshots (1242 x 2688)
  - 5.5" iPhone screenshots (1242 x 2208)
  - iPad Pro 12.9" screenshots (2048 x 2732)
  - App icon (1024x1024, no transparency, no rounded corners)
- [ ] Write App Review Information (test account if applicable)
- [ ] Privacy Policy URL
- [ ] App Privacy Questionnaire (data collection types)
- [ ] In-App Purchase products created and submitted for review

### Upload to App Store

1. Upload via Xcode Organizer or `xcrun altool`
2. In App Store Connect, select the build
3. Complete App Information, Pricing, Privacy sections
4. Submit for Review

### Common App Store Rejection Reasons (Avoid These)

| Reason | Prevention |
|--------|-----------|
| Crashes on launch | Test release build on physical device |
| Missing privacy policy | Host policy at a public URL |
| Incomplete metadata | Fill all required fields |
| Guideline 2.1 — App Completeness | Ensure all features work, provide test credentials |
| Guideline 3.1.1 — IAP | Use Apple's IAP for digital content (not Stripe/PayPal) |
| Guideline 5.1.1 — Data Collection | Complete privacy questionnaire accurately |

---

## CI/CD Pipeline

### GitHub Actions (Recommended)

Create `.github/workflows/flutter.yml`:

```yaml
name: Flutter CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  analyze-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          channel: 'stable'

      - name: Install dependencies
        run: flutter pub get

      - name: Analyze
        run: flutter analyze

      - name: Run tests
        run: flutter test --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info

  build-android:
    needs: analyze-and-test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          channel: 'stable'

      - name: Decode keystore
        run: echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > android/release-keystore.jks

      - name: Create key.properties
        run: |
          echo "storePassword=${{ secrets.KEYSTORE_PASSWORD }}" > android/key.properties
          echo "keyPassword=${{ secrets.KEY_PASSWORD }}" >> android/key.properties
          echo "keyAlias=${{ secrets.KEY_ALIAS }}" >> android/key.properties
          echo "storeFile=../release-keystore.jks" >> android/key.properties

      - name: Build App Bundle
        run: flutter build appbundle --release

      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: app-release.aab
          path: build/app/outputs/bundle/release/app-release.aab

  build-ios:
    needs: analyze-and-test
    runs-on: macos-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          channel: 'stable'

      - name: Install CocoaPods
        run: cd ios && pod install

      - name: Build IPA
        run: flutter build ipa --release --export-options-plist=ios/ExportOptions.plist

      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: app-release.ipa
          path: build/ios/ipa/*.ipa
```

---

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|---------|
| `Gradle build failed` | Run `cd android && ./gradlew clean && cd ..` then try again |
| `CocoaPods not found` | `sudo gem install cocoapods` or `brew install cocoapods` |
| `Pod install failed` | `cd ios && pod repo update && pod install && cd ..` |
| `Hive TypeAdapter not found` | `flutter pub run build_runner build --delete-conflicting-outputs` |
| `AdMob not showing ads` | Verify App ID in manifest/plist; ads may take 1-2 hours to serve |
| `IAP products not loading` | Ensure products are "Active" in Store Console; check signing |
| `Multidex error` | Already configured; verify `multiDexEnabled true` in `build.gradle` |
| `R8/ProGuard crash` | Check `proguard-rules.pro` for missing keep rules |
| `iOS archive fails` | Open `.xcworkspace` (not `.xcodeproj`), check signing |
| `Permission denied on Android 13+` | Using scoped storage; verify `READ_MEDIA_IMAGES` permission |

### Debug Commands

```bash
# Verbose Flutter logs
flutter run --verbose

# Android logcat
adb logcat -s flutter

# iOS device logs
idevicesyslog | grep Flutter

# Dart DevTools
flutter pub global activate devtools
dart devtools
```

---

## Project Architecture Reference

```
lib/
├── main.dart                           # App entry point
├── injection_container.dart            # DI with get_it
├── core/
│   ├── constants/                      # App-wide constants
│   ├── error/                          # Exception & Failure types
│   ├── theme/                          # Material 3 theme
│   ├── utils/                          # File utils, isolate helpers
│   └── services/                       # File picker, permissions
└── features/
    ├── file_conversion/
    │   ├── domain/                     # Entities, repos (abstract), use cases
    │   ├── data/                       # Models, datasources, repo impl
    │   └── presentation/              # BLoC, pages, widgets
    └── monetization/
        ├── domain/                     # Premium entities, repos, use cases
        ├── data/                       # Ads datasource, repo impl
        └── presentation/              # Monetization BLoC, ad widgets, premium page
```

---

## License

Proprietary — All rights reserved.

---

*Generated for File Converter Pro v1.0.0*
