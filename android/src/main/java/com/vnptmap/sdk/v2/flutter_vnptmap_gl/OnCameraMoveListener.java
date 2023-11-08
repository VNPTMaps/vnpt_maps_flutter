package com.vnptmap.sdk.v2.flutter_vnptmap_gl;

import com.mapbox.mapboxsdk.camera.CameraPosition;

/**
 * Listener that gets called when the camera starts moving.
 */
public interface OnCameraMoveListener {
    void onCameraMoveStarted(boolean isGesture);

    void onCameraMove(CameraPosition newPosition);

    void onCameraIdle();
}
