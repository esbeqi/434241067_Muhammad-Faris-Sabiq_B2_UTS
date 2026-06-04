# Flutter

# Keep Flutter classes
-keep class io.flutter.** { *; }

# Keep Kotlin metadata
-keep class kotlin.Metadata { *; }

# Remove log methods in release
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}