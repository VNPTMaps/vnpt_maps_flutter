package com.vnptmap.sdk.v2.flutter_vnptmap_gl;

import com.mapbox.android.gestures.MoveGestureDetector;

import androidx.annotation.NonNull;

/**
 * Interface definition for a callback to be invoked when a move gesture is detected.
 */
public class OnMoveGestureListener implements MoveGestureDetector.OnMoveGestureListener {
    private final VNPTMapViewController mapMapController;

    public OnMoveGestureListener(VNPTMapViewController mapMapController) {
        this.mapMapController = mapMapController;
    }

    @Override
    public boolean onMoveBegin(@NonNull MoveGestureDetector moveGestureDetector) {
        return this.mapMapController.onMoveBegin(moveGestureDetector);
    }

    @Override
    public boolean onMove(@NonNull MoveGestureDetector moveGestureDetector, float v, float v1) {
        return this.mapMapController.onMove(moveGestureDetector);
    }

    @Override
    public void onMoveEnd(@NonNull MoveGestureDetector moveGestureDetector, float v, float v1) {
        this.mapMapController.onMoveEnd(moveGestureDetector);
    }
}
