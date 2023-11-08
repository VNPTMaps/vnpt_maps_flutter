package com.vnptmap.sdk.v2.flutter_vnptmap_gl;

import androidx.annotation.Nullable;
import androidx.lifecycle.Lifecycle;

/**
 * Provides a static method for extracting lifecycle objects from Flutter plugin bindings.
 */
public interface LifecycleProvider {
    @Nullable
    Lifecycle getLifecycle();
}
