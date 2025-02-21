import UIKit
import Flutter
import JitsiMeetSDK

class JitsiNativeViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    private var eventSinkProvider: () -> FlutterEventSink?
    private weak var plugin: JitsiMeetPlugin?
    
    init(messenger: FlutterBinaryMessenger, eventSinkProvider: @escaping () -> FlutterEventSink?, plugin: JitsiMeetPlugin?) {
        self.messenger = messenger
        self.eventSinkProvider = eventSinkProvider
        self.plugin = plugin
        super.init()
    }
    
    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        let arguments = args as! [String: Any]
        let roomUrl = arguments["room"] as! String
        
        let options = try! JitsiMeetConferenceOptions.createConferenceOptions(from: roomUrl)
        
        let view = JitsiNativeView(
            options: options,
            eventSink: eventSinkProvider()
        )
        
        plugin?.jitsiNativeViewCreated(view)
        
        return view
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

extension JitsiMeetConferenceOptions {
    static func createConferenceOptions(from urlString: String) throws -> JitsiMeetConferenceOptions {
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "Invalid URL", code: -1, userInfo: nil)
        }
        
        let domain = url.host ?? ""
        let room = url.pathComponents.last ?? ""
        
        if room.isEmpty {
            throw NSError(domain: "Invalid room name", code: -1, userInfo: nil)
        }

        let builder = JitsiMeetConferenceOptions.fromBuilder { (builder) in
            builder.serverURL = URL(string: "https://\(domain)")
            builder.room = room
            
            var displayName: String? = nil
            var email: String? = nil
            var avatar: URL? = nil
            
            // Разбираем параметры конфигурации
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let fragment = components.fragment {
                let params = fragment.split(separator: "&")
                for param in params {
                    let keyValue = param.split(separator: "=")
                    if keyValue.count == 2 {
                        let key = String(keyValue[0])
                        let value = String(keyValue[1])
                        
                        if key.starts(with: "jwt") {
                            switch key {
                            case "jwt":
                                builder.token = value
                            default:
                                break
                            }
                        } else if key.starts(with: "userInfo.") {
                            // 🔹 User Info
                            switch key {
                                case "userInfo.displayName":
                                    displayName = value
                                case "userInfo.email":
                                    email = value
                                case "userInfo.avatarURL":
                                    avatar = URL(string: value)
                            default:
                                break
                            }
                        } else if key.starts(with: "config.") {
                            switch key {
                            // 🔹 Audio & video
                            case "config.startWithAudioMuted":
                                builder.setAudioMuted(value == "true")
                                builder.setConfigOverride("startWithAudioMuted", withBoolean: (value == "true"))
                            case "config.startWithVideoMuted":
                                builder.setVideoMuted(value == "true")
                                builder.setConfigOverride("startWithVideoMuted", withBoolean: (value == "true"))
                            case "config.audioOnly":
                                builder.setAudioOnly(value == "true")
                            // 🔹 Toolbar Buttons
                            case "config.toolbarButtons":
                                let buttons = value.split(separator: ",").map { String($0) }
                                builder.setConfigOverride("toolbarButtons", withValue: buttons)
                            // 🔹 setFeatureFlag
                            case "config.prejoinPageEnabled":
                                builder.setFeatureFlag("prejoinPageEnabled", withValue: (value == "true"))
                            case "config.disableInviteFunctions":
                                builder.setFeatureFlag("invite.enabled", withValue: !(value == "true"))
                            case "config.chatEnabled":
                                builder.setFeatureFlag("chat.enabled", withValue: (value == "true"))
                            case "config.lobbyModeEnabled":
                                builder.setFeatureFlag("lobby.enabled", withValue: (value == "true"))
                            case "config.raiseHandEnabled":
                                builder.setFeatureFlag("raise-hand.enabled", withValue: (value == "true"))
                            case "config.tileViewEnabled":
                                builder.setFeatureFlag("tile-view.enabled", withValue: (value == "true"))
                            case "config.videoShareButtonEnabled":
                                builder.setFeatureFlag("video-share.enabled", withValue: (value == "true"))
                            // 🔹 setConfigOverride
                            case "config.disableTileView":
                                builder.setConfigOverride("disableTileView", withBoolean: (value == "true"))
                            case "config.enableNoAudioDetection":
                                builder.setConfigOverride("enableNoAudioDetection", withBoolean: (value == "true"))
                            case "config.enableNoisyMicDetection":
                                builder.setConfigOverride("enableNoisyMicDetection", withBoolean: (value == "true"))
                            case "config.enableClosePage":
                                builder.setConfigOverride("enableClosePage", withBoolean: (value == "true"))
                            case "config.disableRemoteMute":
                                builder.setConfigOverride("disableRemoteMute", withBoolean: (value == "true"))
                            case "config.disableSelfView":
                                builder.setConfigOverride("disableSelfView", withBoolean: (value == "true"))
                            case "config.defaultLanguage":
                                builder.setConfigOverride("defaultLanguage", withValue: value)
                            default:
                                break
                            }
                        } else if key.starts(with: "interfaceConfigOverwrite.") {
                            switch key {
                                // 🔹 InterfaceConfigOverwrite
                                case "interfaceConfigOverwrite.TOOLBAR_ALWAYS_VISIBLE":
                                    builder.setConfigOverride("toolbarAlwaysVisible", withValue: value == "true")
                                case "interfaceConfigOverwrite.DISABLE_JOIN_LEAVE_NOTIFICATIONS":
                                    builder.setConfigOverride("disableJoinLeaveNotifications", withValue: value == "true")
                                case "interfaceConfigOverwrite.SHOW_JITSI_WATERMARK":
                                    builder.setConfigOverride("showJitsiWatermark", withBoolean: value == "true")
                                case "interfaceConfigOverwrite.SHOW_WATERMARK_FOR_GUESTS":
                                    builder.setConfigOverride("showWatermarkForGuests", withBoolean: value == "true")
                            default:
                                break
                            }
                        } else {
                            builder.setFeatureFlag(key, withValue: value == "true")
                        }
                    }
                }
            }
            
            let userInfo = JitsiMeetUserInfo(
                displayName: displayName,
                andEmail: email,
                andAvatar: avatar
            )
            builder.userInfo = userInfo
        }
        
        return builder
    }

}
