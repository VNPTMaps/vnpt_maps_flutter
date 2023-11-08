//
//  LayerPropertiesConverter.swift
//  flutter_vnptmap_gl
//
//  Created by Võ Toàn on 13/12/2022.
//

import Mapbox

class LayerPropertyConverter {
    class func addSymbolProperties(symbolLayer: MGLSymbolStyleLayer, properties: [String: String]) {
        for (propertyName, propertyValue) in properties {
            let expression = interpretExpression(
                propertyName: propertyName,
                expression: propertyValue
            )
            switch propertyName {
            case "icon-opacity":
                symbolLayer.iconOpacity = expression
            case "icon-color":
                symbolLayer.iconColor = expression
            case "icon-halo-color":
                symbolLayer.iconHaloColor = expression
            case "icon-halo-width":
                symbolLayer.iconHaloWidth = expression
            case "icon-halo-blur":
                symbolLayer.iconHaloBlur = expression
            case "icon-translate":
                symbolLayer.iconTranslation = expression
            case "icon-translate-anchor":
                symbolLayer.iconTranslationAnchor = expression
            case "text-opacity":
                symbolLayer.textOpacity = expression
            case "text-color":
                symbolLayer.textColor = expression
            case "text-halo-color":
                symbolLayer.textHaloColor = expression
            case "text-halo-width":
                symbolLayer.textHaloWidth = expression
            case "text-halo-blur":
                symbolLayer.textHaloBlur = expression
            case "text-translate":
                symbolLayer.textTranslation = expression
            case "text-translate-anchor":
                symbolLayer.textTranslationAnchor = expression
            case "symbol-placement":
                symbolLayer.symbolPlacement = expression
            case "symbol-spacing":
                symbolLayer.symbolSpacing = expression
            case "symbol-avoid-edges":
                symbolLayer.symbolAvoidsEdges = expression
            case "symbol-sort-key":
                symbolLayer.symbolSortKey = expression
            case "symbol-z-order":
                symbolLayer.symbolZOrder = expression
            case "icon-allow-overlap":
                symbolLayer.iconAllowsOverlap = expression
            case "icon-ignore-placement":
                symbolLayer.iconIgnoresPlacement = expression
            case "icon-optional":
                symbolLayer.iconOptional = expression
            case "icon-rotation-alignment":
                symbolLayer.iconRotationAlignment = expression
            case "icon-size":
                symbolLayer.iconScale = expression
            case "icon-text-fit":
                symbolLayer.iconTextFit = expression
            case "icon-text-fit-padding":
                symbolLayer.iconTextFitPadding = expression
            case "icon-image":
                symbolLayer.iconImageName = expression
            case "icon-rotate":
                symbolLayer.iconRotation = expression
            case "icon-padding":
                symbolLayer.iconPadding = expression
            case "icon-keep-upright":
                symbolLayer.keepsIconUpright = expression
            case "icon-offset":
                symbolLayer.iconOffset = expression
            case "icon-anchor":
                symbolLayer.iconAnchor = expression
            case "icon-pitch-alignment":
                symbolLayer.iconPitchAlignment = expression
            case "text-pitch-alignment":
                symbolLayer.textPitchAlignment = expression
            case "text-rotation-alignment":
                symbolLayer.textRotationAlignment = expression
            case "text-field":
                symbolLayer.text = expression
            case "text-font":
                symbolLayer.textFontNames = expression
            case "text-size":
                symbolLayer.textFontSize = expression
            case "text-max-width":
                symbolLayer.maximumTextWidth = expression
            case "text-line-height":
                symbolLayer.textLineHeight = expression
            case "text-letter-spacing":
                symbolLayer.textLetterSpacing = expression
            case "text-justify":
                symbolLayer.textJustification = expression
            case "text-radial-offset":
                symbolLayer.textRadialOffset = expression
            case "text-variable-anchor":
                symbolLayer.textVariableAnchor = expression
            case "text-anchor":
                symbolLayer.textAnchor = expression
            case "text-max-angle":
                symbolLayer.maximumTextAngle = expression
            case "text-writing-mode":
                symbolLayer.textWritingModes = expression
            case "text-rotate":
                symbolLayer.textRotation = expression
            case "text-padding":
                symbolLayer.textPadding = expression
            case "text-keep-upright":
                symbolLayer.keepsTextUpright = expression
            case "text-transform":
                symbolLayer.textTransform = expression
            case "text-offset":
                symbolLayer.textOffset = expression
            case "text-allow-overlap":
                symbolLayer.textAllowsOverlap = expression
            case "text-ignore-placement":
                symbolLayer.textIgnoresPlacement = expression
            case "text-optional":
                symbolLayer.textOptional = expression
            case "visibility":
                symbolLayer.isVisible = propertyValue == "visible"

            default:
                break
            }
        }
    }

