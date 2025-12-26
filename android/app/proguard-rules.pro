# Keep Kotlin serialization metadata.
-keepclassmembers class ** {
    @kotlinx.serialization.Serializable *;
}

# Keep Retrofit service interfaces and response models.
-keepclassmembers class * {
    @retrofit2.http.* <methods>;
}
