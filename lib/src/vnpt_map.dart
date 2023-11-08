part of flutter_vnptmap_gl;

/// Pass to [VNPTMap.onMapCreated] to receive a [VNPTMapController] when the map is created.
typedef MapCreatedCallback = void Function(VNPTMapController controller);

enum AnnotationType { fill, line, circle, symbol }
enum DragEventType { start, drag, end }

class VNPTMap extends StatefulWidget {
  const VNPTMap({
    Key? key,
    required this.initialCameraPosition,
    this.accessToken,
    this.onMapCreated,
    this.styleString,
    this.onStyleLoadedCallback,
    this.onCameraIdle,
    this.gestureRecognizers,
    this.minMaxZoomPreference = MinMaxZoomPreference.unbounded,
    this.compassEnabled = true,
    this.cameraTargetBounds = CameraTargetBounds.unbounded,
    this.rotateGesturesEnabled = true,
    this.scrollGesturesEnabled = true,
    this.zoomGesturesEnabled = true,
    this.tiltGesturesEnabled = true,
    this.trackCameraPosition = false,
    this.myLocationEnabled = false,
    this.dragEnabled = true,
    this.myLocationTrackingMode = MyLocationTrackingMode.None,
    this.myLocationRenderMode = MyLocationRenderMode.COMPASS,
    this.onMapIdle,
    this.onCameraTrackingDismissed,
    this.onCameraTrackingChanged,
    this.compassViewPosition,
    this.attributionButtonPosition,
    this.onUserLocationUpdated,
    this.onMapClick,
    this.onMapLongClick,
    this.markers = const <Marker>{},
    this.polylines = const <Polyline>{},
    this.polygons = const <Polygon>{},
    this.annotationOrder = const [
      AnnotationType.line,
      AnnotationType.symbol,
      AnnotationType.circle,
      AnnotationType.fill,
    ],
    this.annotationConsumeTapEvents = const [
      AnnotationType.symbol,
      AnnotationType.fill,
      AnnotationType.line,
      AnnotationType.circle,
    ],
  }) : super(key: key);

  @override
  State createState() => _VNPTMapState();

  /// Defines the layer order of annotations displayed on map
  ///
  /// Any annotation type can only be contained once, so 0 to 4 types
  ///
  /// Note that setting this to be empty gives a big perfomance boost for
  /// android. However if you do so annotations will not work.
  final List<AnnotationType> annotationOrder;

  /// Defines the layer order of click annotations
  ///
  /// (must contain at least 1 annotation type, 4 items max)
  final List<AnnotationType> annotationConsumeTapEvents;

  /// The initial position of the map's camera.
  final CameraPosition? initialCameraPosition;

  /// Please note: you should only add annotations (e.g. symbols or circles) after `onStyleLoadedCallback` has been called.
  final MapCreatedCallback? onMapCreated;

  /// Called when the map style has been successfully loaded and the annotation managers have been enabled.
  /// Please note: you should only add annotations (e.g. symbols or circles) after this callback has been called.
  final OnStyleLoadedCallback? onStyleLoadedCallback;

  // Called when camera movement has ended.
  final OnCameraIdleCallback? onCameraIdle;

  /// Called when map view is entering an idle state, and no more drawing will
  /// be necessary until new data is loaded or there is some interaction with
  /// the map.
  /// * No camera transitions are in progress
  /// * All currently requested tiles have loaded
  /// * All fade/transition animations have completed
  final OnMapIdleCallback? onMapIdle;

  /// Style URL or Style JSON
  /// Can be a VNPTMapStyle constant, any VNPTMap Style URL,
  final String? styleString;

  /// If you want to use VNPT hosted styles and map tiles, you need to provide a VNPTMap access token.
  /// Obtain a free access token on [your VNPTMap account page].

  /// Note: You should not use this parameter AND set the access token through external files at the same time, and you should use the same token throughout the entire app.
  final String? accessToken;

  /// Which gestures should be consumed by the map.
  ///
  /// It is possible for other gesture recognizers to be competing with the map on pointer
  /// events, e.g if the map is inside a [ListView] the [ListView] will want to handle
  /// vertical drags. The map will claim gestures that are recognized by any of the
  /// recognizers on this list.
  ///
  /// When this set is empty or null, the map will only handle pointer events for gestures that
  /// were not claimed by any other gesture recognizer.
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  /// Preferred bounds for the camera zoom level.
  ///
  /// Actual bounds depend on map data and device.
  final MinMaxZoomPreference minMaxZoomPreference;

