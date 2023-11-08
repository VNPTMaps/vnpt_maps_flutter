package com.vnptmap.sdk.v2.flutter_vnptmap_gl;

import com.google.gson.JsonElement;
import com.google.gson.JsonParser;

import com.mapbox.mapboxsdk.style.expressions.Expression;
import com.mapbox.mapboxsdk.style.layers.PropertyFactory;
import com.mapbox.mapboxsdk.style.layers.PropertyValue;

import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import static com.vnptmap.sdk.v2.flutter_vnptmap_gl.VNPTMapConvert.toMap;


public class LayerPropertyConverter {
    static PropertyValue[] interpretSymbolLayerProperties(Object o) {
        final Map<String, String> data = (Map<String, String>) toMap(o);
        final List<PropertyValue> properties = new LinkedList();
        final JsonParser parser = new JsonParser();

        for (Map.Entry<String, String> entry : data.entrySet()) {
            final JsonElement jsonElement = parser.parse(entry.getValue());
            Expression expression = Expression.Converter.convert(jsonElement);
            switch (entry.getKey()) {
                case "icon-opacity":
                    properties.add(PropertyFactory.iconOpacity(expression));
                    break;
                case "icon-color":
                    properties.add(PropertyFactory.iconColor(expression));
                    break;
                case "icon-halo-color":
                    properties.add(PropertyFactory.iconHaloColor(expression));
                    break;
                case "icon-halo-width":
                    properties.add(PropertyFactory.iconHaloWidth(expression));
                    break;
                case "icon-halo-blur":
                    properties.add(PropertyFactory.iconHaloBlur(expression));
                    break;
                case "icon-translate":
                    properties.add(PropertyFactory.iconTranslate(expression));
                    break;
                case "icon-translate-anchor":
                    properties.add(PropertyFactory.iconTranslateAnchor(expression));
                    break;
                case "text-opacity":
                    properties.add(PropertyFactory.textOpacity(expression));
                    break;
                case "text-color":
                    properties.add(PropertyFactory.textColor(expression));
                    break;
                case "text-halo-color":
                    properties.add(PropertyFactory.textHaloColor(expression));
                    break;
                case "text-halo-width":
                    properties.add(PropertyFactory.textHaloWidth(expression));
                    break;
                case "text-halo-blur":
                    properties.add(PropertyFactory.textHaloBlur(expression));
                    break;
                case "text-translate":
                    properties.add(PropertyFactory.textTranslate(expression));
                    break;
                case "text-translate-anchor":
                    properties.add(PropertyFactory.textTranslateAnchor(expression));
                    break;
                case "symbol-placement":
                    properties.add(PropertyFactory.symbolPlacement(expression));
                    break;
                case "symbol-spacing":
                    properties.add(PropertyFactory.symbolSpacing(expression));
                    break;
                case "symbol-avoid-edges":
                    properties.add(PropertyFactory.symbolAvoidEdges(expression));
                    break;
                case "symbol-sort-key":
                    properties.add(PropertyFactory.symbolSortKey(expression));
                    break;
                case "symbol-z-order":
                    properties.add(PropertyFactory.symbolZOrder(expression));
                    break;
                case "icon-allow-overlap":
                    properties.add(PropertyFactory.iconAllowOverlap(expression));
                    break;
                case "icon-ignore-placement":
                    properties.add(PropertyFactory.iconIgnorePlacement(expression));
                    break;
                case "icon-optional":
                    properties.add(PropertyFactory.iconOptional(expression));
                    break;
                case "icon-rotation-alignment":
                    properties.add(PropertyFactory.iconRotationAlignment(expression));
                    break;
                case "icon-size":
                    properties.add(PropertyFactory.iconSize(expression));
                    break;
                case "icon-text-fit":
                    properties.add(PropertyFactory.iconTextFit(expression));
                    break;
                case "icon-text-fit-padding":
                    properties.add(PropertyFactory.iconTextFitPadding(expression));
                    break;
                case "icon-image":
                    if (jsonElement.isJsonPrimitive() && jsonElement.getAsJsonPrimitive().isString()) {
                        properties.add(PropertyFactory.iconImage(jsonElement.getAsString()));
                    } else {
                        properties.add(PropertyFactory.iconImage(expression));
                    }
                    break;
                case "icon-rotate":
                    properties.add(PropertyFactory.iconRotate(expression));
                    break;
                case "icon-padding":
                    properties.add(PropertyFactory.iconPadding(expression));
                    break;
                case "icon-keep-upright":
                    properties.add(PropertyFactory.iconKeepUpright(expression));
                    break;
                case "icon-offset":
                    properties.add(PropertyFactory.iconOffset(expression));
                    break;
                case "icon-anchor":
                    properties.add(PropertyFactory.iconAnchor(expression));
                    break;
                case "icon-pitch-alignment":
                    properties.add(PropertyFactory.iconPitchAlignment(expression));
                    break;
                case "text-pitch-alignment":
                    properties.add(PropertyFactory.textPitchAlignment(expression));
                    break;
                case "text-rotation-alignment":
                    properties.add(PropertyFactory.textRotationAlignment(expression));
                    break;
                case "text-field":
                    properties.add(PropertyFactory.textField(expression));
                    break;
                case "text-font":
                    properties.add(PropertyFactory.textFont(expression));
                    break;
                case "text-size":
                    properties.add(PropertyFactory.textSize(expression));
                    break;
                case "text-max-width":
                    properties.add(PropertyFactory.textMaxWidth(expression));
                    break;
                case "text-line-height":
                    properties.add(PropertyFactory.textLineHeight(expression));
                    break;
                case "text-letter-spacing":
                    properties.add(PropertyFactory.textLetterSpacing(expression));
                    break;
                case "text-justify":
                    properties.add(PropertyFactory.textJustify(expression));
                    break;
                case "text-radial-offset":
                    properties.add(PropertyFactory.textRadialOffset(expression));
                    break;
                case "text-variable-anchor":
                    properties.add(PropertyFactory.textVariableAnchor(expression));
                    break;
                case "text-anchor":
                    properties.add(PropertyFactory.textAnchor(expression));
                    break;
                case "text-max-angle":
                    properties.add(PropertyFactory.textMaxAngle(expression));
                    break;
                case "text-writing-mode":
                    properties.add(PropertyFactory.textWritingMode(expression));
                    break;
                case "text-rotate":
                    properties.add(PropertyFactory.textRotate(expression));
                    break;
                case "text-padding":
                    properties.add(PropertyFactory.textPadding(expression));
                    break;
                case "text-keep-upright":
                    properties.add(PropertyFactory.textKeepUpright(expression));
                    break;
                case "text-transform":
                    properties.add(PropertyFactory.textTransform(expression));
                    break;
                case "text-offset":
                    properties.add(PropertyFactory.textOffset(expression));
                    break;
                case "text-allow-overlap":
                    properties.add(PropertyFactory.textAllowOverlap(expression));
                    break;
                case "text-ignore-placement":
                    properties.add(PropertyFactory.textIgnorePlacement(expression));
                    break;
                case "text-optional":
                    properties.add(PropertyFactory.textOptional(expression));
                    break;
                case "visibility":
                    properties.add(PropertyFactory.visibility(entry.getValue()));
                    break;
                default:
                    break;
            }
        }

        return properties.toArray(new PropertyValue[properties.size()]);
    }