    class func addCircleProperties(circleLayer: MGLCircleStyleLayer, properties: [String: String]) {
        for (propertyName, propertyValue) in properties {
            let expression = interpretExpression(
                propertyName: propertyName,
                expression: propertyValue
            )
            switch propertyName {
            case "circle-radius":
                circleLayer.circleRadius = expression
            case "circle-color":
                circleLayer.circleColor = expression
            case "circle-blur":
                circleLayer.circleBlur = expression
            case "circle-opacity":
                circleLayer.circleOpacity = expression
            case "circle-translate":
                circleLayer.circleTranslation = expression
            case "circle-translate-anchor":
                circleLayer.circleTranslationAnchor = expression
            case "circle-pitch-scale":
                circleLayer.circleScaleAlignment = expression
            case "circle-pitch-alignment":
                circleLayer.circlePitchAlignment = expression
            case "circle-stroke-width":
                circleLayer.circleStrokeWidth = expression
            case "circle-stroke-color":
                circleLayer.circleStrokeColor = expression
            case "circle-stroke-opacity":
                circleLayer.circleStrokeOpacity = expression
            case "circle-sort-key":
                circleLayer.circleSortKey = expression
            case "visibility":
                circleLayer.isVisible = propertyValue == "visible"

            default:
                break
            }
        }
    }

    class func addLineProperties(lineLayer: MGLLineStyleLayer, properties: [String: String]) {
        for (propertyName, propertyValue) in properties {
            let expression = interpretExpression(
                propertyName: propertyName,
                expression: propertyValue
            )
            switch propertyName {
            case "line-opacity":
                lineLayer.lineOpacity = expression
            case "line-color":
                lineLayer.lineColor = expression
            case "line-translate":
                lineLayer.lineTranslation = expression
            case "line-translate-anchor":
                lineLayer.lineTranslationAnchor = expression
            case "line-width":
                lineLayer.lineWidth = expression
            case "line-gap-width":
                lineLayer.lineGapWidth = expression
            case "line-offset":
                lineLayer.lineOffset = expression
            case "line-blur":
                lineLayer.lineBlur = expression
            case "line-dasharray":
                lineLayer.lineDashPattern = expression
            case "line-pattern":
                lineLayer.linePattern = expression
            case "line-gradient":
                lineLayer.lineGradient = expression
            case "line-cap":
                lineLayer.lineCap = expression
            case "line-join":
                lineLayer.lineJoin = expression
            case "line-miter-limit":
                lineLayer.lineMiterLimit = expression
            case "line-round-limit":
                lineLayer.lineRoundLimit = expression
            case "line-sort-key":
                lineLayer.lineSortKey = expression
            case "visibility":
                lineLayer.isVisible = propertyValue == "visible"

            default:
                break
            }
        }
    }

    class func addFillProperties(fillLayer: MGLFillStyleLayer, properties: [String: String]) {
        for (propertyName, propertyValue) in properties {
            let expression = interpretExpression(
                propertyName: propertyName,
                expression: propertyValue
            )
            switch propertyName {
            case "fill-antialias":
                fillLayer.fillAntialiased = expression
            case "fill-opacity":
                fillLayer.fillOpacity = expression
            case "fill-color":
                fillLayer.fillColor = expression
            case "fill-outline-color":
                fillLayer.fillOutlineColor = expression
            case "fill-translate":
                fillLayer.fillTranslation = expression
            case "fill-translate-anchor":
                fillLayer.fillTranslationAnchor = expression
            case "fill-pattern":
                fillLayer.fillPattern = expression
            case "fill-sort-key":
                fillLayer.fillSortKey = expression
            case "visibility":
                fillLayer.isVisible = propertyValue == "visible"

            default:
                break
            }
        }
    }

    class func addFillExtrusionProperties(
        fillExtrusionLayer: MGLFillExtrusionStyleLayer,
        properties: [String: String]
    ) {
        for (propertyName, propertyValue) in properties {
            let expression = interpretExpression(
                propertyName: propertyName,
                expression: propertyValue
            )
            switch propertyName {
            case "fill-extrusion-opacity":
                fillExtrusionLayer.fillExtrusionOpacity = expression
            case "fill-extrusion-color":
                fillExtrusionLayer.fillExtrusionColor = expression
            case "fill-extrusion-translate":
                fillExtrusionLayer.fillExtrusionTranslation = expression
            case "fill-extrusion-translate-anchor":
                fillExtrusionLayer.fillExtrusionTranslationAnchor = expression
            case "fill-extrusion-pattern":
                fillExtrusionLayer.fillExtrusionPattern = expression
            case "fill-extrusion-height":
                fillExtrusionLayer.fillExtrusionHeight = expression
            case "fill-extrusion-base":
                fillExtrusionLayer.fillExtrusionBase = expression
            case "fill-extrusion-vertical-gradient":
                fillExtrusionLayer.fillExtrusionHasVerticalGradient = expression
            case "visibility":
                fillExtrusionLayer.isVisible = propertyValue == "visible"

            default:
                break
            }
        }
    }

