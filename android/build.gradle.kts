allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// ── Force ALL sub-projects (including plugins like printing, pdfx, etc.)
//    to use compileSdk 36 and disable fatal lint. This prevents:
//    - android:attr/lStar not found (printing verifyReleaseResources)
//    - pdfx lint OOM crash
//    - Any plugin compiled against an older SDK
subprojects {
    afterEvaluate {
        if (project.hasProperty("android")) {
            val android = project.extensions.getByName("android")
            if (android is com.android.build.gradle.BaseExtension) {
                android.compileSdkVersion(36)
            }
            if (android is com.android.build.gradle.LibraryExtension) {
                android.lint {
                    checkReleaseBuilds = false
                    abortOnError = false
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
