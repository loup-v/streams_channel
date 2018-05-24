//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

#import "DemoPluginRegistrant.h"
#import "DemoPlugin.h"

@implementation DemoPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [DemoPlugin registerWithRegistrar:[registry registrarForPlugin:@"DemoPlugin"]];
}

@end
