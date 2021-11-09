//
//  FlutterQQPlugin.h
//  Runner
//
//  Created by Benster on 2020/11/2.
//

#import <Flutter/Flutter.h>

@interface FlutterQQPlugin : NSObject<FlutterPlugin>

+ (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *, id> *)options;

@end
