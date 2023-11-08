package com.vnptmap.sdk.v2.flutter_vnptmap_gl;

import com.mapbox.mapboxsdk.annotations.Marker;
import com.mapbox.mapboxsdk.annotations.MarkerOptions;
import com.mapbox.mapboxsdk.maps.MapboxMap;

import android.content.Context;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import androidx.annotation.NonNull;
import io.flutter.plugin.common.MethodChannel;

public class VNPTMapMarkerController {
    private final Map<String, VNPTMapMarker> markerIdToController;
    private final Map<Long, String> markerIdToDartMarkerId;
    private final MethodChannel methodChannel;
    private final Context context;
    private MapboxMap mapboxMap;
    private final float density;


    public VNPTMapMarkerController(@NonNull Context context, MethodChannel methodChannel, float density) {
        this.context = context;
        this.markerIdToController = new HashMap<>();
        this.markerIdToDartMarkerId = new HashMap<>();
        this.methodChannel = methodChannel;
        this.density = density;
    }

    void setMap(@NonNull MapboxMap mapboxMap) {
        this.mapboxMap = mapboxMap;
    }

    void addMarkers(List<Object> markersToAdd) {
        if (markersToAdd == null) {
            return;
        }
        for (Object markerToAdd : markersToAdd) {
            addMarker(markerToAdd);
        }
    }


    private void addMarker(Object marker) {
        if (marker == null) {
            return;
        }
        VNPTMapMarkerBuilder markerBuilder = new VNPTMapMarkerBuilder(density);
        String markerId = VNPTMapConvert.interpretMarkerOptions(marker, markerBuilder, context);
        MarkerOptions options = markerBuilder.build();
        addMarker(markerId, options, markerBuilder.consumeTapEvents());
    }

    private void addMarker(String markerId, MarkerOptions markerOptions, boolean consumeTapEvents) {
        final Marker marker = mapboxMap.addMarker(markerOptions);
        VNPTMapMarker controller = new VNPTMapMarker(marker, consumeTapEvents, density);
        markerIdToController.put(markerId, controller);
        markerIdToDartMarkerId.put(marker.getId(), markerId);

    }

    void changeMarkers(List<Object> markersToChange) {
        if (markersToChange != null) {
            for (Object markerToChange : markersToChange) {
                changeMarker(markerToChange);
            }
        }
    }

    void removeMarkers(List<Object> markerIdsToRemove) {
        if (markerIdsToRemove == null) {
            return;
        }
        for (Object rawMarkerId : markerIdsToRemove) {
            if (rawMarkerId == null) {
                continue;
            }
            String markerId = (String) rawMarkerId;
            final VNPTMapMarker markerController = markerIdToController.remove(markerId);
            if (markerController != null) {
                markerController.remove();
                markerIdToDartMarkerId.remove(markerController.getMFMarkerId());
            }
        }
    }

    private void changeMarker(Object marker) {
        if (marker == null) {
            return;
        }
        String markerId = getMarkerId(marker);
        VNPTMapMarker markerController = markerIdToController.get(markerId);
        if (markerController != null) {
            VNPTMapConvert.interpretMarkerOptions(marker, markerController, context);
        }
    }

    @SuppressWarnings("unchecked")
    private static String getMarkerId(Object marker) {
        Map<String, Object> markerMap = (Map<String, Object>) marker;
        return (String) markerMap.get("markerId");
    }

    // onMarkerTap
    boolean onMarkerTap(long vnptMapMarkerId) {
        String markerId = markerIdToDartMarkerId.get(vnptMapMarkerId);
        if (markerId == null) {
            return false;
        }
        methodChannel.invokeMethod("marker#onTap", VNPTMapConvert.markerIdToJson(markerId));
        VNPTMapMarker markerController = markerIdToController.get(markerId);
        if (markerController != null) {
            return markerController.consumeTapEvents();
        }
        return false;
    }
}
