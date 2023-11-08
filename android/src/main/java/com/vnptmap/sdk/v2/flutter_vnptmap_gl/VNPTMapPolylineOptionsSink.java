package com.vnptmap.sdk.v2.flutter_vnptmap_gl;

import com.mapbox.mapboxsdk.geometry.LatLng;

import java.util.List;

/**
 * Interface defining the methods a VNPTMapPolylineOptionsSink must implement to receive VNPTMapPolyline
 * configuration options.
 */
public interface VNPTMapPolylineOptionsSink {

    void setConsumeTapEvents(boolean consumeTapEvents);

    void setColor(int color);

    void setAlpha(float alpha);

    void setPoints(List<LatLng> points);

    void setWidth(float width);

}
