# File Converter Pro

> Enterprise-grade cross-platform file converter built with Flutter, Clean Architecture, and BLoC.

[![Flutter](https://img.shields.io/badge/Flutter-3.16+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.2+-0175C2?logo=dart)](https://dart.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean-brightgreen)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
[![State](https://img.shields.io/badge/State-BLoC-blue)](https://bloclibrary.dev)

---

## Features

### File Conversion
- **DOCX → PDF** — Word documents to PDF with text extraction
- **PDF → TXT** — Extract text content from PDF files
- **TXT → PDF** — Plain text to formatted PDF documents
- **Images → PDF** — Combine multiple images into a single PDF
- **PDF → Images** — Convert PDF pages to PNG/JPG images
- **Batch Conversion** — Convert up to 10 files simultaneously

### Architecture & Engineering
- **Clean Architecture** with strict layer separation (Domain → Data → Presentation)
- **BLoC Pattern** for predictable, testable state management
- **Repository Pattern** with abstract interfaces for dependency inversion
- **Either-based Error Handling** (dartz) — no exceptions leak across layers
- **Isolate Processing** — heavy file operations run off the main thread
- **Material 3** UI with dynamic light/dark theming

### Monetization
- **Freemium Model** — 5 free conversions/day, 50MB file size limit
- **Google AdMob** — Banner + interstitial ads for free tier
- **In-App Purchases** — Monthly and yearly premium subscriptions
- **Premium Features** — Unlimited conversions, no ads, priority processing

### Platform Support
- **Android** 6.0+ (API 23+) with scoped storage and Android 13+ permissions
- **iOS** 14.0+ with StoreKit IAP and App Tracking Transparency

---

## Quick Start

```bash
# Install dependencies
flutter pub get

# Generate Hive TypeAdapters (if modified)
flutter pub run build_runner build --delete-conflicting-outputs

# Run in debug mode
flutter run

# Run analysis
flutter analyze

# Run tests
flutter test
```

---

## Build for Release

```bash
# Android App Bundle
flutter build appbundle --release

# Android APK (split by ABI)
flutter build apk --release --split-per-abi

# iOS IPA
flutter build ipa --release
```

See [DEPLOYMENT.md](DEPLOYMENT.md) for complete build, signing, and store submission instructions.

---

## Architecture

```
lib/
├── main.dart                    # Entry point + BLoC providers
├── injection_container.dart     # Dependency injection (get_it)
├── core/
│   ├── constants/               # App & conversion constants
│   ├── error/                   # Exceptions + Failure types
│   ├── theme/                   # Material 3 theming
│   ├── utils/                   # File utilities, isolate helpers
│   └── services/                # File service, permission service
└── features/
    ├── file_conversion/
    │   ├── domain/              # Entities, repositories, use cases
    │   ├── data/                # Models, datasources, repository impl
    │   └── presentation/        # BLoC, pages, widgets
    └── monetization/
        ├── domain/              # Premium entities, use cases
        ├── data/                # Ads datasource, IAP repository
        └── presentation/        # Monetization BLoC, ad widgets
```

---

## Tech Stack

| Category | Technology |
|----------|-----------|
| Framework | Flutter 3.16+ |
| Language | Dart 3.2+ (null safety) |
| State Management | flutter_bloc 8.1+ |
| DI | get_it 7.6+ |
| Local Storage | Hive 2.2+ |
| Error Handling | dartz (Either monad) |
| PDF Creation | pdf 3.10+ |
| PDF Rendering | pdfx 2.6+ |
| DOCX Parsing | archive + xml |
| Image Processing | image 4.1+ |
| Ads | google_mobile_ads 4.0+ |
| IAP | in_app_purchase 3.1+ |
| File Picker | file_picker 6.1+ |

---

## Configuration

Before deploying to production, update these values:

1. **AdMob IDs** — Replace test IDs in `AndroidManifest.xml`, `Info.plist`, and `app_constants.dart`
2. **IAP Product IDs** — Match IDs in `app_constants.dart` with Play Store / App Store Connect
3. **Signing** — Configure `android/key.properties` with your release keystore
4. **Bundle ID** — Update `com.fileconverter.pro` if using a different identifier

---

## License

Proprietary — All rights reserved.
