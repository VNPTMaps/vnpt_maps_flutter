package com.vnptmap.sdk.v2.flutter_vnptmap_gl;

import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;

import com.mapbox.mapboxsdk.Mapbox;
import com.mapbox.mapboxsdk.WellKnownTileServer;

public class VNPTMapUtils {
    public static final String TAG = VNPTMapUtils.class.getSimpleName();

    static Mapbox getVnptMap(Context context, String accessToken) {
        return Mapbox.getInstance(context, accessToken == null ? getAccessToken(context) : accessToken, WellKnownTileServer.MapLibre);
    }

    static Mapbox getVnptMap(Context context) {
        return Mapbox.getInstance(context);
    }

    private static String getAccessToken(@NonNull Context context) {
        try {
            ApplicationInfo ai =
                    context
                            .getPackageManager()
                            .getApplicationInfo(context.getPackageName(), PackageManager.GET_META_DATA);
            Bundle bundle = ai.metaData;
            String token = bundle.getString("com.vnpt.token");
            if (token == null || token.isEmpty()) {
                throw new NullPointerException();
            }
            return token;
        } catch (Exception e) {
            Log.e(
                    TAG,
                    "Failed to find an Access Token in the Application meta-data. Maps may not load"
                            + " correctly. Please refer to the installation guide at"
                            + " https://vnpmap.com.vn for"
                            + " troubleshooting advice."
                            + e.getMessage());
        }
        return null;
    }

}
