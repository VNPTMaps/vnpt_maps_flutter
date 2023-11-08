package com.vnptmap.sdk.v2.flutter_vnptmap_gl;

import com.mapbox.mapboxsdk.annotations.Polygon;
import com.mapbox.mapboxsdk.geometry.LatLng;

import java.util.List;

/**
 * Controller of a single Polygon on the map.
 */
public class VNPTMapPolygon implements VNPTMapPolygonOptionsSink {

    private final Polygon polygon;
    private final long polygonId;
    private boolean consumeTapEvents;
    private final float density;

    VNPTMapPolygon(Polygon polygon, boolean consumeTapEvents, float density) {
        this.polygon = polygon;
        this.consumeTapEvents = consumeTapEvents;
        this.density = density;
        this.polygonId = polygon.getId();
    }

    public void remove() {
        polygon.remove();
    }

    public long getPolygonId() {
        return polygonId;
    }

    public boolean consumeTapEvents() {
        return consumeTapEvents;
    }

    @Override
    public void setConsumeTapEvents(boolean consumetapEvents) {
        this.consumeTapEvents = consumetapEvents;
    }

    @Override
    public void setFillColor(int color) {
        polygon.setFillColor(color);
    }

    @Override
    public void setStrokeColor(int color) {
        polygon.setStrokeColor(color);
    }

    @Override
    public void setAlpha(float alpha) {
        polygon.setAlpha(alpha);
    }

    @Override
    public void setPoints(List<LatLng> points) {
        polygon.setPoints(points);
    }

    @Override
    public void setHoles(List<List<LatLng>> holes) {
        polygon.setHoles(holes);
    }
}