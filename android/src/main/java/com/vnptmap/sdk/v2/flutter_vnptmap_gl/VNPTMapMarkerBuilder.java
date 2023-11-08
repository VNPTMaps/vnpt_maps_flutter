package com.vnptmap.sdk.v2.flutter_vnptmap_gl;

import com.mapbox.mapboxsdk.annotations.Icon;
import com.mapbox.mapboxsdk.annotations.MarkerOptions;
import com.mapbox.mapboxsdk.geometry.LatLng;

public class VNPTMapMarkerBuilder implements VNPTMapMarkerOptionsSink {
    private final MarkerOptions markerOptions;
    private boolean consumeTapEvents;
    private final float density;

    public VNPTMapMarkerBuilder(float density) {
        this.markerOptions = new MarkerOptions();
        this.density = density;
    }

    boolean consumeTapEvents() {
        return consumeTapEvents;
    }

    MarkerOptions build() {
        return markerOptions;
    }


    @Override
    public void setPosition(LatLng position) {
        markerOptions.position(position);
    }

    @Override
    public void setIcon(Icon icon) {
        markerOptions.icon(icon);
    }

    @Override
    public void setTitle(String title) {
        markerOptions.title(title);
    }

    @Override
    public void setSnippet(String snippet) {
        markerOptions.snippet(snippet);
    }

    @Override
    public void setConsumeTapEvents(boolean consumeTapEvents) {
        this.consumeTapEvents = consumeTapEvents;
    }

}
