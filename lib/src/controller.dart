part of flutter_vnptmap_gl;

typedef OnStyleLoadedCallback = void Function();

typedef OnCameraIdleCallback = void Function();

typedef OnUserLocationUpdated = void Function(UserLocation location);

typedef OnCameraTrackingDismissedCallback = void Function();

typedef OnCameraTrackingChangedCallback = void Function(
    MyLocationTrackingMode mode);

typedef OnMapIdleCallback = void Function();

typedef OnMapClickCallback = void Function(
    Point<double> point, LatLng coordinates);

typedef OnMapLongClickCallback = void Function(
    Point<double> point, LatLng coordinates);

typedef OnFeatureInteractionCallback = void Function(
    dynamic id, Point<double> point, LatLng coordinates);

typedef OnFeatureDragnCallback = void Function(dynamic id,
    {required Point<double> point,
    required LatLng origin,
    required LatLng current,
    required LatLng delta,
    required DragEventType eventType});

class VNPTMapController extends ChangeNotifier {
  VNPTMapController({
    required VNPTMapGlPlatform vnptMapGlPlatform,
    required CameraPosition initialCameraPosition,
    required Iterable<AnnotationType> annotationOrder,
    required Iterable<AnnotationType> annotationConsumeTapEvents,
    this.onStyleLoadedCallback,
    this.onCameraIdle,
    this.onUserLocationUpdated,
    this.onCameraTrackingDismissed,
    this.onCameraTrackingChanged,
    this.onMapIdle,
    this.onMapClick,
    this.onMapLongClick,
    this.onMarkerTap,
    this.onInfoWindowTap,
    this.onPolylineTap,
    this.onPolygonTap,
  }) : _vnptMapGlPlatform = vnptMapGlPlatform {
    _cameraPosition = initialCameraPosition;

    _vnptMapGlPlatform.onMapStyleLoadedPlatform.add((_) {
      final interactionEnabled = annotationConsumeTapEvents.toSet();
      for (var type in annotationOrder.toSet()) {
        final enableInteraction = interactionEnabled.contains(type);
        switch (type) {
          case AnnotationType.circle:
            circleManager = CircleManager(this,
                onTap: onCircleTapped, enableInteraction: enableInteraction);
            break;
          default:
            break;
        }
      }

      if (onStyleLoadedCallback != null) {
        onStyleLoadedCallback!();
      }
    });

    _vnptMapGlPlatform.onFeatureTappedPlatform.add((payload) {
      for (final fun
          in List<OnFeatureInteractionCallback>.from(onFeatureTapped)) {
        fun(payload["id"], payload["point"], payload["latLng"]);
      }
    });

    _vnptMapGlPlatform.onFeatureDraggedPlatform.add((payload) {
      for (final fun in List<OnFeatureDragnCallback>.from(onFeatureDrag)) {
        final DragEventType enmDragEventType = DragEventType.values
            .firstWhere((element) => element.name == payload["eventType"]);
        fun(payload["id"],
            point: payload["point"],
            origin: payload["origin"],
            current: payload["current"],
            delta: payload["delta"],
            eventType: enmDragEventType);
      }
    });

    _vnptMapGlPlatform.onCameraMoveStartedPlatform.add((_) {
      _isCameraMoving = true;
      notifyListeners();
    });

    _vnptMapGlPlatform.onCameraMovePlatform.add((cameraPosition) {
      _cameraPosition = cameraPosition;
      notifyListeners();
    });

    _vnptMapGlPlatform.onCameraIdlePlatform.add((cameraPosition) {
      _isCameraMoving = false;
      if (cameraPosition != null) {
        _cameraPosition = cameraPosition;
      }
      if (onCameraIdle != null) {
        onCameraIdle!();
      }
      notifyListeners();
    });

    _vnptMapGlPlatform.onCameraTrackingChangedPlatform.add((mode) {
      if (onCameraTrackingChanged != null) {
        onCameraTrackingChanged!(mode);
      }
    });

    _vnptMapGlPlatform.onCameraTrackingDismissedPlatform.add((_) {
      if (onCameraTrackingDismissed != null) {
        onCameraTrackingDismissed!();
      }
    });

    _vnptMapGlPlatform.onMapIdlePlatform.add((_) {
      if (onMapIdle != null) {
        onMapIdle!();
      }
    });

    _vnptMapGlPlatform.onUserLocationUpdatedPlatform.add((location) {
      onUserLocationUpdated?.call(location);
    });

    _vnptMapGlPlatform.onMapClickPlatform.add((dict) {
      if (onMapClick != null) {
        onMapClick!(dict['point'], dict['latLng']);
      }
    });

    _vnptMapGlPlatform.onMapLongClickPlatform.add((dict) {
      if (onMapLongClick != null) {
        onMapLongClick!(dict['point'], dict['latLng']);
      }
    });

    _vnptMapGlPlatform.onMarkerTapPlatform.add((markerId) {
      if (onMarkerTap != null) {
        onMarkerTap!(markerId);
      }
    });

    _vnptMapGlPlatform.onInfoWindowTapPlatform.add((markerId) {
      if (onInfoWindowTap != null) {
        onInfoWindowTap!(markerId);
      }
    });

    _vnptMapGlPlatform.onPolylineTapPlatform.add((polylineId) {
      if (onPolylineTap != null) {
        onPolylineTap!(polylineId);
      }
    });

    _vnptMapGlPlatform.onPolygonTapPlatform.add((polygonId) {
      if (onPolygonTap != null) {
        onPolygonTap!(polygonId);
      }
    });
  }

