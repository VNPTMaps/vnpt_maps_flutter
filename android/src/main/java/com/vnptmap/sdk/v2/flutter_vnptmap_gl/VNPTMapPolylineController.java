package com.vnptmap.sdk.v2.flutter_vnptmap_gl;

import com.mapbox.mapboxsdk.annotations.Polyline;
import com.mapbox.mapboxsdk.annotations.PolylineOptions;
import com.mapbox.mapboxsdk.maps.MapboxMap;

import android.util.Log;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class VNPTMapPolylineController {
    private final Map<String, VNPTMapPolyline> polylineIdToController;
    private final Map<Long, String> polylineIdToDartPolylineId;
    private final MethodChannel methodChannel;
    private MapboxMap mapboxMap;
    private final float density;

    VNPTMapPolylineController(MethodChannel methodChannel, float density) {
        this.polylineIdToController = new HashMap<>();
        this.polylineIdToDartPolylineId = new HashMap<>();
        this.methodChannel = methodChannel;
        this.density = density;
    }

    void setMap(MapboxMap mapboxMap) {
        this.mapboxMap = mapboxMap;
    }


    // Add polylines
    void addPolylines(List<Object> polylinesToAdd) {
        if (polylinesToAdd != null) {
            for (Object polylineToAdd : polylinesToAdd) {
                addPolyline(polylineToAdd);
            }
        }
    }

    void changePolylines(List<Object> polylinesToChange) {
        if (polylinesToChange != null) {
            for (Object polylineToChange : polylinesToChange) {
                changePolyline(polylineToChange);
            }
        }
    }

    void removePolylines(List<Object> polylineIdsToRemove) {
        if (polylineIdsToRemove == null) {
            return;
        }
        for (Object rawPolylineId : polylineIdsToRemove) {
            if (rawPolylineId == null) {
                continue;
            }
            String polylineId = (String) rawPolylineId;
            final VNPTMapPolyline polylineController = polylineIdToController.remove(polylineId);
            if (polylineController != null) {
                polylineController.remove();
                polylineIdToDartPolylineId.remove(polylineController.getMFPolylineId());
            }
        }
    }

    boolean onPolylineTap(long vnptPolylineId) {
        String polylineId = polylineIdToDartPolylineId.get(vnptPolylineId);
        if (polylineId == null) {
            return false;
        }
        methodChannel.invokeMethod("polyline#onTap", VNPTMapConvert.polylineIdToJson(polylineId));
        VNPTMapPolyline polylineController = polylineIdToController.get(polylineId);
        if (polylineController != null) {
            return polylineController.consumeTapEvents();
        }
        return false;
    }

    private void addPolyline(Object polyline) {
        if (polyline == null) {
            return;
        }
        VNPTMapPolylineBuilder polylineBuilder = new VNPTMapPolylineBuilder(density);
        String polylineId = VNPTMapConvert.interpretPolylineOptions(polyline, polylineBuilder);
        PolylineOptions options = polylineBuilder.build();
        addPolyline(polylineId, options, polylineBuilder.consumeTapEvents());
    }

    private void addPolyline(
            String polylineId, PolylineOptions polylineOptions, boolean consumeTapEvents) {
        final Polyline polyline = mapboxMap.addPolyline(polylineOptions);
        VNPTMapPolyline polylineController = new VNPTMapPolyline(polyline, consumeTapEvents, density);
        polylineIdToController.put(polylineId, polylineController);
        polylineIdToDartPolylineId.put(polyline.getId(), polylineId);
    }

    private void changePolyline(Object polyline) {
        if (polyline == null) {
            return;
        }
        String polylineId = getPolylineId(polyline);
        VNPTMapPolyline polylineController = polylineIdToController.get(polylineId);
        if (polylineController != null) {
            VNPTMapConvert.interpretPolylineOptions(polyline, polylineController);
        }
    }

    @SuppressWarnings("unchecked")
    private static String getPolylineId(Object polyline) {
        Map<String, Object> polylineMap = (Map<String, Object>) polyline;
        return (String) polylineMap.get("polylineId");
    }
}
