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

// ── Force compileSdk 36 + disable lint on every Android-library sub-project ──
// evaluationDependsOn(":app") eagerly evaluates :app, so :app.state.executed
// is already true when we reach here. For :app we configure directly (no-op
// because it uses com.android.application, not library). For all other library
// sub-projects we use afterEvaluate so our compileSdk override runs AFTER their
// own build.gradle has finished (otherwise their `android{}` block would
// overwrite our value).
subprojects {
    if (project.state.executed) {
        // :app lands here — it's already evaluated.
        // Safe to configure directly; hasPlugin guard skips non-library projects.
        if (project.plugins.hasPlugin("com.android.library")) {
            val android = project.extensions.getByName("android")
                    as com.android.build.gradle.LibraryExtension
            android.compileSdk = 36
            android.lint {
                checkReleaseBuilds = false
                abortOnError = false
            }
        }
    } else {
        // All plugin sub-projects (printing, pdfx, etc.) land here.
        project.afterEvaluate {
            if (plugins.hasPlugin("com.android.library")) {
                val android = extensions.getByName("android")
                        as com.android.build.gradle.LibraryExtension
                android.compileSdk = 36
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
