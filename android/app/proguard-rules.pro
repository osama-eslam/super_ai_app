########## ML Kit & Google Play Services ##########
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.**

########## Flutter TTS ##########
-keep class io.flutter.plugins.flutter_tts.** { *; }

########## Speech to Text ##########
-keep class com.csdcorp.speech_to_text.** { *; }

########## Dio (Networking) ##########
-keep class okhttp3.** { *; }
-keep class okio.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

########## AndroidX ##########
-keep class androidx.lifecycle.** { *; }
-dontwarn androidx.**

########## Keep annotations ##########
-keepattributes *Annotation*
