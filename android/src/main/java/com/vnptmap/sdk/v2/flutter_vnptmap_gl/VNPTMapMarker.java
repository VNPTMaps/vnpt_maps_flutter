package com.vnptmap.sdk.v2.flutter_vnptmap_gl;

import com.mapbox.mapboxsdk.annotations.Icon;
import com.mapbox.mapboxsdk.annotations.Marker;
import com.mapbox.mapboxsdk.geometry.LatLng;

public class VNPTMapMarker implements VNPTMapMarkerOptionsSink {

    private final Marker marker;
    private final long markerId;
    private final float density;
    private boolean consumeTapEvents;

    public VNPTMapMarker(Marker marker, boolean consumeTapEvents, float density) {
        this.marker = marker;
        this.markerId = marker.getId();
        this.density = density;
        this.consumeTapEvents = consumeTapEvents;
    }


    void remove() {
        marker.remove();
    }

    long getMFMarkerId() {
        return markerId;
    }

    boolean consumeTapEvents() {
        return consumeTapEvents;
    }

    @Override
    public void setPosition(LatLng position) {
        marker.setPosition(position);
    }

    @Override
    public void setIcon(Icon icon) {
        marker.setIcon(icon);
    }

    @Override
    public void setTitle(String title) {
        marker.setTitle(title);
    }

    @Override
    public void setSnippet(String snippet) {
        marker.setSnippet(snippet);
    }

    @Override
    public void setConsumeTapEvents(boolean consumeTapEvents) {
        this.consumeTapEvents = consumeTapEvents;
    }
}
