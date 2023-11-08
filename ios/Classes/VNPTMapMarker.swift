//
//  VNPTMapMarker.swift
//  flutter_vnptmap_gl
//
//  Created by Võ Toàn on 08/11/2022.
//

import UIKit
import Mapbox

class VNPTMapMarker: NSObject, MGLAnnotation {
    let markerId: String
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let icon: UIImage?
    let iconIdentify: String?
    let consumeTapEvent: Bool
//    let rotation: Double
//    let dragable: Bool
//    let visible: Bool

    
    init(markerId: String, coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, icon: UIImage?, iconIdentify: String?, consumeTapEvent: Bool?) {
        self.markerId = markerId
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.iconIdentify = iconIdentify
        self.consumeTapEvent = consumeTapEvent ?? true
//        self.rotation = rotation ?? 0.0
//        self.dragable = dragable ?? false
//        self.visible = visible ?? true
    }
}
