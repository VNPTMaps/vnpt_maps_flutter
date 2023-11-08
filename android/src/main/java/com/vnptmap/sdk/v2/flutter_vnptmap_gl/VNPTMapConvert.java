package com.vnptmap.sdk.v2.flutter_vnptmap_gl;

import com.mapbox.mapboxsdk.annotations.Icon;
import com.mapbox.mapboxsdk.annotations.IconFactory;
import com.mapbox.mapboxsdk.camera.CameraPosition;
import com.mapbox.mapboxsdk.camera.CameraUpdate;
import com.mapbox.mapboxsdk.camera.CameraUpdateFactory;
import com.mapbox.mapboxsdk.geometry.LatLng;
import com.mapbox.mapboxsdk.geometry.LatLngBounds;
import com.mapbox.mapboxsdk.maps.MapboxMap;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Point;
import android.util.DisplayMetrics;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.view.FlutterMain;

public class VNPTMapConvert {


    @SuppressWarnings("deprecation")
    public static Icon toIcon(Object o, Context context) {
        final List<?> data = toList(o);
        switch (toString(data.get(0))) {
            case "defaultMarker":
                return IconFactory.getInstance(context).defaultMarker();
            case "fromAssetImage":
                if (data.size() == 3) {
                    // Get image from assets
                    IconFactory iconFactory = IconFactory.getInstance(context);
                    return iconFactory.fromAsset(FlutterMain.getLookupKeyForAsset(toString(data.get(1))));
                } else {
                    throw new IllegalArgumentException(
                            "'fromAssetImage' Expected exactly 3 arguments, got: " + data.size());
                }
            case "fromBytes":
                return getBitmapFromBytes(data, context);
            default:
                throw new IllegalArgumentException("Cannot interpret " + o + " as BitmapDescriptor");
        }
    }

    public static Icon getBitmapFromBytes(List<?> data, Context context) {
        if (data.size() == 2) {
            try {
                Bitmap bitmap = toBitmap(data.get(1));
                return IconFactory.getInstance(context).fromBitmap(bitmap);
            } catch (Exception e) {
                throw new IllegalArgumentException("Unable to interpret bytes as a valid image.", e);
            }
        } else {
            throw new IllegalArgumentException(
                    "fromBytes should have exactly one argument, interpretTileOverlayOptions the bytes. Got: "
                            + data.size());
        }
    }

    public static Bitmap toBitmap(Object o) {
        byte[] bmpData = (byte[]) o;
        Bitmap bitmap = BitmapFactory.decodeByteArray(bmpData, 0, bmpData.length);
        if (bitmap == null) {
            throw new IllegalArgumentException("Unable to decode bytes as a valid bitmap.");
        } else {
            return bitmap;
        }
    }

    static Object latLngToJson(LatLng coordinate) {
        return Arrays.asList(coordinate.getLatitude(), coordinate.getLongitude());
    }


    public static List<?> toList(Object o) {
        return (List<?>) o;
    }

    public static String toString(Object o) {
        return (String) o;
    }

    public static double toDouble(Object o) {
        return ((Number) o).doubleValue();
    }

    public static int toInt(Object o) {
        return ((Number) o).intValue();
    }

    public static float toFloat(Object o) {
        return ((Number) o).floatValue();
    }

    public static Float toFloatWrapper(Object o) {
        return (o == null) ? null : toFloat(o);
    }

    public static boolean toBoolean(Object o) {
        return (Boolean) o;
    }

    public static Map<?, ?> toMap(Object o) {
        return (Map<?, ?>) o;
    }

    public static float toFractionalPixels(Object o, float density) {
        return toFloat(o) * density;
    }

    public static int toPixels(Object o, float density) {
        return (int) toFractionalPixels(o, density);
    }

    public static Map<String, Object> toObjectMap(Object o) {
        Map<String, Object> hashMap = new HashMap<>();
        Map<?, ?> map = (Map<?, ?>) o;
        for (Object key : map.keySet()) {
            Object object = map.get(key);
            if (object != null) {
                hashMap.put((String) key, object);
            }
        }
        return hashMap;
    }

    private static List<LatLng> toPoints(Object o) {
        final List<?> data = toList(o);
        final List<LatLng> points = new ArrayList<>(data.size());

        for (Object rawPoint : data) {
            final List<?> point = toList(rawPoint);
            points.add(new LatLng(toFloat(point.get(0)), toFloat(point.get(1))));
        }
        return points;
    }

