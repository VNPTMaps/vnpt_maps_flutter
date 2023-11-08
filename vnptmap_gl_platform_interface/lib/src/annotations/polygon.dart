part of vnptmap_gl_platform_interface;

typedef OnPolygonTapCallback = void Function(PolygonId polygonId);

@immutable
class PolygonId extends MapsObjectId<Polygon> {
  /// Creates an immutable identifier for a [Polygon].
  const PolygonId(String value) : super(value);
}

class Polygon implements MapsObject {
  /// Creates an immutable object representing a line drawn through geographical locations on the map.
  Polygon({
    required this.polygonId,
    this.consumeTapEvents = false,
    this.fillColor = Colors.black,
    this.fillAlpha = 1.0,
    this.points = const <LatLng>[],
    this.holes = const <List<LatLng>>[],
    this.strokeColor = Colors.black,
    this.onTap,
  });

  /// Uniquely identifies a [Polygon].
  final PolygonId polygonId;

  @override
  PolygonId get mapsId => polygonId;

  /// True if the [Polygon] consumes tap events.
  ///
  /// If this is false, [onTap] callback will not be triggered.
  final bool consumeTapEvents;

  /// Fill color in ARGB format, the same format used by Color. The default value is black (0xff000000).
  final Color fillColor;

  final double fillAlpha;

  /// The vertices of the polygon to be drawn.
  ///
  /// Line segments are drawn between consecutive points. A polygon is not closed by
  /// default; to form a closed polygon, the start and end points must be the same.
  final List<LatLng> points;

  /// To create an empty area within a polygon, you need to use holes.
  /// To create the hole, the coordinates defining the hole path must be inside the polygon.
  ///
  /// The vertices of the holes to be cut out of polygon.
  ///
  /// Line segments of each points of hole are drawn inside polygon between consecutive hole points.
  final List<List<LatLng>> holes;

  /// Line color in ARGB format, the same format used by Color. The default value is black (0xff000000).
  final Color strokeColor;

  /// Callbacks to receive tap events for polygon placed on this map.
  final OnPolygonTapCallback? onTap;

  /// Creates a new [Polygon] object whose values are the same as this instance,
  /// unless overwritten by the specified parameters.
  Polygon copyWith({
    bool? consumeTapEventsParam,
    Color? fillColorParam,
    double? fillAlphaParam,
    List<LatLng>? pointsParam,
    List<List<LatLng>>? holesParam,
    Color? strokeColorParam,
    OnPolygonTapCallback? onTapParam,
  }) {
    return Polygon(
      polygonId: polygonId,
      consumeTapEvents: consumeTapEventsParam ?? consumeTapEvents,
      fillColor: fillColorParam ?? fillColor,
      fillAlpha: fillAlphaParam ?? fillAlpha,
      points: pointsParam ?? points,
      holes: holesParam ?? holes,
      strokeColor: strokeColorParam ?? strokeColor,
      onTap: onTapParam ?? onTap,
    );
  }

  /// Creates a new [Polygon] object whose values are the same as this
  /// instance.
  @override
  Polygon clone() {
    return copyWith(
      pointsParam: List<LatLng>.of(points),
    );
  }

  /// Converts this object to something serializable in JSON.
  /// Converts this object to something serializable in JSON.
  @override
  Object toJson() {
    final Map<String, Object> json = <String, Object>{};

    void addIfPresent(String fieldName, Object? value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('polygonId', polygonId.value);
    addIfPresent('consumeTapEvents', consumeTapEvents);
    addIfPresent('fillColor', fillColor.value);
    addIfPresent('strokeColor', strokeColor.value);
    addIfPresent('fillAlpha', fillAlpha);

    json['points'] = _pointsToJson();

    json['holes'] = _holesToJson();

    return json;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final Polygon typedOther = other as Polygon;
    return polygonId == typedOther.polygonId &&
        consumeTapEvents == typedOther.consumeTapEvents &&
        fillColor == typedOther.fillColor &&
        fillAlpha == typedOther.fillAlpha &&
        listEquals(points, typedOther.points) &&
        const DeepCollectionEquality().equals(holes, typedOther.holes) &&
        strokeColor == typedOther.strokeColor;
  }

  @override
  int get hashCode => polygonId.hashCode;

  Object _pointsToJson() {
    final List<Object> result = <Object>[];
    for (final LatLng point in points) {
      result.add(point.toJson());
    }
    return result;
  }

  List<List<Object>> _holesToJson() {
    final List<List<Object>> result = <List<Object>>[];
    for (final List<LatLng> hole in holes) {
      final List<Object> jsonHole = <Object>[];
      for (final LatLng point in hole) {
        jsonHole.add(point.toJson());
      }
      result.add(jsonHole);
    }
    return result;
  }
}

/// [Polygon] update events to be applied to the [VNPTMap].
///
/// Used in [VNPTMapController] when the map is updated.
// (Do not re-export)
class PolygonUpdates extends MapsObjectUpdates<Polygon> {
  /// Computes [PolygonUpdates] given previous and current [Polygon]s.
  PolygonUpdates.from(Set<Polygon> previous, Set<Polygon> current)
      : super.from(previous, current, objectName: 'polygon');

  /// Set of Polygons to be added in this update.
  Set<Polygon> get polygonsToAdd => objectsToAdd;

  /// Set of PolygonIds to be removed in this update.
  Set<PolygonId> get polygonIdsToRemove => objectIdsToRemove.cast<PolygonId>();

  /// Set of Polygons to be changed in this update.
  Set<Polygon> get polygonsToChange => objectsToChange;
}