  /// True if the map should show a compass when rotated.
  final bool compassEnabled;

  /// True if drag functionality should be enabled.
  ///
  /// Disable to avoid performance issues that from the drag event listeners.
  /// Biggest impact in android
  final bool dragEnabled;

  /// Geographical bounding box for the camera target.
  final CameraTargetBounds? cameraTargetBounds;

  /// True if the map view should respond to rotate gestures.
  final bool rotateGesturesEnabled;

  /// True if the map view should respond to scroll gestures.
  final bool scrollGesturesEnabled;

  /// True if the map view should respond to zoom gestures.
  final bool zoomGesturesEnabled;

  /// True if the map view should respond to tilt gestures.
  final bool tiltGesturesEnabled;

  /// While the `myLocationEnabled` property is set to `true`, this method is
  /// called whenever a new location update is received by the map view.
  final OnUserLocationUpdated? onUserLocationUpdated;

  /// True if you want to be notified of map camera movements by the VNPTMapController. Default is false.
  ///
  /// If this is set to true and the user pans/zooms/rotates the map, VNPTMapController (which is a ChangeNotifier)
  /// will notify it's listeners and you can then get the new VNPTMapController.cameraPosition.
  final bool trackCameraPosition;

  /// True if a "My Location" layer should be shown on the map.
  ///
  /// This layer includes a location indicator at the current device location,
  /// as well as a My Location button.
  /// * The indicator is a small blue dot if the device is stationary, or a
  /// chevron if the device is moving.
  /// * The My Location button animates to focus on the user's current location
  /// if the user's location is currently known.
  ///
  /// Enabling this feature requires adding location permissions to both native
  /// platforms of your app.
  /// * On Android add either
  /// `<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />`
  /// or `<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />`
  /// to your `AndroidManifest.xml` file. `ACCESS_COARSE_LOCATION` returns a
  /// location with an accuracy approximately equivalent to a city block, while
  /// `ACCESS_FINE_LOCATION` returns as precise a location as possible, although
  /// it consumes more battery power. You will also need to request these
  /// permissions during run-time. If they are not granted, the My Location
  /// feature will fail silently.
  /// * On iOS add a `NSLocationWhenInUseUsageDescription` key to your
  /// `Info.plist` file. This will automatically prompt the user for permissions
  /// when the map tries to turn on the My Location layer.
  final bool myLocationEnabled;

  /// The mode used to let the map's camera follow the device's physical location.
  /// `myLocationEnabled` needs to be true for values other than `MyLocationTrackingMode.None` to work.
  final MyLocationTrackingMode myLocationTrackingMode;

  /// The mode to render the user location symbol
  final MyLocationRenderMode myLocationRenderMode;

  /// Set the position for the VNPTMap Compass
  final CompassViewPosition? compassViewPosition;

  /// Set the position for the VNPTMap Attribution Button
  final AttributionButtonPosition? attributionButtonPosition;

  /// Called when the map's camera no longer follows the physical device location, e.g. because the user moved the map
  final OnCameraTrackingDismissedCallback? onCameraTrackingDismissed;

  /// Called when the location tracking mode changes
  final OnCameraTrackingChangedCallback? onCameraTrackingChanged;

  final OnMapClickCallback? onMapClick;
  final OnMapClickCallback? onMapLongClick;

  /// Markers to be placed on the map.
  final Set<Marker> markers;

  /// Polylines to be placed on the map.
  final Set<Polyline> polylines;

  /// Polygons to be placed on the map.
  final Set<Polygon> polygons;
}