    static PropertyValue[] interpretCircleLayerProperties(Object o) {
        final Map<String, String> data = (Map<String, String>) toMap(o);
        final List<PropertyValue> properties = new LinkedList();
        final JsonParser parser = new JsonParser();

        for (Map.Entry<String, String> entry : data.entrySet()) {
            final JsonElement jsonElement = parser.parse(entry.getValue());
            Expression expression = Expression.Converter.convert(jsonElement);
            switch (entry.getKey()) {
                case "circle-radius":
                    properties.add(PropertyFactory.circleRadius(expression));
                    break;
                case "circle-color":
                    properties.add(PropertyFactory.circleColor(expression));
                    break;
                case "circle-blur":
                    properties.add(PropertyFactory.circleBlur(expression));
                    break;
                case "circle-opacity":
                    properties.add(PropertyFactory.circleOpacity(expression));
                    break;
                case "circle-translate":
                    properties.add(PropertyFactory.circleTranslate(expression));
                    break;
                case "circle-translate-anchor":
                    properties.add(PropertyFactory.circleTranslateAnchor(expression));
                    break;
                case "circle-pitch-scale":
                    properties.add(PropertyFactory.circlePitchScale(expression));
                    break;
                case "circle-pitch-alignment":
                    properties.add(PropertyFactory.circlePitchAlignment(expression));
                    break;
                case "circle-stroke-width":
                    properties.add(PropertyFactory.circleStrokeWidth(expression));
                    break;
                case "circle-stroke-color":
                    properties.add(PropertyFactory.circleStrokeColor(expression));
                    break;
                case "circle-stroke-opacity":
                    properties.add(PropertyFactory.circleStrokeOpacity(expression));
                    break;
                case "circle-sort-key":
                    properties.add(PropertyFactory.circleSortKey(expression));
                    break;
                case "visibility":
                    properties.add(PropertyFactory.visibility(entry.getValue()));
                    break;
                default:
                    break;
            }
        }

        return properties.toArray(new PropertyValue[properties.size()]);
    }

