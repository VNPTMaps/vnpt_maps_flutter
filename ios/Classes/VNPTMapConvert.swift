//
//  Convert.swift
//  Pods
//
//  Created by hmtri on 01/11/2022.
//

import Mapbox

class VNPTMapConvert {
    class func interpretVNPTMapOptions(options: Any?, delegate: VNPTMapViewOptionsSink) {
        guard let options = options as? [String: Any] else { return }
        if let cameraTargetBounds = options["cameraTargetBounds"] as? [[[Double]]] {
            delegate
                .setCameraTargetBounds(bounds: MGLCoordinateBounds.fromArray(cameraTargetBounds[0]))
        }
        if let compassEnabled = options["compassEnabled"] as? Bool {
            delegate.setCompassEnabled(compassEnabled: compassEnabled)
        }
        if let minMaxZoomPreference = options["minMaxZoomPreference"] as? [Double] {
            delegate.setMinMaxZoomPreference(
                min: minMaxZoomPreference[0],
                max: minMaxZoomPreference[1]
            )
        }
        if let styleString = options["styleString"] as? String {
            delegate.setStyleString(styleString: styleString)
        }
        if let rotateGesturesEnabled = options["rotateGesturesEnabled"] as? Bool {
            delegate.setRotateGesturesEnabled(rotateGesturesEnabled: rotateGesturesEnabled)
        }
        if let scrollGesturesEnabled = options["scrollGesturesEnabled"] as? Bool {
            delegate.setScrollGesturesEnabled(scrollGesturesEnabled: scrollGesturesEnabled)
        }
        if let tiltGesturesEnabled = options["tiltGesturesEnabled"] as? Bool {
            delegate.setTiltGesturesEnabled(tiltGesturesEnabled: tiltGesturesEnabled)
        }
        if let trackCameraPosition = options["trackCameraPosition"] as? Bool {
            delegate.setTrackCameraPosition(trackCameraPosition: trackCameraPosition)
        }
        if let zoomGesturesEnabled = options["zoomGesturesEnabled"] as? Bool {
            delegate.setZoomGesturesEnabled(zoomGesturesEnabled: zoomGesturesEnabled)
        }
        if let myLocationEnabled = options["myLocationEnabled"] as? Bool {
            delegate.setMyLocationEnabled(myLocationEnabled: myLocationEnabled)
        }
        if let myLocationTrackingMode = options["myLocationTrackingMode"] as? UInt,
           let trackingMode = MGLUserTrackingMode(rawValue: myLocationTrackingMode)
        {
            delegate.setMyLocationTrackingMode(myLocationTrackingMode: trackingMode)
        }
        if let myLocationRenderMode = options["myLocationRenderMode"] as? Int,
           let renderMode = MyLocationRenderMode(rawValue: myLocationRenderMode)
        {
            delegate.setMyLocationRenderMode(myLocationRenderMode: renderMode)
        }
        if let logoViewMargins = options["logoViewMargins"] as? [Double] {
            delegate.setLogoViewMargins(x: logoViewMargins[0], y: logoViewMargins[1])
        }
        if let compassViewPosition = options["compassViewPosition"] as? UInt,
           let position = MGLOrnamentPosition(rawValue: compassViewPosition)
        {
            delegate.setCompassViewPosition(position: position)
        }
        if let compassViewMargins = options["compassViewMargins"] as? [Double] {
            delegate.setCompassViewMargins(x: compassViewMargins[0], y: compassViewMargins[1])
        }
        if let attributionButtonMargins = options["attributionButtonMargins"] as? [Double] {
            delegate.setAttributionButtonMargins(
                x: attributionButtonMargins[0],
                y: attributionButtonMargins[1]
            )
        }
        if let attributionButtonPosition = options["attributionButtonPosition"] as? UInt,
           let position = MGLOrnamentPosition(rawValue: attributionButtonPosition)
        {
            delegate.setAttributionButtonPosition(position: position)
        }
    }
    
