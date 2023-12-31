part of vnptmap_gl_platform_interface;

/// Converts an [Iterable] of [MapsObject]s in a Map of [MapObjectId] -> [MapObject].
Map<MapsObjectId<T>, T> keyByMapsObjectId<T extends MapsObject>(
    Iterable<T> objects) {
  return Map<MapsObjectId<T>, T>.fromEntries(objects.map((T object) =>
      MapEntry<MapsObjectId<T>, T>(
          object.mapsId as MapsObjectId<T>, object.clone())));
}

/// Converts a Set of [MapsObject]s into something serializable in JSON.
Object serializeMapsObjectSet(Set<MapsObject> mapsObjects) {
  return mapsObjects.map<Object>((MapsObject p) => p.toJson()).toList();
}
