package com.vnptmap.sdk.v2.flutter_vnptmap_gl;

import com.mapbox.mapboxsdk.annotations.PolylineOptions;
import com.mapbox.mapboxsdk.geometry.LatLng;

import java.util.List;

public class VNPTMapPolylineBuilder implements VNPTMapPolylineOptionsSink {
    private final PolylineOptions polylineOptions;
    private boolean consumeTapEvents;
    private final float density;


    public VNPTMapPolylineBuilder(float density) {
        this.polylineOptions = new PolylineOptions();
        this.density = density;
    }

    public PolylineOptions build() {
        return polylineOptions;
    }

    public boolean consumeTapEvents() {
        return consumeTapEvents;
    }

    @Override
    public void setConsumeTapEvents(boolean consumeTapEvents) {
        this.consumeTapEvents = consumeTapEvents;
    }

    @Override
    public void setColor(int color) {
        polylineOptions.color(color);
    }

    @Override
    public void setAlpha(float alpha) {
        polylineOptions.alpha(alpha);
    }

    @Override
    public void setPoints(List<LatLng> points) {
        for (LatLng point : points) {
            polylineOptions.add(point);
        }
    }

    @Override
    public void setWidth(float width) {
        polylineOptions.width(width);
    }
}
