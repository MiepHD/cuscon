-optimizationpasses 5
-overloadaggressively
-dontpreverify
-repackageclasses 'o'
-allowaccessmodification

-keep class **.R
-keep class **.R$* {
    <fields>;
}

# Keep the source line when using ProGuard
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

-dontwarn org.conscrypt.Conscrypt$Version
-dontwarn org.conscrypt.Conscrypt
-dontwarn org.conscrypt.ConscryptHostnameVerifier
-dontwarn org.openjsse.javax.net.ssl.SSLParameters
-dontwarn org.openjsse.javax.net.ssl.SSLSocket
-dontwarn org.openjsse.net.ssl.OpenJSSE