    private static List<List<LatLng>> toHoles(Object o) {
        final List<?> data = toList(o);
        final List<List<LatLng>> holes = new ArrayList<>(data.size());

        for (Object rawHole : data) {
            holes.add(toPoints(rawHole));
        }
        return holes;
    }

    private static Point toPoint(Object o, float density) {
        final List<?> data = toList(o);
        return new Point(toPixels(data.get(0), density), toPixels(data.get(1), density));
    }

    static LatLng toLatLng(Object o) {
        final List<?> data = toList(o);
        return new LatLng(toDouble(data.get(0)), toDouble(data.get(1)));
    }

    static LatLngBounds toLatLngBounds(Object o) {
        if (o == null) {
            return null;
        }
        final List<?> data = toList(o);
        LatLng[] boundsArray = new LatLng[]{toLatLng(data.get(0)), toLatLng(data.get(1))};
        List<LatLng> bounds = Arrays.asList(boundsArray);
        LatLngBounds.Builder builder = new LatLngBounds.Builder();
        builder.includes(bounds);
        return builder.build();
    }

    static List<LatLng> toLatLngList(Object o, boolean flippedOrder) {
        if (o == null) {
            return null;
        }
        final List<?> data = toList(o);
        List<LatLng> latLngList = new ArrayList<>();
        for (int i = 0; i < data.size(); i++) {
            final List<?> coords = toList(data.get(i));
            if (flippedOrder) {
                latLngList.add(new LatLng(toDouble(coords.get(1)), toDouble(coords.get(0))));
            } else {
                latLngList.add(new LatLng(toDouble(coords.get(0)), toDouble(coords.get(1))));
            }
        }
        return latLngList;
    }

    private static List<List<LatLng>> toLatLngListList(Object o) {
        if (o == null) {
            return null;
        }
        final List<?> data = toList(o);
        List<List<LatLng>> latLngListList = new ArrayList<>();
        for (int i = 0; i < data.size(); i++) {
            List<LatLng> latLngList = toLatLngList(data.get(i), false);
            latLngListList.add(latLngList);
        }
        return latLngListList;
    }

    static Object toJson(CameraPosition position) {
        if (position == null) {
            return null;
        }
        final Map<String, Object> data = new HashMap<>();
        data.put("bearing", position.bearing);
        data.put("target", toJson(position.target));
        data.put("tilt", position.tilt);
        data.put("zoom", position.zoom);
        return data;
    }

    private static Object toJson(LatLng latLng) {
        return Arrays.asList(latLng.getLatitude(), latLng.getLongitude());
    }

    static Object markerIdToJson(String markerId) {
        if (markerId == null) {
            return null;
        }
        final Map<String, Object> data = new HashMap<>(1);
        data.put("markerId", markerId);
        return data;
    }

    static CameraPosition toCameraPosition(Object o) {
        final Map<?, ?> data = toMap(o);
        final CameraPosition.Builder builder = new CameraPosition.Builder();
        builder.bearing(toFloat(data.get("bearing")));
        builder.target(toLatLng(data.get("target")));
        builder.tilt(toFloat(data.get("tilt")));
        builder.zoom(toFloat(data.get("zoom")));
        return builder.build();
    }

    static CameraUpdate toCameraUpdate(Object o, MapboxMap mapboxMap, float density) {
        final List<?> data = toList(o);
        switch (toString(data.get(0))) {
            case "newCameraPosition":
                return CameraUpdateFactory.newCameraPosition(toCameraPosition(data.get(1)));
            case "newLatLng":
                return CameraUpdateFactory.newLatLng(toLatLng(data.get(1)));
            case "newLatLngBounds":
                return CameraUpdateFactory.newLatLngBounds(
                        toLatLngBounds(data.get(1)),
                        toPixels(data.get(2), density),
                        toPixels(data.get(3), density),
                        toPixels(data.get(4), density),
                        toPixels(data.get(5), density));
            case "newLatLngZoom":
                return CameraUpdateFactory.newLatLngZoom(toLatLng(data.get(1)), toFloat(data.get(2)));
            case "scrollBy":
                mapboxMap.scrollBy(
                        toFractionalPixels(data.get(1), density), toFractionalPixels(data.get(2), density));
                return null;
            case "zoomBy":
                if (data.size() == 2) {
                    return CameraUpdateFactory.zoomBy(toFloat(data.get(1)));
                } else {
                    return CameraUpdateFactory.zoomBy(toFloat(data.get(1)), toPoint(data.get(2), density));
                }
            case "zoomIn":
                return CameraUpdateFactory.zoomIn();
            case "zoomOut":
//                return CameraUpdateFactory.zoomOut(); // not working
                // workaround zoomOut
                return CameraUpdateFactory.zoomBy(-1);
            case "zoomTo":
                return CameraUpdateFactory.zoomTo(toFloat(data.get(1)));
            case "bearingTo":
                return CameraUpdateFactory.bearingTo(toFloat(data.get(1)));
            case "tiltTo":
                return CameraUpdateFactory.tiltTo(toFloat(data.get(1)));
            default:
                throw new IllegalArgumentException("Cannot interpret " + o + " as CameraUpdate");
        }
    }