  final OnStyleLoadedCallback? onStyleLoadedCallback;

  final OnCameraIdleCallback? onCameraIdle;

  final OnUserLocationUpdated? onUserLocationUpdated;

  final OnCameraTrackingDismissedCallback? onCameraTrackingDismissed;

  final OnCameraTrackingChangedCallback? onCameraTrackingChanged;

  final OnMapIdleCallback? onMapIdle;

  /// True if the map camera is currently moving.
  bool get isCameraMoving => _isCameraMoving;
  bool _isCameraMoving = false;

  /// Returns the most recent camera position reported by the platform side.
  /// Will be null, if [VNPTMap.trackCameraPosition] is false.
  CameraPosition? get cameraPosition => _cameraPosition;
  CameraPosition? _cameraPosition;

  final OnMapClickCallback? onMapClick;
  final OnMapLongClickCallback? onMapLongClick;

  final OnMarkerTapCallback? onMarkerTap;

  final OnInfoWindowTapCallback? onInfoWindowTap;

  final OnPolylineTapCallback? onPolylineTap;

  final OnPolygonTapCallback? onPolygonTap;

  final VNPTMapGlPlatform _vnptMapGlPlatform; //ignore: unused_field

  CircleManager? circleManager;

  /// Callbacks to receive tap events for symbols placed on this map.
  final ArgumentCallbacks<Symbol> onSymbolTapped = ArgumentCallbacks<Symbol>();

  /// Callbacks to receive tap events for symbols placed on this map.
  final ArgumentCallbacks<Circle> onCircleTapped = ArgumentCallbacks<Circle>();

  /// The current set of circles on this map.
  ///
  /// The returned set will be a detached snapshot of the circles collection.
  Set<Circle> get circles => circleManager!.annotations;

  /// Callbacks to receive tap events for features (geojson layer) placed on this map.
  final onFeatureTapped = <OnFeatureInteractionCallback>[];

  final onFeatureDrag = <OnFeatureDragnCallback>[];

