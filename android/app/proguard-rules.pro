# Proguard rules for Agentry app
# Keep Hive models from being obfuscated or removed in release builds

-keep class com.example.agentry.models.** { *; }

# Keep Hive internal classes
-keep class com.hivedb.** { *; }
-dontwarn com.hivedb.**
