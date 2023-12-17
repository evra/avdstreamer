import Foundation

import ffmpegkit

enum FFMpegDeviceType {
    case AUDIO, VIDEO
    
}

struct FFMpegDevice : Identifiable {
    let id: String
    let name: String
    let type: FFMpegDeviceType
    init(id:String, name:String, type: FFMpegDeviceType) {
          self.id = id
          self.name = name
        self.type = type
      }
}


func getFFMpegDevicesList() -> [FFMpegDevice] {
    
    // example output
//        [AVFoundation indev @ 0x7fe91a8225c0] AVFoundation video devices:
//        [AVFoundation indev @ 0x7fe91a8225c0] [0] Logitech Webcam C925e
//        [AVFoundation indev @ 0x7fe91a8225c0] [1] FaceTime HD-Kamera (integriert)
//        [AVFoundation indev @ 0x7fe91a8225c0] [2] Capture screen 0
//        [AVFoundation indev @ 0x7fe91a8225c0] [3] Capture screen 1
//        [AVFoundation indev @ 0x7fe91a8225c0] AVFoundation audio devices:
//        [AVFoundation indev @ 0x7fe91a8225c0] [0] mydevice
//        [AVFoundation indev @ 0x7fe91a8225c0] [1] Yeti Stereo Microphone
//        [AVFoundation indev @ 0x7fe91a8225c0] [2] BlackHole 2ch
//        [AVFoundation indev @ 0x7fe91a8225c0] [3] MacBook Pro-Mikrofon
//        [AVFoundation indev @ 0x7fe91a8225c0] [4] Logitech Webcam C925e
//        [AVFoundation indev @ 0x7fe91a8225c0] [5] Microsoft Teams Audio
    
    
    var devices = [FFMpegDevice]()
    
    let videoSection = /\[.*\] AVFoundation video devices:/
    let audioSection = /\[.*\] AVFoundation audio devices:/
    let deviceSection = /\[.*\]\s+\[(\d+)\]\s(.*?)/
            
    guard let session = FFmpegKit.execute("-hide_banner -list_devices true -f avfoundation -i dummy") else {
        print("!! Failed to create session")
        return devices
    }
    print(session.getReturnCode() ?? "invalid return code")
    
    if (session.getState() == SessionState.completed) {
        // the code is error as ffmpeg doesn't like -i dummy
        let sessionOut = session.getOutput() ?? ""
        let lines = sessionOut.split(separator: "\n")
        var devideType: FFMpegDeviceType = FFMpegDeviceType.AUDIO;
            for line in lines {
                if (try? videoSection.wholeMatch(in: line)) != nil {
                    devideType = FFMpegDeviceType.VIDEO;
                }
                if (try? audioSection.wholeMatch(in: line)) != nil {
                    devideType = FFMpegDeviceType.AUDIO;
                }
                if let result = try? deviceSection.wholeMatch(in: line) {
                    devices.append(FFMpegDevice(id: String(result.1), name: String(result.2), type: devideType))
                }
             }

    }
     
    devices.append(FFMpegDevice(id: "none", name: "None", type:FFMpegDeviceType.VIDEO))
    devices.append(FFMpegDevice(id: "none", name: "None", type:FFMpegDeviceType.AUDIO))

    devices.append(FFMpegDevice(id: "default", name: "System default", type:FFMpegDeviceType.VIDEO))
    devices.append(FFMpegDevice(id: "default", name: "System default", type:FFMpegDeviceType.AUDIO))

    
    return devices
}

