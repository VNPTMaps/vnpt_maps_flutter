//
//  VNPTMapPolygon.swift
//  flutter_vnptmap_gl
//
//  Created by Võ Toàn on 15/11/2022.
//
import Mapbox

class VNPTMapPolygon: MGLPolygon {
    var polygonId: String?
    var fillColor: UIColor?
    var fillAlpha: Double?
    var strokeColor: UIColor?
    var consumeTapEvents: Bool?
    
//    init(coordinates: UnsafePointer<CLLocationCoordinate2D>, count: UInt, interiorPolygons: [MGLPolygon]?, polygonId: String, fillColor: UIColor?, strokeColor: UIColor?, consumeTapEvents: Bool?, strokeWidth: Double?) {
//        self.polygonId = polygonId
//        self.fillColor = fillColor ?? UIColor.blue
//        self.strokeColor = strokeColor ?? UIColor.systemBlue
//        self.consumeTapEvents = consumeTapEvents ?? false
//        self.strokeWidth = strokeWidth ?? 10
//        super.init(coordinates: coordinates, count: count, interiorPolygons: interiorPolygons)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
}
