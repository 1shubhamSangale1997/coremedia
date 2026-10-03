# CameraX ProGuard Rules
-keep class androidx.camera.** { *; }

# Google ML Kit ProGuard Rules
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# ZXing (Barcode Scanning) ProGuard Rules
-keep class com.google.zxing.** { *; }

# Mobile Scanner Flutter Plugin ProGuard Rules
-keep class dev.steenbakker.mobile_scanner.** { *; }
-dontwarn dev.steenbakker.mobile_scanner.**

