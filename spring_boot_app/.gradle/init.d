initscript {
    repositories {
        gradlePluginPortal()
    }

    dependencies {
        classpath 'com.gradle:build-scan-plugin:1.15.2'
    }
}

rootProject {
    apply plugin: com.gradle.scan.plugin.BuildScanPlugin

    buildScan {
        termsOfServiceUrl = 'https://gradle.com/terms-of-service'
        termsOfServiceAgree = 'yes'
    }
}
