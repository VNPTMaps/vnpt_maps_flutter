package com.vnptmap.sdk.v2.flutter_vnptmap_gl;

import android.app.Activity;
import android.app.Application;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.LifecycleRegistry;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodChannel;

/**
 * VNPTMapViewPlugin
 */
public class VNPTMapsPlugin implements FlutterPlugin, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    static FlutterAssets flutterAssets;
    private MethodChannel channel;
    @Nullable
    private Lifecycle lifecycle;


    /**
     * Plugin registration.
     */
    @SuppressWarnings("deprecation")
    public static void registerWith(io.flutter.plugin.common.PluginRegistry.Registrar registrar) {
        final Activity activity = registrar.activity();
        if (activity == null) {
            // When a background flutter view tries to register the plugin, the registrar has no activity.
            // We stop the registration process as this plugin is foreground only.
            return;
        }
        if (activity instanceof LifecycleOwner) {
            registrar
                .platformViewRegistry()
                .registerViewFactory(
                    VNPTMethodChannelConstants.METHOD_CHANNEL_MAP_VIEW_TYPE,
                    new VNPTMapViewFactory(
                        registrar.messenger(),
                        new LifecycleProvider() {
                            @Nullable
                            @Override
                            public Lifecycle getLifecycle() {
                                return ((LifecycleOwner) activity).getLifecycle();
                            }
                        }
                    )
                );
        } else {
            registrar
                .platformViewRegistry()
                .registerViewFactory(
                    VNPTMethodChannelConstants.METHOD_CHANNEL_MAP_VIEW_TYPE,
                    new VNPTMapViewFactory(
                        registrar.messenger(),
                        new ProxyLifecycleProvider(activity)
                    )
                );

        }

    }

    public VNPTMapsPlugin() {
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        flutterAssets = flutterPluginBinding.getFlutterAssets();
        MethodChannel methodChannel =
                new MethodChannel(flutterPluginBinding.getBinaryMessenger(), VNPTMethodChannelConstants.METHOD_CHANNEL_NAME);
        methodChannel.setMethodCallHandler(new VNPTMapGlobalMethodHandler(flutterPluginBinding));
        flutterPluginBinding.getPlatformViewRegistry().registerViewFactory(
            VNPTMethodChannelConstants.METHOD_CHANNEL_MAP_VIEW_TYPE,
            new VNPTMapViewFactory(
                flutterPluginBinding.getBinaryMessenger(),
                new LifecycleProvider() {
                    @Nullable
                    @Override
                    public Lifecycle getLifecycle() {
                        return lifecycle;
                    }
                }
            )
        );
    }


    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        // no-op
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(binding);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        onAttachedToActivity(binding);
    }

    @Override
    public void onDetachedFromActivity() {
        lifecycle = null;
    }


    /**
     * This class provides a {@link LifecycleOwner} for the activity driven by {@link
     * Application.ActivityLifecycleCallbacks}.
     *
     * <p>This is used in the case where a direct Lifecycle/Owner is not available.
     */
    private static final class ProxyLifecycleProvider
            implements Application.ActivityLifecycleCallbacks, LifecycleOwner, LifecycleProvider {

        private final LifecycleRegistry lifecycle = new LifecycleRegistry(this);
        private final int registrarActivityHashCode;


        private ProxyLifecycleProvider(Activity activity) {
            this.registrarActivityHashCode = activity.hashCode();
            activity.getApplication().registerActivityLifecycleCallbacks(this);
        }

        @Override
        public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
            if (activity.hashCode() != registrarActivityHashCode) {
                return;
            }
            lifecycle.handleLifecycleEvent(Lifecycle.Event.ON_CREATE);
        }

        @Override
        public void onActivityStarted(Activity activity) {
            if (activity.hashCode() != registrarActivityHashCode) {
                return;
            }
            lifecycle.handleLifecycleEvent(Lifecycle.Event.ON_START);
        }

        @Override
        public void onActivityResumed(Activity activity) {
            if (activity.hashCode() != registrarActivityHashCode) {
                return;
            }
            lifecycle.handleLifecycleEvent(Lifecycle.Event.ON_RESUME);
        }

        @Override
        public void onActivityPaused(Activity activity) {
            if (activity.hashCode() != registrarActivityHashCode) {
                return;
            }
            lifecycle.handleLifecycleEvent(Lifecycle.Event.ON_PAUSE);
        }

        @Override
        public void onActivityStopped(Activity activity) {
            if (activity.hashCode() != registrarActivityHashCode) {
                return;
            }
            lifecycle.handleLifecycleEvent(Lifecycle.Event.ON_STOP);
        }

        @Override
        public void onActivitySaveInstanceState(Activity activity, Bundle outState) {
        }

        @Override
        public void onActivityDestroyed(Activity activity) {
            if (activity.hashCode() != registrarActivityHashCode) {
                return;
            }
            activity.getApplication().unregisterActivityLifecycleCallbacks(this);
            lifecycle.handleLifecycleEvent(Lifecycle.Event.ON_DESTROY);
        }

        @NonNull
        @Override
        public Lifecycle getLifecycle() {
            return lifecycle;
        }
    }
}