    static PropertyValue[] interpretLineLayerProperties(Object o) {
        final Map<String, String> data = (Map<String, String>) toMap(o);
        final List<PropertyValue> properties = new LinkedList();
        final JsonParser parser = new JsonParser();

        for (Map.Entry<String, String> entry : data.entrySet()) {
            final JsonElement jsonElement = parser.parse(entry.getValue());
            Expression expression = Expression.Converter.convert(jsonElement);
            switch (entry.getKey()) {
                case "line-opacity":
                    properties.add(PropertyFactory.lineOpacity(expression));
                    break;
                case "line-color":
                    properties.add(PropertyFactory.lineColor(expression));
                    break;
                case "line-translate":
                    properties.add(PropertyFactory.lineTranslate(expression));
                    break;
                case "line-translate-anchor":
                    properties.add(PropertyFactory.lineTranslateAnchor(expression));
                    break;
                case "line-width":
                    properties.add(PropertyFactory.lineWidth(expression));
                    break;
                case "line-gap-width":
                    properties.add(PropertyFactory.lineGapWidth(expression));
                    break;
                case "line-offset":
                    properties.add(PropertyFactory.lineOffset(expression));
                    break;
                case "line-blur":
                    properties.add(PropertyFactory.lineBlur(expression));
                    break;
                case "line-dasharray":
                    properties.add(PropertyFactory.lineDasharray(expression));
                    break;
                case "line-pattern":
                    properties.add(PropertyFactory.linePattern(expression));
                    break;
                case "line-gradient":
                    properties.add(PropertyFactory.lineGradient(expression));
                    break;
                case "line-cap":
                    properties.add(PropertyFactory.lineCap(expression));
                    break;
                case "line-join":
                    properties.add(PropertyFactory.lineJoin(expression));
                    break;
                case "line-miter-limit":
                    properties.add(PropertyFactory.lineMiterLimit(expression));
                    break;
                case "line-round-limit":
                    properties.add(PropertyFactory.lineRoundLimit(expression));
                    break;
                case "line-sort-key":
                    properties.add(PropertyFactory.lineSortKey(expression));
                    break;
                case "visibility":
                    properties.add(PropertyFactory.visibility(entry.getValue()));
                    break;
                default:
                    break;
            }
        }

        return properties.toArray(new PropertyValue[properties.size()]);
    }

