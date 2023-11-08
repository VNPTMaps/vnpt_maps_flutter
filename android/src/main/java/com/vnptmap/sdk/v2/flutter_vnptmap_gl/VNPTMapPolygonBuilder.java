package com.vnptmap.sdk.v2.flutter_vnptmap_gl;

import com.mapbox.mapboxsdk.annotations.PolygonOptions;
import com.mapbox.mapboxsdk.geometry.LatLng;

import java.util.List;

public class VNPTMapPolygonBuilder implements VNPTMapPolygonOptionsSink {

    private final PolygonOptions polygonOptions;
    private boolean consumeTapEvents;
    private final float density;

    VNPTMapPolygonBuilder(float density) {
        this.polygonOptions = new PolygonOptions();
        this.density = density;
    }

    PolygonOptions build() {
        return polygonOptions;
    }

    boolean consumeTapEvents() {
        return consumeTapEvents;
    }

    @Override
    public void setConsumeTapEvents(boolean consumetapEvents) {
        this.consumeTapEvents = consumetapEvents;
    }

    @Override
    public void setFillColor(int color) {
        polygonOptions.fillColor(color);
    }

    @Override
    public void setStrokeColor(int color) {
        polygonOptions.strokeColor(color);
    }

    @Override
    public void setAlpha(float alpha) {
        polygonOptions.alpha(alpha);
    }

    @Override
    public void setPoints(List<LatLng> points) {
        for (LatLng point : points) {
            polygonOptions.add(point);
        }
    }

    @Override
    public void setHoles(List<List<LatLng>> holes) {
        for (int i = 0; i < holes.size(); ++i) {
            List<LatLng> hole = holes.get(i);
            polygonOptions.addHole(hole);
        }
    }
}
