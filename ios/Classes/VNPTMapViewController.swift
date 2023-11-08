//
//  VNPTMapViewController.swift
//  Pods
//
//  Created by hmtri on 01/11/2022.
//

import Flutter
import Mapbox
import UIKit

class VNPTMapViewMapController: NSObject, FlutterPlatformView, MGLMapViewDelegate, VNPTMapViewOptionsSink,
                                UIGestureRecognizerDelegate
{
    private var registrar: FlutterPluginRegistrar
    private var channel: FlutterMethodChannel?
    
    private var mapView: MGLMapView
    private var isMapReady = false
    private var dragEnabled = true
    private var isFirstStyleLoad = true
    private var onStyleLoadedCalled = false
    private var mapReadyResult: FlutterResult?
    private var previousDragCoordinate: CLLocationCoordinate2D?
    private var originDragCoordinate: CLLocationCoordinate2D?
    private var dragFeature: MGLFeature?
    
    private var initialTilt: CGFloat?
    private var cameraTargetBounds: MGLCoordinateBounds?
    private var trackCameraPosition = false
    private var myLocationEnabled = false
    private var scrollingEnabled = true
    
    private var interactiveFeatureLayerIds = Set<String>()
    
    private var selectedAnnotaion: MGLAnnotation?
    
    private var addedShapesByLayer = [String: MGLShape]()
    
    func view() -> UIView {
        return mapView
    }
    
    init(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        registrar: FlutterPluginRegistrar
    ) {
        //        if let args = args as? [String: Any] {
        //            if let token = args["accessToken"] as? String? {
        //                MGLAccountManager.accessToken = token
        //            }
        //        }
        mapView = MGLMapView(frame: frame)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.logoView.isHidden = true
        mapView.attributionButton.isHidden = true
        self.registrar = registrar
        
        super.init()
        
        channel = FlutterMethodChannel(
            name: "plugin:vnpt-map-view-type_\(viewId)",
            binaryMessenger: registrar.messenger()
        )
        channel!
            .setMethodCallHandler { [weak self] in self?.onMethodCall(methodCall: $0, result: $1) }
        
        mapView.delegate = self
        
        // Handler SingleTap
        let singleTap = UITapGestureRecognizer(
            target: self,
            action: #selector(handleMapTap(sender:))
        )
        for recognizer in mapView.gestureRecognizers! where recognizer is UITapGestureRecognizer {
            singleTap.require(toFail: recognizer)
        }
        mapView.addGestureRecognizer(singleTap)
        
        // Handler LongPress
        let longPress = UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleMapLongPress(sender:))
        )
        for recognizer in mapView.gestureRecognizers!
        where recognizer is UILongPressGestureRecognizer
        {
            longPress.require(toFail: recognizer)
        }
        mapView.addGestureRecognizer(longPress)
        
        
        if let args = args as? [String: Any] {
            VNPTMapConvert.interpretVNPTMapOptions(options: args["options"], delegate: self)
            if let initialCameraPosition = args["initialCameraPosition"] as? [String: Any],
               let camera = MGLMapCamera.fromDict(initialCameraPosition, mapView: mapView),
               let zoom = initialCameraPosition["zoom"] as? Double
            {
                mapView.setCenter(
                    camera.centerCoordinate,
                    zoomLevel: zoom,
                    direction: camera.heading,
                    animated: false
                )
                initialTilt = camera.pitch
            }
            
            if let onAttributionClickOverride = args["onAttributionClickOverride"] as? Bool {
                if onAttributionClickOverride {
                    setupAttribution(mapView)
                }
            }
            
            if let enabled = args["dragEnabled"] as? Bool {
                dragEnabled = enabled
            }
            
            // Add markers on creation params
            if let markersToAdd = args["markersToAdd"] as? [[String: Any]] {
                let annotations = VNPTMapConvert.parseMarkersToAdd(markersJson: markersToAdd, registrar: registrar)
                if (annotations.count > 0) {
                    mapView.addAnnotations(annotations)
                }
            }
            
            // Add polylines on creation params
            if let polylinesToAdd = args["polylinesToAdd"] as? [[String: Any]] {
                let polylines = VNPTMapConvert.parsePolylinesToAdd(polylinesJson: polylinesToAdd)
                if (polylines.count > 0) {
                    mapView.addAnnotations(polylines)
                }
            }
            
            // Add polygons on creation params
            if let polygonsToAdd = args["polygonsToAdd"] as? [[String: Any]] {
                let polygons = VNPTMapConvert.parsePolygonsToAdd(polygonsJson: polygonsToAdd)
                if (polygons.count > 0) {
                    mapView.addAnnotations(polygons)
                }
            }
            
            if dragEnabled {
                let pan = UIPanGestureRecognizer(
                    target: self,
                    action: #selector(handleMapPan(sender:))
                )
                pan.delegate = self
                mapView.addGestureRecognizer(pan)
            }
        }
    }
    
    func gestureRecognizer(
        _: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer
    ) -> Bool {
        return true
    }
    
    func onMethodCall(methodCall: FlutterMethodCall, result: @escaping FlutterResult) {
        print("native ios - receive method: \(methodCall.method)")
        switch methodCall.method {
        case "map#waitForMap":
            if isMapReady {
                result(nil)
                // only call map#onStyleLoaded here if isMapReady has happend and isFirstStyleLoad is true
                if isFirstStyleLoad {
                    isFirstStyleLoad = false
                    
                    if let channel = channel {
                        onStyleLoadedCalled = true
                        channel.invokeMethod("map#onStyleLoaded", arguments: nil)
                    }
                }
            } else {
                mapReadyResult = result
            }
        case "map#update":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            VNPTMapConvert.interpretVNPTMapOptions(options: arguments["options"], delegate: self)
            if let camera = getCamera() {
                result(camera.toDict(mapView: mapView))
            } else {
                result(nil)
            }
        case "camera#animate":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let cameraUpdate = arguments["cameraUpdate"] as? [Any] else { return }
            guard let camera = VNPTMapConvert.parseCameraUpdate(cameraUpdate: cameraUpdate, mapView: mapView) else { return }
            
            
            let completion = {
                result(nil)
            }
            
            if let duration = arguments["duration"] as? TimeInterval {
                if let padding = VNPTMapConvert.parseLatLngBoundsPadding(cameraUpdate) {
                    mapView.fly(to: camera, edgePadding: padding, withDuration: duration / 1000, completionHandler: completion)
                } else {
                    mapView.fly(to: camera, withDuration: duration / 1000, completionHandler: completion)
                }
            } else {
                mapView.setCamera(camera, animated: true)
                completion()
            }
        case "camera#move":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let cameraUpdate = arguments["cameraUpdate"] as? [Any] else { return }
            if let camera = VNPTMapConvert.parseCameraUpdate(cameraUpdate: cameraUpdate, mapView: mapView)
            {
                mapView.setCamera(camera, animated: false)
            }
            result(nil)
        case "map#setCameraBounds":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let west = arguments["west"] as? Double else { return }
            guard let north = arguments["north"] as? Double else { return }
            guard let south = arguments["south"] as? Double else { return }
            guard let east = arguments["east"] as? Double else { return }
            guard let padding = arguments["padding"] as? CGFloat else { return }
            
            let southwest = CLLocationCoordinate2D(latitude: south, longitude: west)
            let northeast = CLLocationCoordinate2D(latitude: north, longitude: east)
            let bounds = MGLCoordinateBounds(sw: southwest, ne: northeast)
            mapView.setVisibleCoordinateBounds(bounds, edgePadding: UIEdgeInsets(top: padding,
                                                                                 left: padding, bottom: padding, right: padding) , animated: true)
            result(nil)
        case "map#updateMyLocationTrackingMode":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            if let myLocationTrackingMode = arguments["mode"] as? UInt,
               let trackingMode = MGLUserTrackingMode(rawValue: myLocationTrackingMode)
            {
                setMyLocationTrackingMode(myLocationTrackingMode: trackingMode)
            }
            result(nil)
        case "locationComponent#getLastLocation":
            var reply = [String: NSObject]()
            if let loc = mapView.userLocation?.location?.coordinate {
                reply["latitude"] = loc.latitude as NSObject
                reply["longitude"] = loc.longitude as NSObject
                result(reply)
            } else {
                result(nil)
            }
        case "map#queryRenderedFeatures":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            var styleLayerIdentifiers: Set<String>?
            if let layerIds = arguments["layerIds"] as? [String] {
                styleLayerIdentifiers = Set<String>(layerIds)
            }
            var filterExpression: NSPredicate?
            if let filter = arguments["filter"] as? [Any] {
                filterExpression = NSPredicate(mglJSONObject: filter)
            }
            var reply = [String: NSObject]()
            var features: [MGLFeature] = []
            if let x = arguments["x"] as? Double, let y = arguments["y"] as? Double {
                features = mapView.visibleFeatures(
                    at: CGPoint(x: x, y: y),
                    styleLayerIdentifiers: styleLayerIdentifiers,
                    predicate: filterExpression
                )
            }
            if let top = arguments["top"] as? Double,
               let bottom = arguments["bottom"] as? Double,
               let left = arguments["left"] as? Double,
               let right = arguments["right"] as? Double
            {
                var width = right - left
                var height = bottom - top
                features = mapView.visibleFeatures(in: CGRect(x: left, y: top, width: width, height: height), styleLayerIdentifiers: styleLayerIdentifiers, predicate: filterExpression)
            }
            var featuresJson = [String]()
            for feature in features {
                let dictionary = feature.geoJSONDictionary()
                if let theJSONData = try? JSONSerialization.data(
                    withJSONObject: dictionary,
                    options: []
                ),
                   let theJSONText = String(data: theJSONData, encoding: .utf8)
                {
                    featuresJson.append(theJSONText)
                }
            }
            reply["features"] = featuresJson as NSObject
            result(reply)
        case "map#toScreenLocation":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let latitude = arguments["latitude"] as? Double else { return }
            guard let longitude = arguments["longitude"] as? Double else { return }
            let latlng = CLLocationCoordinate2DMake(latitude, longitude)
            let returnVal = mapView.convert(latlng, toPointTo: mapView)
            var reply = [String: NSObject]()
            reply["x"] = returnVal.x as NSObject
            reply["y"] = returnVal.y as NSObject
            result(reply)
        case "map#toScreenLocationBatch":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let data = arguments["coordinates"] as? FlutterStandardTypedData else { return }
            let latLngs = data.data.withUnsafeBytes {
                Array(
                    UnsafeBufferPointer(
                        start: $0.baseAddress!.assumingMemoryBound(to: Double.self),
                        count: Int(data.elementCount)
                    )
                )
            }
            var reply: [Double] = Array(repeating: 0.0, count: latLngs.count)
            for i in stride(from: 0, to: latLngs.count, by: 2) {
                let coordinate = CLLocationCoordinate2DMake(latLngs[i], latLngs[i + 1])
                let returnVal = mapView.convert(coordinate, toPointTo: mapView)
                reply[i] = Double(returnVal.x)
                reply[i + 1] = Double(returnVal.y)
            }
            result(FlutterStandardTypedData(
                float64: Data(bytes: &reply, count: reply.count * 8)
            ))
        case "map#getMetersPerPixelAtLatitude":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            var reply = [String: NSObject]()
            guard let latitude = arguments["latitude"] as? Double else { return }
            let returnVal = mapView.metersPerPoint(atLatitude: latitude)
            reply["metersperpixel"] = returnVal as NSObject
            result(reply)
        case "map#toLatLng":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let x = arguments["x"] as? Double else { return }
            guard let y = arguments["y"] as? Double else { return }
            let screenPoint = CGPoint(x: x, y: y)
            let coordinates: CLLocationCoordinate2D = mapView.convert(
                screenPoint,
                toCoordinateFrom: mapView
            )
            var reply = [String: NSObject]()
            reply["latitude"] = coordinates.latitude as NSObject
            reply["longitude"] = coordinates.longitude as NSObject
            result(reply)
        case "markers#update":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            
            if let markersToAdd = arguments["markersToAdd"] as? [[String: Any]] {
                addMarker(markersToAdd: markersToAdd)
            }
            
            if let markerIdsToRemove = arguments["markerIdsToRemove"] as? [String] {
                removeMarker(markerIdsToRemove: markerIdsToRemove)
            }
            
            if let markersToChange = arguments["markersToChange"] as? [[String: Any]] {
                //Remove old markers
                var markerIdsToChange = [String]()
                markersToChange.forEach { markerToUpdate in
                    if let markerId = markerToUpdate["markerId"] as? String {
                        markerIdsToChange.append(markerId)
                    }
                }
                if (markerIdsToChange.count > 0) {
                    removeMarker(markerIdsToRemove: markerIdsToChange)
                }
                
                //Add updated markers
                addMarker(markersToAdd: markersToChange)
            }
            
            result(nil)
        case "map#updateContentInsets":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            
            if let bounds = arguments["bounds"] as? [String: Any],
               let top = bounds["top"] as? CGFloat,
               let left = bounds["left"] as? CGFloat,
               let bottom = bounds["bottom"] as? CGFloat,
               let right = bounds["right"] as? CGFloat,
               let animated = arguments["animated"] as? Bool
            {
                mapView.setContentInset(
                    UIEdgeInsets(top: top, left: left, bottom: bottom, right: right),
                    animated: animated
                ) {
                    result(nil)
                }
            } else {
                result(nil)
            }
        case "polylines#update":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            
            if let polylinesToAdd = arguments["polylinesToAdd"] as? [[String: Any]] {
                addPolyline(polylinesToAdd: polylinesToAdd)
            }
            
            if let polylineIdsToRemove = arguments["polylineIdsToRemove"] as? [String] {
                removePolyline(polylineIdsToRemove: polylineIdsToRemove)
            }
            
            if let polylinesToChange = arguments["polylinesToChange"] as? [[String: Any]] {
                //Remove old polylines
                var polylineIdsToChange = [String]()
                polylinesToChange.forEach { polylineToUpdate in
                    if let polylineId = polylineToUpdate["polylineId"] as? String {
                        polylineIdsToChange.append(polylineId)
                    }
                }
                if (polylineIdsToChange.count > 0) {
                    removePolyline(polylineIdsToRemove: polylineIdsToChange)
                }
                
                //Add updated polylines
                addPolyline(polylinesToAdd: polylinesToChange)
            }
            
            result(nil)
            
        case "polygons#update":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            
            if let polygonsToAdd = arguments["polygonsToAdd"] as? [[String: Any]] {
                addPolygon(polygonsToAdd: polygonsToAdd)
            }
            
            if let polygonIdsToRemove = arguments["polygonIdsToRemove"] as? [String] {
                removePolygon(polygonIdsToRemove: polygonIdsToRemove)
            }
            
            if let polygonsToChange = arguments["polygonsToChange"] as? [[String: Any]] {
                //Remove old polygons
                var polygonIdsToChange = [String]()
                polygonsToChange.forEach { polygonToUpdate in
                    if let polygonId = polygonToUpdate["polygonId"] as? String {
                        polygonIdsToChange.append(polygonId)
                    }
                }
                if (polygonIdsToChange.count > 0) {
                    removePolygon(polygonIdsToRemove: polygonIdsToChange)
                }
                
                //Add updated polygons
                addPolygon(polygonsToAdd: polygonsToChange)
            }
            
            result(nil)
            
        case "symbolLayer#add":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            print("ios native - symbolLayer add: \(arguments)")
            guard let sourceId = arguments["sourceId"] as? String else { return }
            guard let layerId = arguments["layerId"] as? String else { return }
            guard let properties = arguments["properties"] as? [String: String] else { return }
            guard let enableInteraction = arguments["enableInteraction"] as? Bool else { return }
            let belowLayerId = arguments["belowLayerId"] as? String
            let sourceLayer = arguments["sourceLayer"] as? String
            let minzoom = arguments["minzoom"] as? Double
            let maxzoom = arguments["maxzoom"] as? Double
            let filter = arguments["filter"] as? String
            
            let addResult = addSymbolLayer(
                sourceId: sourceId,
                layerId: layerId,
                belowLayerId: belowLayerId,
                sourceLayerIdentifier: sourceLayer,
                minimumZoomLevel: minzoom,
                maximumZoomLevel: maxzoom,
                filter: filter,
                enableInteraction: enableInteraction,
                properties: properties
            )
            switch addResult {
            case .success: result(nil)
            case let .failure(error): result(error.flutterError)
            }
            
        case "lineLayer#add":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let sourceId = arguments["sourceId"] as? String else { return }
            guard let layerId = arguments["layerId"] as? String else { return }
            guard let properties = arguments["properties"] as? [String: String] else { return }
            guard let enableInteraction = arguments["enableInteraction"] as? Bool else { return }
            let belowLayerId = arguments["belowLayerId"] as? String
            let sourceLayer = arguments["sourceLayer"] as? String
            let minzoom = arguments["minzoom"] as? Double
            let maxzoom = arguments["maxzoom"] as? Double
            let filter = arguments["filter"] as? String
            
            let addResult = addLineLayer(
                sourceId: sourceId,
                layerId: layerId,
                belowLayerId: belowLayerId,
                sourceLayerIdentifier: sourceLayer,
                minimumZoomLevel: minzoom,
                maximumZoomLevel: maxzoom,
                filter: filter,
                enableInteraction: enableInteraction,
                properties: properties
            )
            switch addResult {
            case .success: result(nil)
            case let .failure(error): result(error.flutterError)
            }
            
        case "fillLayer#add":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let sourceId = arguments["sourceId"] as? String else { return }
            guard let layerId = arguments["layerId"] as? String else { return }
            guard let properties = arguments["properties"] as? [String: String] else { return }
            guard let enableInteraction = arguments["enableInteraction"] as? Bool else { return }
            let belowLayerId = arguments["belowLayerId"] as? String
            let sourceLayer = arguments["sourceLayer"] as? String
            let minzoom = arguments["minzoom"] as? Double
            let maxzoom = arguments["maxzoom"] as? Double
            let filter = arguments["filter"] as? String
            
            let addResult = addFillLayer(
                sourceId: sourceId,
                layerId: layerId,
                belowLayerId: belowLayerId,
                sourceLayerIdentifier: sourceLayer,
                minimumZoomLevel: minzoom,
                maximumZoomLevel: maxzoom,
                filter: filter,
                enableInteraction: enableInteraction,
                properties: properties
            )
            switch addResult {
            case .success: result(nil)
            case let .failure(error): result(error.flutterError)
            }
            
        case "fillExtrusionLayer#add":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let sourceId = arguments["sourceId"] as? String else { return }
            guard let layerId = arguments["layerId"] as? String else { return }
            guard let properties = arguments["properties"] as? [String: String] else { return }
            guard let enableInteraction = arguments["enableInteraction"] as? Bool else { return }
            let belowLayerId = arguments["belowLayerId"] as? String
            let sourceLayer = arguments["sourceLayer"] as? String
            let minzoom = arguments["minzoom"] as? Double
            let maxzoom = arguments["maxzoom"] as? Double
            let filter = arguments["filter"] as? String
            
            let addResult = addFillExtrusionLayer(
                sourceId: sourceId,
                layerId: layerId,
                belowLayerId: belowLayerId,
                sourceLayerIdentifier: sourceLayer,
                minimumZoomLevel: minzoom,
                maximumZoomLevel: maxzoom,
                filter: filter,
                enableInteraction: enableInteraction,
                properties: properties
            )
            switch addResult {
            case .success: result(nil)
            case let .failure(error): result(error.flutterError)
            }
            
        case "circleLayer#add":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let sourceId = arguments["sourceId"] as? String else { return }
            guard let layerId = arguments["layerId"] as? String else { return }
            guard let properties = arguments["properties"] as? [String: String] else { return }
            guard let enableInteraction = arguments["enableInteraction"] as? Bool else { return }
            let belowLayerId = arguments["belowLayerId"] as? String
            let sourceLayer = arguments["sourceLayer"] as? String
            let minzoom = arguments["minzoom"] as? Double
            let maxzoom = arguments["maxzoom"] as? Double
            let filter = arguments["filter"] as? String
            
            let addResult = addCircleLayer(
                sourceId: sourceId,
                layerId: layerId,
                belowLayerId: belowLayerId,
                sourceLayerIdentifier: sourceLayer,
                minimumZoomLevel: minzoom,
                maximumZoomLevel: maxzoom,
                filter: filter,
                enableInteraction: enableInteraction,
                properties: properties
            )
            switch addResult {
            case .success: result(nil)
            case let .failure(error): result(error.flutterError)
            }
            
        case "hillshadeLayer#add":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let sourceId = arguments["sourceId"] as? String else { return }
            guard let layerId = arguments["layerId"] as? String else { return }
            guard let properties = arguments["properties"] as? [String: String] else { return }
            let belowLayerId = arguments["belowLayerId"] as? String
            let minzoom = arguments["minzoom"] as? Double
            let maxzoom = arguments["maxzoom"] as? Double
            addHillshadeLayer(
                sourceId: sourceId,
                layerId: layerId,
                belowLayerId: belowLayerId,
                minimumZoomLevel: minzoom,
                maximumZoomLevel: maxzoom,
                properties: properties
            )
            result(nil)
            
        case "heatmapLayer#add":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let sourceId = arguments["sourceId"] as? String else { return }
            guard let layerId = arguments["layerId"] as? String else { return }
            guard let properties = arguments["properties"] as? [String: String] else { return }
            let belowLayerId = arguments["belowLayerId"] as? String
            let minzoom = arguments["minzoom"] as? Double
            let maxzoom = arguments["maxzoom"] as? Double
            addHeatmapLayer(
                sourceId: sourceId,
                layerId: layerId,
                belowLayerId: belowLayerId,
                minimumZoomLevel: minzoom,
                maximumZoomLevel: maxzoom,
                properties: properties
            )
            result(nil)
            
        case "rasterLayer#add":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let sourceId = arguments["sourceId"] as? String else { return }
            guard let layerId = arguments["layerId"] as? String else { return }
            guard let properties = arguments["properties"] as? [String: String] else { return }
            let belowLayerId = arguments["belowLayerId"] as? String
            let minzoom = arguments["minzoom"] as? Double
            let maxzoom = arguments["maxzoom"] as? Double
            addRasterLayer(
                sourceId: sourceId,
                layerId: layerId,
                belowLayerId: belowLayerId,
                minimumZoomLevel: minzoom,
                maximumZoomLevel: maxzoom,
                properties: properties
            )
            result(nil)
            
        case "style#addImage":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let name = arguments["name"] as? String else { return }
            print("ios native - add Image name: \(name) - \(arguments)")
            // guard let length = arguments["length"] as? NSNumber else { return }
            guard let bytes = arguments["bytes"] as? FlutterStandardTypedData else { return }
            guard let sdf = arguments["sdf"] as? Bool else { return }
            let data = bytes.data as Data
            guard let image = UIImage(data: data, scale: UIScreen.main.scale) else { return }
            if sdf {
                mapView.style?.setImage(image.withRenderingMode(.alwaysTemplate), forName: name)
            } else {
                mapView.style?.setImage(image, forName: name)
            }
            result(nil)
            
        case "style#addImageSource":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let imageSourceId = arguments["imageSourceId"] as? String else { return }
            guard let bytes = arguments["bytes"] as? FlutterStandardTypedData else { return }
            let data = bytes.data as Data
            guard let image = UIImage(data: data) else { return }
            
            guard let coordinates = arguments["coordinates"] as? [[Double]] else { return }
            let quad = MGLCoordinateQuad(
                topLeft: CLLocationCoordinate2D(
                    latitude: coordinates[0][0],
                    longitude: coordinates[0][1]
                ),
                bottomLeft: CLLocationCoordinate2D(
                    latitude: coordinates[3][0],
                    longitude: coordinates[3][1]
                ),
                bottomRight: CLLocationCoordinate2D(
                    latitude: coordinates[2][0],
                    longitude: coordinates[2][1]
                ),
                topRight: CLLocationCoordinate2D(
                    latitude: coordinates[1][0],
                    longitude: coordinates[1][1]
                )
            )
            
            // Check for duplicateSource error
            if mapView.style?.source(withIdentifier: imageSourceId) != nil {
                result(FlutterError(
                    code: "duplicateSource",
                    message: "Source with imageSourceId \(imageSourceId) already exists",
                    details: "Can't add duplicate source with imageSourceId: \(imageSourceId)"
                ))
                return
            }
            
            let source = MGLImageSource(
                identifier: imageSourceId,
                coordinateQuad: quad,
                image: image
            )
            mapView.style?.addSource(source)
            
            result(nil)
        case "style#updateImageSource":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let imageSourceId = arguments["imageSourceId"] as? String else { return }
            guard let imageSource = mapView.style?
                .source(withIdentifier: imageSourceId) as? MGLImageSource else { return }
            let bytes = arguments["bytes"] as? FlutterStandardTypedData
            if bytes != nil {
                let data = bytes!.data as Data
                guard let image = UIImage(data: data) else { return }
                imageSource.image = image
            }
            let coordinates = arguments["coordinates"] as? [[Double]]
            if coordinates != nil {
                let quad = MGLCoordinateQuad(
                    topLeft: CLLocationCoordinate2D(
                        latitude: coordinates![0][0],
                        longitude: coordinates![0][1]
                    ),
                    bottomLeft: CLLocationCoordinate2D(
                        latitude: coordinates![3][0],
                        longitude: coordinates![3][1]
                    ),
                    bottomRight: CLLocationCoordinate2D(
                        latitude: coordinates![2][0],
                        longitude: coordinates![2][1]
                    ),
                    topRight: CLLocationCoordinate2D(
                        latitude: coordinates![1][0],
                        longitude: coordinates![1][1]
                    )
                )
                imageSource.coordinates = quad
            }
            result(nil)
            
        case "style#removeSource":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let sourceId = arguments["sourceId"] as? String else { return }
            guard let source = mapView.style?.source(withIdentifier: sourceId) else {
                result(nil)
                return
            }
            mapView.style?.removeSource(source)
            result(nil)
            
        case "style#addLayer":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let imageLayerId = arguments["imageLayerId"] as? String else { return }
            guard let imageSourceId = arguments["imageSourceId"] as? String else { return }
            let minzoom = arguments["minzoom"] as? Double
            let maxzoom = arguments["maxzoom"] as? Double
            
            // Check for duplicateLayer error
            if (mapView.style?.layer(withIdentifier: imageLayerId)) != nil {
                result(FlutterError(
                    code: "duplicateLayer",
                    message: "Layer already exists",
                    details: "Can't add duplicate layer with imageLayerId: \(imageLayerId)"
                ))
                return
            }
            // Check for noSuchSource error
            guard let source = mapView.style?.source(withIdentifier: imageSourceId) else {
                result(FlutterError(
                    code: "noSuchSource",
                    message: "No source found with imageSourceId \(imageSourceId)",
                    details: "Can't add add layer for imageSourceId \(imageLayerId), as the source does not exist."
                ))
                return
            }
            
            let layer = MGLRasterStyleLayer(identifier: imageLayerId, source: source)
            
            if let minzoom = minzoom {
                layer.minimumZoomLevel = Float(minzoom)
            }
            
            if let maxzoom = maxzoom {
                layer.maximumZoomLevel = Float(maxzoom)
            }
            
            mapView.style?.addLayer(layer)
            result(nil)
            
        case "style#addLayerBelow":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let imageLayerId = arguments["imageLayerId"] as? String else { return }
            guard let imageSourceId = arguments["imageSourceId"] as? String else { return }
            guard let belowLayerId = arguments["belowLayerId"] as? String else { return }
            let minzoom = arguments["minzoom"] as? Double
            let maxzoom = arguments["maxzoom"] as? Double
            
            // Check for duplicateLayer error
            if (mapView.style?.layer(withIdentifier: imageLayerId)) != nil {
                result(FlutterError(
                    code: "duplicateLayer",
                    message: "Layer already exists",
                    details: "Can't add duplicate layer with imageLayerId: \(imageLayerId)"
                ))
                return
            }
            // Check for noSuchSource error
            guard let source = mapView.style?.source(withIdentifier: imageSourceId) else {
                result(FlutterError(
                    code: "noSuchSource",
                    message: "No source found with imageSourceId \(imageSourceId)",
                    details: "Can't add add layer for imageSourceId \(imageLayerId), as the source does not exist."
                ))
                return
            }
            // Check for noSuchLayer error
            guard let belowLayer = mapView.style?.layer(withIdentifier: belowLayerId) else {
                result(FlutterError(
                    code: "noSuchLayer",
                    message: "No layer found with layerId \(belowLayerId)",
                    details: "Can't insert layer below layer with id \(belowLayerId), as no such layer exists."
                ))
                return
            }
            
            let layer = MGLRasterStyleLayer(identifier: imageLayerId, source: source)
            
            if let minzoom = minzoom {
                layer.minimumZoomLevel = Float(minzoom)
            }
            
            if let maxzoom = maxzoom {
                layer.maximumZoomLevel = Float(maxzoom)
            }
            
            mapView.style?.insertLayer(layer, below: belowLayer)
            result(nil)
            
        case "style#removeLayer":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let layerId = arguments["layerId"] as? String else { return }
            guard let layer = mapView.style?.layer(withIdentifier: layerId) else {
                result(nil)
                return
            }
            interactiveFeatureLayerIds.remove(layerId)
            mapView.style?.removeLayer(layer)
            result(nil)
            
        case "style#setFilter":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let layerId = arguments["layerId"] as? String else { return }
            guard let filter = arguments["filter"] as? String else { return }
            guard let layer = mapView.style?.layer(withIdentifier: layerId) else {
                result(nil)
                return
            }
            switch setFilter(layer, filter) {
            case .success: result(nil)
            case let .failure(error): result(error.flutterError)
            }
            
        case "source#addGeoJson":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            print("ios native - add geojson: \(arguments)")
            guard let sourceId = arguments["sourceId"] as? String else { return }
            guard let geojson = arguments["geojson"] as? String else { return }
            addSourceGeojson(sourceId: sourceId, geojson: geojson)
            result(nil)
            
        case "source#setGeoJson":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            print("ios native - set geojson: \(arguments)")
            guard let sourceId = arguments["sourceId"] as? String else { return }
            guard let geojson = arguments["geojson"] as? String else { return }
            setSource(sourceId: sourceId, geojson: geojson)
            result(nil)
            
        case "source#setFeature":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let sourceId = arguments["sourceId"] as? String else { return }
            guard let geojson = arguments["geojsonFeature"] as? String else { return }
            setFeature(sourceId: sourceId, geojsonFeature: geojson)
            result(nil)
            
        case "style#addSource":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let sourceId = arguments["sourceId"] as? String else { return }
            guard let properties = arguments["properties"] as? [String: Any] else { return }
            addSource(sourceId: sourceId, properties: properties)
            result(nil)
        case "map#getVisibleRegion":
            var reply = [String: NSObject]()
            let visibleRegion = mapView.visibleCoordinateBounds
            reply["sw"] = [visibleRegion.sw.latitude, visibleRegion.sw.longitude] as NSObject
            reply["ne"] = [visibleRegion.ne.latitude, visibleRegion.ne.longitude] as NSObject
            result(reply)
        case "layer#setVisibility":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let layerId = arguments["layerId"] as? String else { return }
            guard let visible = arguments["visible"] as? Bool else { return }
            guard let layer = mapView.style?.layer(withIdentifier: layerId) else {
                result(nil)
                return
            }
            layer.isVisible = visible
            result(nil)
        case "map#querySourceFeatures":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let sourceId = arguments["sourceId"] as? String else { return }
            
            var sourceLayerId = Set<String>()
            if let layerId = arguments["sourceLayerId"] as? String {
                sourceLayerId.insert(layerId)
            }
            var filterExpression: NSPredicate?
            if let filter = arguments["filter"] as? [Any] {
                filterExpression = NSPredicate(mglJSONObject: filter)
            }
            
            var reply = [String: NSObject]()
            var features: [MGLFeature] = []
            
            guard let style = mapView.style else { return }
            if let source = style.source(withIdentifier: sourceId) {
                if let vectorSource = source as? MGLVectorTileSource {
                    features = vectorSource.features(sourceLayerIdentifiers: sourceLayerId, predicate: filterExpression)
                } else if let shapeSource = source as? MGLShapeSource {
                    features = shapeSource.features(matching: filterExpression)
                }
            }
            
            var featuresJson = [String]()
            for feature in features {
                let dictionary = feature.geoJSONDictionary()
                if let theJSONData = try? JSONSerialization.data(
                    withJSONObject: dictionary,
                    options: []
                ),
                   let theJSONText = String(data: theJSONData, encoding: .utf8)
                {
                    featuresJson.append(theJSONText)
                }
            }
            reply["features"] = featuresJson as NSObject
            result(reply)
        case "style#getLayerIds":
            var layerIds = [String]()
            
            guard let style = mapView.style else { return }
            
            style.layers.forEach { layer in layerIds.append(layer.identifier) }
            
            var reply = [String: NSObject]()
            reply["layers"] = layerIds as NSObject
            result(reply)
            
        case "style#getSourceIds":
            var sourceIds = [String]()
            
            guard let style = mapView.style else { return }
            
            style.sources.forEach { source in sourceIds.append(source.identifier) }
            
            var reply = [String: NSObject]()
            reply["sources"] = sourceIds as NSObject
            result(reply)
            
        case "style#getFilter":
            guard let arguments = methodCall.arguments as? [String: Any] else { return }
            guard let layerId = arguments["layerId"] as? String else { return }
            
            guard let style = mapView.style else { return }
            guard let layer = style.layer(withIdentifier: layerId) else { return }
            
            var currentLayerFilter : String = ""
            if let vectorLayer = layer as? MGLVectorStyleLayer {
                if let layerFilter = vectorLayer.predicate {
                    
                    let jsonExpression = layerFilter.mgl_jsonExpressionObject
                    if let data = try? JSONSerialization.data(withJSONObject: jsonExpression, options: []) {
                        currentLayerFilter = String(data: data, encoding: String.Encoding.utf8) ?? ""
                    }
                }
            } else {
                result(MethodCallError.invalidLayerType(
                    details: "Layer '\(layer.identifier)' does not support filtering."
                ).flutterError)
                return;
            }
            
            var reply = [String: NSObject]()
            reply["filter"] = currentLayerFilter as NSObject
            result(reply)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    /*
     *  MGLMapViewDelegate
     */
    func mapView(_ mapView: MGLMapView, didFinishLoading _: MGLStyle) {
        isMapReady = true
        updateMyLocationEnabled()
        
        if let initialTilt = initialTilt {
            let camera = mapView.camera
            camera.pitch = initialTilt
            mapView.setCamera(camera, animated: false)
        }
        
        addedShapesByLayer.removeAll()
        interactiveFeatureLayerIds.removeAll()
        
        mapReadyResult?(nil)
        
        // On first launch we only call map#onStyleLoaded if map#waitForMap has already been called
        if !isFirstStyleLoad || mapReadyResult != nil {
            isFirstStyleLoad = false
            
            if let channel = channel {
                channel.invokeMethod("map#onStyleLoaded", arguments: nil)
            }
        }
    }
    
    func mapView(_ mapView: MGLMapView, shouldChangeFrom _: MGLMapCamera,
                 to newCamera: MGLMapCamera) -> Bool
    {
        guard let bbox = cameraTargetBounds else { return true }
        
        // Get the current camera to restore it after.
        let currentCamera = mapView.camera
        
        // From the new camera obtain the center to test if it’s inside the boundaries.
        let newCameraCenter = newCamera.centerCoordinate
        
        // Set the map’s visible bounds to newCamera.
        mapView.camera = newCamera
        let newVisibleCoordinates = mapView.visibleCoordinateBounds
        
        // Revert the camera.
        mapView.camera = currentCamera
        
        // Test if the newCameraCenter and newVisibleCoordinates are inside bbox.
        let inside = MGLCoordinateInCoordinateBounds(newCameraCenter, bbox)
        let intersects = MGLCoordinateInCoordinateBounds(newVisibleCoordinates.ne, bbox) &&
        MGLCoordinateInCoordinateBounds(newVisibleCoordinates.sw, bbox)
        
        return inside && intersects
    }
    
    func mapView(_: MGLMapView, didUpdate userLocation: MGLUserLocation?) {
        if let channel = channel, let userLocation = userLocation,
           let location = userLocation.location
        {
            channel.invokeMethod("map#onUserLocationUpdated", arguments: [
                "userLocation": location.toDict(),
                "heading": userLocation.heading?.toDict(),
            ])
        }
    }
    
    func mapView(_: MGLMapView, didChange mode: MGLUserTrackingMode, animated _: Bool) {
        if let channel = channel {
            channel.invokeMethod("map#onCameraTrackingChanged", arguments: ["mode": mode.rawValue])
            if mode == .none {
                channel.invokeMethod("map#onCameraTrackingDismissed", arguments: [])
            }
        }
    }
    
    func mapView(_ mapView: MGLMapView, regionDidChangeAnimated _: Bool) {
        let arguments = trackCameraPosition ? [
            "position": getCamera()?.toDict(mapView: mapView)
        ] : [:]
        if let channel = channel {
            channel.invokeMethod("camera#onIdle", arguments: arguments)
        }
    }
    
    func mapViewDidBecomeIdle(_: MGLMapView) {
        if let channel = channel {
            channel.invokeMethod("map#onIdle", arguments: [])
        }
    }
    
    func mapView(_: MGLMapView, regionWillChangeAnimated _: Bool) {
        if let channel = channel {
            channel.invokeMethod("camera#onMoveStarted", arguments: [])
        }
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        if let vnptMapMarker = annotation as? VNPTMapMarker {
            return (vnptMapMarker.title != nil || vnptMapMarker.title != nil)
        }
        else {
            return false
        }
    }
    
    // Handle user tap on InfoWindows of a marker
    func mapView(_ mapView: MGLMapView, tapOnCalloutFor annotation: MGLAnnotation) {
        if let vnptMapMarker = annotation as? VNPTMapMarker {
            if let channel = channel {
                channel.invokeMethod("infoWindow#onTap", arguments: ["markerId": vnptMapMarker.markerId])
            }
        }
    }
    
    // Handle user tap on (select) a marker
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        if let vnptMapPolygon = annotation as? VNPTMapPolygon {
            if vnptMapPolygon.consumeTapEvents! {
                if let channel = channel {
                    channel.invokeMethod("polygon#onTap", arguments: ["polygonId": vnptMapPolygon.polygonId])
                }
            }
        }
        
        if let vnptMapPolyline = annotation as? VNPTMapPolyline {
            if vnptMapPolyline.consumeTapEvents! {
                if let channel = channel {
                    channel.invokeMethod("polyline#onTap", arguments: ["polylineId": vnptMapPolyline.polylineId])
                }
            }
        }
        
        if let vnptMapMarker = annotation as? VNPTMapMarker {
            if vnptMapMarker.consumeTapEvent {
                if let channel = channel {
                    channel.invokeMethod("marker#onTap", arguments: ["markerId": vnptMapMarker.markerId])
                }
            }
        }
    }
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        
        if let vnptMarker = annotation as? VNPTMapMarker {
            if let image = vnptMarker.icon {
                
                // Use the image name as the reuse identifier for its view.
                let reuseIdentifier = vnptMarker.iconIdentify
                
                // For better performance, always try to reuse existing annotations.
                var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier ?? "default_identifier")
                
                // If there’s no reusable annotation view available, initialize a new one.
                if annotationView == nil {
                    annotationView = CustomImageAnnotationView(reuseIdentifier: reuseIdentifier, image: image)
                }
                
                return annotationView
            }
        }
        
        return nil
    }
    
    func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        if let vnptMapPolyline = annotation as? VNPTMapPolyline {
            return vnptMapPolyline.color!.withAlphaComponent(vnptMapPolyline.alpha!)
        }
        
        if let vnptMapPolygon = annotation as? VNPTMapPolygon {
            return vnptMapPolygon.strokeColor!
        }
        
        return .blue
    }
    
    func mapView(_ mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        if let vnptMapPolyline = annotation as? VNPTMapPolyline {
            return vnptMapPolyline.width!
        }
        
        return 10
    }
    
    func mapView(_ mapView: MGLMapView, fillColorForPolygonAnnotation annotation: MGLPolygon) -> UIColor {
        if let vnptMapPolygon = annotation as? VNPTMapPolygon {
            return vnptMapPolygon.fillColor!.withAlphaComponent(vnptMapPolygon.fillAlpha!)
        }
        
        return .blue.withAlphaComponent(0.8)
    }
    
    private func addMarker(markersToAdd: [[String: Any]]) {
        let annotations = VNPTMapConvert.parseMarkersToAdd(markersJson: markersToAdd, registrar: registrar)
        if (annotations.count > 0) {
            mapView.addAnnotations(annotations)
        }
    }
    
    private func removeMarker(markerIdsToRemove: [String]) {
        var annotationsToRemove = [VNPTMapMarker]()
        if let currentAnnotations = mapView.annotations {
            currentAnnotations.forEach { annotation in
                if let vnptMapMarker = annotation as? VNPTMapMarker {
                    for markerIdToRemove in markerIdsToRemove {
                        if (vnptMapMarker.markerId == markerIdToRemove) {
                            annotationsToRemove.append(vnptMapMarker)
                            break
                        }
                    }
                    
                }
            }
            if (annotationsToRemove.count > 0) {
                mapView.removeAnnotations(annotationsToRemove)
            }
        }
    }
    
    private func addPolyline(polylinesToAdd: [[String: Any]]) {
        let polylines = VNPTMapConvert.parsePolylinesToAdd(polylinesJson: polylinesToAdd)
        if (polylines.count > 0) {
            mapView.addAnnotations(polylines)
        }
    }
    
    private func removePolyline(polylineIdsToRemove: [String]) {
        var polylinesToRemove = [VNPTMapPolyline]()
        if let currentAnnotations = mapView.annotations {
            currentAnnotations.forEach { annotation in
                if let vnptMapPolyline = annotation as? VNPTMapPolyline {
                    for polylineIdToRemove in polylineIdsToRemove {
                        if (vnptMapPolyline.polylineId == polylineIdToRemove) {
                            polylinesToRemove.append(vnptMapPolyline)
                            break
                        }
                    }
                }
            }
            if (polylinesToRemove.count > 0) {
                mapView.removeAnnotations(polylinesToRemove)
            }
        }
    }
    
    private func addPolygon(polygonsToAdd: [[String: Any]]) {
        let polygons = VNPTMapConvert.parsePolygonsToAdd(polygonsJson: polygonsToAdd)
        if (polygons.count > 0) {
            mapView.addAnnotations(polygons)
        }
    }
    
    private func removePolygon(polygonIdsToRemove: [String]) {
        var polygonsToRemove = [VNPTMapPolygon]()
        if let currentAnnotations = mapView.annotations {
            currentAnnotations.forEach { annotation in
                if let vnptMapPolygon = annotation as? VNPTMapPolygon {
                    for polygonIdToRemove in polygonIdsToRemove {
                        if (vnptMapPolygon.polygonId == polygonIdToRemove) {
                            polygonsToRemove.append(vnptMapPolygon)
                            break
                        }
                    }
                }
            }
            if (polygonsToRemove.count > 0) {
                mapView.removeAnnotations(polygonsToRemove)
            }
        }
    }
    
    func mapViewRegionIsChanging(_ mapView: MGLMapView) {
        if !trackCameraPosition { return }
        if let channel = channel {
            channel.invokeMethod("camera#onMove", arguments: [
                "position": getCamera()?.toDict(mapView: mapView),
            ])
        }
    }
    
    func addSymbolLayer(
        sourceId: String,
        layerId: String,
        belowLayerId: String?,
        sourceLayerIdentifier: String?,
        minimumZoomLevel: Double?,
        maximumZoomLevel: Double?,
        filter: String?,
        enableInteraction: Bool,
        properties: [String: String]
    ) -> Result<Void, MethodCallError> {
        if let style = mapView.style {
            if let source = style.source(withIdentifier: sourceId) {
                let layer = MGLSymbolStyleLayer(identifier: layerId, source: source)
                LayerPropertyConverter.addSymbolProperties(
                    symbolLayer: layer,
                    properties: properties
                )
                if let sourceLayerIdentifier = sourceLayerIdentifier {
                    layer.sourceLayerIdentifier = sourceLayerIdentifier
                }
                if let minimumZoomLevel = minimumZoomLevel {
                    layer.minimumZoomLevel = Float(minimumZoomLevel)
                }
                if let maximumZoomLevel = maximumZoomLevel {
                    layer.maximumZoomLevel = Float(maximumZoomLevel)
                }
                if let filter = filter {
                    if case let .failure(error) = setFilter(layer, filter) {
                        return .failure(error)
                    }
                }
                if let id = belowLayerId, let belowLayer = style.layer(withIdentifier: id) {
                    style.insertLayer(layer, below: belowLayer)
                } else {
                    style.addLayer(layer)
                }
                if enableInteraction {
                    interactiveFeatureLayerIds.insert(layerId)
                }
            }
        }
        return .success(())
    }
    
    func addLineLayer(
        sourceId: String,
        layerId: String,
        belowLayerId: String?,
        sourceLayerIdentifier: String?,
        minimumZoomLevel: Double?,
        maximumZoomLevel: Double?,
        filter: String?,
        enableInteraction: Bool,
        properties: [String: String]
    ) -> Result<Void, MethodCallError> {
        if let style = mapView.style {
            if let source = style.source(withIdentifier: sourceId) {
                let layer = MGLLineStyleLayer(identifier: layerId, source: source)
                LayerPropertyConverter.addLineProperties(lineLayer: layer, properties: properties)
                if let sourceLayerIdentifier = sourceLayerIdentifier {
                    layer.sourceLayerIdentifier = sourceLayerIdentifier
                }
                if let minimumZoomLevel = minimumZoomLevel {
                    layer.minimumZoomLevel = Float(minimumZoomLevel)
                }
                if let maximumZoomLevel = maximumZoomLevel {
                    layer.maximumZoomLevel = Float(maximumZoomLevel)
                }
                if let filter = filter {
                    if case let .failure(error) = setFilter(layer, filter) {
                        return .failure(error)
                    }
                }
                if let id = belowLayerId, let belowLayer = style.layer(withIdentifier: id) {
                    style.insertLayer(layer, below: belowLayer)
                } else {
                    style.addLayer(layer)
                }
                if enableInteraction {
                    interactiveFeatureLayerIds.insert(layerId)
                }
            }
        }
        return .success(())
    }
    
    func addFillLayer(
        sourceId: String,
        layerId: String,
        belowLayerId: String?,
        sourceLayerIdentifier: String?,
        minimumZoomLevel: Double?,
        maximumZoomLevel: Double?,
        filter: String?,
        enableInteraction: Bool,
        properties: [String: String]
    ) -> Result<Void, MethodCallError> {
        if let style = mapView.style {
            if let source = style.source(withIdentifier: sourceId) {
                let layer = MGLFillStyleLayer(identifier: layerId, source: source)
                LayerPropertyConverter.addFillProperties(fillLayer: layer, properties: properties)
                if let sourceLayerIdentifier = sourceLayerIdentifier {
                    layer.sourceLayerIdentifier = sourceLayerIdentifier
                }
                if let minimumZoomLevel = minimumZoomLevel {
                    layer.minimumZoomLevel = Float(minimumZoomLevel)
                }
                if let maximumZoomLevel = maximumZoomLevel {
                    layer.maximumZoomLevel = Float(maximumZoomLevel)
                }
                if let filter = filter {
                    if case let .failure(error) = setFilter(layer, filter) {
                        return .failure(error)
                    }
                }
                if let id = belowLayerId, let belowLayer = style.layer(withIdentifier: id) {
                    style.insertLayer(layer, below: belowLayer)
                } else {
                    style.addLayer(layer)
                }
                if enableInteraction {
                    interactiveFeatureLayerIds.insert(layerId)
                }
            }
        }
        return .success(())
    }
    
    func addFillExtrusionLayer(
        sourceId: String,
        layerId: String,
        belowLayerId: String?,
        sourceLayerIdentifier: String?,
        minimumZoomLevel: Double?,
        maximumZoomLevel: Double?,
        filter: String?,
        enableInteraction: Bool,
        properties: [String: String]
    ) -> Result<Void, MethodCallError> {
        if let style = mapView.style {
            if let source = style.source(withIdentifier: sourceId) {
                let layer = MGLFillExtrusionStyleLayer(identifier: layerId, source: source)
                LayerPropertyConverter.addFillExtrusionProperties(
                    fillExtrusionLayer: layer,
                    properties: properties
                )
                if let sourceLayerIdentifier = sourceLayerIdentifier {
                    layer.sourceLayerIdentifier = sourceLayerIdentifier
                }
                if let minimumZoomLevel = minimumZoomLevel {
                    layer.minimumZoomLevel = Float(minimumZoomLevel)
                }
                if let maximumZoomLevel = maximumZoomLevel {
                    layer.maximumZoomLevel = Float(maximumZoomLevel)
                }
                if let filter = filter {
                    if case let .failure(error) = setFilter(layer, filter) {
                        return .failure(error)
                    }
                }
                if let id = belowLayerId, let belowLayer = style.layer(withIdentifier: id) {
                    style.insertLayer(layer, below: belowLayer)
                } else {
                    style.addLayer(layer)
                }
                if enableInteraction {
                    interactiveFeatureLayerIds.insert(layerId)
                }
            }
        }
        return .success(())
    }
    
    func addCircleLayer(
        sourceId: String,
        layerId: String,
        belowLayerId: String?,
        sourceLayerIdentifier: String?,
        minimumZoomLevel: Double?,
        maximumZoomLevel: Double?,
        filter: String?,
        enableInteraction: Bool,
        properties: [String: String]
    ) -> Result<Void, MethodCallError> {
        if let style = mapView.style {
            if let source = style.source(withIdentifier: sourceId) {
                let layer = MGLCircleStyleLayer(identifier: layerId, source: source)
                LayerPropertyConverter.addCircleProperties(
                    circleLayer: layer,
                    properties: properties
                )
                if let sourceLayerIdentifier = sourceLayerIdentifier {
                    layer.sourceLayerIdentifier = sourceLayerIdentifier
                }
                if let minimumZoomLevel = minimumZoomLevel {
                    layer.minimumZoomLevel = Float(minimumZoomLevel)
                }
                if let maximumZoomLevel = maximumZoomLevel {
                    layer.maximumZoomLevel = Float(maximumZoomLevel)
                }
                if let filter = filter {
                    if case let .failure(error) = setFilter(layer, filter) {
                        return .failure(error)
                    }
                }
                if let id = belowLayerId, let belowLayer = style.layer(withIdentifier: id) {
                    style.insertLayer(layer, below: belowLayer)
                } else {
                    style.addLayer(layer)
                }
                if enableInteraction {
                    interactiveFeatureLayerIds.insert(layerId)
                }
            }
        }
        return .success(())
    }
    
    func setFilter(_ layer: MGLStyleLayer, _ filter: String) -> Result<Void, MethodCallError> {
        do {
            let filter = try JSONSerialization.jsonObject(
                with: filter.data(using: .utf8)!,
                options: .fragmentsAllowed
            )
            if filter is NSNull {
                return .success(())
            }
            let predicate = NSPredicate(mglJSONObject: filter)
            if let layer = layer as? MGLVectorStyleLayer {
                layer.predicate = predicate
            } else {
                return .failure(MethodCallError.invalidLayerType(
                    details: "Layer '\(layer.identifier)' does not support filtering."
                ))
            }
            return .success(())
        } catch {
            return .failure(MethodCallError.invalidExpression)
        }
    }
    
    func addHillshadeLayer(
        sourceId: String,
        layerId: String,
        belowLayerId: String?,
        minimumZoomLevel: Double?,
        maximumZoomLevel: Double?,
        properties: [String: String]
    ) {
        if let style = mapView.style {
            if let source = style.source(withIdentifier: sourceId) {
                let layer = MGLHillshadeStyleLayer(identifier: layerId, source: source)
                LayerPropertyConverter.addHillshadeProperties(
                    hillshadeLayer: layer,
                    properties: properties
                )
                if let minimumZoomLevel = minimumZoomLevel {
                    layer.minimumZoomLevel = Float(minimumZoomLevel)
                }
                if let maximumZoomLevel = maximumZoomLevel {
                    layer.maximumZoomLevel = Float(maximumZoomLevel)
                }
                if let id = belowLayerId, let belowLayer = style.layer(withIdentifier: id) {
                    style.insertLayer(layer, below: belowLayer)
                } else {
                    style.addLayer(layer)
                }
            }
        }
    }
    
    func addHeatmapLayer(
        sourceId: String,
        layerId: String,
        belowLayerId: String?,
        minimumZoomLevel: Double?,
        maximumZoomLevel: Double?,
        properties: [String: String]
    ) {
        if let style = mapView.style {
            if let source = style.source(withIdentifier: sourceId) {
                let layer = MGLHeatmapStyleLayer(identifier: layerId, source: source)
                LayerPropertyConverter.addHeatmapProperties(
                    heatmapLayer: layer,
                    properties: properties
                )
                if let minimumZoomLevel = minimumZoomLevel {
                    layer.minimumZoomLevel = Float(minimumZoomLevel)
                }
                if let maximumZoomLevel = maximumZoomLevel {
                    layer.maximumZoomLevel = Float(maximumZoomLevel)
                }
                if let id = belowLayerId, let belowLayer = style.layer(withIdentifier: id) {
                    style.insertLayer(layer, below: belowLayer)
                } else {
                    style.addLayer(layer)
                }
            }
        }
    }
    
    func addRasterLayer(
        sourceId: String,
        layerId: String,
        belowLayerId: String?,
        minimumZoomLevel: Double?,
        maximumZoomLevel: Double?,
        properties: [String: String]
    ) {
        if let style = mapView.style {
            if let source = style.source(withIdentifier: sourceId) {
                let layer = MGLRasterStyleLayer(identifier: layerId, source: source)
                LayerPropertyConverter.addRasterProperties(
                    rasterLayer: layer,
                    properties: properties
                )
                if let minimumZoomLevel = minimumZoomLevel {
                    layer.minimumZoomLevel = Float(minimumZoomLevel)
                }
                if let maximumZoomLevel = maximumZoomLevel {
                    layer.maximumZoomLevel = Float(maximumZoomLevel)
                }
                if let id = belowLayerId, let belowLayer = style.layer(withIdentifier: id) {
                    style.insertLayer(layer, below: belowLayer)
                } else {
                    style.addLayer(layer)
                }
            }
        }
    }
    
    func addSourceGeojson(sourceId: String, geojson: String) {
        do {
            let parsed = try MGLShape(
                data: geojson.data(using: .utf8)!,
                encoding: String.Encoding.utf8.rawValue
            )
            let source = MGLShapeSource(identifier: sourceId, shape: parsed, options: [:])
            addedShapesByLayer[sourceId] = parsed
            mapView.style?.addSource(source)
            print(source)
        } catch {}
    }
    
    func setSource(sourceId: String, geojson: String) {
        do {
            let parsed = try MGLShape(
                data: geojson.data(using: .utf8)!,
                encoding: String.Encoding.utf8.rawValue
            )
            if let source = mapView.style?.source(withIdentifier: sourceId) as? MGLShapeSource {
                addedShapesByLayer[sourceId] = parsed
                source.shape = parsed
            }
        } catch {}
    }
    
    func setFeature(sourceId: String, geojsonFeature: String) {
        do {
            let newShape = try MGLShape(
                data: geojsonFeature.data(using: .utf8)!,
                encoding: String.Encoding.utf8.rawValue
            )
            if let source = mapView.style?.source(withIdentifier: sourceId) as? MGLShapeSource,
               let shape = addedShapesByLayer[sourceId] as? MGLShapeCollectionFeature,
               let feature = newShape as? MGLShape & MGLFeature
            {
                if let index = shape.shapes
                    .firstIndex(where: {
                        if let id = $0.identifier as? String,
                           let featureId = feature.identifier as? String
                        { return id == featureId }
                        
                        if let id = $0.identifier as? NSNumber,
                           let featureId = feature.identifier as? NSNumber
                        { return id == featureId }
                        return false
                    })
                {
                    var shapes = shape.shapes
                    shapes[index] = feature
                    
                    source.shape = MGLShapeCollectionFeature(shapes: shapes)
                }
                
                addedShapesByLayer[sourceId] = source.shape
            }
            
        } catch {}
    }
    
    func addSource(sourceId: String, properties: [String: Any]) {
        if let style = mapView.style, let type = properties["type"] as? String {
            var source: MGLSource?
            
            switch type {
            case "vector":
                source = SourcePropertyConverter.buildVectorTileSource(
                    identifier: sourceId,
                    properties: properties
                )
            case "raster":
                source = SourcePropertyConverter.buildRasterTileSource(
                    identifier: sourceId,
                    properties: properties
                )
            case "raster-dem":
                source = SourcePropertyConverter.buildRasterDemSource(
                    identifier: sourceId,
                    properties: properties
                )
            case "image":
                source = SourcePropertyConverter.buildImageSource(
                    identifier: sourceId,
                    properties: properties
                )
            case "geojson":
                source = SourcePropertyConverter.buildShapeSource(
                    identifier: sourceId,
                    properties: properties
                )
            default:
                // unsupported source type
                source = nil
            }
            if let source = source {
                style.addSource(source)
            }
        }
    }
    
    
    /*
     *  UITapGestureRecognizer
     *  On tap invoke the map#onMapClick callback.
     */
    @IBAction func handleMapTap(sender: UITapGestureRecognizer) {
        // Get the CGPoint where the user tapped.
        let point = sender.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        
        if let feature = firstFeatureOnLayers(at: point), let id = feature.identifier {
            channel?.invokeMethod("feature#onTap", arguments: [
                "id": id,
                "x": point.x,
                "y": point.y,
                "lng": coordinate.longitude,
                "lat": coordinate.latitude,
            ])
        } else {
            channel?.invokeMethod("map#onMapClick", arguments: [
                "x": point.x,
                "y": point.y,
                "lng": coordinate.longitude,
                "lat": coordinate.latitude,
            ])
        }
    }
    
    /*
     *  UILongPressGestureRecognizer
     *  After a long press invoke the map#onMapLongClick callback.
     */
    @IBAction func handleMapLongPress(sender: UILongPressGestureRecognizer) {
        // Fire when the long press starts
        if sender.state == .began {
            // Get the CGPoint where the user tapped.
            let point = sender.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            channel?.invokeMethod("map#onMapLongClick", arguments: [
                "x": point.x,
                "y": point.y,
                "lng": coordinate.longitude,
                "lat": coordinate.latitude,
            ])
        }
    }
    
    
    
    private func invokeFeatureDrag(
        _ point: CGPoint,
        _ coordinate: CLLocationCoordinate2D,
        _ eventType: String
    ) {
        if let feature = dragFeature,
           let id = feature.identifier,
           let previous = previousDragCoordinate,
           let origin = originDragCoordinate
        {
            channel?.invokeMethod("feature#onDrag", arguments: [
                "id": id,
                "x": point.x,
                "y": point.y,
                "originLng": origin.longitude,
                "originLat": origin.latitude,
                "currentLng": coordinate.longitude,
                "currentLat": coordinate.latitude,
                "eventType": eventType,
                "deltaLng": coordinate.longitude - previous.longitude,
                "deltaLat": coordinate.latitude - previous.latitude,
            ])
        }
    }
    
    @IBAction func handleMapPan(sender: UIPanGestureRecognizer) {
        let began = sender.state == UIGestureRecognizer.State.began
        let end = sender.state == UIGestureRecognizer.State.ended
        let point = sender.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        
        if dragFeature == nil, began, sender.numberOfTouches == 1,
           let feature = firstFeatureOnLayers(at: point),
           let draggable = feature.attribute(forKey: "draggable") as? Bool,
           draggable
        {
            sender.state = UIGestureRecognizer.State.began
            dragFeature = feature
            originDragCoordinate = coordinate
            previousDragCoordinate = coordinate
            mapView.allowsScrolling = false
            let eventType = "start"
            invokeFeatureDrag(point, coordinate, eventType)
            for gestureRecognizer in mapView.gestureRecognizers! {
                if let _ = gestureRecognizer as? UIPanGestureRecognizer {
                    gestureRecognizer.addTarget(self, action: #selector(handleMapPan))
                    break
                }
            }
        }
        if end, dragFeature != nil {
            mapView.allowsScrolling = true
            let eventType = "end"
            invokeFeatureDrag(point, coordinate, eventType)
            dragFeature = nil
            originDragCoordinate = nil
            previousDragCoordinate = nil
        }
        
        if !began, !end, dragFeature != nil {
            let eventType = "drag"
            invokeFeatureDrag(point, coordinate, eventType)
            previousDragCoordinate = coordinate
        }
    }
    
    /*
     * Override the attribution button's click target to handle the event locally.
     * Called if the application supplies an onAttributionClick handler.
     */
    func setupAttribution(_ mapView: MGLMapView) {
        mapView.attributionButton.removeTarget(
            mapView,
            action: #selector(mapView.showAttribution),
            for: .touchUpInside
        )
        mapView.attributionButton.addTarget(
            self,
            action: #selector(showAttribution),
            for: UIControl.Event.touchUpInside
        )
    }
    
    /*
     * Custom click handler for the attribution button. This callback is bound when
     * the application specifies an onAttributionClick handler.
     */
    @objc func showAttribution() {
        channel?.invokeMethod("map#onAttributionClick", arguments: [])
    }
    
    /*
     *  VNPTMapViewOptionsSink
     */
    func setCameraTargetBounds(bounds: MGLCoordinateBounds?) {
        cameraTargetBounds = bounds
    }
    
    func setCompassEnabled(compassEnabled: Bool) {
        mapView.compassView.isHidden = compassEnabled
        mapView.compassView.isHidden = !compassEnabled
    }
    
    func setMinMaxZoomPreference(min: Double, max: Double) {
        mapView.minimumZoomLevel = min
        mapView.maximumZoomLevel = max
    }
    
    func setStyleString(styleString: String) {
        // Check if json, url, absolute path or asset path:
        if styleString.isEmpty {
            NSLog("setStyleString - string empty")
        } else if styleString.hasPrefix("{") || styleString.hasPrefix("[") {
            // Currently the iOS Mapbox SDK does not have a builder for json.
            NSLog("setStyleString - JSON style currently not supported")
        } else if styleString.hasPrefix("/") {
            // Absolute path
            mapView.styleURL = URL(fileURLWithPath: styleString, isDirectory: false)
        } else if
            !styleString.hasPrefix("http://"),
            !styleString.hasPrefix("https://"),
            !styleString.hasPrefix("mapbox://")
        {
            // We are assuming that the style will be loaded from an asset here.
            let assetPath = registrar.lookupKey(forAsset: styleString)
            mapView.styleURL = URL(string: assetPath, relativeTo: Bundle.main.resourceURL)
            
        } else {
            mapView.styleURL = URL(string: styleString)
        }
    }
    
    func setRotateGesturesEnabled(rotateGesturesEnabled: Bool) {
        mapView.allowsRotating = rotateGesturesEnabled
    }
    
    func setScrollGesturesEnabled(scrollGesturesEnabled: Bool) {
        mapView.allowsScrolling = scrollGesturesEnabled
        scrollingEnabled = scrollGesturesEnabled
    }
    
    func setTiltGesturesEnabled(tiltGesturesEnabled: Bool) {
        mapView.allowsTilting = tiltGesturesEnabled
    }
    
    func setTrackCameraPosition(trackCameraPosition: Bool) {
        self.trackCameraPosition = trackCameraPosition
    }
    
    func setZoomGesturesEnabled(zoomGesturesEnabled: Bool) {
        mapView.allowsZooming = zoomGesturesEnabled
    }
    
    func setLogoViewMargins(x: Double, y: Double) {
        mapView.logoViewMargins = CGPoint(x: x, y: y)
    }
    
    func setCompassViewPosition(position: MGLOrnamentPosition) {
        mapView.compassViewPosition = position
    }
    
    func setCompassViewMargins(x: Double, y: Double) {
        mapView.compassViewMargins = CGPoint(x: x, y: y)
    }
    
    func setAttributionButtonMargins(x: Double, y: Double) {
        mapView.attributionButtonMargins = CGPoint(x: x, y: y)
    }
    
    func setAttributionButtonPosition(position: MGLOrnamentPosition) {
        mapView.attributionButtonPosition = position
    }
    
    func setMyLocationTrackingMode(myLocationTrackingMode: MGLUserTrackingMode) {
        mapView.userTrackingMode = myLocationTrackingMode
    }
    
    func setMyLocationEnabled(myLocationEnabled: Bool) {
        
        if self.myLocationEnabled == myLocationEnabled {
            return
        }
        self.myLocationEnabled = myLocationEnabled
        updateMyLocationEnabled()
        
    }
    
    
    func setMyLocationRenderMode(myLocationRenderMode: MyLocationRenderMode) {
        switch myLocationRenderMode {
        case .Normal:
            mapView.showsUserHeadingIndicator = false
        case .Compass:
            mapView.showsUserHeadingIndicator = true
        case .Gps:
            NSLog("RenderMode.GPS currently not supported")
        }
    }
    
    
    /** Define the functions handler logic on this **/
    private func getCamera() -> MGLMapCamera? {
        return trackCameraPosition ? mapView.camera : nil
    }
    
    private func updateMyLocationEnabled() {
        mapView.showsUserLocation = myLocationEnabled
    }
    
    /*
     *  Scan layers from top to bottom and return the first matching feature
     */
    private func firstFeatureOnLayers(at: CGPoint) -> MGLFeature? {
        guard let style = mapView.style else { return nil }
        
        // get layers in order (interactiveFeatureLayerIds is unordered)
        let clickableLayers = style.layers.filter { layer in
            interactiveFeatureLayerIds.contains(layer.identifier)
        }
        
        for layer in clickableLayers.reversed() {
            let features = mapView.visibleFeatures(
                at: at,
                styleLayerIdentifiers: [layer.identifier]
            )
            if let feature = features.first {
                return feature
            }
        }
        return nil
    }
    
    
}