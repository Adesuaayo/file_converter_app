# ──────────────────────────────────────────────────────────────────────────────
# ProGuard Rules — File Converter Pro
# ──────────────────────────────────────────────────────────────────────────────
# These rules ensure critical classes are not removed or obfuscated during
# R8/ProGuard minification in release builds.

# ─── Flutter ──────────────────────────────────────────────────────────────────
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# ─── Google Mobile Ads (AdMob) ────────────────────────────────────────────────
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# ─── Google Play Billing (In-App Purchase) ───────────────────────────────────
-keep class com.android.vending.billing.** { *; }
-keep class com.android.billingclient.** { *; }
-dontwarn com.android.billingclient.**

# ─── Hive (Local Database) ───────────────────────────────────────────────────
-keep class ** extends com.google.protobuf.GeneratedMessageLite { *; }
-keep class hive.** { *; }

# ─── AndroidX ────────────────────────────────────────────────────────────────
-keep class androidx.lifecycle.** { *; }
-dontwarn androidx.lifecycle.**

# ─── General ─────────────────────────────────────────────────────────────────
# Keep annotations
-keepattributes *Annotation*

# Keep native methods
-keepclassmembers class * {
    native <methods>;
}

# Keep Parcelables
-keepclassmembers class * implements android.os.Parcelable {
    static ** CREATOR;
}

# Keep Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# ─── Debugging ────────────────────────────────────────────────────────────────
# Preserve line numbers for stack traces
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# ─── PDF libraries (pdfx, pdf, printing) ──────────────────────────────────────
-keep class io.scer.pdfx.** { *; }
-dontwarn io.scer.pdfx.**

# ─── Connectivity Plus ────────────────────────────────────────────────────────
-dontwarn dev.fluttercommunity.plus.connectivity.**

# ─── R8 full mode compatibility ──────────────────────────────────────────────
-dontwarn java.lang.invoke.StringConcatFactory
