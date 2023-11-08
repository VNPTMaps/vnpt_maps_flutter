package com.vnptmap.sdk.v2.flutter_vnptmap_gl;

import com.mapbox.mapboxsdk.annotations.Polygon;
import com.mapbox.mapboxsdk.annotations.PolygonOptions;
import com.mapbox.mapboxsdk.maps.MapboxMap;

import android.util.Log;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class VNPTMapPolygonController {
    private final Map<String, VNPTMapPolygon> polygonIdToController;
    private final Map<Long, String> polygonIdToDartPolygonId;
    private final MethodChannel methodChannel;
    private MapboxMap mapboxMap;
    private final float density;

    VNPTMapPolygonController(MethodChannel methodChannel, float density) {
        this.polygonIdToController = new HashMap<>();
        this.polygonIdToDartPolygonId = new HashMap<>();
        this.methodChannel = methodChannel;
        this.density = density;
    }

    void setMap(MapboxMap mapboxMap) {
        this.mapboxMap = mapboxMap;
    }

    void addPolygons(List<Object> polygonsToAdd) {
        if (polygonsToAdd != null) {
            for (Object polygonToAdd : polygonsToAdd) {
                addPolygon(polygonToAdd);
            }
        }
    }

    void changePolygons(List<Object> polygonsToChange) {
        if (polygonsToChange != null) {
            for (Object polygonToChange : polygonsToChange) {
                changePolygon(polygonToChange);
            }
        }
    }

    void removePolygons(List<Object> polygonIdsToRemove) {
        if (polygonIdsToRemove == null) {
            return;
        }
        for (Object rawPolygonId : polygonIdsToRemove) {
            if (rawPolygonId == null) {
                continue;
            }
            String polygonId = (String) rawPolygonId;
            final VNPTMapPolygon polygonController = polygonIdToController.remove(polygonId);
            if (polygonController != null) {
                polygonController.remove();
                polygonIdToDartPolygonId.remove(polygonController.getPolygonId());
            }
        }
    }

    boolean onPolygonTap(long vnptPolygonId) {
        String polygonId = polygonIdToDartPolygonId.get(vnptPolygonId);
        if (polygonId == null) {
            return false;
        }
        methodChannel.invokeMethod("polygon#onTap", VNPTMapConvert.polygonIdToJson(polygonId));
        VNPTMapPolygon polygonController = polygonIdToController.get(polygonId);
        if (polygonController != null) {
            return polygonController.consumeTapEvents();
        }
        return false;
    }

    private void addPolygon(Object polygon) {
        if (polygon == null) {
            return;
        }
        VNPTMapPolygonBuilder polygonBuilder = new VNPTMapPolygonBuilder(density);
        String polygonId = VNPTMapConvert.interpretPolygonOptions(polygon, polygonBuilder);
        PolygonOptions options = polygonBuilder.build();
        addPolygon(polygonId, options, polygonBuilder.consumeTapEvents());
    }

    private void addPolygon(String polygonId, PolygonOptions polygonOptions, boolean consumeTapEvents) {
        final Polygon polygon = mapboxMap.addPolygon(polygonOptions);
        VNPTMapPolygon controller = new VNPTMapPolygon(polygon, consumeTapEvents, density);
        polygonIdToController.put(polygonId, controller);
        polygonIdToDartPolygonId.put(polygon.getId(), polygonId);
    }

    private void changePolygon(Object polygon) {
        if (polygon == null) {
            return;
        }
        String polygonId = getPolygonId(polygon);
        VNPTMapPolygon polygonController = polygonIdToController.get(polygonId);
        if (polygonController != null) {
            VNPTMapConvert.interpretPolygonOptions(polygon, polygonController);
        }
    }

    @SuppressWarnings("unchecked")
    private static String getPolygonId(Object polygon) {
        Map<String, Object> polygonMap = (Map<String, Object>) polygon;
        return (String) polygonMap.get("polygonId");
    }
}
