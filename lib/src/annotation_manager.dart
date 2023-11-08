part of flutter_vnptmap_gl;

abstract class AnnotationManager<T extends Annotation> {
  final VNPTMapController controller;
  final _idToAnnotation = <String, T>{};
  final _idToLayerIndex = <String, int>{};

  /// Called if a annotation is tapped
  final void Function(T)? onTap;

  /// base id of the manager. User [layerdIds] to get the actual ids.
  final String id;

  List<String> get layerIds =>
      [for (int i = 0; i < allLayerProperties.length; i++) _makeLayerId(i)];

  /// If disabled the manager offers no interaction for the created symbols
  final bool enableInteraction;

  /// implemented to define the layer properties
  List<LayerProperties> get allLayerProperties;

  /// used to spedicy the layer and annotation will life on
  /// This can be replaced by layer filters a soon as they are implemented
  final int Function(T)? selectLayer;

  /// get the an annotation by its id
  T? byId(String id) => _idToAnnotation[id];

  Set<T> get annotations => _idToAnnotation.values.toSet();

  AnnotationManager(this.controller,
      {this.onTap, this.selectLayer, required this.enableInteraction})
      : id = getRandomString() {
    for (var i = 0; i < allLayerProperties.length; i++) {
      final layerId = _makeLayerId(i);
      controller.addGeoJsonSource(layerId, buildFeatureCollection([]),
          promoteId: "id");
      controller.addLayer(layerId, layerId, allLayerProperties[i]);
    }

    if (onTap != null) {
      controller.onFeatureTapped.add(_onFeatureTapped);
    }
    controller.onFeatureDrag.add(_onDrag);
  }

  /// This function can be used to rebuild all layers after their properties
  /// changed
  Future<void> _rebuildLayers() async {
    for (var i = 0; i < allLayerProperties.length; i++) {
      final layerId = _makeLayerId(i);
      await controller.removeLayer(layerId);
      await controller.addLayer(layerId, layerId, allLayerProperties[i]);
    }
  }

  _onFeatureTapped(dynamic id, Point<double> point, LatLng coordinates) {
    final annotation = _idToAnnotation[id];
    if (annotation != null) {
      onTap!(annotation);
    }
  }

  String _makeLayerId(int layerIndex) => "${id}_$layerIndex";

  Future<void> _setAll() async {
    if (selectLayer != null) {
      final featureBuckets = [for (final _ in allLayerProperties) <T>[]];

      for (final annotation in _idToAnnotation.values) {
        final layerIndex = selectLayer!(annotation);
        _idToLayerIndex[annotation.id] = layerIndex;
        featureBuckets[layerIndex].add(annotation);
      }

      for (var i = 0; i < featureBuckets.length; i++) {
        await controller.setGeoJsonSource(
            _makeLayerId(i),
            buildFeatureCollection(
                [for (final l in featureBuckets[i]) l.toGeoJson()]));
      }
    } else {
      await controller.setGeoJsonSource(
          _makeLayerId(0),
          buildFeatureCollection(
              [for (final l in _idToAnnotation.values) l.toGeoJson()]));
    }
  }

  /// Adds a multiple annotations to the map. This much faster than calling add
  /// multiple times
  Future<void> addAll(Iterable<T> annotations) async {
    for (var a in annotations) {
      _idToAnnotation[a.id] = a;
    }
    await _setAll();
  }

  /// add a single annotation to the map
  Future<void> add(T annotation) async {
    _idToAnnotation[annotation.id] = annotation;
    await _setAll();
  }

  /// Removes multiple annotations from the map
  Future<void> removeAll(Iterable<T> annotations) async {
    for (var a in annotations) {
      _idToAnnotation.remove(a.id);
    }
    await _setAll();
  }

  /// Remove a single annotation form the map
  Future<void> remove(T annotation) async {
    _idToAnnotation.remove(annotation.id);
    await _setAll();
  }

  /// Removes all annotations from the map
  Future<void> clear() async {
    _idToAnnotation.clear();

    await _setAll();
  }

  /// Fully dipose of all the the resouces managed by the annotation manager.
  /// The manager cannot be used after this has been called
  Future<void> dispose() async {
    _idToAnnotation.clear();
    await _setAll();
    for (var i = 0; i < allLayerProperties.length; i++) {
      await controller.removeLayer(_makeLayerId(i));
      await controller.removeSource(_makeLayerId(i));
    }
  }

  _onDrag(dynamic id,
      {required Point<double> point,
      required LatLng origin,
      required LatLng current,
      required LatLng delta,
      required DragEventType eventType}) {
    final annotation = byId(id);
    if (annotation != null) {
      annotation.translate(delta);
      set(annotation);
    }
  }

  /// Set an existing anntotation to the map. Use this to do a fast update for a
  /// single annotation
  Future<void> set(T anntotation) async {
    assert(_idToAnnotation.containsKey(anntotation.id),
        "you can only set existing annotations");
    _idToAnnotation[anntotation.id] = anntotation;
    final oldLayerIndex = _idToLayerIndex[anntotation.id];
    final layerIndex = selectLayer != null ? selectLayer!(anntotation) : 0;
    if (oldLayerIndex != layerIndex) {
      // if the annotation has to be moved to another layer/source we have to
      // set all
      await _setAll();
    } else {
      await controller.setGeoJsonFeature(
          _makeLayerId(layerIndex), anntotation.toGeoJson());
    }
  }
}

class CircleManager extends AnnotationManager<Circle> {
  CircleManager(
    VNPTMapController controller, {
    void Function(Circle)? onTap,
    bool enableInteraction = true,
  }) : super(
          controller,
          enableInteraction: enableInteraction,
          onTap: onTap,
        );
  @override
  List<LayerProperties> get allLayerProperties => const [
        CircleLayerProperties(
          circleRadius: [Expressions.get, 'circleRadius'],
          circleColor: [Expressions.get, 'circleColor'],
          circleBlur: [Expressions.get, 'circleBlur'],
          circleOpacity: [Expressions.get, 'circleOpacity'],
          circleStrokeWidth: [Expressions.get, 'circleStrokeWidth'],
          circleStrokeColor: [Expressions.get, 'circleStrokeColor'],
          circleStrokeOpacity: [Expressions.get, 'circleStrokeOpacity'],
        )
      ];
}
