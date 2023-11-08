part of vnptmap_gl_platform_interface;

/// Converts an [Iterable] of Markers in a Map of MarkerID -> Marker.
Map<MarkerId, Marker> keyByMarkerId(Iterable<Marker> markers) {
  return keyByMapsObjectId<Marker>(markers).cast<MarkerId, Marker>();
}

/// Converts a Set of Markers into something serializable in JSON.
Object serializeMarkerSet(Set<Marker> markers) {
  return serializeMapsObjectSet(markers);
}


/// Converts an [Iterable] of Polylines in a Map of PolylineId -> Polyline.
Map<PolylineId, Polyline> keyByPolylineId(Iterable<Polyline> polylines) {
  return keyByMapsObjectId<Polyline>(polylines)
      .cast<PolylineId, Polyline>();
}

/// Converts a Set of Polylines into something serializable in JSON.
Object serializePolylineSet(Set<Polyline> polylines) {
  return serializeMapsObjectSet(polylines);
}

/// Converts an [Iterable] of Polygons in a Map of PolygonId -> Polygon.
Map<PolygonId, Polygon> keyByPolygonId(Iterable<Polygon> polygons) {
  return keyByMapsObjectId<Polygon>(polygons).cast<PolygonId, Polygon>();
}

/// Converts a Set of Polygons into something serializable in JSON.
Object serializePolygonSet(Set<Polygon> polygons) {
  return serializeMapsObjectSet(polygons);
}