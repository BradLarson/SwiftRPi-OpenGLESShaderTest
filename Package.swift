import PackageDescription

let package = Package(
    dependencies: [
        .Package(url: "https://github.com/BradLarson/COpenGLES.git", majorVersion: 1),
        .Package(url: "https://github.com/BradLarson/CVideoCore.git", majorVersion: 1)
    ]
) 
