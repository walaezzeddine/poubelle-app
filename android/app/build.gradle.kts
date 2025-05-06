plugins {
    id("com.google.gms.google-services") apply false
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
   // id("com.google.gms.google-services")  // Doit rester en dernier
}

android {
    namespace = "com.example.poubelle"
    compileSdk = flutter.compileSdkVersion.toInt()  // Conversion explicite requise

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()// Simplifié
    }

    defaultConfig {
        applicationId = "com.example.poubelle"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true  // Important pour Firebase

        ndk {
        abiFilters.addAll(listOf("armeabi-v7a", "arm64-v8a"))
    }
    ndkVersion = "27.2.12479018"

    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true  // Activation du code shrinking
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            ndk {
                abiFilters.addAll(listOf("armeabi-v7a", "arm64-v8a"))
            }
        }
    }

    // Configuration supplémentaire pour Flutter
   // flavorDimensions += "environment"
  //  productFlavors {
   //     create("dev") {
          //  dimension = "environment"
           // applicationIdSuffix = ".dev"
        //}
        //create("prod") {
          //  dimension = "environment"
        //}
    //} 
    
}

flutter {
    source = "../.."
}