class _VNPTMapState extends State<VNPTMap> {
  final Completer<VNPTMapController> _controller =
      Completer<VNPTMapController>();
  late _VNPTMapOptions _vnptMapOptions;
  final VNPTMapGlPlatform _vnptMapGlPlatform =
      VNPTMapGlPlatform.createInstance();

  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};

  Map<PolylineId, Polyline> _polylines = <PolylineId, Polyline>{};

  Map<PolygonId, Polygon> _polygons = <PolygonId, Polygon>{};

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> creationParams = <String, dynamic>{
      'initialCameraPosition': widget.initialCameraPosition?.toMap(),
      'options': _VNPTMapOptions.fromWidget(widget).toMap(),
      'accessToken': widget.accessToken,
      'markersToAdd': serializeMarkerSet(widget.markers),
      'polylinesToAdd': serializePolylineSet(widget.polylines),
      'polygonsToAdd': serializePolygonSet(widget.polygons),
      'dragEnabled': widget.dragEnabled,
    };

    return _vnptMapGlPlatform.buildView(
        creationParams, onPlatformViewCreated, widget.gestureRecognizers);
  }

  @override
  void initState() {
    super.initState();
    _vnptMapOptions = _VNPTMapOptions.fromWidget(widget);
    _markers = keyByMarkerId(widget.markers);
    _polylines = keyByPolylineId(widget.polylines);
    _polygons = keyByPolygonId(widget.polygons);
  }

  @override
  void dispose() async {
    super.dispose();
    if (_controller.isCompleted) {
      final controller = await _controller.future;
      controller.dispose();
    }
  }

  @override
  void didUpdateWidget(VNPTMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final _VNPTMapOptions newOptions = _VNPTMapOptions.fromWidget(widget);
    final Map<String, dynamic> updates = _vnptMapOptions.updatesMap(newOptions);
    _updateOptions(updates);
    _vnptMapOptions = newOptions;
    _updateMarkers();
    _updatePolylines();
    _updatePolygons();
  }

  void _updateOptions(Map<String, dynamic> updates) async {
    if (updates.isEmpty) {
      return;
    }
    final VNPTMapController controller = await _controller.future;
    controller._updateMapOptions(updates);
  }

  void _updateMarkers() async {
    final VNPTMapController controller = await _controller.future;
    // ignore: unawaited_futures
    controller._updateMarkers(
        MarkerUpdates.from(_markers.values.toSet(), widget.markers));
    _markers = keyByMarkerId(widget.markers);
  }

  void _updatePolylines() async {
    final VNPTMapController controller = await _controller.future;
    // ignore: unawaited_futures
    controller._updatePolylines(
        PolylineUpdates.from(_polylines.values.toSet(), widget.polylines));
    _polylines = keyByPolylineId(widget.polylines);
  }

  void _updatePolygons() async {
    final VNPTMapController controller = await _controller.future;
    // ignore: unawaited_futures
    controller._updatePolygons(
        PolygonUpdates.from(_polygons.values.toSet(), widget.polygons));
    _polygons = keyByPolygonId(widget.polygons);
  }

  Future<void> onPlatformViewCreated(int id) async {
    final VNPTMapController controller = VNPTMapController(
      vnptMapGlPlatform: _vnptMapGlPlatform,
      initialCameraPosition: widget.initialCameraPosition!,
      onStyleLoadedCallback: () {
        _controller.future.then((_) {
          if (widget.onStyleLoadedCallback != null) {
            widget.onStyleLoadedCallback!();
          }
        });
      },
      onCameraIdle: widget.onCameraIdle,
      onUserLocationUpdated: widget.onUserLocationUpdated,
      onCameraTrackingDismissed: widget.onCameraTrackingDismissed,
      onCameraTrackingChanged: widget.onCameraTrackingChanged,
      onMapIdle: widget.onMapIdle,
      onMapClick: widget.onMapClick,
      onMapLongClick: widget.onMapLongClick,
      onMarkerTap: onMarkerTap,
      onInfoWindowTap: onInfoWindowTap,
      onPolylineTap: onPolylineTap,
      onPolygonTap: onPolygonTap,
      annotationOrder: widget.annotationOrder,
      annotationConsumeTapEvents: widget.annotationConsumeTapEvents,
    );
    await _vnptMapGlPlatform.initPlatform(id);
    _controller.complete(controller);
    if (widget.onMapCreated != null) {
      widget.onMapCreated!(controller);
    }
  }

  void onMarkerTap(MarkerId markerId) {
    final Marker? marker = _markers[markerId];
    if (marker == null) {
      debugPrint('marker $markerId onTap');
    }
    final OnMarkerTapCallback? onTap = marker?.onTap;
    if (onTap != null) {
      onTap(markerId);
    }
  }

  void onInfoWindowTap(MarkerId markerId) {
    final Marker? marker = _markers[markerId];
    if (marker == null) {
      debugPrint('inforWindows of marker $markerId onTap');
    }
    final OnInfoWindowTapCallback? onTap = marker?.infoWindow.onTap;
    if (onTap != null) {
      onTap(markerId);
    }
  }

  void onPolylineTap(PolylineId polylineId) {
    final Polyline? polyline = _polylines[polylineId];
    if (polyline == null) {
      debugPrint('inforWindows of marker $polylineId onTap');
    }
    final OnPolylineTapCallback? onTap = polyline?.onTap;
    if (onTap != null) {
      onTap(polylineId);
    }
  }

  void onPolygonTap(PolygonId polygonId) {
    final Polygon? polygon = _polygons[polygonId];
    if (polygon == null) {
      debugPrint('Polygon $polygonId onTap');
    }
    final OnPolygonTapCallback? onTap = polygon?.onTap;
    if (onTap != null) {
      onTap(polygonId);
    }
  }
}

