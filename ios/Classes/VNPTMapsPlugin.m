#import "VNPTMapsPlugin.h"
#if __has_include(<flutter_vnptmap_gl/flutter_vnptmap_gl-Swift.h>)
#import <flutter_vnptmap_gl/flutter_vnptmap_gl-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_vnptmap_gl-Swift.h"
#endif

@implementation VNPTMapsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [VNPTMapGlFlutterPlugin registerWithRegistrar:registrar];
}
@end
