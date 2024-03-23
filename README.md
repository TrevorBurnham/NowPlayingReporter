# NowPlayingReporter

NowPlayingReporter is a simple CLI tool for macOS 12.0+ that emits information about the currently-playing audio track in easy-to-parse JSON format. When the user hits play/pause or changes to a different track, that information is reported on a new line:

```sh
$ ./NowPlayingReporter
{"artist":"Dua Lipa","name":"Dance The Night","playing":true}
{"artist":"Dua Lipa","name":"Dance The Night","playing":false}
{"artist":"Screen Junkies","name":"Honest Trailers | Barbie","playing":true}
```

This tool uses the MediaRemote framework, which provides the same information displayed in the Now Playing widget in [Control Center](https://support.apple.com/guide/mac-help/quickly-change-settings-mchl50f94f8f/mac).

**Important note for developers:** MediaRemote is a private framework. Backward compatibility in future macOS versions is not guaranteed, and applications that use the framework in any way cannot be distributed through the Mac App Store.

## Building

First, [install Swift](https://www.swift.org/install/). Then:

```sh
swift build --configuration=release --arch arm64 --arch x86_64
```

This will emit a unified binary to `.build/apple/Products/Release/NowPlayingReporter`.

## Acknowledgments

Thanks to John Coates for [Aerial](https://github.com/JohnCoates/Aerial), which the MediaRemote code in this project is adapted from.
