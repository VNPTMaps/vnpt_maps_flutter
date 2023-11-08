package com.vnptmap.sdk.v2.flutter_vnptmap_gl;

import com.mapbox.mapboxsdk.camera.CameraPosition;

import android.content.Context;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

/**
 * Factory for creating a {@link VNPTMapsPlugin} instance.
 */
public class VNPTMapViewFactory extends PlatformViewFactory {

    private final BinaryMessenger binaryMessenger;
    private final LifecycleProvider lifecycleProvider;
    /**
     * Store all mapViewController to use in vnpt_map_gl flutter
     **/
    public static Map<Integer, VNPTMapViewController> mapViewControllerMap;


    static {
        if (mapViewControllerMap == null) {
            mapViewControllerMap = new HashMap<>();
        }
    }

    public VNPTMapViewFactory(BinaryMessenger binaryMessenger, LifecycleProvider lifecycleProvider) {
        super(StandardMessageCodec.INSTANCE);
        this.binaryMessenger = binaryMessenger;
        this.lifecycleProvider = lifecycleProvider;
    }


    @Override
    public PlatformView create(Context context, int viewId, Object args) {
        Map<String, Object> params = (Map<String, Object>) args;
        final VNPTMapViewBuilder builder = new VNPTMapViewBuilder();
        VNPTMapConvert.interpretVNPTMapOptions(params.get("options"), builder, context);

        if (params.containsKey("initialCameraPosition")) {
            CameraPosition position = VNPTMapConvert.toCameraPosition(params.get("initialCameraPosition"));
            builder.setInitialCameraPosition(position);
        }
        if (params.containsKey("dragEnabled")) {
           boolean dragEnabled = VNPTMapConvert.toBoolean(params.get("dragEnabled"));
           builder.setDragEnabled(dragEnabled);
        }

        VNPTMapViewController controller = builder.build(
                viewId, context, binaryMessenger, lifecycleProvider, (String) params.get("accessToken"));

        mapViewControllerMap.put(viewId, controller);
        return controller;

    }
}