    static PropertyValue[] interpretFillLayerProperties(Object o) {
        final Map<String, String> data = (Map<String, String>) toMap(o);
        final List<PropertyValue> properties = new LinkedList();
        final JsonParser parser = new JsonParser();

        for (Map.Entry<String, String> entry : data.entrySet()) {
            final JsonElement jsonElement = parser.parse(entry.getValue());
            Expression expression = Expression.Converter.convert(jsonElement);
            switch (entry.getKey()) {
                case "fill-antialias":
                    properties.add(PropertyFactory.fillAntialias(expression));
                    break;
                case "fill-opacity":
                    properties.add(PropertyFactory.fillOpacity(expression));
                    break;
                case "fill-color":
                    properties.add(PropertyFactory.fillColor(expression));
                    break;
                case "fill-outline-color":
                    properties.add(PropertyFactory.fillOutlineColor(expression));
                    break;
                case "fill-translate":
                    properties.add(PropertyFactory.fillTranslate(expression));
                    break;
                case "fill-translate-anchor":
                    properties.add(PropertyFactory.fillTranslateAnchor(expression));
                    break;
                case "fill-pattern":
                    properties.add(PropertyFactory.fillPattern(expression));
                    break;
                case "fill-sort-key":
                    properties.add(PropertyFactory.fillSortKey(expression));
                    break;
                case "visibility":
                    properties.add(PropertyFactory.visibility(entry.getValue()));
                    break;
                default:
                    break;
            }
        }

        return properties.toArray(new PropertyValue[properties.size()]);
    }

    static PropertyValue[] interpretFillExtrusionLayerProperties(Object o) {
        final Map<String, String> data = (Map<String, String>) toMap(o);
        final List<PropertyValue> properties = new LinkedList();
        final JsonParser parser = new JsonParser();

        for (Map.Entry<String, String> entry : data.entrySet()) {
            final JsonElement jsonElement = parser.parse(entry.getValue());
            Expression expression = Expression.Converter.convert(jsonElement);
            switch (entry.getKey()) {
                case "fill-extrusion-opacity":
                    properties.add(PropertyFactory.fillExtrusionOpacity(expression));
                    break;
                case "fill-extrusion-color":
                    properties.add(PropertyFactory.fillExtrusionColor(expression));
                    break;
                case "fill-extrusion-translate":
                    properties.add(PropertyFactory.fillExtrusionTranslate(expression));
                    break;
                case "fill-extrusion-translate-anchor":
                    properties.add(PropertyFactory.fillExtrusionTranslateAnchor(expression));
                    break;
                case "fill-extrusion-pattern":
                    properties.add(PropertyFactory.fillExtrusionPattern(expression));
                    break;
                case "fill-extrusion-height":
                    properties.add(PropertyFactory.fillExtrusionHeight(expression));
                    break;
                case "fill-extrusion-base":
                    properties.add(PropertyFactory.fillExtrusionBase(expression));
                    break;
                case "fill-extrusion-vertical-gradient":
                    properties.add(PropertyFactory.fillExtrusionVerticalGradient(expression));
                    break;
                case "visibility":
                    properties.add(PropertyFactory.visibility(entry.getValue()));
                    break;
                default:
                    break;
            }
        }

        return properties.toArray(new PropertyValue[properties.size()]);
    }