    class func parseMarkersToAdd(markersJson: [[String: Any]], registrar: (NSObjectProtocol & FlutterPluginRegistrar)?) -> [VNPTMapMarker] {
        var annotations = [VNPTMapMarker]()
        markersJson.forEach { markerJson in
            guard let markerId = markerJson["markerId"] as? String else {return}
            guard let infoWindowJson = markerJson["infoWindow"] as? [String: Any] else {return}
            guard let position = markerJson["position"] as? [Double] else {return}
                        
            let extractedIcon = VNPTMapConvert.extractIcon(markerJson["icon"] as? [AnyHashable], registrar: registrar)
            
            let newAnnotation = VNPTMapMarker(
                markerId: markerId,
                coordinate: CLLocationCoordinate2D(latitude: position[0], longitude: position[1]),
                title: infoWindowJson["title"] as? String,
                subtitle: infoWindowJson["snippet"] as? String,
                icon: extractedIcon.icon,
                iconIdentify: extractedIcon.iconIdentify,
                consumeTapEvent: markerJson["consumeTapEvents"] as? Bool
//                rotation: markerJson["rotation"] as? Double,
//                dragable: markerJson["draggable"] as? Bool,
//                visible: markerJson["visible"] as? Bool
            )
            annotations.append(newAnnotation)
        }
        
        return annotations
    }
    
    class func parsePolylinesToAdd(polylinesJson: [[String: Any]]) -> [VNPTMapPolyline] {
        var polylines = [VNPTMapPolyline]()
        polylinesJson.forEach { polylineJson in
            guard let polylineId = polylineJson["polylineId"] as? String else {return}
            guard let points = polylineJson["points"] as? [[Double]] else {return}
            let coordinates = VNPTMapConvert.toCoordinates(points)
            
            let newPolyline = VNPTMapPolyline(coordinates: coordinates, count: UInt(coordinates.count))
            newPolyline.polylineId = polylineId
            newPolyline.width = polylineJson["width"] as? Double ?? 10.0
            newPolyline.consumeTapEvents = polylineJson["consumeTapEvents"] as? Bool ?? false
            newPolyline.color = VNPTMapConvert.toColor(polylineJson["color"] as? NSNumber) ?? UIColor.blue
            newPolyline.alpha = polylineJson["alpha"] as? Double ?? 1.0
            
            polylines.append(newPolyline)
        }
        
        return polylines
    }
    
    class func parsePolygonsToAdd(polygonsJson: [[String: Any]]) -> [VNPTMapPolygon] {
        var polygons = [VNPTMapPolygon]()
        polygonsJson.forEach { polygonJson in
            guard let polygonId = polygonJson["polygonId"] as? String else {return}
            guard let points = polygonJson["points"] as? [[Double]] else {return}
            
            let coordinates = VNPTMapConvert.toCoordinates(points)
            
            var interiorPolygons: [MGLPolygon]?
            if let interiorPoints = polygonJson["holes"] as? [[[Double]]] {
                interiorPolygons = VNPTMapConvert.toInteriorPolygons(interiorPoints)
            }
            
            let newPolygon = VNPTMapPolygon(coordinates: coordinates, count: UInt(coordinates.count), interiorPolygons: interiorPolygons)
            newPolygon.polygonId = polygonId
            newPolygon.fillColor = VNPTMapConvert.toColor(polygonJson["fillColor"] as? NSNumber) ?? UIColor.blue.withAlphaComponent(0.8)
            newPolygon.strokeColor = VNPTMapConvert.toColor(polygonJson["strokeColor"] as? NSNumber) ?? UIColor.blue
            newPolygon.consumeTapEvents = polygonJson["consumeTapEvents"] as? Bool ?? false
            newPolygon.fillAlpha = polygonJson["fillAlpha"] as? Double ?? 1.0
                    
            polygons.append(newPolygon)
        }
        
        return polygons
    }
    