  /// Updates configuration options of the map user interface.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updateMapOptions(Map<String, dynamic> optionsUpdate) async {
    _cameraPosition = await _vnptMapGlPlatform.updateMapOptions(optionsUpdate);
    notifyListeners();
  }

  /// Starts an animated change of the map camera position.
  ///
  /// [duration] is the amount of time, that the transition animation should take.
  ///
  /// The returned [Future] completes after the change has been started on the
  /// platform side.
  /// It returns true if the camera was successfully moved and false if the movement was canceled.
  /// Note: this currently always returns immediately with a value of null on iOS
  Future<bool?> animateCamera(CameraUpdate cameraUpdate,
      {Duration? duration}) async {
    return _vnptMapGlPlatform.animateCamera(cameraUpdate, duration: duration);
  }

  /// Instantaneously re-position the camera.
  /// Note: moveCamera() quickly moves the camera, which can be visually jarring for a user. Strongly consider using the animateCamera() methods instead because it's less abrupt.
  ///
  /// The returned [Future] completes after the change has been made on the
  /// platform side.
  /// It returns true if the camera was successfully moved and false if the movement was canceled.
  /// Note: this currently always returns immediately with a value of null on iOS
  Future<bool?> moveCamera(CameraUpdate cameraUpdate) async {
    return _vnptMapGlPlatform.moveCamera(cameraUpdate);
  }

  /// Updates user location tracking mode.
  ///
  /// The returned [Future] completes after the change has been made on the
  /// platform side.
  Future<void> updateMyLocationTrackingMode(
      MyLocationTrackingMode myLocationTrackingMode) async {
    return _vnptMapGlPlatform
        .updateMyLocationTrackingMode(myLocationTrackingMode);
  }

  Future<LatLng?> getMyLocationLatLng() async {
    return _vnptMapGlPlatform.requestMyLocationLatLng();
  }

  // Updates marker configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updateMarkers(MarkerUpdates markerUpdates) {
    return _vnptMapGlPlatform.updateMarkers(markerUpdates);
  }

  /// Updates polyline configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updatePolylines(PolylineUpdates polylineUpdates) {
    return _vnptMapGlPlatform.updatePolylines(polylineUpdates);
  }

  /// Updates polygon configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updatePolygons(PolygonUpdates polygonUpdates) {
    return _vnptMapGlPlatform.updatePolygons(polygonUpdates);
  }

  /// Add a circle layer to the map with the given properties
  ///
  /// Consider using [addLayer] for an unified layer api.
  ///
  /// The returned [Future] completes after the change has been made on the
  /// platform side.
  ///
  /// Setting [belowLayerId] adds the new layer below the given id.
  /// If [enableInteraction] is set the layer is considered for touch or drag
  /// events. [sourceLayer] is used to selected a specific source layer from
  /// Vector source.
  /// [minzoom] is the minimum (inclusive) zoom level at which the layer is
  /// visible.
  /// [maxzoom] is the maximum (exclusive) zoom level at which the layer is
  /// visible.
  /// [filter] determines which features should be rendered in the layer.
  /// Filters are written as [expressions].
  ///
  /// [expressions]: https://docs.mapbox.com/mapbox-gl-js/style-spec/expressions
  Future<void> addCircleLayer(
      String sourceId, String layerId, CircleLayerProperties properties,
      {String? belowLayerId,
      String? sourceLayer,
      double? minzoom,
      double? maxzoom,
      dynamic filter,
      bool enableInteraction = true}) async {
    await _vnptMapGlPlatform.addCircleLayer(
      sourceId,
      layerId,
      properties.toJson(),
      belowLayerId: belowLayerId,
      sourceLayer: sourceLayer,
      minzoom: minzoom,
      maxzoom: maxzoom,
      filter: filter,
      enableInteraction: enableInteraction,
    );
  }

  /// Add a raster layer to the map with the given properties
  ///
  /// Consider using [addLayer] for an unified layer api.
  ///
  /// The returned [Future] completes after the change has been made on the
  /// platform side.
  ///
  /// Setting [belowLayerId] adds the new layer below the given id.
  /// [sourceLayer] is used to selected a specific source layer from
  /// Raster source.
  /// [minzoom] is the minimum (inclusive) zoom level at which the layer is
  /// visible.
  /// [maxzoom] is the maximum (exclusive) zoom level at which the layer is
  /// visible.
  Future<void> addRasterLayer(
      String sourceId, String layerId, RasterLayerProperties properties,
      {String? belowLayerId,
      String? sourceLayer,
      double? minzoom,
      double? maxzoom}) async {
    await _vnptMapGlPlatform.addRasterLayer(
      sourceId,
      layerId,
      properties.toJson(),
      belowLayerId: belowLayerId,
      sourceLayer: sourceLayer,
      minzoom: minzoom,
      maxzoom: maxzoom,
    );
  }

  /// Adds a circle to the map, configured using the specified custom [options].
  ///
  /// Change listeners are notified once the circle has been added on the
  /// platform side.
  ///
  /// The returned [Future] completes with the added circle once listeners have
  /// been notified.
  Future<Circle> addCircle(CircleOptions options, [Map? data]) async {
    final CircleOptions effectiveOptions =
        CircleOptions.defaultOptions.copyWith(options);
    final circle = Circle(getRandomString(), effectiveOptions, data);
    await circleManager!.add(circle);
    notifyListeners();
    return circle;
  }

  /// Adds multiple circles to the map, configured using the specified custom
  /// [options].
  ///
  /// Change listeners are notified once the circles have been added on the
  /// platform side.
  ///
  /// The returned [Future] completes with the added circle once listeners have
  /// been notified.
  Future<List<Circle>> addCircles(List<CircleOptions> options,
      [List<Map>? data]) async {
    final cricles = [
      for (var i = 0; i < options.length; i++)
        Circle(getRandomString(),
            CircleOptions.defaultOptions.copyWith(options[i]), data?[i])
    ];
    await circleManager!.addAll(cricles);

    notifyListeners();
    return cricles;
  }

  /// Updates the specified [circle] with the given [changes]. The circle must
  /// be a current member of the [circles] set.
  ///
  /// Change listeners are notified once the circle has been updated on the
  /// platform side.
  ///
  /// The returned [Future] completes once listeners have been notified.
  Future<void> updateCircle(Circle circle, CircleOptions changes) async {
    circle.options = circle.options.copyWith(changes);
    await circleManager!.set(circle);

    notifyListeners();
  }

  /// Retrieves the current position of the circle.
  /// This may be different from the value of `circle.options.geometry` if the circle is draggable.
  /// In that case this method provides the circle's actual position, and `circle.options.geometry` the last programmatically set position.
  Future<LatLng> getCircleLatLng(Circle circle) async {
    return circle.options.geometry!;
  }

  /// Removes the specified [circle] from the map. The circle must be a current
  /// member of the [circles] set.
  ///
  /// Change listeners are notified once the circle has been removed on the
  /// platform side.
  ///
  /// The returned [Future] completes once listeners have been notified.
  Future<void> removeCircle(Circle circle) async {
    circleManager!.remove(circle);

    notifyListeners();
  }

  /// Removes the specified [circles] from the map. The circles must be current
  /// members of the [circles] set.
  ///
  /// Change listeners are notified once the circles have been removed on the
  /// platform side.
  ///
  /// The returned [Future] completes once listeners have been notified.
  Future<void> removeCircles(Iterable<Circle> circles) async {
    await circleManager!.removeAll(circles);
    notifyListeners();
  }

  /// Removes all [circles] from the map.
  ///
  /// Change listeners are notified once all circles have been removed on the
  /// platform side.
  ///
  /// The returned [Future] completes once listeners have been notified.
  Future<void> clearCircles() async {
    circleManager!.clear();

    notifyListeners();
  }

  Future<void> addImage(String name, Uint8List bytes, [bool sdf = false]) {
    return _vnptMapGlPlatform.addImage(name, bytes, sdf);
  }

  /// Adds an image source to the style currently displayed in the map, so that it can later be referred to by the provided id.
  Future<void> addImageSource(
      String imageSourceId, Uint8List bytes, LatLngQuad coordinates) {
    return _vnptMapGlPlatform.addImageSource(imageSourceId, bytes, coordinates);
  }

  /// Update an image source to the style currently displayed in the map, so that it can later be referred to by the provided id.
  Future<void> updateImageSource(
      String imageSourceId, Uint8List? bytes, LatLngQuad? coordinates) {
    return _vnptMapGlPlatform.updateImageSource(
        imageSourceId, bytes, coordinates);
  }

  /// Removes previously added image source by id
  @Deprecated("This method was renamed to removeSource")
  Future<void> removeImageSource(String imageSourceId) {
    return _vnptMapGlPlatform.removeSource(imageSourceId);
  }

  /// Adds a new geojson source
  ///
  /// The json in [geojson] has to comply with the schema for FeatureCollection
  /// as specified in https://datatracker.ietf.org/doc/html/rfc7946#section-3.3
  ///
  /// [promoteId] can be used on web to promote an id from properties to be the
  /// id of the feature. This is useful because by default mapbox-gl-js does not
  /// support string ids
  ///
  /// The returned [Future] completes after the change has been made on the
  /// platform side.
  ///
  Future<void> addGeoJsonSource(String sourceId, Map<String, dynamic> geojson,
      {String? promoteId}) async {
    await _vnptMapGlPlatform.addGeoJsonSource(sourceId, geojson,
        promoteId: promoteId);
  }

  /// Sets new geojson data to and existing source
  ///
  /// This only works as exected if the source has been created with
  /// [addGeoJsonSource] before. This is very useful if you want to update and
  /// existing source with modified data.
  ///
  /// The json in [geojson] has to comply with the schema for FeatureCollection
  /// as specified in https://datatracker.ietf.org/doc/html/rfc7946#section-3.3
  ///
  /// The returned [Future] completes after the change has been made on the
  /// platform side.
  Future<void> setGeoJsonSource(
      String sourceId, Map<String, dynamic> geojson) async {
    await _vnptMapGlPlatform.setGeoJsonSource(sourceId, geojson);
  }

  /// Sets new geojson data to and existing source
  ///
  /// This only works as exected if the source has been created with
  /// [addGeoJsonSource] before. This is very useful if you want to update and
  /// existing source with modified data.
  ///
  /// The json in [geojson] has to comply with the schema for FeatureCollection
  /// as specified in https://datatracker.ietf.org/doc/html/rfc7946#section-3.3
  ///
  /// The returned [Future] completes after the change has been made on the
  /// platform side.
  Future<void> setGeoJsonFeature(
      String sourceId, Map<String, dynamic> geojsonFeature) async {
    await _vnptMapGlPlatform.setFeatureForGeoJsonSource(
        sourceId, geojsonFeature);
  }

  /// Removes previously added source by id
  Future<void> removeSource(String sourceId) {
    return _vnptMapGlPlatform.removeSource(sourceId);
  }

  /// Adds a Mapbox image layer to the map's style at render time.
  Future<void> addImageLayer(String layerId, String imageSourceId,
      {double? minzoom, double? maxzoom}) {
    return _vnptMapGlPlatform.addLayer(
        layerId, imageSourceId, minzoom, maxzoom);
  }

  /// Adds a Mapbox image layer below the layer provided with belowLayerId to the map's style at render time.
  Future<void> addImageLayerBelow(
      String layerId, String sourceId, String imageSourceId,
      {double? minzoom, double? maxzoom}) {
    return _vnptMapGlPlatform.addLayerBelow(
        layerId, sourceId, imageSourceId, minzoom, maxzoom);
  }

  /// Adds a Mapbox image layer below the layer provided with belowLayerId to the map's style at render time. Only works for image sources!
  @Deprecated("This method was renamed to addImageLayerBelow for clarity.")
  Future<void> addLayerBelow(
      String layerId, String sourceId, String imageSourceId,
      {double? minzoom, double? maxzoom}) {
    return _vnptMapGlPlatform.addLayerBelow(
        layerId, sourceId, imageSourceId, minzoom, maxzoom);
  }

  /// Removes a Mapbox style layer
  Future<void> removeLayer(String layerId) {
    return _vnptMapGlPlatform.removeLayer(layerId);
  }

  Future<void> setFilter(String layerId, dynamic filter) {
    return _vnptMapGlPlatform.setFilter(layerId, filter);
  }

  /// Returns the point on the screen that corresponds to a geographical coordinate ([latLng]). The screen location is in screen pixels (not display pixels) relative to the top left of the map (not of the whole screen)
  ///
  /// Note: The resulting x and y coordinates are rounded to [int] on web, on other platforms they may differ very slightly (in the range of about 10^-10) from the actual nearest screen coordinate.
  /// You therefore might want to round them appropriately, depending on your use case.
  ///
  /// Returns null if [latLng] is not currently visible on the map.
  Future<Point> toScreenLocation(LatLng latLng) async {
    return _vnptMapGlPlatform.toScreenLocation(latLng);
  }

  Future<List<Point>> toScreenLocationBatch(Iterable<LatLng> latLngs) async {
    return _vnptMapGlPlatform.toScreenLocationBatch(latLngs);
  }

  /// Returns the geographic location (as [LatLng]) that corresponds to a point on the screen. The screen location is specified in screen pixels (not display pixels) relative to the top left of the map (not the top left of the whole screen).
  Future<LatLng> toLatLng(Point screenLocation) async {
    return _vnptMapGlPlatform.toLatLng(screenLocation);
  }

  /// Returns the distance spanned by one pixel at the specified [latitude] and current zoom level.
  /// The distance between pixels decreases as the latitude approaches the poles. This relationship parallels the relationship between longitudinal coordinates at different latitudes.
  Future<double> getMetersPerPixelAtLatitude(double latitude) async {
    return _vnptMapGlPlatform.getMetersPerPixelAtLatitude(latitude);
  }

  /// Add a new source to the map
  Future<void> addSource(String sourceid, SourceProperties properties) async {
    return _vnptMapGlPlatform.addSource(sourceid, properties);
  }

  /// Add a layer to the map with the given properties
  ///
  /// The returned [Future] completes after the change has been made on the
  /// platform side.
  ///
  /// Setting [belowLayerId] adds the new layer below the given id.
  /// If [enableInteraction] is set the layer is considered for touch or drag
  /// [sourceLayer] is used to selected a specific source layer from Vector
  /// source.
  /// [minzoom] is the minimum (inclusive) zoom level at which the layer is
  /// visible.
  /// [maxzoom] is the maximum (exclusive) zoom level at which the layer is
  /// visible.
  /// [filter] determines which features should be rendered in the layer.
  /// Filters are written as [expressions].
  ///
  /// [expressions]: https://docs.mapbox.com/mapbox-gl-js/style-spec/expressions
  Future<void> addLayer(
      String sourceId, String layerId, LayerProperties properties,
      {String? belowLayerId,
      bool enableInteraction = true,
      String? sourceLayer,
      double? minzoom,
      double? maxzoom,
      dynamic filter}) async {
    if (properties is CircleLayerProperties) {
      addCircleLayer(sourceId, layerId, properties,
          belowLayerId: belowLayerId,
          enableInteraction: enableInteraction,
          sourceLayer: sourceLayer,
          minzoom: minzoom,
          maxzoom: maxzoom,
          filter: filter);
    } else if (properties is RasterLayerProperties) {
      if (filter != null) {
        throw UnimplementedError("RasterLayer does not support filter");
      }
      addRasterLayer(sourceId, layerId, properties,
          belowLayerId: belowLayerId,
          sourceLayer: sourceLayer,
          minzoom: minzoom,
          maxzoom: maxzoom);
    } else {
      throw UnimplementedError("Unknown layer type $properties");
    }
  }

  /// Updates the distance from the edges of the map view’s frame to the edges
  /// of the map view’s logical viewport, optionally animating the change.
  ///
  /// When the value of this property is equal to `EdgeInsets.zero`, viewport
  /// properties such as centerCoordinate assume a viewport that matches the map
  /// view’s frame. Otherwise, those properties are inset, excluding part of the
  /// frame from the viewport. For instance, if the only the top edge is inset,
  /// the map center is effectively shifted downward.
  ///
  /// The returned [Future] completes after the change has been made on the
  /// platform side.
  Future<void> updateContentInsets(EdgeInsets insets,
      [bool animated = false]) async {
    return _vnptMapGlPlatform.updateContentInsets(insets, animated);
  }

  // Query rendered features at a point in screen cooridnates
  Future<List> queryRenderedFeatures(
      Point<double> point, List<String> layerIds, List<Object>? filter) async {
    return _vnptMapGlPlatform.queryRenderedFeatures(point, layerIds, filter);
  }

  /// Query rendered features in a Rect in screen coordinates
  Future<List> queryRenderedFeaturesInRect(
      Rect rect, List<String> layerIds, String? filter) async {
    return _vnptMapGlPlatform.queryRenderedFeaturesInRect(
        rect, layerIds, filter);
  }

  /// Query rendered features at a point in screen coordinates
  /// Note: On web, this will probably only work for GeoJson source, not for vector tiles
  Future<List> querySourceFeatures(
      String sourceId, String? sourceLayerId, List<Object>? filter) async {
    return _vnptMapGlPlatform.querySourceFeatures(
        sourceId, sourceLayerId, filter);
  }

  Future<void> setLayerVisibility(String layerId, bool visible) async {
    return _vnptMapGlPlatform.setLayerVisibility(layerId, visible);
  }

  /// This method returns the boundaries of the region currently displayed in the map.
  Future<LatLngBounds> getVisibleRegion() async {
    return _vnptMapGlPlatform.getVisibleRegion();
  }

  @override
  void dispose() {
    super.dispose();
    _vnptMapGlPlatform.dispose();
  }
}
