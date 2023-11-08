package com.vnptmap.sdk.v2.flutter_vnptmap_gl;

import com.mapbox.mapboxsdk.geometry.LatLng;

import java.util.List;

/**
 * Receiver of Polygon configuration options.
 */
public interface VNPTMapPolygonOptionsSink {

    void setConsumeTapEvents(boolean consumetapEvents);

    void setFillColor(int color);

    void setStrokeColor(int color);

    void setAlpha(float alpha);

    void setPoints(List<LatLng> points);

    void setHoles(List<List<LatLng>> holes);
}