    class func addRasterProperties(rasterLayer: MGLRasterStyleLayer, properties: [String: String]) {
        for (propertyName, propertyValue) in properties {
            let expression = interpretExpression(
                propertyName: propertyName,
                expression: propertyValue
            )
            switch propertyName {
            case "raster-opacity":
                rasterLayer.rasterOpacity = expression
            case "raster-hue-rotate":
                rasterLayer.rasterHueRotation = expression
            case "raster-brightness-min":
                rasterLayer.minimumRasterBrightness = expression
            case "raster-brightness-max":
                rasterLayer.maximumRasterBrightness = expression
            case "raster-saturation":
                rasterLayer.rasterSaturation = expression
            case "raster-contrast":
                rasterLayer.rasterContrast = expression
            case "raster-resampling":
                rasterLayer.rasterResamplingMode = expression
            case "raster-fade-duration":
                rasterLayer.rasterFadeDuration = expression
            case "visibility":
                rasterLayer.isVisible = propertyValue == "visible"

            default:
                break
            }
        }
    }

    class func addHillshadeProperties(
        hillshadeLayer: MGLHillshadeStyleLayer,
        properties: [String: String]
    ) {
        for (propertyName, propertyValue) in properties {
            let expression = interpretExpression(
                propertyName: propertyName,
                expression: propertyValue
            )
            switch propertyName {
            case "hillshade-illumination-direction":
                hillshadeLayer.hillshadeIlluminationDirection = expression
            case "hillshade-illumination-anchor":
                hillshadeLayer.hillshadeIlluminationAnchor = expression
            case "hillshade-exaggeration":
                hillshadeLayer.hillshadeExaggeration = expression
            case "hillshade-shadow-color":
                hillshadeLayer.hillshadeShadowColor = expression
            case "hillshade-highlight-color":
                hillshadeLayer.hillshadeHighlightColor = expression
            case "hillshade-accent-color":
                hillshadeLayer.hillshadeAccentColor = expression
            case "visibility":
                hillshadeLayer.isVisible = propertyValue == "visible"

            default:
                break
            }
        }
    }

    class func addHeatmapProperties(
        heatmapLayer: MGLHeatmapStyleLayer,
        properties: [String: String]
    ) {
        for (propertyName, propertyValue) in properties {
            let expression = interpretExpression(
                propertyName: propertyName,
                expression: propertyValue
            )
            switch propertyName {
            case "heatmap-radius":
                heatmapLayer.heatmapRadius = expression
            case "heatmap-weight":
                heatmapLayer.heatmapWeight = expression
            case "heatmap-intensity":
                heatmapLayer.heatmapIntensity = expression
            case "heatmap-color":
                heatmapLayer.heatmapColor = expression
            case "heatmap-opacity":
                heatmapLayer.heatmapOpacity = expression
            case "visibility":
                heatmapLayer.isVisible = propertyValue == "visible"

            default:
                break
            }
        }
    }

    private class func interpretExpression(propertyName: String,
                                           expression: String) -> NSExpression?
    {
        let isColor = propertyName.contains("color")

        do {
            let json = try JSONSerialization.jsonObject(
                with: expression.data(using: .utf8)!,
                options: .fragmentsAllowed
            )
            // this is required because NSExpression.init(mglJSONObject: json) fails to create
            // a proper Expression if the data of is a hexString
            if isColor {
                if let color = json as? String {
                    return NSExpression(forConstantValue: UIColor(hexString: color))
                }
            }
            // this is required because NSExpression.init(mglJSONObject: json) fails to create
            // a proper Expression if the data of a literal is an array
            if let offset = json as? [Any] {
                if offset.count == 2, offset.first is String, offset.first as? String == "literal" {
                    if let vector = offset.last as? [Any] {
                        if vector.count == 2 {
                            if let x = vector.first as? Double, let y = vector.last as? Double {
                                return NSExpression(
                                    forConstantValue: NSValue(cgVector: CGVector(dx: x,
                                                                                 dy: y))
                                )
                            }
                        }
                    }
                }
            }
            return NSExpression(mglJSONObject: json)
        } catch {}
        return nil
    }
}
