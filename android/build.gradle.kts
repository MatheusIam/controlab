allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// NOTE:
// Removed custom buildDirectory redirection because some Flutter plugin
// modules (fetched in the pub cache) reside on a different drive (e.g. C:) than
// the application project (e.g. D:). Overriding build directories for those
// external composite builds caused Gradle to attempt to compute relative paths
// across different drive roots, triggering errors like:
//   "this and base files have different roots: D:\\... and C:\\..."
// Keeping default build directories avoids that cross-drive mismatch.

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