    class func parseCameraUpdate(cameraUpdate: [Any], mapView: MGLMapView) -> MGLMapCamera? {
        guard let type = cameraUpdate[0] as? String else { return nil }
        switch type {
        case "newCameraPosition":
            guard let cameraPosition = cameraUpdate[1] as? [String: Any] else { return nil }
            return MGLMapCamera.fromDict(cameraPosition, mapView: mapView)
        case "newLatLng":
            guard let coordinate = cameraUpdate[1] as? [Double] else { return nil }
            let camera = mapView.camera
            camera.centerCoordinate = CLLocationCoordinate2D.fromArray(coordinate)
            return camera
        case "newLatLngBounds":
            guard let bounds = cameraUpdate[1] as? [[Double]] else { return nil }
            if let padding = parseLatLngBoundsPadding(cameraUpdate) {
                return mapView.cameraThatFitsCoordinateBounds(
                    MGLCoordinateBounds.fromArray(bounds),
                    edgePadding: padding
                )
            }
            return mapView.cameraThatFitsCoordinateBounds(MGLCoordinateBounds.fromArray(bounds))
        case "newLatLngZoom":
            guard let coordinate = cameraUpdate[1] as? [Double] else { return nil }
            guard let zoom = cameraUpdate[2] as? Double else { return nil }
            let camera = mapView.camera
            camera.centerCoordinate = CLLocationCoordinate2D.fromArray(coordinate)
            let altitude = getAltitude(zoom: zoom, mapView: mapView)
            return MGLMapCamera(
                lookingAtCenter: camera.centerCoordinate,
                altitude: altitude,
                pitch: camera.pitch,
                heading: camera.heading
            )
        case "scrollBy":
            guard let x = cameraUpdate[1] as? CGFloat else { return nil }
            guard let y = cameraUpdate[2] as? CGFloat else { return nil }
            let camera = mapView.camera
            let mapPoint = mapView.convert(camera.centerCoordinate, toPointTo: mapView)
            let movedPoint = CGPoint(x: mapPoint.x + x, y: mapPoint.y + y)
            camera.centerCoordinate = mapView.convert(movedPoint, toCoordinateFrom: mapView)
            return camera
        case "zoomBy":
            guard let zoomBy = cameraUpdate[1] as? Double else { return nil }
            let camera = mapView.camera
            let zoom = getZoom(mapView: mapView)
            let altitude = getAltitude(zoom: zoom + zoomBy, mapView: mapView)
            camera.altitude = altitude
            if cameraUpdate.count == 2 {
                return camera
            } else {
                guard let point = cameraUpdate[2] as? [CGFloat],
                      point.count == 2 else { return nil }
                let movedPoint = CGPoint(x: point[0], y: point[1])
                camera.centerCoordinate = mapView.convert(movedPoint, toCoordinateFrom: mapView)
                return camera
            }
        case "zoomIn":
            let camera = mapView.camera
            let zoom = getZoom(mapView: mapView)
            let altitude = getAltitude(zoom: zoom + 1, mapView: mapView)
            camera.altitude = altitude
            return camera
        case "zoomOut":
            let camera = mapView.camera
            let zoom = getZoom(mapView: mapView)
            let altitude = getAltitude(zoom: zoom - 1, mapView: mapView)
            camera.altitude = altitude
            return camera
        case "zoomTo":
            guard let zoom = cameraUpdate[1] as? Double else { return nil }
            let camera = mapView.camera
            let altitude = getAltitude(zoom: zoom, mapView: mapView)
            camera.altitude = altitude
            return camera
        case "bearingTo":
            guard let bearing = cameraUpdate[1] as? Double else { return nil }
            let camera = mapView.camera
            camera.heading = bearing
            return camera
        case "tiltTo":
            guard let tilt = cameraUpdate[1] as? CGFloat else { return nil }
            let camera = mapView.camera
            camera.pitch = tilt
            return camera
        default:
            print("\(type) not implemented!")
        }
        return nil
    }
    
    class func parseLatLngBoundsPadding(_ cameraUpdate: [Any]) -> UIEdgeInsets? {
        guard let methodName = cameraUpdate[0] as? String else { return nil }
        
        if(methodName != "newLatLngBounds") {
            return nil
        }
        
        guard let paddingLeft = cameraUpdate[2] as? CGFloat else { return nil }
        guard let paddingTop = cameraUpdate[3] as? CGFloat else { return nil }
        guard let paddingRight = cameraUpdate[4] as? CGFloat else { return nil }
        guard let paddingBottom = cameraUpdate[5] as? CGFloat else { return nil }
        
        return UIEdgeInsets(top: paddingTop, left: paddingLeft, bottom: paddingBottom, right: paddingRight)
    }
    
    class func getZoom(mapView: MGLMapView) -> Double {
        return MGLZoomLevelForAltitude(
            mapView.camera.altitude,
            mapView.camera.pitch,
            mapView.camera.centerCoordinate.latitude,
            mapView.frame.size
        )
    }
    
