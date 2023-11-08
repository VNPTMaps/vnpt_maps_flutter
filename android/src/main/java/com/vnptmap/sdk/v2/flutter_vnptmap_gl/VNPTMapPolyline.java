package com.vnptmap.sdk.v2.flutter_vnptmap_gl;

import com.mapbox.mapboxsdk.annotations.Polyline;
import com.mapbox.mapboxsdk.geometry.LatLng;

import java.util.List;

public class VNPTMapPolyline implements VNPTMapPolylineOptionsSink {

    private final Polyline polyline;
    private final long vnptPolylineId;
    private boolean consumeTapEvents;
    private final float density;

    public VNPTMapPolyline(Polyline polyline, boolean consumeTapEvents, float density) {
        this.polyline = polyline;
        this.consumeTapEvents = consumeTapEvents;
        this.density = density;
        this.vnptPolylineId = polyline.getId();

    }

    boolean consumeTapEvents() {
        return consumeTapEvents;
    }

    public void remove() {
        polyline.remove();
    }

    public long getMFPolylineId() {
        return vnptPolylineId;
    }

    @Override
    public void setConsumeTapEvents(boolean consumeTapEvents) {
        this.consumeTapEvents = consumeTapEvents;
    }

    @Override
    public void setColor(int color) {
        polyline.setColor(color);
    }

    @Override
    public void setAlpha(float alpha) {
        polyline.setAlpha(alpha);
    }

    @Override
    public void setPoints(List<LatLng> points) {
        polyline.setPoints(points);
    }

    @Override
    public void setWidth(float width) {
        polyline.setWidth(width);
    }
}
