package com.vnptmap.sdk.v2.flutter_vnptmap_gl;

import com.mapbox.mapboxsdk.annotations.Icon;
import com.mapbox.mapboxsdk.geometry.LatLng;

/**
 * A sink for VNPTMapMarkerOptions. Receiver of Marker configuration options
 */
public interface VNPTMapMarkerOptionsSink {

    void setPosition(LatLng position);

    void setIcon(Icon icon);

    void setTitle(String title);

    void setSnippet(String snippet);

    void setConsumeTapEvents(boolean consumeTapEvents);
}