    class func getAltitude(zoom: Double, mapView: MGLMapView) -> Double {
        return MGLAltitudeForZoomLevel(
            zoom,
            mapView.camera.pitch,
            mapView.camera.centerCoordinate.latitude,
            mapView.frame.size
        )
    }
    
    class func getCoordinates(options: Any?) -> [CLLocationCoordinate2D] {
        var coordinates: [CLLocationCoordinate2D] = []
        
        if let options = options as? [String: Any],
           let geometry = options["geometry"] as? [[Double]], geometry.count > 0
        {
            for coordinate in geometry {
                coordinates.append(CLLocationCoordinate2DMake(coordinate[0], coordinate[1]))
            }
        }
        return coordinates
    }
    
    class func scale(_ image: UIImage?, scale scaleParam: NSNumber?) -> UIImage? {
        var scale = 1.0
        if scaleParam != nil {
            scale = scaleParam?.doubleValue ?? 0.0
        }

        if abs(Float(scale - 1)) > 1e-3 {
            if let cgImage = image?.cgImage, let imageOrientation = image?.imageOrientation {
                return UIImage(
                    cgImage: cgImage,
                    scale: (image?.scale ?? 0.0) * scale,
                    orientation: imageOrientation)
            }
            return nil
        }
        return image
    }

    class func extractIcon(_ iconData: [AnyHashable]?, registrar: (NSObjectProtocol & FlutterPluginRegistrar)?) -> (icon: UIImage?, iconIdentify: String?) {
        var image: UIImage? = nil
        var iconIdentify: String? = nil
        if iconData?.first as? String == "defaultMarker" {
            image = nil
        } else if iconData?.first as? String == "fromAssetImage" {
            if (iconData?.count ?? 0) == 3 {
                let key = registrar?.lookupKey(forAsset: iconData?[1] as? String ?? "")
                let imagePath = Bundle.main.path(forResource: key, ofType: nil)
                image = UIImage(contentsOfFile: imagePath ?? "")
                let scaleParam = iconData?[2] as? NSNumber
                image = VNPTMapConvert.scale(image, scale: scaleParam)
                iconIdentify = imagePath
            } else {
                print(
                    String(format: "InvalidBitmapDescriptor | 'fromAssetImage' should have exactly 3 arguments. Got: %lu", UInt(iconData?.count ?? 0)))
            }
        } else if iconData?[0] as? String == "fromBytes" {
            if (iconData?.count ?? 0) == 2 {
                if let byteData = iconData?[1] as? FlutterStandardTypedData {
                    let screenScale = UIScreen.main.scale
                    let myData = Data(byteData.data)
                    image = UIImage(data: myData, scale: screenScale)
                    iconIdentify = "\(myData.hashValue)"
                }
            } else {
                print(
                    String(format: "InvalidByteDescriptor | 'fromBytes' should have exactly 2 arguments, the bytes. Got: %lu", UInt(iconData?.count ?? 0)))
            }
        }

        return (image, iconIdentify)
    }
    
    class func toColor(_ numberColor: NSNumber?) -> UIColor? {
        let value = numberColor?.uintValue ?? 0
        return UIColor(
            red: CGFloat((Float((value & 0xff0000) >> 16)) / 255.0),
            green: CGFloat((Float((value & 0xff00) >> 8)) / 255.0),
            blue: CGFloat((Float(value & 0xff)) / 255.0),
            alpha: CGFloat((Float((value & 0xff000000) >> 24)) / 255.0))
    }
    
    class func toCoordinates(_ position: [[Double]]) -> [CLLocationCoordinate2D] {
        var coorfinates = [CLLocationCoordinate2D]()
        position.forEach { point in
            let coordinate = CLLocationCoordinate2D(latitude: point[0], longitude: point[1])
            coorfinates.append(coordinate)
        }
        return coorfinates
    }
    
    class func toInteriorPolygons(_ interiorPoints: [[[Double]]]) -> [MGLPolygon]? {
        var interiorPolygons = [MGLPolygon]()
        interiorPoints.forEach { points in
            let newInteriorPoints = VNPTMapConvert.toCoordinates(points)
            if newInteriorPoints.count > 0 {
                interiorPolygons.append(MGLPolygon(coordinates: newInteriorPoints, count: UInt(newInteriorPoints.count)))
            }
            
        }
        if interiorPolygons.count > 0 {
            return interiorPolygons
        }
        
        return nil
    }
}
