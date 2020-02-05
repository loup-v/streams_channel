//
//  PluginExample.h
//  Runner
//
//  Created by Lukasz on 2020-02-05.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface PluginExample : NSObject

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar;

@end

NS_ASSUME_NONNULL_END