    static void interpretVNPTMapOptions(Object o, VNPTMapViewOptionsSink sink, Context context) {
        final DisplayMetrics metrics = context.getResources().getDisplayMetrics();
        final Map<?, ?> data = toMap(o);
        final Object cameraTargetBounds = data.get("cameraTargetBounds");
        if (cameraTargetBounds != null) {
            final List<?> targetData = toList(cameraTargetBounds);
            sink.setCameraTargetBounds(toLatLngBounds(targetData.get(0)));
        }
        final Object compassEnabled = data.get("compassEnabled");
        if (compassEnabled != null) {
            sink.setCompassEnabled(toBoolean(compassEnabled));
        }
        final Object styleString = data.get("styleString");
        if (styleString != null) {
            sink.setStyleString(toString(styleString));
        }
        final Object minMaxZoomPreference = data.get("minMaxZoomPreference");
        if (minMaxZoomPreference != null) {
            final List<?> zoomPreferenceData = toList(minMaxZoomPreference);
            sink.setMinMaxZoomPreference( //
                    toFloatWrapper(zoomPreferenceData.get(0)), //
                    toFloatWrapper(zoomPreferenceData.get(1)));
        }
        final Object rotateGesturesEnabled = data.get("rotateGesturesEnabled");
        if (rotateGesturesEnabled != null) {
            sink.setRotateGesturesEnabled(toBoolean(rotateGesturesEnabled));
        }
        final Object scrollGesturesEnabled = data.get("scrollGesturesEnabled");
        if (scrollGesturesEnabled != null) {
            sink.setScrollGesturesEnabled(toBoolean(scrollGesturesEnabled));
        }
        final Object tiltGesturesEnabled = data.get("tiltGesturesEnabled");
        if (tiltGesturesEnabled != null) {
            sink.setTiltGesturesEnabled(toBoolean(tiltGesturesEnabled));
        }
        final Object trackCameraPosition = data.get("trackCameraPosition");
        if (trackCameraPosition != null) {
            sink.setTrackCameraPosition(toBoolean(trackCameraPosition));
        }
        final Object zoomGesturesEnabled = data.get("zoomGesturesEnabled");
        if (zoomGesturesEnabled != null) {
            sink.setZoomGesturesEnabled(toBoolean(zoomGesturesEnabled));
        }
        final Object myLocationEnabled = data.get("myLocationEnabled");
        if (myLocationEnabled != null) {
            sink.setMyLocationEnabled(toBoolean(myLocationEnabled));
        }
        final Object myLocationTrackingMode = data.get("myLocationTrackingMode");
        if (myLocationTrackingMode != null) {
            sink.setMyLocationTrackingMode(toInt(myLocationTrackingMode));
        }
        final Object myLocationRenderMode = data.get("myLocationRenderMode");
        if (myLocationRenderMode != null) {
            sink.setMyLocationRenderMode(toInt(myLocationRenderMode));
        }
        final Object logoViewMargins = data.get("logoViewMargins");
        if (logoViewMargins != null) {
            final List logoViewMarginsData = toList(logoViewMargins);
            final Point point = toPoint(logoViewMarginsData, metrics.density);
            sink.setLogoViewMargins(point.x, point.y);
        }
        final Object compassGravity = data.get("compassViewPosition");
        if (compassGravity != null) {
            sink.setCompassGravity(toInt(compassGravity));
        }
        final Object compassViewMargins = data.get("compassViewMargins");
        if (compassViewMargins != null) {
            final List compassViewMarginsData = toList(compassViewMargins);
            final Point point = toPoint(compassViewMarginsData, metrics.density);
            sink.setCompassViewMargins(point.x, point.y);
        }
        final Object attributionButtonGravity = data.get("attributionButtonPosition");
        if (attributionButtonGravity != null) {
            sink.setAttributionButtonGravity(toInt(attributionButtonGravity));
        }
        final Object attributionButtonMargins = data.get("attributionButtonMargins");
        if (attributionButtonMargins != null) {
            final List attributionButtonMarginsData = toList(attributionButtonMargins);
            final Point point = toPoint(attributionButtonMarginsData, metrics.density);
            sink.setAttributionButtonMargins(point.x, point.y);
        }
    }

