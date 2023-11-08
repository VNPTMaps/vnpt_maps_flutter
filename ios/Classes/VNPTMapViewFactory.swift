//
//  VNPTMapViewFactory.swift
//  Pods
//
//  Created by hmtri on 01/11/2022.
//

import Flutter

class VNPTMapViewFactory: NSObject, FlutterPlatformViewFactory {
    var registrar: FlutterPluginRegistrar
    
    init(withRegistrar registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
        super.init()
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
    
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64,
                arguments args: Any?) -> FlutterPlatformView
    {
        return VNPTMapViewMapController(
            withFrame: frame,
            viewIdentifier: viewId,
            arguments: args,
            registrar: registrar
        )
    }
}
