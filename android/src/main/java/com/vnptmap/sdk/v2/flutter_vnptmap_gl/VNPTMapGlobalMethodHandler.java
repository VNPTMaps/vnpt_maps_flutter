package com.vnptmap.sdk.v2.flutter_vnptmap_gl;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

/**
 * VNPTMapGlobalMethodHandler is a class that handles global method calls.
 */
public class VNPTMapGlobalMethodHandler implements MethodChannel.MethodCallHandler {
    private final String TAG = VNPTMapGlobalMethodHandler.class.getSimpleName();

    @NonNull
    private final Context context;
    @NonNull
    private final BinaryMessenger messenger;
    @Nullable
    private PluginRegistry.Registrar registrar;
    @Nullable
    private FlutterPlugin.FlutterAssets flutterAssets;

    @SuppressWarnings("deprecation")
    public VNPTMapGlobalMethodHandler(@Nullable PluginRegistry.Registrar registrar) {
        this.registrar = registrar;
        this.context = registrar.activeContext();
        this.messenger = registrar.messenger();
    }

    public VNPTMapGlobalMethodHandler(@NonNull FlutterPlugin.FlutterPluginBinding binding) {
        this.context = binding.getApplicationContext();
        this.flutterAssets = binding.getFlutterAssets();
        this.messenger = binding.getBinaryMessenger();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall methodCall, @NonNull MethodChannel.Result result) {
        String accessToken = methodCall.argument("accessToken");
        VNPTMapUtils.getVnptMap(context, accessToken);

        /** Define case  with channel */
        switch (methodCall.method) {

            default:
                result.notImplemented();
                break;
        }
    }
}