    static String interpretMarkerOptions(Object o, VNPTMapMarkerOptionsSink sink, Context context) {
        final Map<?, ?> data = toMap(o);
        final Object consumeTapEvents = data.get("consumeTapEvents");

        final Object position = data.get("position");
        if (position != null) {
            sink.setPosition(toLatLng(position));
        }
        final Object icon = data.get("icon");
        if (icon != null) {
            sink.setIcon(toIcon(icon, context));
        }
        final Object infoWindow = data.get("infoWindow");
        if (infoWindow != null) {
            interpretInfoWindowOptions(sink, toObjectMap(infoWindow));
        }

        final String markerId = (String) data.get("markerId");
        if (markerId == null) {
            throw new IllegalArgumentException("markerId was null");
        } else {
            return markerId;
        }
    }

    private static void interpretInfoWindowOptions(
            VNPTMapMarkerOptionsSink sink, Map<String, Object> infoWindow) {
        String title = (String) infoWindow.get("title");
        String snippet = (String) infoWindow.get("snippet");
        if (title != null) {
            sink.setTitle(title);
        }
        if (snippet != null) {
            sink.setSnippet(snippet);
        }

    }

    static Object polylineIdToJson(String polylineId) {
        if (polylineId == null) {
            return null;
        }
        final Map<String, Object> data = new HashMap<>(1);
        data.put("polylineId", polylineId);
        return data;
    }

    static String interpretPolylineOptions(Object o, VNPTMapPolylineOptionsSink sink) {
        final Map<?, ?> data = toMap(o);
        final Object consumeTapEvents = data.get("consumeTapEvents");
        if (consumeTapEvents != null) {
            sink.setConsumeTapEvents(toBoolean(consumeTapEvents));
        }
        final Object color = data.get("color");
        if (color != null) {
            sink.setColor(toInt(color));
        }
        final Object alpha = data.get("alpha");
        if (alpha != null) {
            sink.setAlpha(toFloat(alpha));
        }
        final Object width = data.get("width");
        if (width != null) {
            sink.setWidth(toInt(width));
        }
        final Object points = data.get("points");
        if (points != null) {
            sink.setPoints(toPoints(points));
        }
        final String polylineId = (String) data.get("polylineId");
        if (polylineId == null) {
            throw new IllegalArgumentException("polylineId was null");
        } else {
            return polylineId;
        }
    }

    static Object polygonIdToJson(String polygonId) {
        if (polygonId == null) {
            return null;
        }
        final Map<String, Object> data = new HashMap<>(1);
        data.put("polygonId", polygonId);
        return data;
    }

    static String interpretPolygonOptions(Object o, VNPTMapPolygonOptionsSink sink) {
        final Map<?, ?> data = toMap(o);
        final Object consumeTapEvents = data.get("consumeTapEvents");
        if (consumeTapEvents != null) {
            sink.setConsumeTapEvents(toBoolean(consumeTapEvents));
        }
        final Object fillColor = data.get("fillColor");
        if (fillColor != null) {
            sink.setFillColor(toInt(fillColor));
        }
        final Object alpha = data.get("fillAlpha");
        if (alpha != null) {
            sink.setAlpha(toFloat(alpha));
        }
        final Object strokeColor = data.get("strokeColor");
        if (strokeColor != null) {
            sink.setStrokeColor(toInt(strokeColor));
        }
        final Object points = data.get("points");
        if (points != null) {
            sink.setPoints(toPoints(points));
        }
        final Object holes = data.get("holes");
        if (holes != null) {
            sink.setHoles(toHoles(holes));
        }
        final String polygonId = (String) data.get("polygonId");
        if (polygonId == null) {
            throw new IllegalArgumentException("polygonId was null");
        } else {
            return polygonId;
        }
    }

    // Zoom out
    public void zoomOut(MapboxMap mapboxMap) {
        CameraPosition currentCameraPosition = mapboxMap.getCameraPosition();
        CameraPosition cameraPosition = new CameraPosition.Builder()
                .target(currentCameraPosition.target)
                .zoom(currentCameraPosition.zoom - 1)
                .build();
        mapboxMap.animateCamera(CameraUpdateFactory.newCameraPosition(cameraPosition), 1000);
    }

}
