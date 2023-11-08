import Flutter
import Foundation
import Mapbox
import UIKit

public class VNPTMapGlFlutterPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = VNPTMapViewFactory(withRegistrar: registrar)
        registrar.register(instance, withId: "plugin:vnpt-map-view-type")
        
        let channel = FlutterMethodChannel(
            name: "plugin:vnpt-map-view-type",
            binaryMessenger: registrar.messenger()
        )
        
        /**Define case  with channel**/
        channel.setMethodCallHandler { methodCall, result in
            switch methodCall.method {
                
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result("iOS " + UIDevice.current.systemVersion)
    }
}
