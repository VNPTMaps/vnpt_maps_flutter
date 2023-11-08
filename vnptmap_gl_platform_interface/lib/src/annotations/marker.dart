part of vnptmap_gl_platform_interface;

typedef OnMarkerTapCallback = void Function(MarkerId markerId);

typedef OnInfoWindowTapCallback = void Function(MarkerId markerId);

@immutable
class MarkerId extends MapsObjectId<Marker> {
  /// Creates an immutable identifier for a [Marker].
  const MarkerId(String value) : super(value);
}

class Marker implements MapsObject {
  const Marker({
    required this.markerId,
    this.consumeTapEvents = false,
    this.position = const LatLng(0.0, 0.0),
    this.icon = Bitmap.defaultIcon,
    this.infoWindow = InfoWindow.noText,
    this.onTap,
  });

  final MarkerId markerId;

  @override
  MarkerId get mapsId => markerId;

  /// True if the [Marker] consumes tap events.
  ///
  /// If this is false, [onTap] callback will not be triggered.
  final bool consumeTapEvents;

  final LatLng position;

  /// A description of the bitmap used to draw the marker icon.
  final Bitmap icon;

  /// The window is displayed when the marker is tapped.
  final InfoWindow infoWindow;

  /// Callbacks to receive tap events for marker placed on this map.
  final OnMarkerTapCallback? onTap;

  /// Creates a new [Marker] object whose values are the same as this instance,
  /// unless overwritten by the specified parameters.
  Marker copyWith({
    bool? consumeTapEventsParam,
    LatLng? positionParam,
    Bitmap? iconParam,
    InfoWindow? infoWindowParam,
    OnMarkerTapCallback? onTapParam,
  }) {
    return Marker(
      consumeTapEvents: consumeTapEventsParam ?? consumeTapEvents,
      markerId: markerId,
      position: positionParam ?? position,
      icon: iconParam ?? icon,
      infoWindow: infoWindowParam ?? infoWindow,
      onTap: onTapParam ?? onTap,
    );
  }

  @override
  Marker clone() => copyWith();

  /// Converts this object to something serializable in JSON.
  @override
  Object toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};

    void addIfPresent(String fieldName, dynamic value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('markerId', markerId.value);
    addIfPresent('consumeTapEvents', consumeTapEvents);
    addIfPresent('position', position.toJson());
    addIfPresent('icon', icon.toJson());
    addIfPresent('infoWindow', infoWindow._toJson());
    return json;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final Marker typedOther = other as Marker;
    return markerId == typedOther.markerId &&
        consumeTapEvents == typedOther.consumeTapEvents &&
        position == typedOther.position &&
        icon == typedOther.icon &&
        infoWindow == typedOther.infoWindow;
  }

  @override
  int get hashCode => markerId.hashCode;

  @override
  String toString() => 'Marker(id: $markerId, position: $position)';
}

/// [Marker] update events to be applied to the [VNPTMap].
///
/// Used in [VNPTMapController] when the map is updated.
// (Do not re-export)
class MarkerUpdates extends MapsObjectUpdates<Marker> {
  /// Computes [MarkerUpdates] given previous and current [Marker]s.
  MarkerUpdates.from(Set<Marker> previous, Set<Marker> current)
      : super.from(previous, current, objectName: 'marker');

  /// Set of Markers to be added in this update.
  Set<Marker> get markersToAdd => objectsToAdd;

  /// Set of MarkerIds to be removed in this update.
  Set<MarkerId> get markerIdsToRemove => objectIdsToRemove.cast<MarkerId>();

  /// Set of Markers to be changed in this update.
  Set<Marker> get markersToChange => objectsToChange;
}

Object _offsetToJson(Offset offset) {
  return <Object>[offset.dx, offset.dy];
}

/// Text labels for a [Marker] info window.
class InfoWindow {
  /// Creates an immutable representation of a label on for [Marker].
  const InfoWindow({
    this.title,
    this.snippet,
    this.onTap,
  });

  /// Text labels specifying that no text is to be displayed.
  static const InfoWindow noText = InfoWindow();

  final String? title;

  final String? snippet;

  /// onTap callback for this [InfoWindow].
  final OnInfoWindowTapCallback? onTap;

  /// Creates a new [InfoWindow] object whose values are the same as this instance,
  /// unless overwritten by the specified parameters.
  InfoWindow copyWith({
    String? titleParam,
    String? snippetParam,
    OnInfoWindowTapCallback? onTapParam,
  }) {
    return InfoWindow(
      title: titleParam ?? title,
      snippet: snippetParam ?? snippet,
      onTap: onTapParam ?? onTap,
    );
  }

  Object _toJson() {
    final Map<String, Object> json = <String, Object>{};

    void addIfPresent(String fieldName, Object? value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('title', title);
    addIfPresent('snippet', snippet);

    return json;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final InfoWindow typedOther = other as InfoWindow;
    return title == typedOther.title && snippet == typedOther.snippet;
  }

  @override
  int get hashCode => hashValues(title.hashCode, snippet);
}
