//
//  VNPTMapPolyline.swift
//  flutter_vnptmap_gl
//
//  Created by Võ Toàn on 14/11/2022.
//

import Mapbox

class VNPTMapPolyline: MGLPolyline {
    var polylineId: String?
    var color: UIColor?
    var consumeTapEvents: Bool?
    var width: Double?
    var alpha: Double?
}
