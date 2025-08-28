buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Firebase Google Services plugin
        classpath("com.google.gms:google-services:4.3.15") // Could update to latest stable for bug fixes & compatibility
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir) // Custom build directory; ensure external tools/scripts are aware

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app") // Consider merging with above block for cleaner structure
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
