# File Converter Pro — Release Checklist

Use this checklist before every production release.

---

## 1. Signing Key (one-time setup)

- [ ] Generate an upload keystore:
  ```bash
  keytool -genkey -v -keystore release.keystore \
    -alias upload -keyalg RSA -keysize 2048 -validity 10000
  ```
- [ ] Create `android/key.properties` locally (**never commit this**):
  ```properties
  storePassword=YOUR_PASSWORD
  keyPassword=YOUR_PASSWORD
  keyAlias=upload
  storeFile=release.keystore
  ```
- [ ] Add **GitHub Secrets** (Settings → Secrets → Actions):
  | Secret | Value |
  |--------|-------|
  | `KEYSTORE_BASE64` | `base64 -w 0 release.keystore` output |
  | `KEY_PROPERTIES` | Contents of `android/key.properties` |
- [ ] Verify `android/app/build.gradle.kts` reads `key.properties` ✅ (already done)

---

## 2. AdMob — Production Ad IDs

Replace test IDs in `lib/core/constants/app_constants.dart`:

| Constant | Test value (current) | Replace with |
|----------|---------------------|--------------|
| `admobAppIdAndroid` | `ca-app-pub-3940256099942544~3347511713` | Your real App ID |
| `bannerAdUnitIdAndroid` | `ca-app-pub-3940256099942544/6300978111` | Your real banner ID |
| `interstitialAdUnitIdAndroid` | `ca-app-pub-3940256099942544/1033173712` | Your real interstitial ID |

Also update `AndroidManifest.xml` meta-data `com.google.android.gms.ads.APPLICATION_ID`.

> **Tip:** Keep test IDs on `main` branch; swap to real IDs only on the release tag branch or via CI environment variable override.

---

## 3. In-App Purchase — Play Console Products

Create these products in **Google Play Console → Monetize → Subscriptions**:

| Product ID | Type | Price |
|------------|------|-------|
| `premium_weekly` | Subscription (weekly) | ₦500 |
| `premium_monthly` | Subscription (monthly) | ₦1,500 |
| `premium_yearly` | Subscription (yearly) | ₦12,000 |

- [ ] Create all 3 subscription products in Play Console
- [ ] Set free trial period (optional — e.g. 3-day trial for weekly)
- [ ] Add license testers (Play Console → Settings → License testing)
- [ ] Test purchase flow end-to-end with a license tester account

---

## 4. Version Bump

Update version in `pubspec.yaml` before tagging:

```yaml
version: 1.0.0+1    # format: semver+buildNumber
```

- **versionName** = `1.0.0` (shown to users in Play Store)
- **versionCode** = `1` (integer, must increase on every upload)

Bump with the helper script:
```powershell
# Example: bump to v1.0.1 build 2
powershell -File scripts/bump_version.ps1 -Version "1.0.1" -Build 2
```

---

## 5. Build & Release

```bash
# Push a version tag to trigger CI release pipeline
git tag v1.0.0
git push origin v1.0.0
```

CI will automatically:
1. Run analysis + tests
2. Build signed release APK (split per ABI) + AAB
3. Create a GitHub Release with all artifacts attached

---

## 6. Play Store Submission

- [ ] Download `app-release.aab` from GitHub Release artifacts
- [ ] Upload to Play Console → Production (or Internal Testing first)
- [ ] Fill in store listing:
  - App name: **File Converter Pro**
  - Short description (80 chars)
  - Full description (4000 chars)
  - Feature graphic (1024×500 px)
  - Screenshots (phone: min 2, tablet: optional)
  - App icon (512×512 px, already in mipmap folders)
- [ ] Content rating questionnaire
- [ ] Data safety form
- [ ] Target audience & content
- [ ] Set pricing: **Free** (with in-app purchases)
- [ ] Select countries for distribution

---

## 7. Pre-Launch QA Checklist

### Conversions
- [ ] PDF → TXT: small file, large file, scanned PDF
- [ ] PDF → DOCX
- [ ] DOCX → PDF
- [ ] Image → PDF (single and batch)
- [ ] PDF → Images
- [ ] Image resize / format conversion

### Monetization
- [ ] Free tier: 5 conversions/day limit enforced
- [ ] Counter resets at midnight
- [ ] Subscription purchase flows (weekly/monthly/yearly)
- [ ] Premium unlocks unlimited conversions
- [ ] Ads show for free users, hidden for premium
- [ ] Banner ad loads on home screen
- [ ] Interstitial ad shows after conversion (free tier)

### UI/UX
- [ ] Splash screen shows branded blue screen with icon
- [ ] App icon shows document + arrows (not Flutter logo)
- [ ] Conversion success view displays properly (not stuck)
- [ ] History page shows all past conversions
- [ ] Output directory button opens file manager
- [ ] Share button works on converted files
- [ ] Dark mode works correctly
- [ ] Privacy Policy page accessible
- [ ] Terms of Use page accessible

### Edge Cases
- [ ] No internet: app works for conversions (offline)
- [ ] Permission denied: graceful error message
- [ ] Empty/corrupt file: clear error, no crash
- [ ] Very large file (>50MB): handles or shows size limit
- [ ] Back button: proper navigation, no state loss
- [ ] App kill + restart: state preserved via Hive

---

## 8. Post-Launch

- [ ] Monitor crash reports (add Firebase Crashlytics in future)
- [ ] Monitor ad revenue in AdMob dashboard
- [ ] Monitor subscription metrics in Play Console
- [ ] Respond to user reviews
- [ ] Plan v1.1.0 features based on feedback
