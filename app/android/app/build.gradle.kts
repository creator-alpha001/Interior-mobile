import java.util.Properties

/**
 * The release signing key, when this machine has one.
 *
 * `key.properties` is deliberately not in the repository — it names a keystore
 * and carries its passwords, and the keystore *is* the app's identity: Play
 * accepts an update only if it is signed by the same key, so a leaked one lets
 * somebody else ship as us and a lost one ends the listing. `android/.gitignore`
 * already excludes it and every `.jks`.
 *
 * Absent, a release build falls back to the debug key. That keeps
 * `flutter run --release` working on a fresh clone; Play refuses such a build,
 * which is the right failure — loud, at upload, rather than a store listing
 * signed with a key every Flutter install shares.
 */
val keyProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}
val releaseKeystore = keyProperties.getProperty("storeFile")

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.decorashine.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // Changed once, before publishing, and never again: an applicationId
        // *is* the listing's identity on Play.
        applicationId = "com.decorashine.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (releaseKeystore != null) {
            create("release") {
                storeFile = file(releaseKeystore)
                storePassword = keyProperties.getProperty("storePassword")
                keyAlias = keyProperties.getProperty("keyAlias")
                keyPassword = keyProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (releaseKeystore != null) {
                signingConfigs.getByName("release")
            } else {
                // Not shippable, and meant to be noticed: Play rejects an
                // upload signed with the debug key.
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
