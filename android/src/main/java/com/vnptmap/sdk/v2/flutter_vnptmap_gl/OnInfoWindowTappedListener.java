package com.vnptmap.sdk.v2.flutter_vnptmap_gl;

import com.mapbox.mapboxsdk.annotations.Marker;

/**
 * Listener that gets called when the info window of a marker is tapped.
 */
public interface OnInfoWindowTappedListener {
    void onInfoWindowTapped(Marker marker);
}
