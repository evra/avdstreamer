

// https://blog.schurigeln.com/menu-bar-apps-swift-ui/
// https://github.com/arthenica/ffmpeg-kit
// https://stackoverflow.com/questions/72672889/ffmpeg-for-use-in-ios-application-coded-in-swift

// https://github.com/sindresorhus/KeyboardShortcuts
// https://stackoverflow.com/questions/47760135/global-keyboard-shortcuts-for-a-mac-tray-app

// https://docs.agora.io/en/help/integration-issues/framework_cannot_be_opened


import SwiftUI
import ffmpegkit
import Foundation
import KeyboardShortcuts

@main
struct AvdStreamerApp: App {
    
    @StateObject private var appState = AppState()
        
                
    var body: some Scene {
                
        MenuBarExtra() {
            
            Button(action: action1, label: { Text("Start")}).disabled(appState.streamSessionRunning)
            Button(action: action2, label: { Text("Stop") }).disabled(!appState.streamSessionRunning)
            
            Divider()
            SettingsLink()
            
            Button(action: action4, label: { Text("Show log") })
            Divider()
            
            Button(action: action3, label: { Text("Exit") })
        } label: {
            Image(systemName: "antenna.radiowaves.left.and.right.circle")
                .symbolRenderingMode(.palette)
                .foregroundStyle(appState.streamSessionRunning ? Color.yellow : Color.primary,
                                 appState.streamSessionRunning ? Color.cyan : Color.primary
                    )
        }
        
        Settings( content: {
            AppSettingsView()
        }
        )
        
    }
    
    func action1() { appState.startStreamingAsync() }
    func action2() { appState.stopStreaming() }
    func action3() { exit(EXIT_SUCCESS) }
    func action4() { showLogDialog(logContent: appState.ffMpegLogs) }

    
    func showLogDialog(logContent: Array<String>) {
        //https://stackoverflow.com/questions/63277226/scrollable-nstextfield-in-alert-message
        
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = "Log"
        
        alert.addButton(withTitle: "OK")
        
        let scrollView = NSScrollView(frame: NSRect(x:0, y:0, width: 400, height: 300))
        scrollView.hasVerticalScroller = true
        
        let clipView = NSClipView(frame: scrollView.bounds)
        clipView.autoresizingMask = [.width, .height]
        
        let textView = NSTextView(frame: clipView.bounds)
        textView.autoresizingMask = [.width, .height]
        
        for element in logContent {
            textView.string += element + "\n"
        }
        
        
        clipView.documentView = textView
        scrollView.contentView = clipView
        
        alert.accessoryView = scrollView
        
        let response = alert.runModal()
        
        switch response {
        case .alertFirstButtonReturn:
            return
        default: return
        }
        
    }
    
}


@MainActor
final class AppState: ObservableObject {

    private var ffMpegSession : FFmpegSession?
    var ffMpegLogs = Array<String>()
    
    @Published var streamSessionRunning : Bool = false

    
    init() {
        KeyboardShortcuts.onKeyUp(for: .toggleStartStopMode) { [self] in
                
                        if (streamSessionRunning) {
                            stopStreaming()
                        } else {
                            startStreamingAsync()
                        }
            
            print("Start/stop recieved!")
        }
    }
 
    func stopStreaming() {
        ffMpegSession?.cancel();
    }
    
    func getFFMpegCommand() -> String {
        
        //ffmpeg -f avfoundation -ac 2 -i :0 -c:a aac -f flv rtmp://localhost:1935/test/record123.flv

        
        let serverUrl = UserDefaults.standard.string(forKey: "rtmpServerUrl") ?? ""
        let audioDeviceId = UserDefaults.standard.string(forKey: "audioDeviceId") ?? "default"
        let videoDeviceId = UserDefaults.standard.string(forKey: "videoDeviceId") ?? "none"
        let ffmpegOptions = UserDefaults.standard.string(forKey: "ffmpegOptions") ?? "-c:a aac"
                
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYMMd-HHmmss"
        let currentDateStr = dateFormatter.string(from: Date())
        
//        let command = "-nostats -f avfoundation -ac 2 -i \(videoDeviceId):\(audioDeviceId) -c:a aac -f flv \(serverUrl)/\(currentDateStr).flv"
        let command = "-nostats -f avfoundation -i \(videoDeviceId):\(audioDeviceId) \(ffmpegOptions) -f flv \(serverUrl)/\(currentDateStr).flv"
        return command
    }
    
    func startStreamingAsync() {
          
        ffMpegSession = FFmpegKit.executeAsync(getFFMpegCommand()) { session in
            self.streamSessionRunning = false;
            guard let session = session else {
                self.logFFMpeg(logStr: "!! Invalid session")
                return
            }
            guard let returnCode = session.getReturnCode() else {
                self.logFFMpeg(logStr: "!! Invalid return code")
                return
            }
            self.logFFMpeg(logStr: "FFmpeg process exited with state \(FFmpegKitConfig.sessionState(toString: session.getState()) ?? "Unknown") and rc \(returnCode).\(session.getFailStackTrace() ?? "Unknown")")
        } withLogCallback: { logs in
            guard let logs = logs else { return }
            self.logFFMpeg(logStr: logs.getMessage())
        } withStatisticsCallback: { stats in
            guard let stats = stats else { return }
            // TODO set stats in the app state and display in an info dialog
        }
        self.streamSessionRunning = true;
        
    }
    
    func logFFMpeg(logStr: String) {
        ffMpegLogs.append(logStr)
        print(logStr);
    }


}