    static PropertyValue[] interpretRasterLayerProperties(Object o) {
        final Map<String, String> data = (Map<String, String>) toMap(o);
        final List<PropertyValue> properties = new LinkedList();
        final JsonParser parser = new JsonParser();

        for (Map.Entry<String, String> entry : data.entrySet()) {
            final JsonElement jsonElement = parser.parse(entry.getValue());
            Expression expression = Expression.Converter.convert(jsonElement);
            switch (entry.getKey()) {
                case "raster-opacity":
                    properties.add(PropertyFactory.rasterOpacity(expression));
                    break;
                case "raster-hue-rotate":
                    properties.add(PropertyFactory.rasterHueRotate(expression));
                    break;
                case "raster-brightness-min":
                    properties.add(PropertyFactory.rasterBrightnessMin(expression));
                    break;
                case "raster-brightness-max":
                    properties.add(PropertyFactory.rasterBrightnessMax(expression));
                    break;
                case "raster-saturation":
                    properties.add(PropertyFactory.rasterSaturation(expression));
                    break;
                case "raster-contrast":
                    properties.add(PropertyFactory.rasterContrast(expression));
                    break;
                case "raster-resampling":
                    properties.add(PropertyFactory.rasterResampling(expression));
                    break;
                case "raster-fade-duration":
                    properties.add(PropertyFactory.rasterFadeDuration(expression));
                    break;
                case "visibility":
                    properties.add(PropertyFactory.visibility(entry.getValue()));
                    break;
                default:
                    break;
            }
        }

        return properties.toArray(new PropertyValue[properties.size()]);
    }

    static PropertyValue[] interpretHillshadeLayerProperties(Object o) {
        final Map<String, String> data = (Map<String, String>) toMap(o);
        final List<PropertyValue> properties = new LinkedList();
        final JsonParser parser = new JsonParser();

        for (Map.Entry<String, String> entry : data.entrySet()) {
            final JsonElement jsonElement = parser.parse(entry.getValue());
            Expression expression = Expression.Converter.convert(jsonElement);
            switch (entry.getKey()) {
                case "hillshade-illumination-direction":
                    properties.add(PropertyFactory.hillshadeIlluminationDirection(expression));
                    break;
                case "hillshade-illumination-anchor":
                    properties.add(PropertyFactory.hillshadeIlluminationAnchor(expression));
                    break;
                case "hillshade-exaggeration":
                    properties.add(PropertyFactory.hillshadeExaggeration(expression));
                    break;
                case "hillshade-shadow-color":
                    properties.add(PropertyFactory.hillshadeShadowColor(expression));
                    break;
                case "hillshade-highlight-color":
                    properties.add(PropertyFactory.hillshadeHighlightColor(expression));
                    break;
                case "hillshade-accent-color":
                    properties.add(PropertyFactory.hillshadeAccentColor(expression));
                    break;
                case "visibility":
                    properties.add(PropertyFactory.visibility(entry.getValue()));
                    break;
                default:
                    break;
            }
        }

        return properties.toArray(new PropertyValue[properties.size()]);
    }

    static PropertyValue[] interpretHeatmapLayerProperties(Object o) {
        final Map<String, String> data = (Map<String, String>) toMap(o);
        final List<PropertyValue> properties = new LinkedList();
        final JsonParser parser = new JsonParser();

        for (Map.Entry<String, String> entry : data.entrySet()) {
            final JsonElement jsonElement = parser.parse(entry.getValue());
            Expression expression = Expression.Converter.convert(jsonElement);
            switch (entry.getKey()) {
                case "heatmap-radius":
                    properties.add(PropertyFactory.heatmapRadius(expression));
                    break;
                case "heatmap-weight":
                    properties.add(PropertyFactory.heatmapWeight(expression));
                    break;
                case "heatmap-intensity":
                    properties.add(PropertyFactory.heatmapIntensity(expression));
                    break;
                case "heatmap-color":
                    properties.add(PropertyFactory.heatmapColor(expression));
                    break;
                case "heatmap-opacity":
                    properties.add(PropertyFactory.heatmapOpacity(expression));
                    break;
                case "visibility":
                    properties.add(PropertyFactory.visibility(entry.getValue()));
                    break;
                default:
                    break;
            }
        }

        return properties.toArray(new PropertyValue[properties.size()]);
    }
}