/// Configuration options for the VNPTMaps user interface.
///
/// When used to change configuration, null values will be interpreted as
/// "do not change this configuration option".
class _VNPTMapOptions {
  _VNPTMapOptions({
    this.styleString,
    this.minMaxZoomPreference,
    this.compassEnabled,
    this.cameraTargetBounds,
    required this.rotateGesturesEnabled,
    required this.scrollGesturesEnabled,
    required this.zoomGesturesEnabled,
    required this.tiltGesturesEnabled,
    this.trackCameraPosition,
    this.myLocationEnabled,
    this.myLocationTrackingMode,
    this.myLocationRenderMode,
    this.compassViewPosition,
    this.attributionButtonPosition,
  });

  static _VNPTMapOptions fromWidget(VNPTMap map) {
    return _VNPTMapOptions(
      styleString: map.styleString,
      minMaxZoomPreference: map.minMaxZoomPreference,
      compassEnabled: map.compassEnabled,
      cameraTargetBounds: map.cameraTargetBounds,
      rotateGesturesEnabled: map.rotateGesturesEnabled,
      scrollGesturesEnabled: map.scrollGesturesEnabled,
      zoomGesturesEnabled: map.zoomGesturesEnabled,
      tiltGesturesEnabled: map.tiltGesturesEnabled,
      trackCameraPosition: map.trackCameraPosition,
      myLocationEnabled: map.myLocationEnabled,
      myLocationTrackingMode: map.myLocationTrackingMode,
      myLocationRenderMode: map.myLocationRenderMode,
      compassViewPosition: map.compassViewPosition,
      attributionButtonPosition: map.attributionButtonPosition,
    );
  }

  final String? styleString;

  final MinMaxZoomPreference? minMaxZoomPreference;

  final bool? compassEnabled;

  final CameraTargetBounds? cameraTargetBounds;

  final bool rotateGesturesEnabled;

  final bool scrollGesturesEnabled;

  final bool zoomGesturesEnabled;

  final bool tiltGesturesEnabled;

  final bool? trackCameraPosition;

  final bool? myLocationEnabled;

  final MyLocationTrackingMode? myLocationTrackingMode;

  final MyLocationRenderMode? myLocationRenderMode;

  final CompassViewPosition? compassViewPosition;

  final AttributionButtonPosition? attributionButtonPosition;

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> optionsMap = <String, dynamic>{};

    void addIfNonNull(String fieldName, dynamic value) {
      if (value != null) {
        optionsMap[fieldName] = value;
      }
    }

    addIfNonNull('styleString', styleString);
    addIfNonNull('minMaxZoomPreference', minMaxZoomPreference?.toJson());
    addIfNonNull('compassEnabled', compassEnabled);

    addIfNonNull('cameraTargetBounds', cameraTargetBounds?.toJson());
    addIfNonNull('rotateGesturesEnabled', rotateGesturesEnabled);
    addIfNonNull('scrollGesturesEnabled', scrollGesturesEnabled);
    addIfNonNull('zoomGesturesEnabled', zoomGesturesEnabled);
    addIfNonNull('tiltGesturesEnabled', tiltGesturesEnabled);

    addIfNonNull('trackCameraPosition', trackCameraPosition);
    addIfNonNull('myLocationEnabled', myLocationEnabled);
    addIfNonNull('myLocationTrackingMode', myLocationTrackingMode?.index);
    addIfNonNull('myLocationRenderMode', myLocationRenderMode?.index);
    addIfNonNull('compassViewPosition', compassViewPosition?.index);
    addIfNonNull('attributionButtonPosition', attributionButtonPosition?.index);

    return optionsMap;
  }

  Map<String, dynamic> updatesMap(_VNPTMapOptions newOptions) {
    final Map<String, dynamic> prevOptionsMap = toMap();
    final newOptionsMap = newOptions.toMap();

    return newOptionsMap
      ..removeWhere((String key, dynamic value) {
        final oldValue = prevOptionsMap[key];
        if (oldValue is List && value is List) {
          return listEquals(oldValue, value);
        }
        return oldValue == value;
      });
  }
}
