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
    val configureNamespaceAndSdk = {
        val android = extensions.findByName("android") as? com.android.build.gradle.BaseExtension
        if (android != null) {
            if (android.namespace == null) {
                android.namespace = "com.example.${project.name.replace("-", "_").replace(".", "_")}"
            }
            android.compileSdkVersion(36)
        }
    }
    if (project.state.executed) {
        configureNamespaceAndSdk()
    } else {
        project.afterEvaluate {
            configureNamespaceAndSdk()
        }
    }

    // Task to remove the package attribute from AndroidManifest.xml for plugins
    tasks.whenTaskAdded {
        if (name.contains("processDebugManifest") || name.contains("processReleaseManifest")) {
            doFirst {
                val manifestFile = file("${projectDir}/src/main/AndroidManifest.xml")
                if (manifestFile.exists()) {
                    var content = manifestFile.readText(Charsets.UTF_8)
                    if (content.contains("package=")) {
                        content = content.replace(Regex("""package="[^"]+""""), "")
                        manifestFile.writeText(content, Charsets.UTF_8)
                    }
                }
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
