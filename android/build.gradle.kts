// Top-level build file where you can add configuration options common to all sub-projects/modules.

buildscript {
    // --- PERBAIKAN: Ganti 'ext' dengan definisi 'val' langsung ---
    // Definisikan versi plugin di sini
    val androidGradlePluginVersion = "8.4.1" // Versi Android Gradle Plugin
    val kotlinGradlePluginVersion = "1.9.0" // Versi Kotlin Gradle Plugin
    val googleServicesPluginVersion = "4.4.1" // Versi Google Services Plugin

    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:$androidGradlePluginVersion")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinGradlePluginVersion")
        // Plugin Google Services untuk Firebase (WAJIB jika menggunakan Firebase)
        classpath("com.google.gms:google-services:$googleServicesPluginVersion")
    }
}


allprojects {
    repositories {
        google()
        mavenCentral()
        // Jika ada dependensi lain yang membutuhkan repository khusus (misal: JitPack)
        // maven { url 'https://www.jitpack.io' }
    }
}

// Konfigurasi untuk menempatkan output build Flutter di folder 'build' root proyek
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Memastikan modul 'app' dievaluasi lebih dulu
subprojects {
    project.evaluationDependsOn(":app")
}

// Task untuk membersihkan output build
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}