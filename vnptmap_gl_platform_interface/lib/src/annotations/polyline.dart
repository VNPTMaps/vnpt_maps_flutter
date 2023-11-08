part of vnptmap_gl_platform_interface;

typedef OnPolylineTapCallback = void Function(PolylineId polylineId);

@immutable
class PolylineId extends MapsObjectId<Polyline> {
  /// Creates an immutable identifier for a [Polyline].
  const PolylineId(String value) : super(value);
}

class Polyline implements MapsObject {
  /// Creates an immutable object representing a line drawn through geographical locations on the map.
  Polyline({
    required this.polylineId,
    this.consumeTapEvents = false,
    this.points = const <LatLng>[],
    this.width = 10,
    this.color = Colors.red,
    this.alpha = 1.0,
    this.onTap,
  });

  /// Uniquely identifies a [Polyline].
  final PolylineId polylineId;

  @override
  PolylineId get mapsId => polylineId;

  /// True if the [Polyline] consumes tap events.
  ///
  /// If this is false, [onTap] callback will not be triggered.
  final bool consumeTapEvents;

  /// Line segment color in ARGB format, the same format used by Color. The default value is black (0xff000000).
  final Color color;

  /// Alpha color in ARGB format, the same format used by Color. The default value is black (0xff000000).
  final double alpha;

  /// The vertices of the polyline to be drawn.
  ///
  /// Line segments are drawn between consecutive points. A polyline is not closed by
  /// default; to form a closed polyline, the start and end points must be the same.
  final List<LatLng> points;

  /// Width of the polyline, used to define the width of the line segment to be drawn.
  ///
  /// The width is constant and independent of the camera's zoom level.
  /// The default value is 10.
  final int width;

  /// Callbacks to receive tap events for polyline placed on this map.
  final OnPolylineTapCallback? onTap;

  /// Creates a new [Polyline] object whose values are the same as this instance,
  /// unless overwritten by the specified parameters.
  Polyline copyWith({
    Color? colorParam,
    double? alphaParam,
    bool? consumeTapEventsParam,
    List<LatLng>? pointsParam,
    int? widthParam,
    OnPolylineTapCallback? onTapParam,
  }) {
    return Polyline(
      polylineId: polylineId,
      color: colorParam ?? color,
      alpha: alphaParam ?? alpha,
      consumeTapEvents: consumeTapEventsParam ?? consumeTapEvents,
      points: pointsParam ?? points,
      width: widthParam ?? width,
      onTap: onTapParam ?? onTap,
    );
  }

  /// Creates a new [Polyline] object whose values are the same as this
  /// instance.
  @override
  Polyline clone() {
    return copyWith(
      pointsParam: List<LatLng>.of(points),
    );
  }

  /// Converts this object to something serializable in JSON.
  @override
  Object toJson() {
    final Map<String, Object> json = <String, Object>{};

    void addIfPresent(String fieldName, Object? value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('polylineId', polylineId.value);
    addIfPresent('consumeTapEvents', consumeTapEvents);
    addIfPresent('color', color.value);
    addIfPresent('alpha', alpha);
    addIfPresent('width', width);

    json['points'] = _pointsToJson();

    return json;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final Polyline typedOther = other as Polyline;
    return polylineId == typedOther.polylineId &&
        consumeTapEvents == typedOther.consumeTapEvents &&
        color == typedOther.color &&
        alpha == typedOther.alpha &&
        listEquals(points, typedOther.points) &&
        width == typedOther.width;
  }

  @override
  int get hashCode => polylineId.hashCode;

  Object _pointsToJson() {
    final List<Object> result = <Object>[];
    for (final LatLng point in points) {
      result.add(point.toJson());
    }
    return result;
  }
}

/// [Polyline] update events to be applied to the [VNPTMap].
///
/// Used in [VNPTMapController] when the map is updated.
// (Do not re-export)
class PolylineUpdates extends MapsObjectUpdates<Polyline> {
  /// Computes [PolylineUpdates] given previous and current [Polyline]s.
  PolylineUpdates.from(Set<Polyline> previous, Set<Polyline> current)
      : super.from(previous, current, objectName: 'polyline');

  /// Set of Polylines to be added in this update.
  Set<Polyline> get polylinesToAdd => objectsToAdd;

  /// Set of PolylineIds to be removed in this update.
  Set<PolylineId> get polylineIdsToRemove =>
      objectIdsToRemove.cast<PolylineId>();

  /// Set of Polylines to be changed in this update.
  Set<Polyline> get polylinesToChange => objectsToChange;
}
