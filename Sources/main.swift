//
//  main.swift
//  NowPlayingReporter
//

import Foundation

// JSON-serializable structure for track info.
struct TrackInfo: Codable, Equatable {
  let name: String?
  let artist: String?
  let playing: Bool
}

// Load the MediaRemote framework.
let bundle = CFBundleCreate(
  kCFAllocatorDefault,
  NSURL(fileURLWithPath: "/System/Library/PrivateFrameworks/MediaRemote.framework"))

class NowPlayingReporter: NSObject {
  // Track info that was last displayed.
  var prevTrackInfo: TrackInfo?

  // Timer used to debounce the print function.
  var debounceTimer: Timer?

  // JSON encoder used when printing track info.
  let encoder: JSONEncoder = JSONEncoder()

  override init() {
    super.init()
    self.encoder.outputFormatting = .sortedKeys
    self.printNowPlayingInfo()
    self.registerNotificationObservers()
  }

  func registerNotificationObservers() {
    // Get a Swift function for MRMediaRemoteRegisterForNowPlayingNotifications.
    guard
      let registerForNotificationsPointer =
        CFBundleGetFunctionPointerForName(
          bundle, "MRMediaRemoteRegisterForNowPlayingNotifications" as CFString)
    else { return }
    typealias RegisterForNotificationsFunction = @convention(c) (
      DispatchQueue
    ) -> Void
    let registerForNowPlayingNotifications = unsafeBitCast(
      registerForNotificationsPointer,
      to: RegisterForNotificationsFunction.self)

    // Register for "Now Playing" notifications.
    registerForNowPlayingNotifications(DispatchQueue.main)

    DispatchQueue.main.async {
      // Handle NowPlayingApplicationIsPlayingDidChange events.
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(self.printNowPlayingInfo),
        name: NSNotification.Name(
          "kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification"), object: nil)

      // Handle NowPlayingInfoDidChange events.
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(self.printNowPlayingInfo),
        name: NSNotification.Name("kMRMediaRemoteNowPlayingInfoDidChangeNotification"), object: nil)
    }
  }

  @objc func printNowPlayingInfo() {
    self.debounceTimer?.invalidate()
    self.debounceTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
      // Get a Swift function for MRMediaRemoteGetNowPlayingInfo.
      guard
        let MRMediaRemoteGetNowPlayingInfoPointer = CFBundleGetFunctionPointerForName(
          bundle, "MRMediaRemoteGetNowPlayingInfo" as CFString)
      else { return }
      typealias MRMediaRemoteGetNowPlayingInfoFunction = @convention(c) (
        DispatchQueue, @escaping ([String: Any]) -> Void
      ) -> Void
      let MRMediaRemoteGetNowPlayingInfo = unsafeBitCast(
        MRMediaRemoteGetNowPlayingInfoPointer, to: MRMediaRemoteGetNowPlayingInfoFunction.self)

      // Get song info.
      MRMediaRemoteGetNowPlayingInfo(
        DispatchQueue.main,
        { (information) in
          var name: String?
          var artist: String?
          var playbackRate = 0.0

          if information["kMRMediaRemoteNowPlayingInfoArtist"] != nil {
            if let info = information["kMRMediaRemoteNowPlayingInfoArtist"] as? String {
              artist = info
            }
            if let info = information["kMRMediaRemoteNowPlayingInfoTitle"] as? String {
              name = info
            }
            if let info = information["kMRMediaRemoteNowPlayingInfoPlaybackRate"] as? Double {
              playbackRate = info
            }
          }

          let trackInfo = TrackInfo(name: name, artist: artist, playing: playbackRate != 0.0)

          if trackInfo != self.prevTrackInfo {
            print(self.serializeTrackInfo(trackInfo))
            self.prevTrackInfo = trackInfo
          }
        }
      )
    }
  }

  func serializeTrackInfo(_ trackInfo: TrackInfo) -> String {
    // Convert track info to a JSON string.
    do {
      let jsonData = try encoder.encode(trackInfo)
      let jsonString = String(data: jsonData, encoding: .utf8)!
      return jsonString
    } catch {
      return "{\"error\": \"An error occurred while serializing JSON data.\")"
    }
  }
}

let nowPlayingReporter = NowPlayingReporter()
RunLoop.main.run()
