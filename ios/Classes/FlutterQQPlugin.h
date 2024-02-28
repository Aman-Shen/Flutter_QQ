//
//  FlutterQQPlugin.h
//  Runner
//
//  Created by Benster on 2020/11/2.
//

#import <Flutter/Flutter.h>

@interface FlutterQQPlugin : NSObject<FlutterPlugin>

+ (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

@end
