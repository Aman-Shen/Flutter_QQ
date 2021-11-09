//
//  FlutterQQPlugin.m
//  Runner
//
//  Created by Benster on 2020/11/2.
//

#import "FlutterQQPlugin.h"

#if __has_include(<flutter_qq/flutter_qq-Swift.h>)
#import <flutter_qq/flutter_qq-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_qq-Swift.h"
#endif

@implementation FlutterQQPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterQQPlugin registerWithRegistrar:registrar];
}

#pragma - mark 9.0以后使用新API接口
+ (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *, id> *)options {
    return [[SwiftFlutterQQPlugin sharedInstance] application:app openURL:url options:options];
}

@end
