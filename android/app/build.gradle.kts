plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Tambahkan plugin Firebase Google Services jika belum ada dan jika menggunakan Firebase
    id("com.google.gms.google-services") // Pastikan Anda menambahkan ini jika menggunakan Firebase
}

android {
    namespace = "com.example.daily_reminder_app"
    compileSdk = flutter.compileSdkVersion

    // --- PERBAIKAN 1: NDK Version Mismatch ---
    // Ganti 'flutter.ndkVersion' dengan versi NDK yang dibutuhkan plugin
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // --- PERBAIKAN 2b: Core Library Desugaring di compileOptions (INI YANG BENAR) ---
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.daily_reminder_app"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // --- PERBAIKAN: BARIS INI DIHAPUS dari sini ---
        // coreLibraryDesugaringEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// --- PERBAIKAN 2c: Tambahkan dependensi Core Library Desugaring ---
dependencies {
    // Dependensi lain mungkin ada di sini secara otomatis dari "flutter create ."
    // Contoh:
    // testImplementation(kotlin("test"))
    // testImplementation("junit:junit:4.13.2")
    // ...

    // --- TAMBAHKAN BARIS INI ---
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4") // Gunakan versi stabil terbaru
    // --- END TAMBAHKAN BARIS INI ---
}