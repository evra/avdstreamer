import SwiftUI
import KeyboardShortcuts


struct AppSettingsView: View {
      @AppStorage("rtmpServerUrl") private var rtmpServerUrl = "rtmp://localhost:1935/"
      @AppStorage("audioDeviceId") private var audioDeviceId = "default";
      @AppStorage("videoDeviceId") private var videoDeviceId = "none";

    private var allDevices = getFFMpegDevicesList()
  
    
//    @AppStorage("showPreview") private var showPreview = true
//    @AppStorage("fontSize") private var fontSize = 12.0


        var body: some View {
            Form {
                TextField("RTMP URL:", text: $rtmpServerUrl)
                Picker("Audio device:", selection: $audioDeviceId) {
                    
                    ForEach( allDevices.filter({$0.type == FFMpegDeviceType.AUDIO})) { device in
                        Text(device.name)
                    }
                }
                Picker("Video device:", selection: $videoDeviceId) {
                    
                    ForEach( allDevices.filter({$0.type == FFMpegDeviceType.VIDEO}) ) { device in
                        Text(device.name)
                    }
                }
                
                KeyboardShortcuts.Recorder("Start/stop shortcut:", name: .toggleStartStopMode)
                
//                Toggle("Show Previews", isOn: $showPreview)
//                Slider(value: $fontSize, in: 9...96) {
//                    Text("Font Size (\(fontSize, specifier: "%.0f") pts)")
//                }
            }
            .padding(20)
            .frame(width: 400, height: 300)
        }
}

#Preview {
    AppSettingsView()
}
