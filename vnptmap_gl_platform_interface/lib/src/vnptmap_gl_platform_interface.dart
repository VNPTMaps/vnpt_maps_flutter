part of vnptmap_gl_platform_interface;

typedef OnPlatformViewCreatedCallback = void Function(int);

abstract class VNPTMapGlPlatform {
  /// The default instance of [VNPTMapGlPlatform] to use.
  static MethodChannelVNPTMapGl? _instance;

  ///
  /// Defaults to [MethodChannelVNPTMapGl].
  ///
  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [VNPTMapGlPlatform] when they register themselves.
  static VNPTMapGlPlatform Function() createInstance =
      () => _instance ?? MethodChannelVNPTMapGl();

  static set instance(MethodChannelVNPTMapGl instance) {
    _instance = instance;
  }

  final onMapStyleLoadedPlatform = ArgumentCallbacks<void>();

  final onCameraMoveStartedPlatform = ArgumentCallbacks<void>();

  final onCameraMovePlatform = ArgumentCallbacks<CameraPosition>();

  final onCameraIdlePlatform = ArgumentCallbacks<CameraPosition?>();

  final ArgumentCallbacks<void> onAttributionClickPlatform =
      ArgumentCallbacks<void>();

  final ArgumentCallbacks<MyLocationTrackingMode>
      onCameraTrackingChangedPlatform =
      ArgumentCallbacks<MyLocationTrackingMode>();

  final onCameraTrackingDismissedPlatform = ArgumentCallbacks<void>();

  final onMapIdlePlatform = ArgumentCallbacks<void>();

  final onUserLocationUpdatedPlatform = ArgumentCallbacks<UserLocation>();

  final onMapClickPlatform = ArgumentCallbacks<Map<String, dynamic>>();

  final onMapLongClickPlatform = ArgumentCallbacks<Map<String, dynamic>>();

  final onMarkerTapPlatform = ArgumentCallbacks<MarkerId>();

  final onInfoWindowTapPlatform = ArgumentCallbacks<MarkerId>();

  final onPolylineTapPlatform = ArgumentCallbacks<PolylineId>();

  final onPolygonTapPlatform = ArgumentCallbacks<PolygonId>();

  final onFeatureTappedPlatform = ArgumentCallbacks<Map<String, dynamic>>();

  final onFeatureDraggedPlatform = ArgumentCallbacks<Map<String, dynamic>>();

  final onInfoWindowTappedPlatform = ArgumentCallbacks<String>();

  Future<void> initPlatform(int id);
  Widget buildView(
      Map<String, dynamic> creationParams,
      OnPlatformViewCreatedCallback onPlatformViewCreated,
      Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers);

  Future<CameraPosition?> updateMapOptions(Map<String, dynamic> optionsUpdate);

  Future<bool?> animateCamera(CameraUpdate cameraUpdate, {Duration? duration});

  Future<bool?> moveCamera(CameraUpdate cameraUpdate);

  Future<void> updateMyLocationTrackingMode(
      MyLocationTrackingMode myLocationTrackingMode);

  Future<LatLng?> requestMyLocationLatLng();

  Future<void> updateMarkers(MarkerUpdates markerUpdates);

  Future<void> updatePolylines(PolylineUpdates polylineUpdates);

  Future<void> updatePolygons(PolygonUpdates polygonUpdates);

  Future<void> addImage(String name, Uint8List bytes, [bool sdf = false]);

  Future<void> addImageSource(
      String imageSourceId, Uint8List bytes, LatLngQuad coordinates);

  Future<void> updateImageSource(
      String imageSourceId, Uint8List? bytes, LatLngQuad? coordinates);

  Future<void> addLayer(String imageLayerId, String imageSourceId,
      double? minzoom, double? maxzoom);

  Future<void> addLayerBelow(String imageLayerId, String imageSourceId,
      String belowLayerId, double? minzoom, double? maxzoom);

  Future<LatLngBounds> getVisibleRegion();

  Future<void> setLayerVisibility(String layerId, bool visible);

  Future<void> removeLayer(String imageLayerId);

  Future<void> setFilter(String layerId, dynamic filter);

  Future<dynamic> getFilter(String layerId);

  Future<List> getLayerIds();

  Future<List> getSourceIds();

  Future<Point> toScreenLocation(LatLng latLng);

  Future<List<Point>> toScreenLocationBatch(Iterable<LatLng> latLngs);

  Future<LatLng> toLatLng(Point screenLocation);

  Future<double> getMetersPerPixelAtLatitude(double latitude);

  Future<void> addGeoJsonSource(String sourceId, Map<String, dynamic> geojson,
      {String? promoteId});

  Future<void> setGeoJsonSource(String sourceId, Map<String, dynamic> geojson);

  Future<void> setFeatureForGeoJsonSource(
      String sourceId, Map<String, dynamic> geojsonFeature);

  Future<void> updateContentInsets(EdgeInsets insets, bool animated);

  Future<List> queryRenderedFeatures(
      Point<double> point, List<String> layerIds, List<Object>? filter);

  Future<List> queryRenderedFeaturesInRect(
      Rect rect, List<String> layerIds, String? filter);

  Future<List> querySourceFeatures(
      String sourceId, String? sourceLayerId, List<Object>? filter);

  Future<void> addSource(String sourceId, SourceProperties properties);
  Future<void> removeSource(String sourceId);

  Future<void> addCircleLayer(
      String sourceId, String layerId, Map<String, dynamic> properties,
      {String? belowLayerId,
      String? sourceLayer,
      double? minzoom,
      double? maxzoom,
      dynamic filter,
      required bool enableInteraction});

  Future<void> addRasterLayer(
      String sourceId, String layerId, Map<String, dynamic> properties,
      {String? belowLayerId,
      String? sourceLayer,
      double? minzoom,
      double? maxzoom});

  @mustCallSuper
  void dispose() {
    // clear all callbacks to avoid cyclic refs
    onCameraMoveStartedPlatform.clear();
    onCameraMovePlatform.clear();
    onCameraIdlePlatform.clear();
    onFeatureTappedPlatform.clear();
    onFeatureDraggedPlatform.clear();
    onInfoWindowTappedPlatform.clear();
    onInfoWindowTapPlatform.clear();
    onMapStyleLoadedPlatform.clear();

    onMapClickPlatform.clear();
    onMapLongClickPlatform.clear();
    onMarkerTapPlatform.clear();
    onPolylineTapPlatform.clear();
    onPolygonTapPlatform.clear();
    onCameraTrackingChangedPlatform.clear();
    onCameraTrackingDismissedPlatform.clear();
    onMapIdlePlatform.clear();
    onUserLocationUpdatedPlatform.clear();
  }
}
