package com.vnptmap.sdk.v2.flutter_vnptmap_gl;

import com.google.gson.Gson;

import com.mapbox.geojson.FeatureCollection;
import com.mapbox.mapboxsdk.geometry.LatLng;
import com.mapbox.mapboxsdk.geometry.LatLngQuad;
import com.mapbox.mapboxsdk.maps.Style;
import com.mapbox.mapboxsdk.style.sources.GeoJsonOptions;
import com.mapbox.mapboxsdk.style.sources.GeoJsonSource;
import com.mapbox.mapboxsdk.style.sources.ImageSource;
import com.mapbox.mapboxsdk.style.sources.RasterDemSource;
import com.mapbox.mapboxsdk.style.sources.RasterSource;
import com.mapbox.mapboxsdk.style.sources.Source;
import com.mapbox.mapboxsdk.style.sources.TileSet;
import com.mapbox.mapboxsdk.style.sources.VectorSource;

import android.net.Uri;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class SourcePropertyConverter {
    private static final String TAG = SourcePropertyConverter.class.getSimpleName();

    static TileSet buildTileset(Map<String, Object> data) {
        final Object tiles = data.get("tiles");

        // options are only valid with tiles
        if (tiles == null) {
            return null;
        }

        final TileSet tileSet =
                new TileSet("2.1.0", (String[]) VNPTMapConvert.toList(tiles).toArray(new String[0]));

        final Object bounds = data.get("bounds");
        if (bounds != null) {
            List<Float> boundsFloat = new ArrayList<Float>();
            for (Object item : VNPTMapConvert.toList(bounds)) {
                boundsFloat.add(VNPTMapConvert.toFloat(item));
            }
            tileSet.setBounds(boundsFloat.toArray(new Float[0]));
        }

        final Object scheme = data.get("scheme");
        if (scheme != null) {
            tileSet.setScheme(VNPTMapConvert.toString(scheme));
        }

        final Object minzoom = data.get("minzoom");
        if (minzoom != null) {
            tileSet.setMinZoom(VNPTMapConvert.toFloat(minzoom));
        }

        final Object maxzoom = data.get("maxzoom");
        if (maxzoom != null) {
            tileSet.setMaxZoom(VNPTMapConvert.toFloat(maxzoom));
        }

        final Object attribution = data.get("attribution");
        if (attribution != null) {
            tileSet.setAttribution(VNPTMapConvert.toString(attribution));
        }
        return tileSet;
    }

    static GeoJsonOptions buildGeojsonOptions(Map<String, Object> data) {
        GeoJsonOptions options = new GeoJsonOptions();

        final Object buffer = data.get("buffer");
        if (buffer != null) {
            options = options.withBuffer(VNPTMapConvert.toInt(buffer));
        }

        final Object cluster = data.get("cluster");
        if (cluster != null) {
            options = options.withCluster(VNPTMapConvert.toBoolean(cluster));
        }

        final Object clusterMaxZoom = data.get("clusterMaxZoom");
        if (clusterMaxZoom != null) {
            options = options.withClusterMaxZoom(VNPTMapConvert.toInt(clusterMaxZoom));
        }

        final Object clusterRadius = data.get("clusterRadius");
        if (clusterRadius != null) {
            options = options.withClusterRadius(VNPTMapConvert.toInt(clusterRadius));
        }

        final Object lineMetrics = data.get("lineMetrics");
        if (lineMetrics != null) {
            options = options.withLineMetrics(VNPTMapConvert.toBoolean(lineMetrics));
        }

        final Object maxZoom = data.get("maxZoom");
        if (maxZoom != null) {
            options = options.withMaxZoom(VNPTMapConvert.toInt(maxZoom));
        }

        final Object minZoom = data.get("minZoom");
        if (minZoom != null) {
            options = options.withMinZoom(VNPTMapConvert.toInt(minZoom));
        }

        final Object tolerance = data.get("tolerance");
        if (tolerance != null) {
            options = options.withTolerance(VNPTMapConvert.toFloat(tolerance));
        }
        return options;
    }

    static GeoJsonSource buildGeojsonSource(String id, Map<String, Object> properties) {
        final Object data = properties.get("data");
        final GeoJsonOptions options = buildGeojsonOptions(properties);
        if (data != null) {
            if (data instanceof String) {
                try {
                    final URI uri = new URI(VNPTMapConvert.toString(data));
                    return new GeoJsonSource(id, uri, options);
                } catch (URISyntaxException e) {
                }
            } else {
                Gson gson = new Gson();
                String geojson = gson.toJson(data);
                final FeatureCollection featureCollection = FeatureCollection.fromJson(geojson);
                return new GeoJsonSource(id, featureCollection, options);
            }
        }
        return null;
    }

    static ImageSource buildImageSource(String id, Map<String, Object> properties) {
        final Object url = properties.get("url");
        List<LatLng> coordinates = VNPTMapConvert.toLatLngList(properties.get("coordinates"), true);
        final LatLngQuad quad =
                new LatLngQuad(
                        coordinates.get(0), coordinates.get(1), coordinates.get(2), coordinates.get(3));
        try {
            final URI uri = new URI(VNPTMapConvert.toString(url));
            return new ImageSource(id, quad, uri);
        } catch (URISyntaxException e) {
        }
        return null;
    }

    static VectorSource buildVectorSource(String id, Map<String, Object> properties) {
        final Object url = properties.get("url");
        if (url != null) {
            final Uri uri = Uri.parse(VNPTMapConvert.toString(url));

            if (uri != null) {
                return new VectorSource(id, uri);
            }
            return null;
        }

        final TileSet tileSet = buildTileset(properties);
        return tileSet != null ? new VectorSource(id, tileSet) : null;
    }

    static RasterSource buildRasterSource(String id, Map<String, Object> properties) {
        final Object url = properties.get("url");
        if (url != null) {
            try {
                final URI uri = new URI(VNPTMapConvert.toString(url));
                return new RasterSource(id, uri);
            } catch (URISyntaxException e) {
            }
        }

        final TileSet tileSet = buildTileset(properties);
        return tileSet != null ? new RasterSource(id, tileSet) : null;
    }

    static RasterDemSource buildRasterDemSource(String id, Map<String, Object> properties) {
        final Object url = properties.get("url");
        if (url != null) {
            try {
                final URI uri = new URI(VNPTMapConvert.toString(url));
                return new RasterDemSource(id, uri);
            } catch (URISyntaxException e) {
            }
        }

        final TileSet tileSet = buildTileset(properties);
        return tileSet != null ? new RasterDemSource(id, tileSet) : null;
    }

    static void addSource(String id, Map<String, Object> properties, Style style) {
        final Object type = properties.get("type");
        Source source = null;

        if (type != null) {
            switch (VNPTMapConvert.toString(type)) {
                case "vector":
                    source = buildVectorSource(id, properties);
                    break;
                case "raster":
                    source = buildRasterSource(id, properties);
                    break;
                case "raster-dem":
                    source = buildRasterDemSource(id, properties);
                    break;
                case "image":
                    source = buildImageSource(id, properties);
                    break;
                case "geojson":
                    source = buildGeojsonSource(id, properties);
                    break;
                default:
                    // unsupported source type
            }
        }

        if (source != null) {
            style.addSource(source);
        }
    }
}
